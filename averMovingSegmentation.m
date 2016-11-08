function Pic_new = averMovingSegmentation(Pic)
	[Row, Col] = size(Pic);
	L = 256; %256个灰度级

	%Count是一个数组，存放了每一个灰度值的数量，【下标-1】表示对应的灰度值
	%x是一个数组，用来存放【灰度值】
	[Count, x] = imhist(Pic);
    
    total = Row*Col;
	Count = Count / total;	%每一个灰度值的频率

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