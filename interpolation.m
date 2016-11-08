function Pic_temp = interpolation(Pic)
    [row, col] = size(Pic);
    Pic_temp = Pic;
    for i = 2 : row-1
        for j = 2 : col-1
            %检查周围4个元素，如果该点的水平或垂直方向上的邻近点与该点的灰度值不同，则把该点的灰度值重新赋值为邻近点的值
            if (Pic(i, j) ~= Pic(i-1, j) && Pic(i, j) ~= Pic(i+1, j)) || (Pic(i, j) ~= Pic(i, j-1) && Pic(i, j) ~= Pic(i, j+1))
                Pic_temp(i, j) = 255 - Pic_temp(i, j);
            end
        end
    end
end