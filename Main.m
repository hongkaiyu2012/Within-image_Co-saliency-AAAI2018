clear all;
close all;
warning off;
clc;
AddPath;
%% Four-step computation for our AAAI 2018 paper
% 1. prepare EdgeBox proposals
PrepareProposals;
% 2. find common proposals
CommonInstanceSearch;
% 3. generate 10 saliency maps for each image in folder 'Debug_output'
CoInstance_ContrastSaliency_prepare;
% 4. low rank fusion: generate maps in folder 'output' with name '_CDS' for our method and run low rank based fusion on 10 maps to generate 1 map for each image
CoInstanceContrastCue_lowrank_fusion;
