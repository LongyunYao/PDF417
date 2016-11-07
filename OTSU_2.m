function [thresholdValue, Pic] = OTSU_2(Pic)
    % 设t为设定的阈值。
    % wo： 分开后 前景像素点数占图像的比例
    % uo： 分开后 前景像素点的平均灰度
    % w1：分开后 被景像素点数占图像的比例
    % u1： 分开后 被景像素点的平均灰度
    % u=w0*u0 + w1*u1 :图像总平均灰度
    % 从L个灰度级遍历t，使得t为某个值的时候，前景和背景的方差最大， 则 这个 t 值便是我们要求得的阈值。
    % 其中，方差的计算公式如下：
    % g=wo * (uo - u) * (uo - u) + w1 * (u1 - u) * (u1 - u)
    % [ 此公式计算量较大，可以采用： g = wo * w1 * (uo - u1) * (uo - u1) ]
    % 由于otsu算法是对图像的灰度级进行聚类，so 在执行otsu算法之前，需要计算该图像的灰度直方图。
    % 迭代法原理：迭代选择法是首先猜测一个初始阈值，然后再通过对图像的多趟计算对阈值进行改进的过程。重复地对图像进行阈值操作，将图像分割为对象类和背景类，然后来利用每一个类中的灰阶级别对阈值进行改进。
    % 图像阈值分割---迭代算法
    %    1 .处理流程：
    %        1.为全局阈值选择一个初始估计值T(图像的平均灰度)。
    %        2.用T分割图像。产生两组像素：G1有灰度值大于T的像素组成，G2有小于等于T像素组成。
    %        3.计算G1和G2像素的平均灰度值m1和m2；
    %        4.计算一个新的阈值:T = (m1 + m2) / 2;
    %        5.重复步骤2和4,直到连续迭代中的T值间的差小于一个预定义参数为止。
    %        适合图像直方图有明显波谷
	[Row, Col] = size(Pic);
	L = 256; %256个灰度级

	%Count是一个数组，存放了每一个灰度值的数量，【下标-1】表示对应的灰度值
	%x是一个数组，用来存放【灰度值】
	[Count, x] = imhist(Pic);

	Count = Count / (Row*Col);	%每一个灰度值的频率


	for i = 1 : L
		if Count(i) ~= 0		%第一个不为0的灰度值的下标
			start_index = i;	%该灰度值，注意【下标-1】表示对应的灰度值
			break;
		end
	end

	for i = L : -1 : 1
		if Count(i) ~= 0		%倒数第一个不为0的灰度值的下标
			end_index = i;		%该灰度值
			break;
		end
	end

	%Count是每个灰度出现的【概率】
	%去掉0值是为了方便之后的方差计算
	%Count = Count(start_index: end_index);
	%x = x(start_index: end_index);
    sum = 0;
    n = 0;
	for k =1 : 256
		sum = sum +  k *  Count(k); % x*f(x) 质量矩
		n = n + Count(k); % f(x) 质量 
	end

	fmax =-1.0;
	n1 = 0;
    csum = 0;
	for k = 1:256
		n1 = n1 + Count(k);%前景像素频率之和
		n2 = n - n1;%后景像素频率之和
		if (n1 == 0 || n2 == 0) %避免除0
			continue;
        end
		csum = csum + k * Count(k);
		m1 = csum / n1;%前景像素期望
		m2 = (sum - csum) / n2;%后景像素期望
		sb = (n1 * (n2) *(m1 - m2) * (m1 - m2));
		% bbg: note: can be optimized. */
		if (sb > fmax) 
			fmax = sb;
			thresholdValue = k;
        end
    end
    for i = 1 : Row
		for j = 1 : Col
			if Pic(i, j) > thresholdValue
				Pic(i, j) = 255;
			else
				Pic(i, j) = 0;
			end
		end
    end
end