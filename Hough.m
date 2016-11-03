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
function accum = Hough(bound)
    threshold = 20;
    total = 0;
    linesMax = 6;
    peak_num = 4;
    range = 25;
    [row, col] = size(bound);
    %pho  = x*cos(theta) + y*sin(theta);
    %rhomax=(sqrt(row^2+col^2));
    numangle = 180;    % 霍夫空间，角度方向的大小  
    numrho = round((sqrt(row^2+col^2)) * 2 + 1);  % r的空间范围  
    %H[rhomax][180];
    accum = zeros(numangle+2, numrho+2);%累加器
    %sort_buf = zeros(numangle, numrho);
    ang = 0;
    for n = 1 : numangle    %计算正弦曲线的准备工作，查表  
        tabSin(n) = sin(n/180*pi);
        tabCos(n) = cos(n/180*pi);
    end
    
    % stage 1. fill accumulator  
    for i = 1 : row
        for j = 1 : col
            %将每个非零点，转换为霍夫空间的离散正弦曲线，并统计。  
            if( bound(i, j) ~= 0 )
                for n = 1 : numangle
                    %ρ=x*cosθ+y*sinθ
                    r = round( j * tabCos(n) + i * tabSin(n) );  
                    r = round(r + (numrho - 1) / 2);%将负数ρ变成正数
                    accum(n, r) = accum(n, r)+1;%每条线统计一次
                end
            end
        end
    end
    
    %surf(accum),brighten(1)  ;
    %{
    %stage 2. find local maximums  
    % 霍夫空间，局部最大点，采用四邻域判断，比较。(也可以使8邻域或者更大的方式）,
    %如果不判断局部最大值，同时选用次大值与最大值，就可能会是两个相邻的直线，但实际上是一条直线。
    %选用最大值，也是去除离散的近似计算带来的误差，或合并近似曲线。  
    for r = 1 : numrho  
        for n = 1 : numangle
            %int base = (n+1) * (numrho+2) + r+1;  
            if accum(n, r) > threshold &&  ...
                accum(n, r) > accum(n, r-1) && accum(n, r) >= accum(n, r+1) &&  ...
                accum(n, r) > accum(n-1, r) && accum(n, r) >= accum(n+1, r) 
                sort_buf(n, r) = base;
                total = total+1;
            end
        end
    end
    %}
    %对矩阵进行0扩充
    accum_buff = zeros(numangle+range*2+2, numrho+range*2+2);
    for i = range+1 : numangle+range+2
        for j = range+1 : numrho+range+2
            accum_buff(i, j) = accum(i-range, j-range);
        end
    end
    %构造一个17*17的窗
    accum_window = zeros(range*2+1, range*2+1);
    figure, surf(accum_buff), brighten(1);
    for it = 1 : 20
        %find表示找到所有的非0点，并且返回的点的横坐标，纵坐标，个数
        %sorted_valude表示每条线出现的次数（降序排列），sorted_index表示当前次数对应的下标
        [i_index, j_index, values] = find(accum_buff);
        [sorted_valude, sorted_index] = sort(values, 'descend');
        for point = 1 : peak_num
            %对于峰值的坐标的（-range，+range）进行加窗，找到峰值，其他全部清空
            %必须要在窗里面再次寻找最大值，才能保证我们需要找的点
            %每次选取前四位峰值所在的点进行清空操作
            accum_window_mid_i = i_index(sorted_index(point));
            accum_window_mid_j = j_index(sorted_index(point));
            for i = 1 : range*2+1
                for j = 1 : range*2+1
                    accum_window(i, j) = accum_buff(accum_window_mid_i-range-1+i, accum_window_mid_j-range-1+j);
                end
            end
            %accum_window
            [window_i_index, window_j_index, window_values] = find(accum_window);
            [sorted_window_valude, sorted_window_index] = max(window_values);
            % 清空accum_buff窗内的内容
            for i = accum_window_mid_i-range :  accum_window_mid_i+range
                for j = accum_window_mid_j-range : accum_window_mid_j+range
                    accum_buff(i, j) = 0;
                end
            end
            accum_buff(accum_window_mid_i-range-1+window_i_index(sorted_window_index), accum_window_mid_j-range-1+window_j_index(sorted_window_index)) = sorted_window_valude;
        end
        %找出前4名的点
        if it == 20
            !point1!
            i_index(sorted_index(1)), j_index(sorted_index(1))
            !point2!
            i_index(sorted_index(2)), j_index(sorted_index(2))
            !point3!
            i_index(sorted_index(3)), j_index(sorted_index(3))
            !point4!
            i_index(sorted_index(4)), j_index(sorted_index(4))
        end
    end
    
    figure, surf(accum_buff), brighten(1);
    %{
    % stage 3. sort the detected lines by accumulator value
    % 由点的个数排序，依次找出哪些最有可能是直线  
    icvHoughSortDescent32s( sort_buf, total, accum );
    %}
    
    % stage 4. store the first min(total,linesMax) lines to the output buffer
    %bound_temp = 255 - bound;
    %figure, imshow(bound_temp);
    %hold on;
    
    for i = 1 : 4
        x(i) = j_index(sorted_index(i))*cos(i_index(sorted_index(i))/180*pi);
        y(i) = j_index(sorted_index(i))*sin(i_index(sorted_index(i))/180*pi);
        
    end
     %plot(x, y, 'o');
end