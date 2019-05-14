function solved_x=CVX_Solver(opt)

%%%% link: http://www.cnblogs.com/sparkwen/p/3155850.html
%%%% how to construct Laplace matrix: refer to http://www.mathworks.com/matlabcentral/fileexchange/34412-fast-and-efficient-spectral-clustering/content/files/SpectralClustering.m
%%%% how to use Laplace matrix in segmentation: refer to: http://ai.stanford.edu/~ajoulin/article/cvpr14-coloc.pdf and http://ai.stanford.edu/~ajoulin/article/JoulBachPonceCVPR10.pdf

%   'Type' - Defines the type of spectral clustering algorithm
%            that should be used. Choices are:
%      1 - Unnormalized Laplace matrix
%      2 - Normalized Laplace matrix according to Shi and Malik (2000)
%      3 - Normalized Laplace matrix according to Jordan and Weiss (2002)
%      4 - Normalized Laplace matrix according to ajoulin cvpr14 and CVPR10

Num=opt.Num; % total proposal number
K=opt.K; % want to select K proposals 
Type=opt.Type;
lamda_lap=opt.lamda_lap; % weight for x'*L*x , spectral term
lamda_sal=opt.lamda_sal; % weight for -x'*log(saliency), saliency term
S=opt.S; % similarity matrix
Sal=opt.Sal;% saliency value;


Log_Sal=log(Sal+eps);
% calculate degree matrix
degs = sum(S, 2);
D    = sparse(1:size(S, 1), 1:size(S, 2), degs);
L = D - S;% compute unnormalized Laplacian

% compute normalized Laplacian if needed
switch Type
    case 2
        % avoid dividing by zero
        degs(degs == 0) = eps;
        % calculate inverse of D
        D = spdiags(1./degs, 0, size(D, 1), size(D, 2));
        % calculate normalized Laplacian
        L = D * L;
    case 3
        % avoid dividing by zero
        degs(degs == 0) = eps;
        % calculate D^(-1/2)
        D = spdiags(1./(degs.^0.5), 0, size(D, 1), size(D, 2));
        % calculate normalized Laplacian
        L = D * L * D;
    case 4
        % avoid dividing by zero
        degs(degs == 0) = eps;
        % calculate D^(-1/2)
        D = spdiags(1./(degs.^0.5), 0, size(D, 1), size(D, 2));
        % calculate normalized Laplacian
        L = eye(size(S,1),size(S,2)) - (D * S * D); 
end
disp('S is constructed and Optimization begins....');
%% QP solver: 
%%%%%%% convex relax to solve this problem  
cvx_begin
   variable x(Num)
   minimize (lamda_lap*(x'*L*x)+lamda_sal*(-x'*Log_Sal))
   %minimize lamda_lap*(x'*L*x)
   %minimize lamda_sal*(-x'*Log_Sal)
   subject to
        x<=1;
        x>=0;
        sum(x(:)) == K   % K proposals are wanted
cvx_end
%% to get the sparse results
[sort_v, sort_id]=sort(x);
potential_x=sort_id(end-3*K:end); % 2K potentail candidates, then check their similarity
max_similairy=-1;
for i=1:length(potential_x)
    for j=i+1:length(potential_x)
        if S(potential_x(i),potential_x(j))>max_similairy
            max_similairy=S(potential_x(i),potential_x(j));
            final1=potential_x(i);
            final2=potential_x(j);
        end
    end
end
solved_x=[final1,final2];