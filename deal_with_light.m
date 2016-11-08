function f1 = deal_with_light(g)
%将灰度图“取反”，为了顶帽变换时背景不会变成黑色
[row, col] = size(g);
f = g;
for i=1:row
    for j=1:col
        f(i,j)=255 - g(i,j);
    end
end
figure('Name', '处理光源问题');subplot(2,2,1);imshow(f);
se=strel('disk',35);%产生结构元素
%顶帽变换
f1=imtophat(f,se);%使用顶帽变换
%顶帽变换后再“取反”，这样图形背景就是白色的了
for i=1:row
    for j=1:col
        f1(i,j)=255 - f1(i,j);
    end
end
subplot(2,2,2),imshow(f1);
title('使用顶帽变换后的图像');
%底帽变换
f2=imbothat(imcomplement(f),se);
subplot(2,2,3),imshow(f2);
title('使用底帽变换后的图像');
%f1=histeq(f1);
%增强对比度，具体来说就是让黑色更黑
f1 = imadjust(f1,[0.1 1],[0,1],15);
f1 = im2bw(f1)*255;
f1 = medfilt2(f1);
%%%%%%%%%%%%lv4和lv5把下面这句话取消注释%%%%%%%%%%%%%%