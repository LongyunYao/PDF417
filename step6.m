close all;
corner=xlsread('corner5.xlsx')
img=imread('step5.bmp');
x1=corner(1,1);
y1=corner(1,2);
x2=corner(2,1);
y2=corner(2,2);
x3=corner(3,1);
y3=corner(3,2);
x4=corner(4,1);
y4=corner(4,2);
x5=300;
y5=300;

%{
imshow(img);
hold on;
plot(x1,y1,'bo');
plot(x2,y2,'ro');
plot(x3,y3,'go');
plot(x4,y4,'ko');
plot(x5,y5,'co');
hold off
%}

A=[corner,corner(:,1).*corner(:,2),ones(4,1)]

tp=10;              %确定生成区域
bt=10+200;
lf=10;
rt=10+700;

xd1=lf;
xd2=rt;
xd3=rt;
xd4=lf;
yd1=bt;
yd2=bt;
yd3=tp;
yd4=tp

b1=A\[xd1;xd2;xd3;xd4]
b2=A\[yd1;yd2;yd3;yd4]

Ac=[b1';b2'];   %变换矩阵

newimg=ones(bt,rt);
[height,width]=size(img)
for m=1:width 
    for n=1:height
        new=Ac*[m;n;m*n;1];
        new=round(new);
        if(new(1)>0&&new(1)<=rt&&new(2)>0&&new(2)<=bt)
            newimg(new(2),new(1))=img(n,m);
        end
    end
end

newimg=1-newimg;
B=ones(3);
Bx=2,By=2;
newimg=forp(newimg,B,Bx,By,1);  %膨胀
newimg=forp(newimg,B,Bx,By,-1); %腐蚀
newimg=1-newimg;

figure,imshow(newimg);

        