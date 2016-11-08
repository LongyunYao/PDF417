function bound = find_bound(Pic)
    [row, col] = size(Pic);
    Pic = 1-Pic;
%     se = getnhood(strel('disk',3));
    se = ones(5, 5);
    % Pic_imopen = imopen(Pic, se);
    Pic_imopen=forp(Pic,se,3,3,1);  %≈Ú’Õ
    Pic_imopen2=forp(Pic_imopen,se,3,3,1);  %≈Ú’Õ
    bound = Pic_imopen2 - Pic_imopen;
    figure, imshow(bound);
end