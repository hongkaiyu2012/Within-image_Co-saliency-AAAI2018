classdef Proposal
  methods(Static=true)
    %---------------------------------------------------------------------------
    % remove small proposals, like smaller than 1% of image area
    function out=FixProposals(im, bbs)
        bbs(bbs<=0)=1; 
        out=bbs;
        [height,width,dim]=size(im);
        for i=1:size(bbs,1) 
            box=bbs(i,:);
            x=box(1); y=box(2); w=box(3); h=box(4); score=box(5);
            if x>width
                x=width;
            end
            if y>height
                y=height;
            end
            if x+w>width
                w=width-x;
            end
            if y+h>height
                h=height-y;
            end
            out(i,:)=[x,y,w,h,score];
        end           
    end
    %---------------------------------------------------------------------------
    % select K proposals that each pair overlap very small
    function out=SelectProposals(im, bbs, K)
        [height,width,dim]=size(im);
        id=1;
        out=[];
        for i=1:size(bbs,1)
            box=bbs(i,:);
            x=box(1);y=box(2);w=box(3); h=box(4);
            
            if x>width
                continue;
            end
            if y>height
                continue;
            end
            if x+w>width
                continue;
            end
            if y+h>height
                continue;
            end
            
            ratio=w*h/(height*width);
            if ratio>0.5
               continue;
            end
            if isempty(out)
               out=box;
            else
               o=[]; 
               for j=1:size(out,1)
                   box_j=out(j,:);
                   temp=Proposal.Overlap(box, box_j);     
                   o(j)=temp.relative;
               end  
               if max(o)<0.25
                   out=[out;box];
                   id=id+1;
               end               
            end
            if id==K
                break;
            end
        end  
    end
    %---------------------------------------------------------------------------
    % remove small proposals, like smaller than 1% of image area
    function out=MultiScaleBoxes(im, bbs, th)
        [row,col,dim]=size(im);
        for i=size(bbs,1):-1:1
            box=bbs(i,:);
            w=box(3); h=box(4);
            ratio=w*h/(row*col);
            min_th=th(1);
            max_th=th(2);
            if ratio >= max_th || ratio < min_th
                bbs(i,5)=-999;
            end
        end  
        id=find(bbs(:,5)~=-999);
        out=bbs(id,:);
    end
    %---------------------------------------------------------------------------
    % remove small proposals, like smaller than 1% of image area
    function out=RmoveSmall(im, bbs, th)
        [row,col,dim]=size(im);
        for i=size(bbs,1):-1:1
            box=bbs(i,:);
            w=box(3); h=box(4);
            ratio=w*h/(row*col);
            if ratio<th
                bbs(i,:)=[];
            end
        end  
        out=bbs;
    end
    %---------------------------------------------------------------------------
     % remove big proposals, like bigger than 25% of image area
    function out=RmoveBig(im, bbs, th)
        [row,col,dim]=size(im);
        for i=size(bbs,1):-1:1
            box=bbs(i,:);
            w=box(3); h=box(4);
            ratio=w*h/(row*col);
            if ratio>th
                bbs(i,:)=[];
            end
        end  
        out=bbs;
    end
    %---------------------------------------------------------------------------
    % draw many proposals on one image
    function DrawProposal(im, boxes, fileName)
        fig = Viz.Init(im);
        Viz.DrawBox(fig, boxes);
        Viz.SaveFig(fig, fileName,200);
    end
    %---------------------------------------------------------------------------
    % spatial overlap of two proposals. box: x,y,w,h
    function out=Overlap(box1, box2)
        %[row,col,dim]=size(im);
        %im_area=row*col;
        area = rectint(box1,box2);
        min_box_area=min(box1(3)*box1(4),box2(3)*box2(4));
        %out.whole=area/im_area;        
        out.relative=area/min_box_area;
        if out.relative>0.1 % to-do: add a threshold later
            out.relative=100;
        end
    end
    %---------------------------------------------------------------------------
    % mean saliency of one proposal divided by its area. 
    % SaliencyMap: single channel 0-to-1 map. box: x,y,w,h
    function out=MeanSaliency(SaliencyMap, box)
        x=box(1); y=box(2); w=box(3); h=box(4);
        crop_map=SaliencyMap(y:y+h,x:x+w);
        %out=mean(crop_map(:))/(w*h);
        out=mean(crop_map(:));
    end
    %---------------------------------------------------------------------------
    % get appearance feature for one proposal. im: original rgb image. box: x,y,w,h. 
    function f=GetFeature(im, box)
        x=box(1); y=box(2); w=box(3); h=box(4);
        %im=RGB2Lab(im);
        [row,col,dim]=size(im);
        new_y=y+h;
        new_x=x+w;
        if new_y>row
            new_y=row;
        end
        if new_x>col
            new_x=col;
        end
        crop_im=im(y:new_y,x:new_x,:);
        R=crop_im(:,:,1);G=crop_im(:,:,2);B=crop_im(:,:,3);
        %crop_im2=rgb2hsv(crop_im);
        %H=crop_im2(:,:,1);S=crop_im2(:,:,2);V=crop_im2(:,:,3);
        %f=[mean(R(:))/255, mean(G(:))/255, mean(B(:))/255,mean(H(:)), mean(S(:)), mean(V(:))]; 
        hist1=imhist(R)./numel(R); hist2=imhist(G)./numel(G); hist3=imhist(B)./numel(B);
        f=[hist1;hist2;hist3];
