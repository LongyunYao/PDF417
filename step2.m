close all;
%% ȥ����ͨ��
Pic = imread('step1.bmp');
% [leftline, k] = LineScan(Pic);
%�������
% ltl=leftline';
% figure,plot(ltl(2,1:k));
% title('�����');
%plot(leftline(1:k, 2));

% Pic = revolve(Pic, leftline, k);
% figure, imshow(Pic);
% title('��ת֮��');
% saveas(gcf,'leftrevolve.bmp')

for i = 1 : 4
    Pic = interpolation(Pic);
end

figure, imshow(Pic);
title('�˲����');

Pic = move(Pic);
figure, imshow(Pic);
title('ȥ����ͨ��');
imwrite(Pic, 'step2.bmp');
