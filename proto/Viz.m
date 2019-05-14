classdef Viz
  methods(Static=true)
    %---------------------------------------------------------------------------
    function SetCurrentFig(fig)
      set(0, 'currentfigure', fig);
    end
    %---------------------------------------------------------------------------
    function SetFigSize(fig, im, r)
      if(nargin ~= 3)
        r = 200;
      end
      set(fig, 'PaperPosition', [0,0,size(im,2), size(im,1)]/r);
    end
    %---------------------------------------------------------------------------
    function SaveFig(fig, fileName, r)
      if(nargin ~= 3)
        r = 200;
      end
      print(fig, fileName, '-dtiff', sprintf('-r%d',r));
    end
    %---------------------------------------------------------------------------
    function ShowImage(fig, im)
      Viz.SetCurrentFig(fig);
      imshow(im, 'InitialMagnification', 'fit', 'Border', 'tight');
    end
    %---------------------------------------------------------------------------
    function fig = Init(im)
      fig = figure('visible', 'off');
      Viz.SetFigSize(fig, im);
      Viz.ShowImage(fig, im);
    end
    %---------------------------------------------------------------------------
    function DrawText(fig, x, y, str, c, box)
      Viz.SetCurrentFig(fig);      
      if(box == true)
        text(x-8, y, str, 'Color', c, 'FontSize', 10, 'FontWeight', 'bold',...
          'EdgeColor', c, 'LineWidth', 2);
      else
        text(x-8, y, str, 'Color', c, 'FontSize', 10, 'FontWeight', 'bold');
      end
    end
    %---------------------------------------------------------------------------
    function DrawPoints(fig, points, flag)
      Viz.SetCurrentFig(fig);
      hold on;
      if flag==1
        plot(points(:,1),points(:,2),'b*');
      elseif flag==2
        plot(points(:,1),points(:,2),'go');  
      end
      hold off;
    end
    %---------------------------------------------------------------------------
    % Draw an ellipse on current figure.
    %   c: color string or a RGB vector.
    function DrawEllipse(fig, ellipse, c)
      if(nargin == 2)
        c = 'r';
      end
      Viz.SetCurrentFig(fig);
      for i = 1 : size(ellipse, 1)
        o = Detect.EllipseStruct(ellipse(i,:));
        plot_ellipse(o.major, o.minor, o.r, o.x, o.y, c);
      end
    end
    %---------------------------------------------------------------------------
    % Visualize a set of 2D points. If providing their grouping indices,
    % colors are utilized to distinguish them.
    function DrawCluster(points, idx)
      if(~exist('idx', 'var') || isempty(idx))
        idx = ones(size(points,1), 1);
      end
      cluster = sort(unique(idx));
      % Cluster colors.
      color = hsv(length(cluster));
      figure; hold on;
      axis ij; % Change origin to top left.
      %axis off;
      % Draw points for each cluster.
      for i = 1 : length(cluster)
        scatter(points(idx == cluster(i), 1), points(idx == cluster(i), 2),...
          [], color(i,:));
      end
    end
    %---------------------------------------------------------------------------
    % Visualize 2D point matching results. Matched points are connected with a
    % dash line; Unmatched points are visualized as special symbols.
    function fig = DrawMatch(from, to, from_unmatched, to_unmatched, fig)
      assert(size(from,1) == size(to,1));
      
      if(~exist('fig', 'var'))
        fig = figure;
      else
        Viz.SetCurrentFig(fig);
      end
      hold on;
      axis ij;
      %axis off;
      
      s = 72;
      scatter(from(:,1), from(:,2), s, 'k', 's');
      if(exist('from_unmatched', 'var') && ~isempty(from_unmatched))
        scatter(from_unmatched(:,1), from_unmatched(:,2), s, 'k', 'p');
      end
      scatter(to(:,1), to(:,2), s, 'r');
      if(exist('to_unmatched', 'var') && ~isempty(to_unmatched))
        scatter(to_unmatched(:,1), to_unmatched(:,2), s, 'r', 'p');
      end
      for i = 1 : size(from,1)
        plot([from(i,1); to(i,1)], [from(i,2); to(i,2)], '--b');
      end
    end
    %---------------------------------------------------------------------------
    % Given an tracker/detection association, visualize it by showing matched
    % point pairs.
    function DrawAssocation(tracker, detect, z, fig)
      [tracker_matched, detect_matched,...
        tracker_unmatched, detect_unmatched] = Track.AssociatedPoint(tracker, detect, z);
      if(~exist('fig', 'var'))
        fig = figure;
      end
      Viz.DrawMatch(tracker_matched, detect_matched,...
        tracker_unmatched, detect_unmatched, fig);
    end
    %---------------------------------------------------------------------------
	%---------------------------------------------------------------------------
    % get distance of matching pairs
    function match_distance=MatchDistance(tracker, detect, z)
      [tracker_matched, detect_matched,...
        tracker_unmatched, detect_unmatched] = Track.AssociatedPoint(tracker, detect, z);
      from=tracker_matched;
      to=detect_matched;
      match_distance=[];
      for i = 1 : size(from,1)
         match_distance=[match_distance, norm([from(i,1)-to(i,1), from(i,2)-to(i,2)],2)];
      end 
    end
    %---------------------------------------------------------------------------
    % get distance of matching pairs
    function DrawHist(Data, x_label, y_label, binNum, fig)
      if(~exist('fig', 'var'))
        fig = figure;
      end
      hist(Data,binNum);
      xlabel(x_label);
      ylabel(y_label);
    end
    %---------------------------------------------------------------------------
    % draw prediction and detection together
    function DrawPredictionDetection(tracker, detect, fig)
      predict = Track.LocationFromState( Track.ExtractState(tracker) );
      
      if(~exist('fig', 'var'))
        fig = figure;
      else
        Viz.SetCurrentFig(fig);
      end
      hold on;
      axis ij;
      %axis off;
      
      s = 72;
      scatter(predict(:,1), predict(:,2), s, 'k', 's');
      scatter(detect(:,1), detect(:,2), s, 'r');
    end
    %---------------------------------------------------------------------------
     function DrawTwoGroupPoints(fig, Hyp, gt_one)
      if(~exist('fig', 'var'))
        fig = figure;
      else
        Viz.SetCurrentFig(fig);
      end      
      plot(Hyp(:,1),Hyp(:,2),'r+');
      hold on;
      plot(gt_one(:,1),gt_one(:,2),'go');
      hold off;
      axis ij;
    end
    %---------------------------------------------------------------------------
    function DrawBox(fig, boxes)       
      Viz.SetCurrentFig(fig);
          % many boxes, format: [x, y, w, h], only draw top 5 pair
%           L=10;
%           if size(boxes,1)<10
%               L=size(boxes,1);
%           end
          for i=1:size(boxes,1)
              if i==1||i==2
                   color='r';
              end
              if i==3||i==4
                  color='g';
              end
              if i==5||i==6
                  color='b';
              end
              if i==7||i==8
                  color='m'; % magenta                  
              end
              if i==9||i==10
                  color='k'; % black
              end
              if i>10
                  break;
              end
%               if i==11||i==12
%                   color='y';  %yellow
%               end
%               if i==13||i==14
%                   color='w';  % white
%               end
%               if i==15||i==16
%                   color='c';  %cyan
%               end
%               if i==17||i==18
%                   color=[0.5,0.5,0.5]; 
%               end
%               if i==19||i==20
%                   color=[0,0.7,0.5]; 
%               end              
              b=boxes(i,:);              
              rectangle('Position', [b(1),b(2),b(3),b(4)],'LineWidth', 2, 'EdgeColor', color);
              hold on;
          end
          hold off;
    end
    %---------------------------------------------------------------------------
  end
end