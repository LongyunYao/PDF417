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
function [H, theta, rho, peak, XY] = Hough(bound)
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
    title('H');
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
    figure, imshow(bound);
    title('图形边界');
    hold on;
    for i = 1 : peak_num
        begin_x = 1; begin_y = peak(i, 2)/SinTheta(peak(i, 1));
        end_x = col; end_y = begin_y-col/tan(peak(i, 1)/180*pi);
        line([begin_x, end_x], [begin_y, end_y], 'Color', 'b');
        grid on;
    end
    %% 求解四个顶点
    %整理一下4条边
    % B=A(1,:)
    % A(1,:)=A(2,:)
    % A(2,:)=B
    if abs(peak(1, 2)) > abs(peak(2, 2))
        temp = peak(1, :); peak(1, :) = peak(2, :); peak(2, :) = temp;
    end
    if abs(peak(3, 2)) > abs(peak(4, 2))
        temp = peak(3, :); peak(3, :) = peak(4, :); peak(4, :) = temp;
    end
    % y=kb(i,1)x+kb(i,2)
    % Y=k*X+b
    % k=-cot(theta)  b=rho/sin(theta)
    % x=(b2-b1)/(k1-k2)   y=K1*x+b1;
    k = zeros(1, 4);
    b = zeros(1, 4);
    XY = zeros(4, 2);
    for i = 1 : 4
        if(peak(i, 1) == 90 || (peak(i, 1) == 180))
            continue;
        end
        k(i) = -cot(peak(i, 1)/180*pi);
        b(i) = peak(i, 2)/SinTheta(peak(i, 1));
    end
    %求解P1 = L1∩L3
    [XY(1, 1), XY(1, 2)] = findpoint(peak(1, 1), peak(1, 2), peak(3, 1), peak(3, 2));
    [XY(2, 1), XY(2, 2)] = findpoint(peak(1, 1), peak(1, 2), peak(4, 1), peak(4, 2));
    [XY(3, 1), XY(3, 2)] = findpoint(peak(2, 1), peak(2, 2), peak(4, 1), peak(4, 2));
    [XY(4, 1), XY(4, 2)] = findpoint(peak(2, 1), peak(2, 2), peak(3, 1), peak(3, 2));
end