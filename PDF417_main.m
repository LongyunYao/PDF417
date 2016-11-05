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

% level = graythresh(Pic);
% BW = im2bw(Pic,level);
% figure;
% imshow(BW)

if degree > 2
    Pic=rgb2gray(Pic);
end
%subplot(211);
figure;
imshow(Pic);
%[maxgrey, Pic] = otsu(Pic);%大津算法计算二值图像
[maxgrey, Pic] = OTSU_2(Pic);%大津算法计算二值图像
%[maxgrey, Pic] = thresh_md(Pic);%大津算法计算二值图像
figure;
imshow(Pic);

[leftline, k] = LineScan(Pic);
%描左侧线
ltl=leftline';
figure;
plot(ltl(2,1:k));
%plot(leftline(1:k, 2));

Pic = revolve(Pic, leftline, k);

figure;
imshow(Pic);
for i = 1 : 4
    Pic = interpolation(Pic);
end
figure;
imshow(Pic);

%% 二维码的四个角的选择
%设置腐蚀膨胀的半径为20pixel
se = strel('disk',20);
Pic_imopen = imopen(Pic, se);
title('imopen');
% figure, imshow(Pic_imopen);

bound = find_bound(Pic_imopen);
% figure, imshow(bound);
%conrer_x, corner_y就是四个点的坐标，有重复未去除
[H, theta, rho, peak, conrer_x, corner_y]= Hough(bound);