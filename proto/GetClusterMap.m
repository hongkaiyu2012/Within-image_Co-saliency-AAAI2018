%%%% By Hongkai Yu, 03/25/2015
%%%% Get the cluster map of a RGB color image using K-means clustering on HSV color feature

function ClusterID=GetClusterMap(I,K)
ball=I;
ball_HSV=rgb2hsv(ball);
ball_H=ball_HSV(:,:,1);
ball_S=ball_HSV(:,:,2);
ball_V=ball_HSV(:,:,3);
[M,N]=size(ball_H);
NumPixels=M*N;
Colors= zeros(NumPixels,3);
for j=1:NumPixels
    Colors(j,1) = ball_H(j) ;
    Colors(j,2) = ball_S(j) ;
    Colors(j,3) = ball_V(j) ;
    [row,col]=Convert1DIndexTo2DIndex(j,M,N);
    Colors(j,4) = 0.001*row;
    Colors(j,5) = 0.001*col;
end
[Id Clusters] = kmeans(Colors, K); % k-means clustering
ClusterID=Id;
ClusterID=reshape(Id,M,N);