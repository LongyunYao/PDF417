close all;
%% ��ά����ĸ��ǵ�ѡ��
%���ø�ʴ���͵İ뾶Ϊ12pixel
Pic = imread('step2.bmp');
se = getnhood(strel('disk',12));
% Pic_imopen = imopen(Pic, se);
Pic_imopen=forp(Pic,se,12,12,-1); %��ʴ
Pic_imopen=forp(Pic_imopen,se,12,12,1);  %����
figure,imshow(Pic_imopen);
bound = find_bound(Pic_imopen);
[H, theta, rho, peak, XY]= Hough(Pic,bound);
figure,imshow(Pic);
title('ͼ���Լ��ĸ�����');
hold on;
plot(XY(:, 1), XY(:, 2),'o');
imwrite(Pic, 'step3.bmp');
xlswrite('corner.xlsx', double(XY));
