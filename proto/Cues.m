classdef Cues
  % saliency cue calculation
  methods(Static=true)
    %---------------------------------------------------------------------------
    % remove small proposals, like smaller than 1% of image area
    function weight=CoinstanceSpatialCue(im, Cluster_Map, saliencyMap, ClusterNum)
        weight=[]; % mean l2 distance to center of corresponding cluster
        adaptive_th=2*mean(saliencyMap(:));
        if adaptive_th>0.9
            adaptive_th=0.9;
        end
        if adaptive_th<0.1
            adaptive_th=0.1;
        end
        map=im2bw(saliencyMap,adaptive_th);
        map=map.*Cluster_Map;
        pixel_num=size(Cluster_Map,1)*size(Cluster_Map,2);
        bkg_cluster = Cues.FindBkgCluster(Cluster_Map, saliencyMap, ClusterNum, 0.15);
        
        for p=1:ClusterNum
            if any(bkg_cluster==p)
                weight(p)=0;
                continue;
            end            
             c_p=find(Cluster_Map==p);                           
             position=[];
             for j=1:length(c_p)
                [r,c]=Convert1DIndexTo2DIndex(c_p(j),size(Cluster_Map,1),size(Cluster_Map,2));
                position(j,:)=[r,c];                 
             end
             d = Cues.L2Distance2Center(position);
             weight(p) = d.meandist;              
        end
        weight=weight/max(weight);
        %weight= Gauss_normal(weight);      
    end
    %---------------------------------------------------------------------------
    %%% input: points as a n-by-2 array
    %%% output: out.dist: l2 distance to center for each point, out.meandist: mean l2 distance, out.center: 1-by-2 as center point 
    function [out] = L2Distance2Center(points)
        L=size(points,1);
        if L==1
            out.center=points;
            out.dist=0;
            out.meandist=0;
            return
        end        
        center = mean(points);        
        for i=1:L
           D(i)= sqrt(sum((points(i,:)-center).^2));            
        end
        out.center=center;
        out.dist=D;
        out.meandist=mean(D);
    end
    %------------------------------------------------------------------------------ 
    %%% get background cluster id 
    function [out] = FindBkgCluster(Cluster_Map, saliencyMap, ClusterNum,th)
        adaptive_th=2*mean(saliencyMap(:));
        if adaptive_th>0.9
            adaptive_th=0.9;
        end
        if adaptive_th<0.1
            adaptive_th=0.1;
        end
        map=im2bw(saliencyMap,adaptive_th);
        map_bkg=(1-map).*Cluster_Map; 
        bkg_pixel=find(map_bkg~=0);
        bkg_pixel_num=length(bkg_pixel);
        out=[];
        for p=1:ClusterNum
            c_p=find(map_bkg==p);
            if length(c_p)>th*bkg_pixel_num
                out=[out;p];
            end
        end
    end
    %------------------------------------------------------------------------------ 
    % only consider the salient pixels
    function [weight,object_map]=CoinstanceNewSpatialCue(im, Cluster_Map, saliencyMap, ClusterNum)
        weight=zeros(ClusterNum,1); % mean l2 distance to center of corresponding cluster
        if mean(saliencyMap(:))<0.1
            adaptive_th=0.1;
        else
            adaptive_th=0.3;
        end
        object_map=im2bw(saliencyMap,adaptive_th);
        map=object_map.*Cluster_Map;  
        
        for p=1:ClusterNum
             one_cluster_map=zeros(size(map,1),size(map,2));
             c_p=find(map==p);                           
             for j=1:length(c_p)
                [r,c]=Convert1DIndexTo2DIndex(c_p(j),size(map,1),size(map,2));
                one_cluster_map(r,c)=1;          
             end
             area_th=int32(0.004*size(map,1)*size(map,2));
             if area_th>800
                 area_th=800;
             end
             one_cluster_map = bwareaopen(one_cluster_map, double(area_th));
             c_p=find(one_cluster_map==1);   
             position=[];
             for j=1:length(c_p)
                [r,c]=Convert1DIndexTo2DIndex(c_p(j),size(map,1),size(map,2));
                position(j,:)=[r,c];           
             end
             if ~isempty(position)
                d = Cues.L2Distance2Center(position);
                weight(p) = d.meandist;
             end
        end
        if sum(weight)~=0
            weight=weight/max(weight);
        else
            % no need to remove small objects   
            weight=zeros(ClusterNum,1); % mean l2 distance to center of corresponding cluster
            if mean(saliencyMap(:))<0.2
                adaptive_th=0.1;
            else
                adaptive_th=0.3;
            end
            object_map=im2bw(saliencyMap,adaptive_th);
            map=object_map.*Cluster_Map;  
            for p=1:ClusterNum
                 one_cluster_map=zeros(size(map,1),size(map,2));
                 c_p=find(map==p);                           
                 for j=1:length(c_p)
                    [r,c]=Convert1DIndexTo2DIndex(c_p(j),size(map,1),size(map,2));
                    one_cluster_map(r,c)=1;          
                 end                
                 c_p=find(one_cluster_map==1);   
                 position=[];
                 for j=1:length(c_p)
                    [r,c]=Convert1DIndexTo2DIndex(c_p(j),size(map,1),size(map,2));
                    position(j,:)=[r,c];           
                 end
                 if ~isempty(position)
                    d = Cues.L2Distance2Center(position);
                    weight(p) = d.meandist;
                 end
            end
            weight=weight/max(weight);            
        end
        [sort_v,sort_id]=sort(weight);
        %weight(sort_id(1:3))=0;
    end
    %---------------------------------------------------------------------------
  end
end