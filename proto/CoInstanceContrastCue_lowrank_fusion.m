clear all; close all;
path_images='./images/';
im_type='jpg';
JPGFile=dir([path_images,'*.',im_type]);
ImageNum=size(JPGFile,1);
linear=0; % 1 for using linear fusion; 0 for low-rank fusion

for i=1:ImageNum
        fprintf('Low rank fusion for image %d \n', i);
        [pathstr,name,ext] =fileparts(JPGFile(i).name);
        M=[];
        %%
        load(['output_common_box/' name '_optimal_boxes.mat']); %optimal_boxes
        Mset=[];
        for s=1:2:size(optimal_boxes,1) 
            map=imread(['Debug_output/' name '_' num2str(int32(s/2)) '.png']);
            Mset{int32(s/2)}=double(map)/255; 
        end 
        M=[M,Mset];
    %% low-rank saliency map fusion  
    if linear==0
        map_num=length(M);
        %map_names = {'_CoInstanceSaliency_1.png','_CoInstanceSaliency_2.png','_CoInstanceSaliency_3.png','_CoInstanceSaliency_4.png','_CoInstanceSaliency_5.png'};
        inames{1}=name;
        w = sacs_calWeight(map_num, inames , M, path_images);
        if isnan(w(1))
            w=(1/length(M))*ones(length(M),1);
        end
        saliency = zeros(size(M{1,1}));
        for j=1:length(M)
            saliency  = saliency + w(j)*double(M{j});
        end
        raws = saliency;
        %final_map = normalize(raws);
        final_map=(raws-min(raws(:)))/(max(raws(:))-min(raws(:)));
        imwrite(final_map, ['output/' name '_CDS.png']);    
    else
%         %% linear fusion
%         final_map=zeros(size(M{1}));
%         for m=1:length(M)
%             final_map=final_map+(1/length(M))*M{m};
%         end
%         final_map=(final_map-min(final_map(:)))/(max(final_map(:))-min(final_map(:)));
%         imwrite(final_map, ['CoInstanceContrastCue/' name '_CoInstanceSaliencyContrast_linear.png']);       
    end
end