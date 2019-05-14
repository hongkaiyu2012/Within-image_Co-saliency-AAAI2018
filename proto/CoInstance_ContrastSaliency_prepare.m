clear all; close all;

path_images='images/';
im_type='jpg';
JPGFile=dir([path_images,'*.',im_type]);
ImageNum=size(JPGFile,1);

for i=1:ImageNum
    fprintf('Prepare salency for image %d \n', i);
    [pathstr,name,ext] =fileparts(JPGFile(i).name);
    %%
    file_path=[path_images name '.jpg'];
    im=imread(file_path);
    saliencyMap=imread(['single-saliency-map/dcl/' name '_DCL.png']);
    saliencyMap=double(saliencyMap);
    saliencyMap=(saliencyMap-min(saliencyMap(:)))/(max(saliencyMap(:))-min(saliencyMap(:))+eps);
    %%
    load(['output_common_box/' name '_optimal_boxes.mat']); %optimal_boxes
    img_mask=im2bw(saliencyMap, 0.2);
    im=double(im);
    r=im(:,:,1).*img_mask;
    g=im(:,:,2).*img_mask;
    b=im(:,:,3).*img_mask;
    img_new=cat(3, uint8(r), uint8(g), uint8(b));
    [orgH orgW channel]=size(im);
    [All_vector All_img All_DisVector]=GetImVector(img_new, orgH, orgW, 0); 
    fg=all(All_vector,2);
    All_vector=All_vector(fg,:);
    SS(i)= std2(All_vector);
    %% call Huazhu Fu's TIP 2013 code to get cluster map and constrast cue for each cluster
    [orgH orgW channel]=size(im);
    %--- cluster number -------
     Bin_num_single=6;
    %---- scaling the image ---
    % ScaleH=300;
    % ScaleW=300;
    %----- obtaining the features -----
    [All_vector All_img All_DisVector]=GetImVector(im, orgH, orgW, 0);
    %----- image clustering (using Kmean++) ---
    [idx,ctrs] = kmeansPP(All_vector',Bin_num_single);
    idx=idx'; ctrs=ctrs';
    %----- clustering idx map ---------
    Cluster_Map = reshape(idx, orgH, orgW);
    %figure,imshow(Cluster_Map,[]);
    %----- computing the Contrast cue -------
    Contrast_W=GetSalWeight(ctrs,idx);
        
    M=[];
    [row, col, dim]=size(im);
    for s=1:2:size(optimal_boxes,1)
        co_boxes=optimal_boxes([s s+1],:);
%         mask=zeros(row,col);
%         mask(co_boxes(1,2):(co_boxes(1,2)+co_boxes(1,4)), co_boxes(1,1):(co_boxes(1,1)+co_boxes(1,3)))=1;
%         mask(co_boxes(2,2):(co_boxes(2,2)+co_boxes(2,4)), co_boxes(2,1):(co_boxes(2,1)+co_boxes(2,3)))=1;        
%         CoInstance_Saliency=mask;  
        %% 
        [CoInstance_W, object_map]=Proposal.ClusterCoInstanceWeightWithSaliencyMap(Cluster_Map, co_boxes, saliencyMap,1);        
%         CoInstance_W=Proposal.ClusterCoInstanceWeight(Cluster_Map, co_boxes);
        object_map=saliencyMap;
        W=CoInstance_W;
        Final_W= W; 
        %%  get the final co-instance saliency map
        CoInstance_Saliency = Cluster2img(Cluster_Map, Final_W, Bin_num_single); % call Fu's code to convert cluster weight to map
        CoInstance_Saliency = CoInstance_Saliency.*object_map;
        CoInstance_Saliency(CoInstance_Saliency>0.2)=1;
        CoInstance_Saliency = imfill(CoInstance_Saliency,'holes');
        h = ones(5,5) / 25;
        CoInstance_Saliency = imfilter(CoInstance_Saliency,h);
        CoInstance_Saliency=(CoInstance_Saliency-min(CoInstance_Saliency(:)))/(max(CoInstance_Saliency(:))-min(CoInstance_Saliency(:))+eps);
        M{int32(s/2)}=CoInstance_Saliency;
        imwrite(M{int32(s/2)}, ['Debug_output/' name '_' num2str(int32(s/2)) '.png']);
    end
end
% CoInstanceContrastCue_lowrank_fusion;