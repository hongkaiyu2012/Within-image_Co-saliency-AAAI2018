% The demo for Cluster-based Co-saliency Detection in multiple images

clc;close all;clear;

name= 'MSRC_Hongkai';
file_path=strcat('img_data/co_saliency_data/', name, '/');
files=dir([file_path '*.jpg']);

Img_num=size(files,1);
Scale=200; % Scale 

%clustering number on multi-image
Bin_num=min(max(2*Img_num,10),30);

%clustering number on single-image
Bin_num_single=6;

%% ------ Obtain the co-saliency for multiple images-------------
%----- obtaining the features -----
All_vector = [];
All_DisVector = [];
All_img = [];
for i=1:Img_num
   path=strcat(file_path, files(i,1).name);
   [imvector img DisVector]=GetImVector(path, Scale, Scale,0);
   All_vector=[All_vector; imvector];
   All_DisVector=[All_DisVector; DisVector];
   All_img=[All_img img];
end

% ---- clustering -------
[idx,ctrs] = kmeansPP(All_vector',Bin_num);
idx=idx';
ctrs=ctrs';

%----- clustering idx map ---------
Cluster_Map = reshape(idx, Scale, Scale*Img_num);

%----- computing the Contrast cue -------
Sal_weight_co= Gauss_normal(GetSalWeight( ctrs,idx ));
%----- computing the Spatial cue -------
Dis_weight_co= Gauss_normal(GetPositionW( idx, All_DisVector, Scale, Bin_num ));
%----- computing the Corresponding cue -------
co_weight_co= Gauss_normal(GetCoWeight( idx, Scale, Scale ));
 
%----- combining the Co-Saliency cues -----
SaliencyWeight=(Sal_weight_co.*Dis_weight_co.*co_weight_co);

%----- generating the co-saliency map -----
Saliency_Map_co = Cluster2img( Cluster_Map, SaliencyWeight, Bin_num);


%% ------ Obtain the Single-saliency for each image -------------
%----- the detals see the Demo_single.m ----

Saliency_Map_single = zeros(size(Saliency_Map_co));
for i=1:Img_num
    path=strcat(file_path, files(i,1).name);
    [imvector img DisVector]=GetImVector(path, Scale, Scale,0);
    [idx,ctrs] = kmeansPP(imvector',Bin_num_single);
    idx=idx'; ctrs=ctrs';
    Cluster_Map = reshape(idx, Scale, Scale);
    Sal_weight=GetSalWeight( ctrs,idx  );
    Dis_weight  = GetPositionW( idx, DisVector, Scale, Bin_num_single );
    Sal_weight= Gauss_normal(Sal_weight);
    Dis_weight= Gauss_normal(Dis_weight); 
    SaliencyWeight_all=(Sal_weight.*Dis_weight);
    Saliency_sig_final = Cluster2img( Cluster_Map, SaliencyWeight_all, Bin_num_single);
    
    Saliency_Map_single(:,1+(i-1)*Scale:Scale+(i-1)*Scale)=Saliency_sig_final;
end

%% ---- output co-saliency map ----- 
Saliency_Map_final=Saliency_Map_single .* Saliency_Map_co;

% Summation is better for the complex video !
%Saliency_Map_final=Saliency_Map_single + Saliency_Map_co;

figure(1),subplot(3,1,1), imshow(All_img),title('Input images');
subplot(3,1,2), imshow((Saliency_Map_single)),colormap(gray),title('Single Saliency');
subplot(3,1,3), imshow(Saliency_Map_final),colormap(gray),title('Co-Saliency');

if (~exist(['img_output/' name '/'], 'dir')) 
    mkdir(['img_output/' name '/']);
end

for i=1:Img_num
   path=strcat(file_path, files(i,1).name);
   im = imread(path);
   [imH imW imC] = size(im);
   %imwrite(im,['img_output/' name '/' files(i,1).name '_org.png'],'png');
   cosal = Saliency_Map_final(:, (1 + (i-1)*Scale):(i*Scale));
   imwrite(imresize(cosal, [imH imW]),['img_output/' name '/' files(i,1).name '_cosal.png'],'png');
   %sigsal = Saliency_Map_single(:, (1 + (i-1)*Scale):(i*Scale));
   %imwrite(imresize(sigsal, [imH imW]),['img_output/' name '/' files(i,1).name '_single.png'],'png');
end







