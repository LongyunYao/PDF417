function bound = find_bound(Pic)
    [row, col] = size(Pic);
    bound = zeros(row, col);
    for i = 2 : row-1
        for j = 2 : col-1
            for p = i-1 : i+1
                for q = j-1 : j+1
                    if p == i && q == j
                        continue;
                    end
                    if Pic(i, j) ~= Pic(p, q);
                        bound(i, j) = 255;
                        break
                    end
                end
            end
        end
    end
end