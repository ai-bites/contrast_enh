clc; clear all;

% take 2D DWT of the input image
A = imread('cameraman.tif');
%[LL HH HL LH] = dwt2(A,'db1');

%% compute dominant brightness level 

% for each pixel(x,y) compute the dominant brightness level
% and normalize
D = dominant_brightness(LL)
D = D/256;

%% form 3 layers based on the dominant brightness measure
low_bound = 0.4; high_bound = 0.7;
low_layer  = (D < low_bound).*D;
mid_layer  = (D > low_bound) .* (D < high_bound).*D;
high_layer = (D > high_bound).*D;

%% Adaptive intensity transformation

% mean brightness
ml = mean(low_layer(:)); 
mh = mean(high_layer(:));
mm = mean(mid_layer(:));

% weights
wl = 0.5; wh = 0.5; wm = 0.5; 

% knee points
Pl = low_bound + wl*(low_bound - ml);
Ph = high_bound + wh*(high_bound - mh);
Pml = low_bound - wm*(low_bound - mm) + (Pl - Ph);
Pmh = high_bound + wm*(high_bound - mm) + (Pl - Ph);

ktrf_img_l = knee_transfer(low_bound,Pl,low_layer);
ktrf_img_m = knee_transfer([low_bound high_bound],[Pml Pmh],mid_layer);
ktrf_img_h = knee_transfer(high_bound,Ph,high_layer);

%figure(1);imshow(ktrf_img_h); 
%figure(2);imshow(ktrf_img_m);
%figure(3);imshow(ktrf_img_h);


%% Gamma adjustment
Ml = low_bound; Mm = high_bound-low_bound; Mh = 1-high_bound;

%TODO: set gamma value appropriately
gamma = 2; % specified constant

G_low = ((ktrf_img_l/Ml).^(1/gamma)) - ((1-(ktrf_img_l/Ml)).^(1/gamma)) + 1;
G_mid = ((ktrf_img_m/Mm).^(1/gamma)) - ((1-(ktrf_img_m/Mm)).^(1/gamma)) + 1;
G_high =((ktrf_img_h/Mh).^(1/gamma)) - ((1-(ktrf_img_h/Mh)).^(1/gamma)) + 1;

%% weighting map estimation

W_one = 1; W_two = 1;
%% fuse all the three images

F = W_one*G_low + (1-W_one)*((W_two*G_mid) + (1-W_two)*G_high);

imshow(F); % only the LL band. 

%% Inverse transform to obtain the image

% final inverse DWT with processed LL band
result = uint8(idwt2(LL,HH,HL,LH,'db1'));
imshow(result);

