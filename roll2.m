function h = roll2(Angle, Image)
    [X,Y]=size(Image);
%     x0= (x - rx0)*cos(a) - (y - ry0)*sin(a) + rx0 ;
%     y0= (x - rx0)*sin(a) + (y - ry0)*cos(a) + ry0 ;

    %计算四个角点的新坐标，确定旋转后的显示区域 
    LeftTop(1,1)=-(Y-1)*sin(Angle);
    LeftTop(1,2)=(Y-1)*cos(Angle);

    LeftBottom(1,1)=0; 
    LeftBottom(1,2)=0; 

    RightTop(1,1)=(X-1)*cos(Angle)-(Y-1)*sin(Angle); 
    RightTop(1,2)=(X-1)*sin(Angle)+(Y-1)*cos(Angle); 

    RightBottom(1,1)=(X-1)*cos(Angle);
    RightBottom(1,2)=(X-1)*sin(Angle);

    %计算显示区域的行列数 
    Xnew=max([LeftTop(1,1),LeftBottom(1,1),RightTop(1,1),RightBottom(1,1)])-min([LeftTop(1,1),LeftBottom(1,1),RightTop(1,1),RightBottom(1,1)]); 
    Ynew=max([LeftTop(1,2),LeftBottom(1,2),RightTop(1,2),RightBottom(1,2)])-min([LeftTop(1,2),LeftBottom(1,2),RightTop(1,2),RightBottom(1,2)]); 

    % 分配新显示区域矩阵 
    ImageNew=ones(round(Xnew),round(Ynew));

    %计算原图像各像素的新坐标 
    for indexX=0:(X-1)
        for indexY=0:(Y-1)
            new_x = round(indexX*cos(Angle)-indexY*sin(Angle));
            rx0 = round(abs(min([LeftTop(1,1),LeftBottom(1,1),RightTop(1,1),RightBottom(1,1)])));
            new_y = round(indexX*sin(Angle)+indexY*cos(Angle));
            ry1 = round(abs(min([LeftTop(1,2),LeftBottom(1,2),RightTop(1,2),RightBottom(1,2)])));
            ImageNew(new_x+rx0+1,new_y+ry1+1)=Image(indexX+1,indexY+1);
        end  
    end 

    h=(ImageNew);
    h=medfilt2(h); 
%     for i = 1 : 1
%         h = interpolation(h);
%     end
    figure,imshow(h)
    imwrite(h,'rotate.jpg','quality',100);
end