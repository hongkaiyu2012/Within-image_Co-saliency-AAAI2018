% The demo for Cluster-based Saliency Detection in single image
clear all;
close all;
clc
name= 'single_data';
file_path=strcat('img_data/', name, '/');
files=dir([file_path '*.png']);
Img_num=size(files,1);

%--- cluster number -------
Bin_num_single=6;
%---- scaling the image ---
ScaleH=300;
ScaleW=300;

for i=1:Img_num
    file_path=strcat('img_data/', name, '/');
    file_path=strcat(file_path, files(i,1).name);
    im=imread([file_path]);
    [orgH orgW channel]=size(im);

    %----- obtaining the features -----
    [All_vector All_img All_DisVector]=GetImVector([file_path], ScaleH, ScaleW,0);

    %----- image clustering (using Kmean++) ---
    [idx,ctrs] = kmeansPP(All_vector',Bin_num_single);
    idx=idx'; ctrs=ctrs';

    %----- clustering idx map ---------
    Cluster_Map = reshape(idx, ScaleH, ScaleW);

    %----- computing the Contrast cue -------
    Sal_weight_single= Gauss_normal(GetSalWeight( ctrs,idx));
 
    %----- computing the Spatial cue -------
    Dis_weight_single= Gauss_normal(GetPositionW( idx, All_DisVector, ScaleW, Bin_num_single ));

    %----- combining the cues -------
    SaliencyWeight_all=(Sal_weight_single.*Dis_weight_single);

    %----- generating the saliency map -----
    Saliency_Map_single = Cluster2img( Cluster_Map, SaliencyWeight_all, Bin_num_single);

    Saliency_Map_single=imresize(Gauss_normal(Saliency_Map_single),[orgH orgW]);

    %imwrite(im,strcat('img_output/',name(1:end-4), '_org.png'),'png');
    imwrite(imresize(Saliency_Map_single, [orgH orgW]),strcat('img_output/SingleSaliencyOutput/',files(i,1).name, '_SingleSal.png'),'png');
    Saliency_Map_single_BW = im2bw(Saliency_Map_single, graythresh(Saliency_Map_single));
    imwrite(imresize(Saliency_Map_single_BW, [orgH orgW]),strcat('img_output/SingleSaliencyOutput/',files(i,1).name, '_SingleSalSeg.png'),'png');
    figure,subplot(1,3,1), imshow(im),title('Input images');
    subplot(1,3,2),imshow(Saliency_Map_single),title('Single Saliency');
    subplot(1,3,3), imshow(Saliency_Map_single_BW),title('Single Saliency Seg');
end




