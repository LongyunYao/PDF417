close all;
string_1 = '1.bmp';
string_2 = '2.bmp';
string_3 = '3.bmp';
string_4 = '4.bmp';
string_5 = 'week12test.bmp';
load symcodes.mat -ascii
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
dx = imfilter(I, x_mask, 'conv');  %?计算X方向的梯度分量?
dx2 = imfilter(I, x_mask2, 'conv');  %?计算X方向的梯度分量?
dy = imfilter(I, y_mask, 'conv');  %?计算Y方向的梯度分量??
dy2 = imfilter(I, y_mask2, 'conv');  %?计算Y方向的梯度分量??
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
% xlswrite('decode.xlsx', decode);

%% 解码

%%解码
%文本模式码表TC,码表里的值是Ascii值，之所以不直接存成字符，是因为有些Ascii值无法显示，比如LF、CR等
%将模式转换符号定义成数值,如下：
%ll=201，锁定为小写字母模式
%ml=202，锁定为混合模式
%pl=203，锁定为标点模式
%al=200，锁定为大写字母模式
%ps=204，转移为标点模式
%as=205，转移为大写字母模式
tc_uc=[65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,32,201,202,204];%大写字母模式
tc_lc=[97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,32,205,202,204];%小写字母模式
tc_mi=[48,49,50,51,52,53,54,55,56,57,38,13,09,44,58,35,45,46,36,47,43,37,42,61,94,203,32,201,200,204];%混合型模式
tc_do=[59,60,62,64,91,92,93,95,96,126,33,13,09,44,58,10,45,46,36,47,34,124,42,40,41,63,123,125,39,200];%标点型模式
%数字模式码表
nc_tb=[48,49,50,51,52,53,54,55,56,57];
%开始解码，暂时不支持字节型模式，只支持文本模式和数字模式
codelen=decode(1);
mode=11;%2->数字型、3->字节型、11->文本模式大写型、12->文本模式小写型、13->文本模式混合型、14->文本模式标点型
premode=[0,0];%用于转移模式时记录模式值,第一个值表示当前是否为转移模式，第二个值表示要返回的模式值
tcbyte=zeros(1,2);%用于记录文本模式时的高低位数据，第一个值表示高位数据，第二个值表示低位数据
valueindex=[0,0];%用于记录字节模式和数字模式的缓存序列，其中第一个值表示序列是否有效及何种模式0->无效、1->数字模式、2->字节模式，第二个值表示序列起始位置
str='';
for i=2:codelen
    if decode(i)>=900
        if decode(i)==900
            mode=11;
        elseif decode(i)==902
            mode=2;
        elseif (decode(i)==901) || (decode(i)==924) || (decode(i)==913)
            mode=3;
        end
        
        %数字模式解码
        if valueindex(1)==1
            caches=decode(valueindex(2):(i-1))
            len=size(caches,2)
            curvalues=zeros(1,15);
            for k=1:15:len
                if (k+14)<len %当前组大于15个码字
                    curvalues = caches(k:k+14);
                else          %当前组不足15个码字
                    curvalues(k+15-len:15) = caches(k:len);
                end
                %开始解码
                longnum=0;
                for x=1:15
                    %必须用符号运算，否则有效数最多只有16位
                    longnum = longnum+curvalues(x)*sym(9^(15-x))*(100^(15-x));
                end
                tempstr=char(longnum);
                str = strcat(str, tempstr(2:end));
            end
        end
             
        valueindex = [0,0];
        
    else
       
        %文本模式解码
        if mode>10
            tcbyte(1)=floor(decode(i)/30);
            tcbyte(2)=decode(i) - tcbyte(1)*30;
            for j=1:2
                if mode==11
                    if premode(1)==1
                        mode=premode(2);
                        premode(1)=0;
                    end
                    if tc_uc(tcbyte(j)+1)==201
                        mode=12;
                    elseif tc_uc(tcbyte(j)+1)==202
                        mode=13;
                    elseif tc_uc(tcbyte(j)+1)==204
                        premode(1)=1;
                        premode(2)=mode;
                        mode=14;
                    else
                        str = strcat(str,char(tc_uc(tcbyte(j)+1)));
                    end
                elseif mode==12
                    if premode(1)==1
                        mode=premode(2);
                        premode(1)=0;
                    end
                    if tc_lc(tcbyte(j)+1)==205
                        premode(1)=1;
                        premode(2)=mode;
                        mode=11;
                    elseif tc_lc(tcbyte(j)+1)==202
                        mode=13;
                    elseif tc_lc(tcbyte(j)+1)==204
                        premode(1)=1;
                        premode(2)=mode;
                        mode=14;
                    else
                        str = strcat(str,char(tc_lc(tcbyte(j)+1)));
                    end
                elseif mode==13
                    if premode(1)==1
                        mode=premode(2);
                        premode(1)=0;
                    end
                    if tc_mi(tcbyte(j)+1)==200
                        mode=11;
                    elseif tc_mi(tcbyte(j)+1)==201
                        mode=12;
                    elseif tc_mi(tcbyte(j)+1)==203
                        mode=14;
                    elseif tc_mi(tcbyte(j)+1)==204
                        premode(1)=1;
                        premode(2)=mode;
                        mode=14;
                    else
                        str = strcat(str,char(tc_mi(tcbyte(j)+1)));
                    end
                elseif mode==14
                    if premode(1)==1
                        mode=premode(2);
                        premode(1)=0;
                    end
                    if tc_do(tcbyte(j)+1)==200
                        mode=11;
                    else
                        str = strcat(str,char(tc_do(tcbyte(j)+1)));
                    end
                end
            end
            %文本模式解码结束
            
        elseif mode==2
            if valueindex(1)==0
                valueindex(1)=1;
                valueindex(2)=i;
            end
        elseif mode==3
            if valueindex(1)==0
                valueindex(1)=2;
                valueindex(2)=i;
            end
        end
    end
end
disp(['解码后的数据为：',str])