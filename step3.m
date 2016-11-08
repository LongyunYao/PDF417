close all;
%% 二维码的四个角的选择
%设置腐蚀膨胀的半径为12pixel
Pic = imread('step2.bmp');
se = getnhood(strel('disk',12));
% Pic_imopen = imopen(Pic, se);
Pic_imopen=forp(Pic,se,12,12,-1); %腐蚀
Pic_imopen=forp(Pic_imopen,se,12,12,1);  %膨胀
figure,imshow(Pic_imopen);
bound = find_bound(Pic_imopen);
[H, theta, rho, peak, XY]= Hough(Pic,bound);
figure,imshow(Pic);
title('图像以及四个顶点');
hold on;
plot(XY(:, 1), XY(:, 2),'o');
imwrite(Pic, 'step3.bmp');
xlswrite('corner.xlsx', double(XY));