%         % hog feature
%         Im_gray=rgb2gray(crop_im);
%         Im_gray = imresize(Im_gray, [50,50]);  
%         [hog,hog_visualization] = extractHOGFeatures(Im_gray, 'CellSize',[5 5]);  
%         % color hist + hog
%         f=[hist1;hist2;hist3;hog'];
    end
    %---------------------------------------------------------------------------
    % feature distance of two proposals. box: x,y,w,h. flag: 1 for L1
    % distance, 2 for L2 distance
    function out=FeatureDistance(im, box1, box2, flag)
        f1=Proposal.GetFeature(im, box1);
        f2=Proposal.GetFeature(im, box2);
        if flag==1
            out=norm(f1-f2,1);
        elseif flag==2
            out=norm(f1-f2,2);
        end
    end
    %---------------------------------------------------------------------------
    % combined similarity matrix between any two proposals. im: rgb image, bbs: output of EdgeBox proposals (sored by 
    % objectiveness score), m: m top objectiveness score are selected (suggest: 100), flag: 1 for L1 distance, 2 for L2 distance. 
    function [S O]=CombinedSimilarity(im, bbs, m, Sal, flag)
        Num=size(bbs,1);
        if m<Num
            Num=m;
        end
        S=zeros(Num,Num); % S_ii=0 or 1 ?
        O=zeros(Num,Num);  
        for i=1:Num
            box_i=bbs(i,1:4);
            for j=i+1:Num
                box_j=bbs(j,1:4);           
                f_ij=Proposal.FeatureDistance(im, box_i, box_j, flag);
                p1=box_i(1,2);p2=box_j(1,2);
                d_ij=norm(p1-p2,2);
                [row,col,dim]=size(im);
%                 if d_ij<0.1*row
%                    d_ij=0; 
%                 end
                o_ij=Proposal.Overlap(box_i, box_j);
                O(i,j)=o_ij.relative;
                O(j,i)=o_ij.relative;
                sal_i=Sal(i);
                sal_j=Sal(j);
                %S(i,j)=(d_ij)^2*(sal_i+sal_j)/(f_ij^2+(o_ij.relative)^2);  
                S(i,j)=(sal_i+sal_j)/(f_ij^2+(o_ij.relative)^2);  
                S(j,i)=S(i,j); % symmetric matrix
            end
        end
    end
    %---------------------------------------------------------------------------
    % feature distance and overlap of one box to many bbs box
    function [d,O]=OneBox_Similarity(im, box, bbs, flag)
        Num=size(bbs,1);
        d=1000*ones(Num,1);  
        O=1000*ones(Num,1);
        %CrossCorr=1000*zeros(Num,1);
        
        x=box(1);y=box(2);w=box(3);h=box(4);
        center_x=x+0.5*w;
        center_y=y+0.5*h;
        if w>80
            box_small=[center_x-40,center_y-40,80,80];
            %crop_im=im(center_y-40:center_y+40,center_x-40:center_x+40,:);
            %figure,imshow(crop_im,[]); 
        else
            box_small=[center_x-20,center_y-20,40,40];
            %crop_im=im(center_y-20:center_y+20,center_x-20:center_x+20,:);
            %figure,imshow(crop_im,[]); 
        end
                            
        for i=1:Num           
            box_i=bbs(i,1:4);  
            o_i=Proposal.Overlap(box, box_i);                    
            if o_i.relative<0.1
                O(i)=o_i.relative;
                img_box_i=im(center_y-(h/2):center_y+(h/2),center_x-(w/2):center_x+(w/2),:);
                %CrossCorr(i)=ImgReg.NormCrossCorr(crop_im, img_box_i);
                d(i)=Proposal.FeatureDistance(im, box_small, box_i, flag);
            end
        end
    end
    
    %---------------------------------------------------------------------------
    % similarity matrix between any two proposals. im: rgb image, bbs: output of EdgeBox proposals (sored by 
    % objectiveness score), m: m top objectiveness score are selected (suggest: 100), flag: 1 for L1 distance, 2 for L2 distance. 
    function [S,O]=Similarity(im, bbs, m, flag)
        Num=size(bbs,1);
        if m<Num
            Num=m;
        end
        S=zeros(Num,Num); % S_ii=0 or 1 ?
        O=zeros(Num,Num);  
        for i=1:Num
            box_i=bbs(i,1:4);
            for j=i+1:Num
                box_j=bbs(j,1:4);           
                f_ij=Proposal.FeatureDistance(im, box_i, box_j, flag);
%                 p1=box_i(1,2);p2=box_j(1,2);
%                 d_ij=norm(p1-p2,2);
%                 [row,col,dim]=size(im);
%                 if d_ij<0.25*row
%                    d_ij=0; 
%                 end

%                 size_ratio_ij=box_i(3)*box_i(4)/(box_j(3)*box_j(4));
%                 if size_ratio_ij>1.2 || size_ratio_ij<0.8
%                     size_ratio_ij=0;
%                 end

                o_ij=Proposal.Overlap(box_i, box_j);
                O(i,j)=o_ij.relative;
                O(j,i)=o_ij.relative;
                %S(i,j)=exp(-(d_ij^2+(o_ij.relative)^2)); % to do: whole or relative ?
                S(i,j)=1/(f_ij^2+(o_ij.relative)^2); % to do: whole or relative ?
                %S(i,j)=size_ratio_ij^2/(f_ij^2+(o_ij.relative)^2);
                S(j,i)=S(i,j); % symmetric matrix
            end
        end
    end
    %---------------------------------------------------------------------------
    % similarity matrix between any two proposals. im: rgb image, bbs: output of EdgeBox proposals (sored by 
    % objectiveness score), m: m top objectiveness score are selected (suggest: 100), flag: 1 for L1 distance, 2 for L2 distance. 
    function Sal=Saliency(SaliencyMap, bbs, m)
       Num=size(bbs,1);
       if m<Num
            Num=m;
       end
       Sal=zeros(Num,1); 
       for i=1:Num
            box_i=bbs(i,1:4);
            %objectiveness=bbs(i,5);
            %Sal(i)=objectiveness+Proposal.MeanSaliency(SaliencyMap, box_i);
            Sal(i)=Proposal.MeanSaliency(SaliencyMap, box_i);
            if Sal(i)<0.05
                Sal(i)=0;
            end
       end
    end
    %---------------------------------------------------------------------------
    % given cluster map, saliency map and potential K co-instance boxes, find main clusters in the co-instance boxes   
    % output the weight of each cluster as co-instance
    function [weight,object_map]=ClusterCoInstanceWeightWithSaliencyMap(cluster_map, co_boxes, saliency_map, GoodBox)
       object_map= im2bw(saliency_map,0.2);              
       Num=size(co_boxes,1); 
       map=cluster_map.*object_map;
       combine=[];
       for i=1:Num
           box=co_boxes(i,1:4);
           x=box(1); y=box(2); w=box(3); h=box(4);
           crop_map=map(y:y+h,x:x+w);
           combine=[combine;crop_map(:)];
       end
       t=tabulate(combine); % [Value, Count, Percent]
       K=max(cluster_map(:));
       weight=zeros(K,1);
       for i=1:size(t,1)
           k=t(i,1);
           if k~=0  % cluster id 0 is added by seg, it is no needed since cluster id is like 1,2,3, ...
             weight(k)=t(i,3)/100;
           end
       end
%       weight(weight<0.5*mean(weight))=0;
       
%        if GoodBox==1
%            %weight(weight<0.5*mean(weight))=0;
%            m_w=mean(weight);
%            for h=1:length(weight)
%                if weight(h)<m_w
%                    weight(h)=0;
%                end
%            end
%        else
%            %weight(weight>0.5*mean(weight))=0;
%        end
        if sum(weight)==0
            weight= (1/length(weight))*ones(length(weight),1);
        else
            weight= Gauss_normal(weight);            
        end        
    end
    %---------------------------------------------------------------------------
    function weight=ClusterCoInstanceWeight(cluster_map, co_boxes)
       Num=size(co_boxes,1);         
       combine=[];
       for i=1:Num
           box=co_boxes(i,1:4);
           x=box(1); y=box(2); w=box(3); h=box(4);
           crop_map=cluster_map(y:y+h,x:x+w);
           combine=[combine;crop_map(:)];
       end
       t=tabulate(combine); % [Value, Count, Percent]
       K=max(cluster_map(:));
       weight=zeros(K,1);
       for i=1:size(t,1)
           k=t(i,1);
           if k~=0  % cluster id is like 1,2,3, ...
             weight(k)=t(i,3)/100;
           end
       end
       %weight(weight<mean(weight))=0;
       %weight= Gauss_normal(weight);       
    end
    %---------------------------------------------------------------------------
    function weight=ClusterCoInstanceWeightBadBox(cluster_map, bad_box)
       Num=size(bad_box,1);         
       combine=[];
       for i=1:Num
           box=bad_box(i,1:4);
           x=box(1); y=box(2); w=box(3); h=box(4);
           crop_map=cluster_map(y:y+h,x:x+w);
           combine=[combine;crop_map(:)];
       end
       t=tabulate(combine); % [Value, Count, Percent]
       K=max(cluster_map(:));
       weight=ones(K,1);
       for i=1:size(t,1)
           k=t(i,1);
           if k~=0  % cluster id is like 1,2,3, ...
             weight(k)=t(i,3)/100;
           end
       end
       weight(weight>0.2)=0;
       %weight= Gauss_normal(weight);       
    end
    %---------------------------------------------------------------------------
    %---------------------------------------------------------------------------
    function weight=ClusterCoInstanceWeightGoodBox(cluster_map, good_box)
       Num=size(good_box,1);         
       combine=[];
       for i=1:Num
           box=good_box(i,1:4);
           x=box(1); y=box(2); w=box(3); h=box(4);
           crop_map=cluster_map(y:y+h,x:x+w);
           combine=[combine;crop_map(:)];
       end
       t=tabulate(combine); % [Value, Count, Percent]
       K=max(cluster_map(:));
       weight=ones(K,1);
       for i=1:size(t,1)
           k=t(i,1);
           if k~=0  % cluster id is like 1,2,3, ...
             weight(k)=t(i,3)/100;
           end
       end
       weight(weight<0.2)=0;
       %weight= Gauss_normal(weight);       
    end
    %---------------------------------------------------------------------------
  end
end