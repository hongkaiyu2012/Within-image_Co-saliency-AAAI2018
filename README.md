This is a software package for Within-image Co-Saliency Detection.
  
version: 1.0
data: 05/14/2019

1. COPYRIGHT
Copyright (c) Hongkai Yu, Computer Vision Lab at University of South Carolina, Columbia, SC, USA. 
All rights reserved. E-mail for questions or bugs: hongkaiyu2012@gmail.com 

This software package can ONLY be used for Academic purposes. Do not use this software package for Commercial or Non-academic usages. If you think this work is helpful, please cite our paper:

Hongkai Yu, Kang Zheng, Jianwu Fang, Hao Guo, Wei Feng, and Song Wang. Co-Saliency Detection within a Single Image. AAAI Conference on Artificial Intelligence (AAAI), New Orleans, LA, 2018.

2. USAGE INSTRUCTIONS 
Requirement: Matlab R2014 or later version on Windows or Linux system.

2.1 Install CVX convex optimization package for Matlab [http://cvxr.com/cvx/] 
2.2 Prepare initial saliency maps by DCL method [Deep Contrast Learning for Salient Object Detection, CVPR2016] and put it in ./single-saliency-map/dcl
2.3 You could also use initial saliency maps by other deep learning based methods instead of DCL. 
2.4 Run Main.m for demo.

It will generate results in './output' for each image in './images'. 

3. To evaluate your saliency map, you may try our benchmark evaluation code at: https://faculty.utrgv.edu/hongkai.yu/AAAI2018.html

Note: Our software package includes downloaded Outer packages: EdgeBox code [https://github.com/pdollar/edges] and clustering based saliency code [https://github.com/HzFu/Cosaliency_tip2013] and low rank based image fusion [https://github.com/HzFu/SACS_TIP2014]. 

Thank you!
