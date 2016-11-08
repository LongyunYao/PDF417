function Pic_temp = interpolation(Pic)
    [row, col] = size(Pic);
    Pic_temp = Pic;
    for i = 2 : row-1
        for j = 2 : col-1
            %�����Χ4��Ԫ�أ�����õ��ˮƽ��ֱ�����ϵ��ڽ�����õ�ĻҶ�ֵ��ͬ����Ѹõ�ĻҶ�ֵ���¸�ֵΪ�ڽ����ֵ
            if (Pic(i, j) ~= Pic(i-1, j) && Pic(i, j) ~= Pic(i+1, j)) || (Pic(i, j) ~= Pic(i, j-1) && Pic(i, j) ~= Pic(i, j+1))
                Pic_temp(i, j) = 255 - Pic_temp(i, j);
            end
        end
    end
end