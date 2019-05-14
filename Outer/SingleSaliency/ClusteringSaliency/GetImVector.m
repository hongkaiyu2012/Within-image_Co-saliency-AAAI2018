function [ vector img DisVector] = GetImVector( img, ScaleH, ScaleW ,need_texture)
% Get the vector of image

% addpath(fullfile(pwd,'mexDenseSIFT'));
% cellsize=3;
% gridspacing=1;

%img=imread(imgpath);
img = imresize(img, [ScaleH, ScaleW]);

if need_texture
    N=8;
    lambda  = 8;
    theta   = 0;
    psi     = [0 pi/2];
    gamma   = 0.5;
    bw      = 1;
    img_in = im2double(rgb2gray(img));
    Gabor_img = zeros(ScaleH, ScaleW, N);
    for n=1:N
        gb = gabor_fn(bw,gamma,psi(1),lambda,theta)...
            + 1i * gabor_fn(bw,gamma,psi(2),lambda,theta);
        % gb is the n-th gabor filter
        Gabor_img(:,:,n) = imfilter(img_in, gb, 'symmetric');
        % filter output to the n-th channel
        theta = theta + 2*pi/N;
        % next orientation
    end
    Gabor_img = sum(abs(Gabor_img).^2, 3).^0.5;
end

%img2 = colorspace('Lab<-RGB',img); 
img2=img;
vector=zeros( ScaleH*ScaleW,3);

if need_texture
vector=zeros( ScaleH*ScaleW,4);
end

DisVector=zeros( ScaleH*ScaleW,1);
for j=1:ScaleH 
    for i=1:ScaleW 
        vector(j +(i-1)*ScaleH,1)=round(img2(j, i, 1));
        vector(j +(i-1)*ScaleH,2)=round(img2(j, i, 2));
        vector(j +(i-1)*ScaleH,3)=round(img2(j, i, 3));     
        if need_texture
            vector(j +(i-1)*ScaleH,4)=Gabor_img(j, i);
        end
      DisVector(j +(i-1)*ScaleH)=round(sqrt((i-ScaleW/2)^2+(j-ScaleH/2)^2));
    end
end


end

