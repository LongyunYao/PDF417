%{
% hough变换，传入图像的边框
% hough的定义：
% 在直角坐标系中有一条直线l，原点到该直线的垂直距离为ρ，垂线与x轴的夹角为θ，这这一条直线式唯一的，且其直线方程为：
% ρ=x*cosθ+y*sinθ
% x=rho*cos（theta），y=rho*sin(theta)
% 而这条直线用极坐标表示为一点（ρ，θ）。
% 可见直角坐标系中的一条直线对应极坐标系中的一点，这种线到点的变换就是Hough变换。
% 在直角坐标系中国任一点（x0，y0）的直线系，满足ρ=x0*cosθ+y0*sinθ=(x0?+y0?)?sin(θ+Φ)(Φ=tan-1(y0/x0))
% 横坐标θ不断变换，对于所有的不为0的像素点，计算出ρ，找到ρ在坐标(θ,ρ)的位置累加1.
% 参考网站 http://www.cnblogs.com/smartvessel/archive/2011/10/20/2218654.html
% rho: 霍夫空间的r粒度大小 
% theta: 旋转角度的粒度 
% threshold:直线上有多少个点的阈值 
% lines：输出lines结果 
% linesMax：lines的最大个数
%}
function [H, theta, rho, peak, pointx,pointy] = Hough(bound)
    threshold = 20;
    total = 0;
    linesMax = 6;
    
    %% rough函数的实现
    %   hough函数的作用就在于在一个离散的“RT空间”上完成累积
    [row, col] = size(bound);
    %pho  = x*cos(theta) + y*sin(theta);
    %rhomax=(sqrt(row^2+col^2));
    numangle = 180;    % 霍夫空间，角度方向的大小
    maxrho = round(sqrt(row^2+col^2));
    numrho = round(maxrho * 2 + 1);  % r的空间范围
    %H[rhomax][180];
    H = zeros(numrho, numangle);%累加器
    %sort_buf = zeros(numangle, numrho);
    for i = 1 : numangle
        theta(i) = i;
    end
    for i = 1 : numrho+1
        rho(i) = i-1-maxrho;
    end
    for i = 1 : numangle    %计算正弦曲线的准备工作，查表  
        SinTheta(i) = sin(theta(i)/180*pi);
        CosTheta(i) = cos(theta(i)/180*pi);
    end
    
    % stage 1. fill Hulator  
    for i = 1 : row
        for j = 1 : col
            %将每个非零点，转换为霍夫空间的离散正弦曲线，并统计。  
            if( bound(i, j) ~= 0 )
                for n = 1 : numangle
                    %ρ=x*cosθ+y*sinθ
                    r = round( j * CosTheta(n) + i * SinTheta(n));  
                    r = round(r + (numrho - 1) / 2);%将负数ρ变成正数
                    H(r, theta(n)) = H(r, theta(n))+1;%每条线统计一次
                end
            end
        end
    end

    %% numangle的实现    
    %  houghpeaks主要是用来找出“H”上累积出来的几个最大的累积值，从而确定最可能是直线的直线

    %构造一个边长为windows_range*2+1的窗
    windows_range = 8;
    peak_num = 4;
    figure, surf(H), brighten(1);
    i_index = zeros(numrho);
    j_index = zeros(numangle);
    peak = zeros(peak_num, 2);
    for it = 1 : 20
        %find表示找到所有的非0点，并且返回的点的横坐标，纵坐标，个数
        %sorted_valude表示每条线出现的次数（降序排列），sorted_index表示当前次数对应的下标
        [i_index, j_index, values] = find(H);
        [sorted_valude, sorted_index] = sort(values, 'descend');
        for point = 1 : peak_num
            %对于峰值的坐标的（-windows_range，+windows_range）进行加窗，找到峰值，其他全部清空
            %必须要在窗里面再次寻找最大值，才能保证我们需要找的点
            %每次选取前四位峰值所在的点进行清空操作
            H_window_mid_i = i_index(sorted_index(point));
            H_window_mid_j = j_index(sorted_index(point));
            for i = 0-windows_range*10 : windows_range*10
                for j = 0-windows_range : windows_range
                    if i == 0 && j == 0
                        continue;
                    end
                    i_temp = H_window_mid_i+i;
                    j_temp = H_window_mid_j+j;
                    if (i_temp > numrho) i_temp = i_temp-numrho; end
                    if (i_temp < 1) i_temp = i_temp+numrho; end
                    if (j_temp > numangle) j_temp = j_temp-numangle; end
                    if (j_temp < 1) j_temp = j_temp+numangle; end
                    H(i_temp, j_temp) = 0;
                end
            end
            H(H_window_mid_i, H_window_mid_j) = sorted_valude(point);
        end
        %找出前4名的点
        if it == 20
            for i = 1 : peak_num
                peak(i, 1) = theta(j_index(sorted_index(i)));
                peak(i, 2) = rho(i_index(sorted_index(i)));
            end
        end
    end
    x1y1 = zeros(4, 2);
    x2y2 = zeros(4, 2);
    %% 将rho和theta变换到直角坐标系中
    imshow(bound);
    hold on;
    for i = 1 : peak_num
        end_x = peak(i,2)/CosTheta(peak(i, 1));
        begin_y = peak(i, 2)/SinTheta(peak(i, 1));
        if abs(begin_y) > 10^10
            x1y1(i, 1) = abs(end_x); x1y1(i, 2) = abs(begin_y);
            x2y2(i, 1) = abs(end_x); x2y2(i, 2) = abs(begin_y)*2;
            plot([abs(end_x), abs(end_x)], [0, row]);
            grid on;
        elseif abs(end_x) > 10^10
            x1y1(i, 1) = abs(end_x); x1y1(i, 2) = abs(begin_y);
            x2y2(i, 1) = abs(end_x)*2; x2y2(i, 2) = abs(begin_y);
            plot([0, col], [abs(begin_y), abs(begin_y)]);
            grid on;
        elseif end_x >= 0
            x1y1(i, 1) = abs(0); x1y1(i, 2) = abs(begin_y);
            x2y2(i, 1) = abs(end_x); x2y2(i, 2) = abs(0);
            plot([0, end_x*2], [begin_y, 0-begin_y]);
            grid on;
        else
            x1y1(i, 1) = -abs(end_x); x1y1(i, 2) = 0;
            x2y2(i, 1) = 0; x2y2(i, 2) = abs(begin_y);
            plot([end_x, 0-end_x], [0, begin_y*2]);
            grid on;
        end
    end
    
    %% 求解四个顶点
    % y=kb(i,1)x+kb(i,2)
    kb = zeros(4, 2);
    for i = 1:4
        x1 = x1y1(i, 1);x2 = x2y2(i, 1); y1 = x1y1(i, 2); y2 = x2y2(i, 2);
        if(abs(x1) > 10^10 || abs(x2) > 10^10 || abs(y1) > 10^10 || abs(y2) > 10^10) continue; end
        temp = polyfit([x1,x2],[y1,y2],1);
        kb(i, 1) = temp(1); kb(i, 2) = temp(2);
    end
    syms k1 k2 c1 c2 x y
    count = 1;
    pointx = zeros(1,4);
    pointy = zeros(1,4);
    for i = 1 : 4
        if(abs(x1y1(i,1)) > 10^10)
            func1 = sprintf('%s%f', 'y=', x1y1(i,2));
        elseif(abs(x1y1(i,2)) > 10^10)
            func1 = sprintf('%s%f', 'x=', x1y1(i,1));
        else
            func1 = sprintf('%s%f%s%f%s','y=(',kb(i, 1),')*x+(', kb(i, 2), ')');
        end
        for j = 1 : 4
            if (i == j) continue; end
            if(abs(x2y2(j,1)) > 10^10)
                func2 = sprintf('%s%f', 'y=', x2y2(j,2));
            elseif(abs(x2y2(j,2)) > 10^10)
                func2 = sprintf('%s%f', 'x=', x2y2(j,1));
            else
                func2 = sprintf('%s%f%s%f%s','y=(',kb(j, 1),')*x+(', kb(j, 2), ')');
            end
            [x_temp,y_temp] = solve(func1,func2,'x','y');
            if abs(round(x_temp)) <= col & abs(round(y_temp)) <= row
                pointx(count) = round(x_temp); pointy(count) = round(y_temp);
                count = count+1;
            end
        end
    end
    plot(pointx,pointy,'o')
end