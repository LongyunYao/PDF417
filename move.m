function img=move(oldimg)
img=oldimg;
%------------����Ժ�ɾ��-------------
%if ndims(img)==3
%    img=rgb2gray(img);
%end
%img=im2bw(img,0.6);
%------------------------------------
img=im2bw(img,0.6);
subplot(121);imshow(img);
[height,width]=size(img)
newimg=1-img;
%B=[0,1,0;1,1,1;0,1,0];
B=ones(17);                  %���þ���
Bx=9;By=9;                   %ѡȡԭ��
newimg=forp(newimg,B,Bx,By,1);  %����
newimg=forp(newimg,B,Bx,By,-1); %��ʴ
B=ones(3);         
Bx=2;By=2;
mask=newimg;
h=newimg;
edge_wide=1;        %�趨�߽���
for m=1+edge_wide:height-edge_wide     %ȡ�߽�
    for n=1+edge_wide:width-edge_wide
        h(m,n)=0;
    end
end
cnt=0;
newh=forp(h,B,Bx,By,1)&mask;
while ~isequal(h, newh)         %��������ȡ��߽���������ͨ��
    h=newh;
    newh=forp(h,B,Bx,By,1)&mask;
end
newimg=newimg-h;                %ȥ����Щ��ͨ��
img=1-img;
img=img-h;
[L,num]=bwlabel(newimg);        %����ͨ����
s=zeros(num,1);
max=0;
for i=1:num
    for m=1:height
        for n=1:width
            if L(m,n)==i 
                s(i)=s(i)+1;
            end
            if s(i)>max 
                max=s(i);
            end
        end
    end          
end
for m=1:height
    for n=1:width
        if img(m,n)<0
            img(m,n)=0;
        end
        i=L(m,n);
        if i==0 
            continue;
        end
        if s(i)<0.5*max
            L(m,n)=0;
            img(m,n)=0;
        end
    end
end
img=1-img;
subplot(122);
imshow(img);
end