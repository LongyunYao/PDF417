%% 二维码的二次矫正
Pic = imread('step3.bmp');
XY = xlsread('corner.xlsx');
Pic = roll2((peak(1, 1)-90)/180*pi, Pic);
figure,imshow(Pic);
title('旋转之后');