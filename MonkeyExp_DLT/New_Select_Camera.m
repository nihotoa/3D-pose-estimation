function [useCam,usecam_all_contents_sel,P] = New_Select_Camera(setting, likelihood)

% Setting parameter
    PNum = setting.PNum;  CNum = setting.CNum;
    P = 1:PNum;
  %% code section
    for ii = 1:PNum
          for jj = 1:CNum
              eval(['point_' num2str(ii) '{1,' num2str(jj) '} = likelihood(:,' num2str(ii+4*(jj-1)) ');']);
          end
          eval(['point_' num2str(ii) '= cell2mat(point_' num2str(ii) ');'])
          for kk = 1:length(likelihood)
              %↓カメラの選択方法を改良するためには、ここをいじる必要がある
              [~,use_cam] = maxk(eval(['point_' num2str(ii) '(kk,:)']),2);
              use_cam = sort(use_cam);
              eval(['point_' num2str(ii) '_use_cam{' num2str(kk) ',1} = use_cam;'])
          end
          eval(['point_' num2str(ii) '_use_cam = cell2mat(point_' num2str(ii) '_use_cam);'])
          eval(['useCam.point' num2str(ii) ' = point_' num2str(ii) '_use_cam;'])
          usecam_temp{1,ii} = eval(['point_' num2str(ii) '_use_cam;']);
    end
    usecam_all_contents_sel = cell2mat(usecam_temp);
end

