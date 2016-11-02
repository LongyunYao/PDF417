close all;
string_0 = 'lv0 - relax.bmp';
string_1 = 'lv1 - easy.jpg';
string_2 = 'lv2 - normal.jpg';
string_3 = 'lv3 - hard.jpg';
string_4 = 'lv4 - crazy.jpg';
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
OTSU_2(Pic)
%[maxgrey, Pic] = otsu(Pic);%大津算法计算二值图像
[maxgrey, Pic] = OTSU_2(Pic);%大津算法计算二值图像
%[maxgrey, Pic] = thresh_md(Pic);%大津算法计算二值图像
maxgrey
figure;
imshow(Pic);
%{
[leftline, k] = LineScan(Pic);
%描左侧线
ltl=leftline';
figure;
plot(ltl(2,1:k));
%plot(leftline(1:k, 2));

Pic = revolve(Pic, leftline, k);

figure;
imshow(Pic);
Pic = interpolation(Pic);

figure;
imshow(Pic);
%}