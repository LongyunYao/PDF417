function newimg=forp(img,B,Bx,By,choice)
%Bx和By是原点坐标，choice为1是膨胀，为0是腐蚀
[width,height]=size(img);
[Bw,Bh]=size(B);
newimg=zeros(width,height);
if choice~=1
    choice=0;
end
    for y=1:height            
       for x=1:width
           tmp=1-choice;
           for i=1:Bh
               for j=1:Bw
                   if B(i,j)==1&&~(x-Bx+i<=0||x-Bx+i>width||y-By+j<=0||y-By+j>height)
                       if img(x-Bx+i,y-By+j)==choice
                           tmp=choice;
                       end
                   end
               end
           end
           newimg(x,y)=tmp;
       end
    end


end