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
str = string_0;
Pic=imread(str);
[row, col, degree] = size(Pic);
if degree > 2
    Pic=rgb2gray(Pic);
end
figure,imshow(Pic);
title('ԭʼͼƬ');
%% ע�⣺ǰ3��ʹ��OTSU
%������ʹ���ƶ�ƽ���ľֲ���ֵ
%�Ƽ�n=69��b=0.78 ����120 0.6
if strcmp(str,string_5) || strcmp(str,string_4)
    Pic = averMovingSegmentation2(Pic);%����㷨�����ֵͼ��
elseif strcmp(str,string_6)
    Pic = averMovingSegmentation(Pic);%����㷨�����ֵͼ��
else
    Pic = OTSU_2(Pic);
end
% Pic = OTSU_2(Pic);%����㷨�����ֵͼ��
figure, imshow(Pic);
title('��ֵ���Ժ�');
imwrite(Pic,'step1.bmp');
