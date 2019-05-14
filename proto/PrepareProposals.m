clear all;
clc;
close all;
path_images='images/';
im_type='jpg';
JPGFile=dir([path_images,'*.',im_type]);
ImageNum=size(JPGFile,1);
for i=1:ImageNum    
    bbs=[];
    I=imread([path_images,JPGFile(i).name]);    
    
    [pathstr,name,ext] =fileparts(JPGFile(i).name);
    tic
    if ~exist(['proposals/' name '_filtered.mat'])
        fprintf('Extract proposals for image %d \n', i);
        bbs=EdgeBoxWrapper(I);  
        save(['proposals/' name '.mat'], 'bbs', '-mat');
        bbs=Proposal.RmoveSmall(I, bbs, 0.01);
        bbs=Proposal.RmoveBig(I, bbs, 0.25);
        save(['proposals/' name '_filtered.mat'], 'bbs', '-mat');
    end
    I=imread(['single-saliency-map/dcl/', name, '_DCL.png']);
    I=double(I)/255.0;
    load(['proposals/' name '_filtered.mat']);    
    Sal=Proposal.Saliency(I, bbs, 300);
    save(['proposals_saliency/Sal_' name '_dcl.mat'], 'Sal', '-mat');
    toc
end
  