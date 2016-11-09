close all;
img=imread('step6.bmp');
[height,width]=size(img);
w=50;
left=0;
right=0;

%{
figure
imshow(img)
hold on
line([w,w],[1,height]);
x=width-w;
line([x,x],[1,height]);
hold off
%}
for m=1:height
    for n=1:width
        if n<=w&&img(m,n)==0
            left=left+1;
        end
        if n>width-w&&img(m,n)==0
            right=right+1;
        end
    end
end
left
right
if left<right
    newimg=rot90(img,2);
else
    newimg=img;
end
imshow(newimg)