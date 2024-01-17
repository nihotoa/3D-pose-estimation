function [useCam, P] = Select_Camera(j, setting, likelihood, imagePos,cam_select_setting)
  % Setting parameter
  PNum = setting.PNum;  CNum = setting.CNum;
  f1 = setting.f1; f2 = setting.f2;
  threshold = 0.9;
  f_lose = zeros([PNum CNum]);
  lose = zeros([PNum CNum]);
  useCam = zeros([PNum CNum]);
  visible = zeros([PNum 1]);
  P_temp = zeros([1 PNum]);
  for(i = 1 : PNum)
    P_temp(1, i) = i;
  end

  % Identify frames that have lost marker (likelihood)←各カメラ、各マーカーにおいて、何フレーム失ったかを導出(失うの定義は上のthresholdを調整)
  if cam_select_setting == 0
      for(i = 1 : PNum)
        for(n = 1 : CNum)
          for(f = f1 : f2 - 1)
            u1 = imagePos(f, (2 * PNum * (n - 1)) + ((2 * i) - 1)); v1 = imagePos(f, 2 * PNum * (n - 1) + 2 * i);
            u2 = imagePos(f + 1, 2 * PNum * (n - 1) + 2 * i - 1); v2 = imagePos(f + 1, 2 * PNum * (n - 1) + 2 * i);
            if((likelihood(f, (n - 1) * PNum + i) < threshold) || hypot(u1, v1) - hypot(u2, v2) > 5)
              f_lose(i, n) = f_lose(i, n) + 1;
            end
          end
        end
      end
      assignin('base', 'f_lose', f_lose);

      % Select camera can see marker on all frame
      for(i = 1 : PNum)
        fprintf('\nMarker %d : \n', i);
        for(n = 1 : CNum)
          if(f_lose(i, n) == 0)
            fprintf('Camera %d : visible in all frames \n', n);
            useCam(i, n) = n;
            visible(i) = visible(i) + 1;
          elseif(f_lose(i, n) == f2 - f1 + 1)
            fprintf('Camera %d : not visible in all frames \n', n);
          else
            fprintf('Camera %d : not visible in %d frames \n', n, f_lose(i, n));
          end
        end
      end
      assignin('base', 'visible', visible);

      % Select remaining cameras
      for(i = 1 : PNum)
        if(visible(i) == 1) || (visible(i) == 0)
          fprintf('\nMarker %d : visible 0 or 1 cameras\n', i);
          [X, N] = mink(f_lose(i, :), 2); %f_lose(i,:)の中で,値の低い2つの要素の列番号を出力
          if(f_lose(i, N(1)) ~= f2 - f1 + 1) && (f_lose(i, N(2)) ~= f2 - f1 + 1)
            fprintf('Camera %d and %d use\n', N(1), N(2));
            useCam(i, N(1)) = N(1);
            useCam(i, N(2)) = N(2);
            visible(i) = 2;
          elseif(f_lose(i, N(1)) == f2 - f1 + 1) || (f_lose(i, N(2)) == f2 - f1 + 1)
            fprintf('Marker %d cannot be tracked!\n', i);
            P_temp(1, i) = 0;
          end
        end
      end
      fprintf('\n');

      i2 = 1; P = [];
      for(i = 1 : PNum)
        if(P_temp(1, i) ~= 0)
          P(1, i2) = P_temp(1, i);
          i2 = i2 + 1;
        end
      end
  elseif cam_select_setting == 1
      for ii = 1:PNum
          for jj = 1:CNum
              eval(['point_' num2str(ii) '{1,' num2str(jj) '} = likelihood(:,' num2str(ii+4*(jj-1)) ');']);
          end
          eval(['point_' num2str(ii) '= cell2mat(point_' num2str(ii) ');'])
          for kk = 1:length(likelihood)
              [~,use_cam] = maxk(eval(['point_' num2str(ii) '(kk,:)']),2);
              eval(['point_' num2str(ii) '_use_cam{' num2str(kk) ',1} = use_cam;'])
          end
           eval(['point_' num2str(ii) '_use_cam = cell2mat(point_' num2str(ii) '_use_cam);'])
      end
      
 
          
      
      %{
      for(i = 1 : PNum)
        for(n = 1 : CNum)
          for(f = f1 : f2 - 1)
            u1 = imagePos(f, (2 * PNum * (n - 1)) + ((2 * i) - 1)); v1 = imagePos(f, 2 * PNum * (n - 1) + 2 * i);
            u2 = imagePos(f + 1, 2 * PNum * (n - 1) + 2 * i - 1); v2 = imagePos(f + 1, 2 * PNum * (n - 1) + 2 * i);
            if((likelihood(f, (n - 1) * PNum + i) < threshold) || hypot(u1, v1) - hypot(u2, v2) > 5)
              f_lose(i, n) = f_lose(i, n) + 1;
            end
          end
        end
      end
      assignin('base', 'f_lose', f_lose);

      % Select camera can see marker on all frame
      for(i = 1 : PNum)
        fprintf('\nMarker %d : \n', i);
        for(n = 1 : CNum)
          if(f_lose(i, n) == 0)
            fprintf('Camera %d : visible in all frames \n', n);
            useCam(i, n) = n;
            visible(i) = visible(i) + 1;
          elseif(f_lose(i, n) == f2 - f1 + 1)
            fprintf('Camera %d : not visible in all frames \n', n);
          else
            fprintf('Camera %d : not visible in %d frames \n', n, f_lose(i, n));
          end
        end
      end
      assignin('base', 'visible', visible);

      % Select remaining cameras
      for(i = 1 : PNum)
        if(visible(i) == 1) || (visible(i) == 0)
          fprintf('\nMarker %d : visible 0 or 1 cameras\n', i);
          [X, N] = mink(f_lose(i, :), 2); %f_lose(i,:)の中で,値の低い2つの要素の列番号を出力
          if(f_lose(i, N(1)) ~= f2 - f1 + 1) && (f_lose(i, N(2)) ~= f2 - f1 + 1)
            fprintf('Camera %d and %d use\n', N(1), N(2));
            useCam(i, N(1)) = N(1);
            useCam(i, N(2)) = N(2);
            visible(i) = 2;
          elseif(f_lose(i, N(1)) == f2 - f1 + 1) || (f_lose(i, N(2)) == f2 - f1 + 1)
            fprintf('Marker %d cannot be tracked!\n', i);
            P_temp(1, i) = 0;
          end
        end
      end
      fprintf('\n');

      i2 = 1; P = [];
      for(i = 1 : PNum)
        if(P_temp(1, i) ~= 0)
          P(1, i2) = P_temp(1, i);
          i2 = i2 + 1;
        end
      end
      %}
  end
