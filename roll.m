function I = roll(ang, Pic)
    [row, col] = size(Pic);
    x1 = 0; y1 = 0; x2 = col; y2 = 0;
    x3 = col; y3 = row; x4 = 0; y4 = row;

    %(rx0, ry0)表示旋转之前的中心坐标
    rx0 = round(col/2+0.5);
    ry0 = round(row/2+0.5);
    
    new_x1 = (y1 - ry0)*sin(ang) + (x1 - rx0)*cos(ang) + rx0;
    new_y1 = (y1 - ry0)*cos(ang) - (x1 - rx0)*sin(ang) + ry0;
    
    new_x2 = (y2 - ry0)*sin(ang) + (x2 - rx0)*cos(ang) + rx0;
    new_y2 = (y2 - ry0)*cos(ang) - (x2 - rx0)*sin(ang) + ry0;
    
    new_x3 = (y3 - ry0)*sin(ang) + (x3 - rx0)*cos(ang) + rx0;
    new_y3 = (y3 - ry0)*cos(ang) - (x3 - rx0)*sin(ang) + ry0;
    
    new_x4 = (y4 - ry0)*sin(ang) + (x4 - rx0)*cos(ang) + rx0;
    new_y4 = (y4 - ry0)*cos(ang) - (x4 - rx0)*sin(ang) + ry0;

    %计算旋转后的图像的宽度和高度
    new_col = round(max(abs(new_x1 - new_x3),abs(new_x2 - new_x4))+0.5);
    new_row = round(max(abs(new_y1 - new_y3),abs(new_y2 - new_y4))+0.5);
    
    %旋转后中心坐标
    rx1=round((new_col - 1) / 2 + 0.5);
    ry1=round((new_row - 1) / 2 + 0.5);
    
    t1=[1 0 0;0 1 0;-rx0 -ry0 1];
    t2=[cos(ang) -sin(ang) 0;sin(ang) cos(ang) 0;0 0 1];
    t3=[1 0 0;0 1 0;rx1 ry1 1];
    xform=t1*t2*t3;
    tform_translate = maketform('affine',xform);
    %[cb_trans xdata ydata] = imtransform(cb, tform_translate);
    
    newWidth = new_col;
    newHeight = new_row;
    m = row;
    n = col;
    I1 = Pic;
    %构造新坐标系x和y的值
    tx=ones(newHeight,newWidth)*255;
    ty=ones(newHeight,newWidth)*255;
    for i=1:newHeight
        for j=1:newWidth
            tx(i,j)=i;
            ty(i,j)=j;
        end
    end
    
    [w z]=tforminv(tform_translate,tx,ty); %反向坐标值

    I=double(zeros(newHeight,newWidth));

    %给新图像各像素点赋值
    for i=1:newHeight
        for j=1:newWidth
            S_x=w(i,j);
            S_y=z(i,j);
            if(S_x>=m-1||S_y>=n-1||double(uint16(S_x))<=0||double(uint16(S_y))<=0) 
                I(i,j)=255; %不在原图像上
            else
                if (S_x/double(uint16(S_x))==1.0&S_y/double(uint16(S_y))==1.0)
                    I(i,j)=I1(uint16(S_x),uint16(S_y));%整数点
                else
                    I(i,j)=I1(uint16(S_x),uint16(S_y));
                end
            end
        end
    end
end