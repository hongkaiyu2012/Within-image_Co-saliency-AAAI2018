function Saliency_Map_single=ClusteringSingleSaliency(imRGB)
% Cluster-based Saliency Detection in single image without considering multi-image correspondence
% by Hongkai Yu, 10/14/2014

%--- cluster number -------
Bin_num_single=6;
%---- scaling the image ---
ScaleH=300;
ScaleW=300;

    im=imRGB;
    [orgH orgW channel]=size(im);

    %----- obtaining the features -----
    [All_vector All_img All_DisVector]=GetImVectorWithoutPath(im, ScaleH, ScaleW,0);

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

    %imwrite(imresize(Saliency_Map_single, [orgH orgW]),strcat('img_output/SingleSaliencyOutput/',files(i,1).name, '_SingleSal.png'),'png');
   



