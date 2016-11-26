close all;
string_1 = '1.bmp';
string_2 = '2.bmp';
string_3 = '3.bmp';
string_4 = '4.bmp';
string_5 = 'week12test.bmp';
str = string_5;
Pic=imread(str);
[row, col, degree] = size(Pic);
if degree > 2
    Pic=rgb2gray(Pic);
end
Pic = im2bw(Pic);

%对图像周边进行白色填充扩展
Pic_temp = ones(row+5, col+5);
Pic_temp(3:row+2, 3:col+2) = Pic;
Pic = Pic_temp;
[row, col, degree] = size(Pic);

figure,imshow(Pic);
title('原始图片');

%% 图像解码
% 目前可用 1.bmp, 2.bmp, 3.bmp, 4.bmp, week12test.bmp
y_mask = [1 1 1;0 0 0;-1 -1 -1];%?建立Y方向的模板
y_mask2 = [-1 -1 -1;0 0 0;1 1 1];%?建立Y方向的模板
x_mask = y_mask';  %?建立X方向的模板?
x_mask2 = y_mask2';  %?建立X方向的模板?
I = im2double(Pic);  %?将图像数据转化为双精度?
dx = imfilter(I, x_mask);  %?计算X方向的梯度分量?
dx2 = imfilter(I, x_mask2);  %?计算X方向的梯度分量?
dy = imfilter(I, y_mask);  %?计算Y方向的梯度分量??
dy2 = imfilter(I, y_mask2);  %?计算Y方向的梯度分量??
%ho左白右黑，ho2左黑右白
ho=im2bw(dx); ho2=im2bw(dx2); hor = ho+ho2;
for i = 2 : size(hor, 1)
    for j = 2 : size(hor, 2)
        if hor(i, j) + hor(i, j-1) == 2*hor(i, j)
            hor(i, j) = 0;
        end
    end
end
figure,imshow(hor),title('水平边缘检测');
%ve上白下黑ve2上黑下白
ve=im2bw(dy);ve2=im2bw(dy2);ver = ve+ve2;
for j = 2 : size(ver, 2)
    for i = 2 : size(ver, 1)
        if ver(i, j) + ver(i-1, j) == 2*ver(i, j)
            ver(i, j) = 0;
        end
    end
end
figure,imshow(ver),title('垂直边缘检测');

sum_hor = sum(hor);
len_hor = size(sum_hor, 2);
for i = 2 : len_hor
    if sum_hor(1, i) + sum_hor(1, i-1) == 2*sum_hor(1, i)
        sum_hor(1, i-1) = 0;
    end
end

sum_ver = sum(ver,2);
len_ver = size(sum_ver, 1);
for i = 2 : len_ver
    if sum_ver(i, 1) + sum_ver(i-1, 1) == 2*sum_ver(i, 1)
        sum_ver(i-1, 1) = 0;
    end
end
%横向边界统计
figure, plot(1:len_hor, sum_hor);
%纵向边界统计
figure, plot(1:len_ver, sum_ver);

%pks 对应峰值，locs 对应峰值位数，去掉边界点
[ver_pks,ver_locs] = findpeaks(sum_ver)
[hor_pks,hor_locs] = findpeaks(sum_hor)
top = ver_locs(1); but = ver_locs(size(ver_locs,1));
left = hor_locs(1); right = hor_locs(size(hor_locs, 2))
%ver_pks = ver_pks(2:size(ver_pks,1)-1);
%locs = locs(2:size(locs, 1)-1);

%统计每一层的中心，记录行数
k = size(ver_pks, 1);
layers=zeros(1, k-1);
for i=1:k-1
    layers(i)=round((ver_locs(i)+ver_locs(i+1))/2);
end

code=zeros(k-1, col);
last_code=zeros(1, k-1);
for i=1:k-1
    m=0;
    for j=left+2:right
        if hor(layers(i), j)==1 
            if m==0
                m=m+1;
                %记录第一列位置
                code(i, m)=j-left;
                temp=j;
            else
                m=m+1;
                %与前一列的距离
                code(i, m)=j-temp;
                temp=j;
            end
            %总列数
            last_code(i)=m;
        end
    end
end
asum = sum(code);
%aunit为一个模块的长度
aunit = round((asum(1)/(k-1))/8);
code_calculate= zeros(k-1, last_code(1));
for i=1:k-1
    for j=1:last_code(1)
        code_calculate(i, j)=round(code(i, j)/aunit);
    end
end

%解码码字转换
[row,col] = size(code_calculate);
code_calculate = code_calculate(1:row, 17:col-17);
[row,col] = size(code_calculate);
decode = zeros(1, round(row*col/8));
load symcodes.mat -ascii
k = 1;
for i=1:row
    for j=1:8:col
        temp = 0;
        for p = 0:7
            temp = temp + code_calculate(i, j+p)*10^(7-p);
        end
        for m=1:3
            for n=1:929
                if symcodes(m,n)==temp
                    decode(k)=n-1;
                    k=k+1;
                    break;
                end
            end
        end
    end
end
xlswrite('decode.xlsx', decode);