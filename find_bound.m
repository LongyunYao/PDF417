function bound = find_bound(Pic)
    [row, col] = size(Pic);
    se = getnhood(strel('disk',3));
    % Pic_imopen = imopen(Pic, se);
    Pic_imopen=forp(Pic,se,3,3,-1);  %��ʴ
    figure, imshow(Pic_imopen);
    bound = Pic - Pic_imopen;
    figure, imshow(bound);
end