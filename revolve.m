function I = revolve(Pic, leftline, k)
    [row, col] = size(Pic);
    n = int16(k/2);
    tanarray = zeros(n, 1);
    for i = 1:n
        %��ȡ���n����ŵ������߽��֮���γɵ�tanֵ
        tanarray(i) = (leftline(i+n, 2)-leftline(i, 2))/(leftline(i+n, 1)-leftline(i, 1));
    end
    %sort֮��ȡ�е��tanֵ
    tanarray = sort(tanarray);
    %ang����ת�Ƕ�
    ang = atan(tanarray(int16(n/2)));
    I = roll(ang, Pic);
end