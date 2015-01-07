function eme_value = eme(img)

eme_value = 0.0;
c = 0.0001;
img_size = size(img);
num_blocks = 8; % as in paper

row_blocks = img_size(1) / num_blocks;
col_blocks = img_size(2) / num_blocks;

for i = 1 : 8 : row_blocks
    for j = 1 : 8: col_blocks
        img_block = img(i:i+7, j:j+7);
        i_max = double(max(img_block(:)));
        i_min = double(min(img_block(:)));
        temp = double(i_max / (i_min + c));
        eme_value = eme_value + temp * log(temp);
    end
end

eme_value = eme_value * ( 1 / (row_blocks * col_blocks));
end