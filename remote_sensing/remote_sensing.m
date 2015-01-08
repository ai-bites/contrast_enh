%clc; clear all;

% take 2D DWT of the input image
A = imread('cameraman.tif');
%[LL HH HL LH] = dwt2(A,'db7');

%% compute dominant brightness level 

% for each pixel(x,y) compute the dominant brightness level
% and normalize
D = dominant_brightness(LL);
D = D/max(D(:));

%% form 3 layers based on the dominant brightness measure
low_bound = 0.4; high_bound = 0.7;
low_layer  = (D < low_bound).*D;
mid_layer  = (D > low_bound) .* (D < high_bound).*D;
high_layer = (D > high_bound).*D;

figure(1);
subplot(2,3,1), imshow(low_layer,[]);
subplot(2,3,2), imshow(mid_layer,[]);
subplot(2,3,3), imshow(high_layer,[]);

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


%% Gamma adjustment
Ml = low_bound; Mm = high_bound-low_bound; Mh = 1-high_bound;

%TODO: set gamma value appropriately
gamma = 0.15; % specified constant

G_low = real(((ktrf_img_l/Ml).^(1/gamma)) - ((1-(ktrf_img_l/Ml)).^(1/gamma)) + 1);
G_mid = real(((ktrf_img_m/Mm).^(1/gamma)) - ((1-(ktrf_img_m/Mm)).^(1/gamma)) + 1);
G_high =real(((ktrf_img_h/Mh).^(1/gamma)) - ((1-(ktrf_img_h/Mh)).^(1/gamma)) + 1);

%figure(2)
subplot(2,3,4),imshow(G_low); 
subplot(2,3,5),imshow(G_mid);
subplot(2,3,6),imshow(G_high);

%% weighting map estimation

% Gaussian boundary smoothing weight calculation
ftr = fspecial('gaussian',[3 3], 0.5);
low_layer_ftd = imfilter(low_layer, ftr, 'replicate');
mid_layer_ftd = imfilter(mid_layer, ftr, 'replicate');
high_layer_ftd = imfilter(high_layer, ftr, 'replicate');


temp_ll = sort(low_layer_ftd(:),'descend'); 
temp_ml = sort(mid_layer_ftd(:),'descend'); 
temp_hl = sort(high_layer_ftd(:),'descend'); 
temp_ll = [temp_ll(1),temp_ll(2)];
temp_ml = [temp_ml(1),temp_ml(2)];
temp_hl = [temp_hl(1),temp_hl(2)];

% sum of two significant bits in each layer
weights(1) = sum(temp_ll);
weights(2) = sum(temp_ml);
weights(3) = sum(temp_hl);

% pick bit maps with highest sums as W_one and W_two
[vals idxs] = sort(weights,'descend');
if (idxs(1) == 3) W_one = temp_hl(1); W_two = temp_hl(2); end;
if (idxs(1) == 2) W_one = temp_ml(1); W_two = temp_ml(2); end;
if (idxs(1) == 1) W_one = temp_ll(1); W_two = temp_ll(2); end;

%% fuse all the three images
%W_one = 0.9873; W_two=0.9823;
F = W_one*G_low + (1-W_one)*((W_two*G_mid) + (1-W_two)*G_high);

figure;imshow(F); % only the LL band. 

%% Inverse transform to obtain the image

% final inverse DWT with processed LL band
result = uint8(idwt2(F,HH,HL,LH,'db7'));
imshow(result);

