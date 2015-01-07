clc();
files = dir('data/*.jpg');
for file = files'
    read_path = strcat('data/',file.name);
    img = imread(read_path);
    eme_value = eme(img)
end