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
Pic=imread(string_13);
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
%[maxgrey, Pic] = otsu(Pic);%����㷨�����ֵͼ��
[maxgrey, Pic] = OTSU_2(Pic);%����㷨�����ֵͼ��
%[maxgrey, Pic] = thresh_md(Pic);%����㷨�����ֵͼ��
figure;
imshow(Pic);

[leftline, k] = LineScan(Pic);
%�������
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

%���ø�ʴ���͵İ뾶Ϊ20pixel
se = strel('disk',20);
Pic_imopen = imopen(Pic, se);
title('imopen');
% figure, imshow(Pic_imopen);

bound = find_bound(Pic_imopen);
% figure, imshow(bound);
[H, theta, rho, peak]= Hough(bound);
% figure, surf(H),brighten(1);
% peak=houghpeaks(H,8);
% 
% lines=houghlines(bound,theta,rho,peak);      
% figure,imshow(bound,[]),title('Hough Transform Detect Result'),hold on      
% 
% for k=1:length(lines)
%     xy=[lines(k).point1;lines(k).point2];
%     lines(k).point1
%     lines(k).point2
%     plot(xy(:,1),xy(:,2),'LineWidth',4,'Color',[.6 .6 .6]);      
% end