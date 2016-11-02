%hough�任������ͼ��ı߿�
% hough�Ķ��壺
% ��ֱ������ϵ����һ��ֱ��l��ԭ�㵽��ֱ�ߵĴ�ֱ����Ϊ�ѣ�������x��ļн�Ϊ�ȣ�����һ��ֱ��ʽΨһ�ģ�����ֱ�߷���Ϊ��
% ��=x*cos��+y*sin��
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
function Hough(bound)
    threshold = 20;
    total = 0;
    linesMax = 4;
    [row, col] = size(bound);
    pho  = x*cos(theta) + y*sin(theta);
    %rhomax=(sqrt(row^2+col^2));
    numangle = 90;    % ����ռ䣬�Ƕȷ���Ĵ�С  
    numrho = round(((width + height) * 2 + 1) / rho);  % r�Ŀռ䷶Χ  
    %H[rhomax][180];
    accum = zeros(numangle+2, (numrho+2));
    sort_buf = zeros(numangle, (numrho));
    ang = 0;
    for n = 1 : numangle    %�����������ߵ�׼�����������  
        tabSin(n) = sin(ang/180*pi);
        tabCos(n) = cos(ang/180*pi);
        ang = ang+1;
    end
    
    % stage 1. fill accumulator  
    for i = 1 : height
        for j = 1 : width
            %��ÿ������㣬ת��Ϊ����ռ����ɢ�������ߣ���ͳ�ơ�  
            if( bound(i, j) ~= 0 )
                for n = 1 : numangle
                    %��=x*cos��+y*sin��
                    r = round( j * tabCos(n) + i * tabSin(n) );  
                    r = r + (numrho - 1) / 2;  
                    accum(n, r) = accum(n, r)+1;  
                end
            end
        end
    end
    
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
                sort_buf(total) = base;
                total = total+1;
            end
        end
    end
    
    % stage 3. sort the detected lines by accumulator value
    % �ɵ�ĸ������������ҳ���Щ���п�����ֱ��  
    icvHoughSortDescent32s( sort_buf, total, accum );
    
    % stage 4. store the first min(total,linesMax) lines to the output buffer  
    linesMax = min(linesMax, total);  
    scale = 1./(numrho+2);  
    for i = 1 : linesMax  % ���ݻ���ռ�ֱ��ʣ�����ֱ�ߵ�ʵ��r��theta����  
        CvLinePolar line;  
        idx = sort_buf(i);  
        n = floor(idx*scale) - 1;  
        r = idx - (n+1)*(numrho+2) - 1;  
        line.rho = (r - (numrho - 1)*0.5) * rho;  
        line.angle = n * theta;  
        cvSeqPush( lines, &line );  
    end
end