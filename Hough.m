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
function accum = Hough(bound)
    threshold = 20;
    total = 0;
    linesMax = 6;
    peak_num = 4;
    range = 25;
    [row, col] = size(bound);
    %pho  = x*cos(theta) + y*sin(theta);
    %rhomax=(sqrt(row^2+col^2));
    numangle = 180;    % ����ռ䣬�Ƕȷ���Ĵ�С  
    numrho = round((sqrt(row^2+col^2)) * 2 + 1);  % r�Ŀռ䷶Χ  
    %H[rhomax][180];
    accum = zeros(numangle+2, numrho+2);%�ۼ���
    %sort_buf = zeros(numangle, numrho);
    ang = 0;
    for n = 1 : numangle    %�����������ߵ�׼�����������  
        tabSin(n) = sin(n/180*pi);
        tabCos(n) = cos(n/180*pi);
    end
    
    % stage 1. fill accumulator  
    for i = 1 : row
        for j = 1 : col
            %��ÿ������㣬ת��Ϊ����ռ����ɢ�������ߣ���ͳ�ơ�  
            if( bound(i, j) ~= 0 )
                for n = 1 : numangle
                    %��=x*cos��+y*sin��
                    r = round( j * tabCos(n) + i * tabSin(n) );  
                    r = round(r + (numrho - 1) / 2);%�������ѱ������
                    accum(n, r) = accum(n, r)+1;%ÿ����ͳ��һ��
                end
            end
        end
    end
    
    %surf(accum),brighten(1)  ;
    %{
    %stage 2. find local maximums  
    % ����ռ䣬�ֲ����㣬�����������жϣ��Ƚϡ�(Ҳ����ʹ8������߸���ķ�ʽ��,
    %������жϾֲ����ֵ��ͬʱѡ�ôδ�ֵ�����ֵ���Ϳ��ܻ����������ڵ�ֱ�ߣ���ʵ������һ��ֱ�ߡ�
    %ѡ�����ֵ��Ҳ��ȥ����ɢ�Ľ��Ƽ������������ϲ��������ߡ�  
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
    %�Ծ������0����
    accum_buff = zeros(numangle+range*2+2, numrho+range*2+2);
    for i = range+1 : numangle+range+2
        for j = range+1 : numrho+range+2
            accum_buff(i, j) = accum(i-range, j-range);
        end
    end
    %����һ��17*17�Ĵ�
    accum_window = zeros(range*2+1, range*2+1);
    figure, surf(accum_buff), brighten(1);
    for it = 1 : 20
        %find��ʾ�ҵ����еķ�0�㣬���ҷ��صĵ�ĺ����꣬�����꣬����
        %sorted_valude��ʾÿ���߳��ֵĴ������������У���sorted_index��ʾ��ǰ������Ӧ���±�
        [i_index, j_index, values] = find(accum_buff);
        [sorted_valude, sorted_index] = sort(values, 'descend');
        for point = 1 : peak_num
            %���ڷ�ֵ������ģ�-range��+range�����мӴ����ҵ���ֵ������ȫ�����
            %����Ҫ�ڴ������ٴ�Ѱ�����ֵ�����ܱ�֤������Ҫ�ҵĵ�
            %ÿ��ѡȡǰ��λ��ֵ���ڵĵ������ղ���
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
            % ���accum_buff���ڵ�����
            for i = accum_window_mid_i-range :  accum_window_mid_i+range
                for j = accum_window_mid_j-range : accum_window_mid_j+range
                    accum_buff(i, j) = 0;
                end
            end
            accum_buff(accum_window_mid_i-range-1+window_i_index(sorted_window_index), accum_window_mid_j-range-1+window_j_index(sorted_window_index)) = sorted_window_valude;
        end
        %�ҳ�ǰ4���ĵ�
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
    % �ɵ�ĸ������������ҳ���Щ���п�����ֱ��  
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