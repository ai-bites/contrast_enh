function [xx,yy] = knee_transfer(x,y,I)
% x = array of input points along x axis
% y = corresponding array of points in y axis

    X = [0 x 1];
    Y = [0 y 1];
    %xx = 0:0.01:1;
    xx = I;
    yy = spline(X,Y,xx); % output image

end