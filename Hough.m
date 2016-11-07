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
function [H, theta, rho, peak, XY] = Hough(bound)
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
    title('H');
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
    figure, imshow(bound);
    title('ͼ�α߽�');
    hold on;
    for i = 1 : peak_num
        begin_x = 1; begin_y = peak(i, 2)/SinTheta(peak(i, 1));
        end_x = col; end_y = begin_y-col/tan(peak(i, 1)/180*pi);
        line([begin_x, end_x], [begin_y, end_y], 'Color', 'b');
        grid on;
    end
    %% ����ĸ�����
    %����һ��4����
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
    %���P1 = L1��L3
    [XY(1, 1), XY(1, 2)] = findpoint(peak(1, 1), peak(1, 2), peak(3, 1), peak(3, 2));
    [XY(2, 1), XY(2, 2)] = findpoint(peak(1, 1), peak(1, 2), peak(4, 1), peak(4, 2));
    [XY(3, 1), XY(3, 2)] = findpoint(peak(2, 1), peak(2, 2), peak(4, 1), peak(4, 2));
    [XY(4, 1), XY(4, 2)] = findpoint(peak(2, 1), peak(2, 2), peak(3, 1), peak(3, 2));
end