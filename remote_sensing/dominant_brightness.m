function [ D ] = dominant_brightness( I )
%DOMINANT_BRIGHTNESS compute and return dominant brightness level for a
%   given image.

e = 0.1; % prevents log from diverging

%rectangular region size
a = 1; b=1; m = length(I(:,1)); n = length(I(1,:));
N_L = 9; % number of pixels in image grid S
D = I;

for i=1+a:(m-a)
    for j=1+b:(n-b)
        % choose rectangular region around each pixel
        S = I(i-a:i+a,j-b:j+b);
        L = log(S + e);
        D(i,j) = exp((1/N_L) * sum(L(:)));
    end
end

end
