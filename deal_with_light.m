function f1 = deal_with_light(g)
%���Ҷ�ͼ��ȡ������Ϊ�˶�ñ�任ʱ���������ɺ�ɫ
[row, col] = size(g);
f = g;
for i=1:row
    for j=1:col
        f(i,j)=255 - g(i,j);
    end
end
figure('Name', '�����Դ����');subplot(2,2,1);imshow(f);
se=strel('disk',35);%�����ṹԪ��
%��ñ�任
f1=imtophat(f,se);%ʹ�ö�ñ�任
%��ñ�任���١�ȡ����������ͼ�α������ǰ�ɫ����
for i=1:row
    for j=1:col
        f1(i,j)=255 - f1(i,j);
    end
end
subplot(2,2,2),imshow(f1);
title('ʹ�ö�ñ�任���ͼ��');
%��ñ�任
f2=imbothat(imcomplement(f),se);
subplot(2,2,3),imshow(f2);
title('ʹ�õ�ñ�任���ͼ��');
%f1=histeq(f1);
%��ǿ�Աȶȣ�������˵�����ú�ɫ����
f1 = imadjust(f1,[0.1 1],[0,1],15);
f1 = im2bw(f1)*255;
f1 = medfilt2(f1);
%%%%%%%%%%%%lv4��lv5��������仰ȡ��ע��%%%%%%%%%%%%%%