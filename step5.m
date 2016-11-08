close all;
corner=xlsread('corner.xlsx')
img=imread('step3.bmp');
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

A=[[corner(1,:);corner(3:4,:)],ones(3,1)]

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

b1=A\[xd1;xd3;xd4]
b2=A\[yd1;yd3;yd4]

Ac=[b1(1),b1(2);b2(1),b2(2)];   %变换矩阵
Bc=[b1(3);b2(3)];

newimg=ones(bt+200,rt+200);
[height,width]=size(img)
for m=1:width 
    for n=1:height
        new=Ac*[m;n]+Bc;
        new=round(new);
        if(new(1)>0&&new(1)<=rt+200&&new(2)>0&&new(2)<=bt+200)
            newimg(new(2),new(1))=img(n,m);
        end
    end
end

newp1=Ac*[round(x1);round(y1)]+Bc
newp2=Ac*[round(x2);round(y2)]+Bc
newp3=Ac*[round(x3);round(y3)]+Bc
newp4=Ac*[round(x4);round(y4)]+Bc
newp5=Ac*[round(x5);round(y5)]+Bc



figure, imshow(newimg);
imwrite(newimg,'step5.bmp');
output=[newp1';newp2';newp3';newp4']
xlswrite('corner5.xlsx',output);
hold on
plot(newp1(1),newp1(2),'bo');
plot(newp2(1),newp2(2),'ro');
plot(newp3(1),newp3(2),'go');
plot(newp4(1),newp4(2),'ko');
plot(newp5(1),newp5(2),'co');
hold off
        

