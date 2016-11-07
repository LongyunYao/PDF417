%% 二维码的四个角的选择
%设置腐蚀膨胀的半径为20pixel
Pic = imread('step2.bmp');
se = strel('disk',20);
Pic_imopen = imopen(Pic, se);

bound = find_bound(Pic_imopen);
[H, theta, rho, peak, XY]= Hough(bound);
figure,imshow(Pic);
title('图像以及四个顶点');
hold on;
plot(XY(:, 1), XY(:, 2),'o');
imwrite(Pic, 'step3.bmp');
xlswrite('corner.xlsx', XY);
