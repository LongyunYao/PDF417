function [leftline, k] = LineScan(Pic)
    [Row, Col] = size(Pic);
    leftline = zeros (Row, 2);
    %%旋转
    %寻找左侧边线
    leftline=zeros(Row,2);
    k=1;
    for i=int16(Row/3):Row %不能从1开始扫描，否则在运行例如test.jpg的时候会描边错误
        for j=1:Col
            if Pic(i,j) <= 50
                if k == 1         
                    leftline(k,1) = i;
                    leftline(k,2) = j;
                    k = k+1;
                else 
                    if abs(j-leftline(k-1, 2)) < 10
                        leftline(k,1) = i;
                        leftline(k,2) = j;
                        k = k+1;
                    end
                end
                break
            end
        end
    end
end