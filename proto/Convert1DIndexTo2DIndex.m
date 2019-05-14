function [row,col]=Convert1DIndexTo2DIndex(index,sizeh,sizew)
%%%%%%%%input: index:1D index; sizeh: row; sizew:col
%%%%%%%%output: row,col: row and col in 2D matrix(sizeh*sizew) 
%%%%%%%% function: convert 1D index to row and col index in 2D matrix
%%%%%%%% using example: [row,col]=convertMatlabsq2Csq(602,300,200)
%%%%%%%% row=2, col=3

col=floor(index/sizeh);
 if col<index/sizeh 
    col=col+1;
 end

row=index-sizeh*(col-1);
 if col==1
    row=index;
 end
 if row==0
    row=sizeh;
 end