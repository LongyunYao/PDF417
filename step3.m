%% ��ά����ĸ��ǵ�ѡ��
%���ø�ʴ���͵İ뾶Ϊ20pixel
Pic = imread('step2.bmp');
se = strel('disk',20);
Pic_imopen = imopen(Pic, se);

bound = find_bound(Pic_imopen);
[H, theta, rho, peak, XY]= Hough(bound);
figure,imshow(Pic);
title('ͼ���Լ��ĸ�����');
hold on;
plot(XY(:, 1), XY(:, 2),'o');
imwrite(Pic, 'step3.bmp');
xlswrite('corner.xlsx', XY);
