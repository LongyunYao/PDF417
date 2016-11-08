function I = revolve(Pic, leftline, k)
    [row, col] = size(Pic);
    n = int16(k/2);
    tanarray = zeros(n, 1);
    for i = 1:n
        %求取相隔n个编号的两个边界点之间形成的tan值
        tanarray(i) = (leftline(i+n, 2)-leftline(i, 2))/(leftline(i+n, 1)-leftline(i, 1));
    end
    %sort之后取中点的tan值
    tanarray = sort(tanarray);
    %ang是旋转角度
    ang = atan(tanarray(int16(n/2)));
    I = roll(ang, Pic);
end