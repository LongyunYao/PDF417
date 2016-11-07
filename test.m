str1 = 'iloveu';
str2 = 1314;
str3 = sprintf('%s%d',str1,str2)
[x, y] = findpoint(90, 269, 179, -646);
close all;
string_0 = 'lv0 - relax.bmp';
string_1 = 'lv1 - easy.jpg';
string_2 = 'lv2 - normal.jpg';
string_3 = 'lv3 - hard.jpg';
string_4 = 'lv4 - crazy.jpg';
string_5 = 'lv5 - insane.jpg';
string_6 = 'lv6 - lunatic.jpg';
string_7 = '1.bmp';
string_8 = '2.bmp';
string_9 = '2.jpg';
string_10 = '3.bmp';
string_11 = '4.bmp';
string_12 = '5.bmp';
string_13 = '6.bmp';
Pic=imread(string_1);
[row, col, degree] = size(Pic);

if degree > 2
    Pic=rgb2gray(Pic);
end
%subplot(211);
figure,imshow(Pic);
title('原始图片');
[maxgrey, Pic] = OTSU_2(Pic);%大津算法计算二值图像
figure, imshow(Pic);
title('大津算法二值化以后');
Pic = roll2(90/180*pi, Pic);
figure, imshow(Pic);
title('旋转以后');