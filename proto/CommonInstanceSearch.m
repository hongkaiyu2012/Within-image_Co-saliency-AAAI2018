clear all; %clc; 
close all;
path_images='images/';
im_type='jpg';
JPGFile=dir([path_images,'*.',im_type]);
ImageNum=size(JPGFile,1);
method=2; % 1: combined similarity then find biggest similarity as proposals; 2: cvx optimization for proposal selection

for i=1:ImageNum
    %% input
    fprintf('Find common proposals for image %d \n', i);
    [pathstr,name,ext] =fileparts(JPGFile(i).name);   
    I=imread([path_images name '.jpg']);
    P=load(['proposals/' name '_filtered.mat']);
    bbs=P.bbs;
    saliencyMap=imread(['single-saliency-map/dcl/' name '_DCL.png']);
    saliencyMap = double(saliencyMap);
    saliencyMap=(saliencyMap-min(saliencyMap(:)))/(max(saliencyMap(:))-min(saliencyMap(:))+eps);
    %% prepare the saliency and similarity matrix for proposals
    m=100; % m top scored proposals
    Sal=Proposal.Saliency(saliencyMap, bbs, m);
    [S_combined,~]=Proposal.CombinedSimilarity(I, bbs, m, Sal, 2); % L2 distance 
    %tic
    [S,~]=Proposal.Similarity(I, bbs, m, 2); % L2 distance
    %toc
    %% CVX optimization
    solved_x=[];
    if method==1    
        optimal_boxes=[];
        for b=1:10
            if ~isempty(solved_x)
                b1=solved_x(1);
                b2=solved_x(2);
                S(b1,:)=0;S(:,b1)=0;
                S(b2,:)=0;S(:,b2)=0;
            end
            [index_r,index_c]=find(S==max(S(:)));
            solved_x=[index_r(1),index_c(1)];
            optimal_boxes=[optimal_boxes; bbs(solved_x,:)];
        end
    elseif method==2
        opt.Num=m; % total proposal number
        opt.K=2; % want to select K proposals 
        opt.Type=4; %type of spectral clustering algorithm
        opt.lamda_lap=1; % weight for x'*L*x , spectral term
        opt.lamda_sal=0.01; % weight for -x'*log(saliency), saliency term        
        opt.Sal=Sal;% saliency value;
        optimal_boxes=[];
        id=0;
        for b=1:20
            if ~isempty(solved_x)
                b1=solved_x(1);
                b2=solved_x(2);
                S(b1,:)=0;S(:,b1)=0;
                S(b2,:)=0;S(:,b2)=0;
                S_combined(b1,:)=0;S_combined(:,b1)=0;
                S_combined(b2,:)=0;S_combined(:,b2)=0;
            end
            opt.S=S; % similarity matrix
            try 
                solved_x=CVX_Solver(opt);
            catch
                continue;
            end
            %S(solved_x(1),solved_x(2))
            if S(solved_x(1),solved_x(2))>1
                optimal_boxes=[optimal_boxes; bbs(solved_x,:)];
            else
                max(S_combined(:))
                [index_r,index_c]=find(S_combined==max(S_combined(:)));
                solved_x=[index_r(1),index_c(1)];
                optimal_boxes=[optimal_boxes; bbs(solved_x,:)];
            end
            id=id+1;
            if id==10
                break;
            end
        end
    end
    %% draw the results
    save(['output_common_box/' name '_optimal_boxes.mat'], 'optimal_boxes', '-mat');       
    %Proposal.DrawProposal(I, optimal_boxes, ['output_common_box/' name '_common.tif']);
end