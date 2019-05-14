classdef Utility
  % saliency cue calculation
  methods(Static=true)
    %---------------------------------------------------------------------------
    %e.g.: FileName=Utility.ChangeNames_String2Number('images-noise/', 'jpg', 'images-numbers/', 'jpg');
    function FileName=ChangeNames_String2Number(input_path, im_type1, output_path, im_type2)
        JPGFile=dir([input_path,'*.',im_type1]);
        ImageNum=size(JPGFile,1);
        FileName=[];
        for i=1:ImageNum
                i
                [pathstr,name,ext] =fileparts(JPGFile(i).name);
                file_path=[input_path name '.' im_type1];
                im=imread(file_path);
                imwrite(im,[output_path num2str(i) '.' im_type2]);
                FileName{i}=name;
        end        
    end
    %------------------------------------------------------------------------------ 
    % Utility.ChangeNames_Number2String(100, 'MCDL_CVPR2015_Zhao_output_number/', 'png','_mc', 'MCDL_CVPR2015_Zhao_output/', 'png', '_mc',FileName);
    function ChangeNames_Number2String(ImageNum, input_path, im_type1, extent1, output_path, im_type2, extent2, FileName)
        JPGFile=dir([input_path,'*.',im_type1]);
        for i=1:ImageNum
                i
                file_path=[input_path num2str(i) extent1 '.' im_type1];
                im=imread(file_path);           
                imwrite(im,[output_path FileName{i} extent2 '.' im_type2]);
        end        
    end
    %---------------------------------------------------------------------------
  end
end