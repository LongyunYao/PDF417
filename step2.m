close all;
%% 去除连通块
Pic = imread('step1.bmp');
% [leftline, k] = LineScan(Pic);
%描左侧线
% ltl=leftline';
% figure,plot(ltl(2,1:k));
% title('左边线');
%plot(leftline(1:k, 2));

% Pic = revolve(Pic, leftline, k);
% figure, imshow(Pic);
% title('旋转之后');
% saveas(gcf,'leftrevolve.bmp')

for i = 1 : 4
    Pic = interpolation(Pic);
end

figure, imshow(Pic);
title('滤波完毕');

Pic = move(Pic);
figure, imshow(Pic);
title('去除连通域');
imwrite(Pic, 'step2.bmp');
