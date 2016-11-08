function Pic_new = averMovingSegmentation2(Pic)
	[Row, Col] = size(Pic);
	L = 256; %256个灰度级

	%Count是一个数组，存放了每一个灰度值的数量，【下标-1】表示对应的灰度值
	%x是一个数组，用来存放【灰度值】
	[Count, x] = imhist(Pic);
    
    total = Row*Col;
	Count = Count / total;	%每一个灰度值的频率

    n = 65;
    Pic_new = zeros(Row, Col);
    Pic_temp = zeros(Row+n*2+2, Col+n*2+2);
    Pic_temp([n+1,n+Row], [n+1, n+Col]) = Pic([1, Row], [1, Col]);
    m = zeros(1, total+2);
    z = zeros(n+2, n+2);
    pixel_count = 0;
    b = 0.80;
    k = 1;
    half_n = round(n/2);

    z(1) = Pic(1, 1);
    m(1) = z(1)/n;
	for i = n+1 : n+Row
        for j = n+1 : n+Col
            pixel_count = 0;
            k = k+1;
%             z([1,n], [1,n]) = Pic_temp([i-half_n,i+n-half_n+1], [j-half_n,j+n-half_n+1]);
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