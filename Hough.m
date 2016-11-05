%{
% hough�任������ͼ��ı߿�
% hough�Ķ��壺
% ��ֱ������ϵ����һ��ֱ��l��ԭ�㵽��ֱ�ߵĴ�ֱ����Ϊ�ѣ�������x��ļн�Ϊ�ȣ�����һ��ֱ��ʽΨһ�ģ�����ֱ�߷���Ϊ��
% ��=x*cos��+y*sin��
% x=rho*cos��theta����y=rho*sin(theta)
% ������ֱ���ü������ʾΪһ�㣨�ѣ��ȣ���
% �ɼ�ֱ������ϵ�е�һ��ֱ�߶�Ӧ������ϵ�е�һ�㣬�����ߵ���ı任����Hough�任��
% ��ֱ������ϵ�й���һ�㣨x0��y0����ֱ��ϵ�������=x0*cos��+y0*sin��=(x0?+y0?)?sin(��+��)(��=tan-1(y0/x0))
% ������Ȳ��ϱ任���������еĲ�Ϊ0�����ص㣬������ѣ��ҵ���������(��,��)��λ���ۼ�1.
% �ο���վ http://www.cnblogs.com/smartvessel/archive/2011/10/20/2218654.html
% rho: ����ռ��r���ȴ�С 
% theta: ��ת�Ƕȵ����� 
% threshold:ֱ�����ж��ٸ������ֵ 
% lines�����lines��� 
% linesMax��lines��������
%}
function [H, theta, rho, peak, pointx,pointy] = Hough(bound)
    threshold = 20;
    total = 0;
    linesMax = 6;
    
    %% rough������ʵ��
    %   hough���������þ�������һ����ɢ�ġ�RT�ռ䡱������ۻ�
    [row, col] = size(bound);
    %pho  = x*cos(theta) + y*sin(theta);
    %rhomax=(sqrt(row^2+col^2));
    numangle = 180;    % ����ռ䣬�Ƕȷ���Ĵ�С
    maxrho = round(sqrt(row^2+col^2));
    numrho = round(maxrho * 2 + 1);  % r�Ŀռ䷶Χ
    %H[rhomax][180];
    H = zeros(numrho, numangle);%�ۼ���
    %sort_buf = zeros(numangle, numrho);
    for i = 1 : numangle
        theta(i) = i;
    end
    for i = 1 : numrho+1
        rho(i) = i-1-maxrho;
    end
    for i = 1 : numangle    %�����������ߵ�׼�����������  
        SinTheta(i) = sin(theta(i)/180*pi);
        CosTheta(i) = cos(theta(i)/180*pi);
    end
    
    % stage 1. fill Hulator  
    for i = 1 : row
        for j = 1 : col
            %��ÿ������㣬ת��Ϊ����ռ����ɢ�������ߣ���ͳ�ơ�  
            if( bound(i, j) ~= 0 )
                for n = 1 : numangle
                    %��=x*cos��+y*sin��
                    r = round( j * CosTheta(n) + i * SinTheta(n));  
                    r = round(r + (numrho - 1) / 2);%�������ѱ������
                    H(r, theta(n)) = H(r, theta(n))+1;%ÿ����ͳ��һ��
                end
            end
        end
    end

    %% numangle��ʵ��    
    %  houghpeaks��Ҫ�������ҳ���H�����ۻ������ļ��������ۻ�ֵ���Ӷ�ȷ���������ֱ�ߵ�ֱ��

    %����һ���߳�Ϊwindows_range*2+1�Ĵ�
    windows_range = 8;
    peak_num = 4;
    figure, surf(H), brighten(1);
    i_index = zeros(numrho);
    j_index = zeros(numangle);
    peak = zeros(peak_num, 2);
    for it = 1 : 20
        %find��ʾ�ҵ����еķ�0�㣬���ҷ��صĵ�ĺ����꣬�����꣬����
        %sorted_valude��ʾÿ���߳��ֵĴ������������У���sorted_index��ʾ��ǰ������Ӧ���±�
        [i_index, j_index, values] = find(H);
        [sorted_valude, sorted_index] = sort(values, 'descend');
        for point = 1 : peak_num
            %���ڷ�ֵ������ģ�-windows_range��+windows_range�����мӴ����ҵ���ֵ������ȫ�����
            %����Ҫ�ڴ������ٴ�Ѱ�����ֵ�����ܱ�֤������Ҫ�ҵĵ�
            %ÿ��ѡȡǰ��λ��ֵ���ڵĵ������ղ���
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
        %�ҳ�ǰ4���ĵ�
        if it == 20
            for i = 1 : peak_num
                peak(i, 1) = theta(j_index(sorted_index(i)));
                peak(i, 2) = rho(i_index(sorted_index(i)));
            end
        end
    end
    x1y1 = zeros(4, 2);
    x2y2 = zeros(4, 2);
    %% ��rho��theta�任��ֱ������ϵ��
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
    
    %% ����ĸ�����
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