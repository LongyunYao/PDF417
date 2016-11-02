%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OTSU 最大类间方差法图像分类
%该方法将图像分为前景和背景两部分，背景和目标之间的类间方差越大,说明构成图像的2部分的差别越大,
%当部分目标错分为背景或部分背景错分为目标都会导致2部分差别变小。因此,使类间方差最大的分割意味着错分概率最小。
%Command 中调用方式： OTSU('D:\Images\pic_loc\1870405130305041503.jpg')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [th, a]=thresh_md(a)
   %[count x]=imhist(a); 
   [m,n]=size(a); 
   N=m*n; 
   L=256; 
   
for i=1:L
    count(i)=length(find(a==(i-1)));
    f(i)=count(i)/(N);
end

for i=1:L 
    if count(i)~=0 
        st=i-1; 
        break; 
    end 
end 
for i=L:-1:1 
    if count(i)~=0 
        nd=i-1; 
        break; 
    end 
end 
%f=count(st+1:nd+1);  %f是每个灰度出现的概率 
p=st;   q=nd-st; 
u=0; 
for i=1:q 
    u=u+f(i)*(p+i-1);  %u是像素的平均值  
    ua(i)=u;           %ua（i）是前i个像素的平均灰度值 
end; 
 
for i=1:q 
    w(i)=sum(f(1:i));  %w（i）是前i个像素的累加概率 
end; 
w=w+0.0001;
 
d=(u*w-ua).^2./(w.*(1-w)); 
[y,tp]=max(d);  %可以取出数组的最大值及取最大值的点 
th=tp+p; 

for i=1:m 
    for j=1:n 
        if a(i,j)>th 
            a(i,j)=0; 
        else 
            a(i,j)=255; 
        end 
    end 
end  
imshow(a,[]);