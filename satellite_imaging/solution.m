clc;
clear all;
close all;


grayImage=rgb2gray(imread('image.png'));
sizeOfGrayImage=size(grayImage);

% we make a Decomposition of the original gray-level image into the four frequency subbands
% by using DWT

[LL,LH,HL,HH]=dwt2(grayImage,'db7');

% we d
figure(1)
subplot(3,2,1), imshow(grayImage, []), title('The Original Gray Image');
subplot(3,2,3), imshow(LL, []), title('LL subband of image');
subplot(3,2,4), imshow(LH, []), title('LH subband of image');
subplot(3,2,5), imshow(HL, []), title('HL subband of image');
subplot(3,2,6), imshow(HH, []), title('HH subband of image');

%%%%% Decomposition of equalized gray-level image using DWT

[gLL,gLH,gHL,gHH]=dwt2(histeq(grayImage),'db7');

figure(2)
subplot(3,2,1), imshow(grayImage, []), title('Original image');
subplot(3,2,2), imshow(histeq(grayImage)), title('Equalized GHE image');
subplot(3,2,3), imshow(gLL, []), title('gLL subband of image');
subplot(3,2,4), imshow(gLH, []), title('gLH subband of image');
subplot(3,2,5), imshow(gHL, []), title('gHL subband of image');
subplot(3,2,6), imshow(gHH, []), title('gHH subband of image');

% Singular value decomposition of  LL subband of the gray level image and the
% equalized gray level image

[U, S, V] = svd(LL);
[gEU, gES, gEV] = svd(gLL);

% Calculation of correction coefficient for the singular value matrix

% Find maximum element in Singular_Values
max_Singular_Values1 = max(max(S));
% Find maximum element in gE_Singular_Values
max_gE_Singular_Values1 = max(max(gES));

% Correction coefficient
ratio = max_gE_Singular_Values1 / max_Singular_Values1;

display(max_gE_Singular_Values1);
display(max_Singular_Values1);
display(ratio);

% Calculation of new S usinf the correction coefficient
S1 = ratio * S;

% Reconstruction of LL as output_LL, using U and V of subband LL of
% original image and the new S1
LL1 = U * S1 * V';

figure(3)
imshow(LL1, []), title('The new subband LL');

%%%%% Reconstruction of image by using IDWT with new subband LL and the ones from
%%%%% the original image

Final_result = idwt2(LL1, LH, HL, HH, 'db7');

figure(4)
subplot(1,2,1), imshow(grayImage, []), title('Original image');
subplot(1,2,2), imshow(Final_result, []), title('Constrast Enhanced Image');
