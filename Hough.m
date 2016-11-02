%hough变换，传入图像的边框
% hough的定义：
% 在直角坐标系中有一条直线l，原点到该直线的垂直距离为ρ，垂线与x轴的夹角为θ，这这一条直线式唯一的，且其直线方程为：
% ρ=x*cosθ+y*sinθ
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
function Hough(bound)
    threshold = 20;
    total = 0;
    linesMax = 4;
    [row, col] = size(bound);
    pho  = x*cos(theta) + y*sin(theta);
    %rhomax=(sqrt(row^2+col^2));
    numangle = 90;    % 霍夫空间，角度方向的大小  
    numrho = round(((width + height) * 2 + 1) / rho);  % r的空间范围  
    %H[rhomax][180];
    accum = zeros(numangle+2, (numrho+2));
    sort_buf = zeros(numangle, (numrho));
    ang = 0;
    for n = 1 : numangle    %计算正弦曲线的准备工作，查表  
        tabSin(n) = sin(ang/180*pi);
        tabCos(n) = cos(ang/180*pi);
        ang = ang+1;
    end
    
    % stage 1. fill accumulator  
    for i = 1 : height
        for j = 1 : width
            %将每个非零点，转换为霍夫空间的离散正弦曲线，并统计。  
            if( bound(i, j) ~= 0 )
                for n = 1 : numangle
                    %ρ=x*cosθ+y*sinθ
                    r = round( j * tabCos(n) + i * tabSin(n) );  
                    r = r + (numrho - 1) / 2;  
                    accum(n, r) = accum(n, r)+1;  
                end
            end
        end
    end
    
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
                sort_buf(total) = base;
                total = total+1;
            end
        end
    end
    
    % stage 3. sort the detected lines by accumulator value
    % 由点的个数排序，依次找出哪些最有可能是直线  
    icvHoughSortDescent32s( sort_buf, total, accum );
    
    % stage 4. store the first min(total,linesMax) lines to the output buffer  
    linesMax = min(linesMax, total);  
    scale = 1./(numrho+2);  
    for i = 1 : linesMax  % 依据霍夫空间分辨率，计算直线的实际r，theta参数  
        CvLinePolar line;  
        idx = sort_buf(i);  
        n = floor(idx*scale) - 1;  
        r = idx - (n+1)*(numrho+2) - 1;  
        line.rho = (r - (numrho - 1)*0.5) * rho;  
        line.angle = n * theta;  
        cvSeqPush( lines, &line );  
    end
end