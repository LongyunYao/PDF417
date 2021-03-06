%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%传入之前必须先变成灰度图
%OTSU 最大类间方差法图像分类  
%该方法将图像分为前景和背景两部分，背景和目标之间的类间方差越大,说明构成图像的2部分的差别越大,  
%当部分目标错分为背景或部分背景错分为目标都会导致2部分差别变小。因此,使类间方差最大的分割意味着错分概率最小。  
%Command 中调用方式： OTSU('D:\Images\pic_loc\1870405130305041503.jpg')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function [maxgrey, Pic] = otsu(Pic)
	%[Count x]=imhist(a);
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
	Count = Count(start_index: end_index);
	x = x(start_index: end_index);

	%t之前的被称为前景像素，t之后的被称为背景像素
	%这里PPT的matlab有误，因为可能产生越界行为
    u0 = zeros(end_index-start_index+1, 1);
    u1 = zeros(end_index-start_index+1, 1);
	for t = 1 : end_index-start_index+1
		%w0(i)是前i个像素的累加概率
		w0(t) = sum(Count(1 : t));
		%(start_index + t - 1)表示当前的灰度值
		%u0(i)是前i个像素q期望值
        %PPT计算期望代码
		u0(t) = sum(Count(1 : t) .* x(1 : t))/w0(t);
        if(t == end_index-start_index+1)
            u1(t) = 0;
		else u1(t) = sum(Count(t+1 : end_index-start_index+1) .* x(t+1 : end_index-start_index+1))/(1-w0(t));
        end
    end

	%u代表整个图像的期望
	u = u0(end_index-start_index+1);
	%这里PPT的matlab代码有错误，要根据PPT的公式来写代码
	%g表示每个像素值所对应的的期望阀值
	%g = (u * w0 - u0) .^ 2 ./ (w0 .* (1 - w0));
    for t = 1 : end_index-start_index+1
        g = (u0(t)-u)*(u0(t)-u)*(u1(t)-u)*(u1(t)-u);
    end

	%找到最佳阀值
	[g_max, g_index] = max(g);  %可以取出数组的最大值及取最大值的点   
	%max表示最大的阀值所对应的灰度值的下标
    maxgrey = x(g_index); %找到对应的灰度值
	  
	for i = 1 : Row
		for j = 1 : Col
			if Pic(i, j) > maxgrey
				Pic(i, j) = 255;
			else
				Pic(i, j) = 0;
			end
		end
	end
	%subplot(212);
end