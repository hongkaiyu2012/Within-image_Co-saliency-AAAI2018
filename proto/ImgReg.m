classdef ImgReg
  methods(Static=true)
    %---------------------------------------------------------------------------
    % Find translation matrix from 'src' to 'dst'.
    %   x, y, w, h: defines cropped area in dst.
    function [T, patch] = Translate(src, dst, x, y, w, h)
      patch = dst(y:y+h-1, x:x+w-1);
      % Search matched patch in src.
      nxc = normxcorr2(patch, src);
      % Find highest correlation point in src: (inxc,inxr)
      [maxc,inxr] = max(nxc);
      [~,inxc] = max(maxc);
      inxr = inxr(inxc);
      % The highest correlation point should be the center of the
      % bounding box, but the image has been enlarged. So we need to
      % substract 2*(w/2) = w.
      px = inxc - w;
      py = inxr - h;
      % Translation matrix map points from src to dst.
      T = [
        1,0,0;
        0,1,0;
        x-px,y-py,1];
    end
    %---------------------------------------------------------------------------
    % Translate a set of images into the same plane. If an image is empty we use
    % its neighbor's translation matrix instead.
    %   T: a cell array contains translate matrices for each image.
    function T = TranslateImageSet(buff, x, y, w, h)
      T = cell(length(buff), 1);
      for i = 1 : length(buff) - 1
        src = buff{i};
        % If src is invalid, we use an identity matrix.
        if(isempty(src))
          T{i} = eye(3);
          continue;
        end
        
        dst = buff{i+1};
        % If dst is invalid, we find next valid image.
        if(isempty(dst))
          j = i + 1;
          while(j <= length(buff) && isempty(buff{j}))
            j = j + 1;
          end
          dst = buff{j};
          clear j;
        end
        
        T{i} = ImgReg.Translate(src, dst, x, y, w, h);
      end
      
      %TODO Smooth noisy T.
%       for i = (1+1) : (length(buff)-1-1)
%         if(norm(T{i}-T{i-1},2) > 500 && norm(T{i}-T{i+1},2) > 500)
%           T{i} = eye(3);
%         end
%       end
      
      % The last image plane is the target translation plane for all images in
      % the sequence. In order to prevent out-of-boundary image movement, we
      % enlarge the image plane by 2, and align the last image to the center of
      % new plane.
      T{end} = [
        1, 0, 0;
        0, 1, 0;
        size(buff{end}, 2) / 2, size(buff{end}, 1) / 2, 1];           
      
      % Stack all pairwise translation matrices.
      for i = 1 : length(T)
        for j = i + 1 : length(T)
          T{i} = T{i} * T{j};
        end
      end
    end
    %---------------------------------------------------------------------------
    function [tx, ty] = RegisterPoint(x, y, T)
      assert(size(T,1) == 3);
      out = [x,y,1] * T;
      tx = out(1);
      ty = out(2);
    end
    %---------------------------------------------------------------------------
    function out = RegisterPoints(buff, T)
      out = [buff(:,1:2), repmat(1, size(buff,1), 1)] * T;
      out = out(:, 1:2);
    end
    %---------------------------------------------------------------------------
    function out = RegisterImage(im, T)
      tform = maketform('affine', T);
      % In order to prevent out-of-boundary translation, we enlarge the original
      % image plane by factor of 2. Also see above code for T calculation.
      out = imtransform(im, tform,...
        'XData', [1, size(im,2) * 2], 'YData', [1, size(im,1) * 2]);
    end
    %---------------------------------------------------------------------------
    % Data specific functions.
    %---------------------------------------------------------------------------
    function T = FiberImageTranslate(dataDir, imList, outName)
      buff = IO.LoadImageSet(dataDir, imList);
      T = ImgReg.TranslateImageSet(buff, 300, 200, 300, 400);
      if(exist('outName', 'var'))
        save(outName, 'T', '-mat');
      end
    end
    %---------------------------------------------------------------------------
    function FiberPointRegister(dataDir, ptList, T, outDir)
      list = IO.filelist(ptList);
      buff = cell(length(list), 1);
      for i = 1 : length(list)
        if(~IO.emptyfile(fullfile(dataDir, list{i})))          
          buff{i} = dlmread(fullfile(dataDir, list{i}), '\t');
          % If there is other data associated with points, preserve them.
          if(size(buff{i}, 2) > 2)
            data = buff{i}(:, 3:end);
          end
          point = ImgReg.RegisterPoints(buff{i}(:, 1:2), T{i});
          buff{i} = [point, data];
        end
        dlmwrite(fullfile(outDir, IO.filename(list{i})), buff{i},...
          'delimiter', '\t', 'newline', 'unix');
      end
    end
    %---------------------------------------------------------------------------
    function FiberImageRegister(dataDir, imList, T, outDir)
      list = IO.filelist(imList);
      buff = IO.LoadImageSet(dataDir, imList);
      assert(length(buff) == length(T));
      for i = 1 : length(buff)
        if(isempty(buff{i}))
          continue;
        end
        buff{i} = ImgReg.RegisterImage(buff{i}, T{i});
        imwrite(buff{i}, fullfile(outDir, IO.filename(list{i})));
      end
    end
    %---------------------------------------------------------------------------
    % Normalized Cross-Correlation between two RGB images(first: small template, second: equal or big size image)
    %   max_c: maximum Normalized Cross-Correlation value, peak: point of
    %   maximum Normalized Cross-Correlation
    function s = NormCrossCorr(img1, img2)        
        s=0;
        for i=1:3
            im1=img1(:,:,i);
            im2=img2(:,:,i);
            c = normxcorr2(im1,im2);
            [max_c, imax] = max(abs(c(:)));
            if max_c>s
                s=max_c;
            end
           % s=s+max_c;
        end
        %s=s/3;        
%         [ypeak, xpeak] = ind2sub(size(c),imax(1));
%         corr_offset = [(xpeak-size(img1,2))
%                (ypeak-size(img1,1))];
%         peak.xoffset = corr_offset(1);
%         peak.yoffset = corr_offset(2);
    end
    %---------------------------------------------------------------------------
        
    
    
    
    
    
    
    
    
    
    
    
  end
end