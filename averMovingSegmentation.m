function Pic_new = averMovingSegmentation(Pic)
	[Row, Col] = size(Pic);
	L = 256; %256���Ҷȼ�

	%Count��һ�����飬�����ÿһ���Ҷ�ֵ�����������±�-1����ʾ��Ӧ�ĻҶ�ֵ
	%x��һ�����飬������š��Ҷ�ֵ��
	[Count, x] = imhist(Pic);
    
    total = Row*Col;
	Count = Count / total;	%ÿһ���Ҷ�ֵ��Ƶ��

    Pic_new = zeros(Row, Col);
    z = zeros(1, total+2);
    m = zeros(1, total+2);
    n = 120;
    k = 1;
    b = 0.6;

    z(1) = Pic(1, 1);
    m(1) = z(1)/n;
	for i = 1 : Row
        for j = 1 : Col
            k = k+1;
            z(k) = Pic(i, j);
            if(k<=n)
                m(k) = sum(z([1:k]))/k;
            else
                m(k) = m(k-1) + (z(k)-z(k-n+1))/n;
            end
  
            if(Pic(i, j)>b*m(k))  
                Pic_new(i, j) = 255;  
            else  
                Pic_new(i, j) = 0;
            end
        end
    end
end