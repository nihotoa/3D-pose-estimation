%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Coded by: Naohito Ota
Last Modificatin: 2023.03.23

DLT法を用いて、３次元座標を導出するプログラム
詳細な使い方は松木さんのくれたテクストファイルの中に書いてある
【function】
DLT法により，3次元座標を計算する
【procedure】
・pre: a lot of things (GetSuccessMovie.m & MoveFold.m & analysis result of DeepLabCut ) 
・post: nothing?

【caution!!】:
・DLC_csvfileの中にDeeplabcutのcsvファイルを全て保存しておく(現状のプログラムだとこのフォルダ内には1日分のCSVファイルしか入っていない前提で話が進んでいる)
・結果はDLT_resultの中に保存される

【やること】
・calibrationのcsvファイルをこのディレクトリ直下のcalibrationフォルダに移すためのプログラムを書く．

【必要な情報】
・キャリブレーションの結果(csvファイル)
・deeplabcutの結果(DLC_csvファイルの中に保存)
・

【改善点】
101行目のif文の数値(likelyhood)の値を変更する(事前に変数で規定しておくように改善する)
全ての座標で軸を統一するように、ylimをつける
10回ずつ分けて重ねるような図を作る(10のところは、変数で変えられるようにする)
ALIGNのコードに必要なため,各タスクの、再構成した3次元座標を配列にまとめて.matファイルに保存する
DLT_resultフォルダの中に、もうひと階層(日付のフォルダ)を追加し、そこにデータを保存するように変更する
おそらくpoint4個の時しか対応していないので，汎用性を高める(judge == 1の時の中身を見て，そう感じた)
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Set param
  %cam_select_setting = 1; %0がデフォルト、1が改変後のカメラ選択の設定
  projectFolder = pwd; %MonkeyExp_DLTのパス(自分のパソとMacで解析するときでパスが異なることに注意)
  setting.PNum = 4; %マーカーの数
  setting.CNum = 4; %カメラの数
  setting.P_cal = 8; %チェックポイントの数
  criterion = 0.9; %judge = 1の時に使用する域値 
  norm_cri = 30;%judge = 1の時に使用する。前フレームとの距離(ノルム)の閾値設定 
  individual_plot = 0; %個々のタスクの結果を出力するかどうか
  stack_plot = 1; %まとめたタスクの結果を出力するかどうか
  date = '220520'; %日付
  setting.judge = 1;  
  output_useCam = 1;
  judge = setting.judge;
  setting.header = {'thumb1 X', 'thumb1 Y', 'thumb1 Z', ...
                    'index1 X', 'index1 Y', 'index1 Z', ...
                    'index2 X', 'index2 Y', 'index2 Z', ...
                    'index3 X', 'index3 Y', 'index3 Z'}; %csvファイルのヘッダー(結果の保存(outputMatrix)に使用する)
  %% code section
  setting.saveFolder = strcat(projectFolder, '/DLT_result/'); %mac,windowsで変更が必要
  saveFolder = setting.saveFolder;
  % Get calibration information
  calfileName = strcat('P_image_Monkey_', date, '.csv'); %calibration
  cd(['calibration/' num2str(date)]);
  P_image = csvread(calfileName, 2, 1);%(3,2)が(1,1)になるようにオフセット
  P_world = csvread('P_world_Monkey.csv', 1, 1);
  %assignin('base', 'P_image', P_image); %assing P_imgage to P_image (I dont know why this is neccesary)
  %assignin('base', 'P_world', P_world);
  cd ../../

  % Estimation camera parameter
  CamParam = Get_CamParam(P_world, P_image, setting); %function which generate CamereaParameter
  %assignin('base', 'CamParam', CamParam);

  PNum = setting.PNum;  CNum = setting.CNum;
  %{
  f_start = setting.f_start; f_end = setting.f_end;
  f1 = setting.f1; f2 = setting.f2;
  %}
  
  % Get list of csv files
  folderName = strcat(projectFolder, '/DLC_csvfile/', num2str(date));%カレントディレクトリのパスに'\DLC_csvfile'を連結したものをfoulderNameに代入
  datalist  =  dir([folderName, '/cam*.csv']); %./ファイルがあるとエラー吐くから注意(./ファイル対策で接頭語camを使用している)
  datalist  =  {datalist.name}.';
  TrNum     = length(datalist) / CNum; % タスクの試行回数(csvファイルの数/カメラの数)
  %assignin('base', 'TrNum', TrNum);
  %useCam_all = cell(PNum * TrNum, CNum + 1);
  %{
  if cam_select_setting == 0

  elseif cam_select_setting == 1

  end
 %}
  for(j = 1 : TrNum)
    if j~=1
        clear imagePos;
        clear likelihood;
    end
    % Get experiment date and rat name(元のCSVファイルの6~13文字までを代入(6~13文字がちょうどトライアルの名前のとこに匹敵する))
    %setting.exp_info{j, 1} = extractBefore(datalist{(j - 1) * CNum + 1}, 17);%datalistの13文字目までを代入
    %setting.exp_info{j, 1} = extractAfter(setting.exp_info{j, 1}, 8); %setting.exp_info{j, 1}の6文字目以降を代入
    setting.exp_info{j, 1} = extractBefore(datalist{j}, 17);%datalistの13文字目までを代入
    setting.exp_info{j, 1} = extractAfter(setting.exp_info{j, 1}, 8); %setting.exp_info{j, 1}の6文字目以降を代入
    disp(setting.exp_info{j, 1});

    % Read csv file of 2D coordinates position on image(._ファイル等が生成されてエラー吐くことがあるから注意する)
    for(n = 1 : CNum)
          disp(datalist{j + TrNum * (n - 1)});
          cd(['DLC_csvfile/' num2str(date)]);
          temp = csvread(datalist{j + TrNum * (n - 1)}, 3, 1);%J:何タスク目か, TRNUM : タスクの総数 N:カメラの番号　(例：全て1ならカメラ１からのタスク1のcsvファイルを読み込む)
          cd ../../
          f_start = 1; f_end = length(temp);
          if n ~= 1
              if f_end <length(imagePos) 
                  imagePos = imagePos(1:f_end,:);
                  likelihood = likelihood(1:f_end,:); 
              else
                  f_end = length(imagePos);
              end
          end
          setting.f_start = f_start; setting.f_end = f_end;

          %imagePos
          for(i = 1 : PNum)
              imagePos(:, 2 * PNum * (n - 1) + 2 * i - 1)  = temp(f_start : f_end , 3 * i - 2); % x position(image coordination)
              imagePos(:, 2 * PNum * (n - 1) + 2 * i)      = temp(f_start : f_end , 3 * i - 1); % y position(image coordination)
              likelihood(:, PNum * (n - 1) + i)            = temp(f_start : f_end , 3 * i);
          end
    end
    [setting.useCam,setting.usecam_all_contents_sel,setting.P] = New_Select_Camera(setting, likelihood);
    useCam = setting.useCam;
    usecam_all_contents_sel = setting.usecam_all_contents_sel;
    usecam_all_contents{1,j} = usecam_all_contents_sel;
    %{
    for(n = 1 : CNum)
      for(i = 1 : PNum)
        useCam_all(i + PNum * (j - 1), 1) = cellstr(strcat(setting.exp_info{j, 1}, '_P', num2str(i)));
        useCam_all(i + PNum * (j - 1), n + 1) = num2cell(useCam(i, n));
      end
    end
    %}

    % 3D coordinates reconstruction
    worldPos = zeros([f_end 3 * PNum]);
    worldPos_temp = zeros([f_end 3 * PNum]);
    %↓マーカーごとに三次元座標変換してwordlPosに代入
    for(i = 1 : length(setting.P))
      worldPos_temp = Get_worldPos(i, imagePos, CamParam, setting);
      worldPos = worldPos + worldPos_temp;
    end
    
    if judge == 1
        for ii = 1:PNum
            for jj = 1:length(likelihood)
                selected_cam = eval(['useCam.point' num2str(ii) '(' num2str(jj) ',:)']);
                %{
                if likelihood(jj,ii+4*(selected_cam(1,1)-1))>0.9 && likelihood(jj,ii+4*(selected_cam(1,2)-1))>0.9

                else
                    worldPos(jj,(ii*3)-2) = 0/0; %0/0だとNaNが出力される
                    worldPos(jj,(ii*3)-1) = 0/0; 
                    worldPos(jj,(ii*3)) = 0/0; 
                end
                %}
                
                if jj == 1
                    if likelihood(jj,ii+4*(selected_cam(1,1)-1))>criterion && likelihood(jj,ii+4*(selected_cam(1,2)-1))>criterion
                        
                    else
                        worldPos(jj,(ii*3)-2) = 0/0; %0/0だとNaNが出力される
                        worldPos(jj,(ii*3)-1) = 0/0; 
                        worldPos(jj,(ii*3)) = 0/0; 
                    end
                else
                    if isnan(worldPos(jj-1,(ii*3)-2:ii*3))
                        if likelihood(jj,ii+4*(selected_cam(1,1)-1))>criterion && likelihood(jj,ii+4*(selected_cam(1,2)-1))>criterion
                        
                        else
                            worldPos(jj,(ii*3)-2) = 0/0; %0/0だとNaNが出力される
                            worldPos(jj,(ii*3)-1) = 0/0; 
                            worldPos(jj,(ii*3)) = 0/0; 
                        end
                    else
                        if likelihood(jj,ii+4*(selected_cam(1,1)-1))>criterion && likelihood(jj,ii+4*(selected_cam(1,2)-1))>criterion && norm(worldPos(jj,(3*ii)-2:(3*ii))-worldPos(jj-1,(3*ii)-2:(3*ii)))<norm_cri
                   
                        else
                            worldPos(jj,(ii*3)-2) = 0/0; %0/0だとNaNが出力される
                            worldPos(jj,(ii*3)-1) = 0/0; 
                            worldPos(jj,(ii*3)) = 0/0; 
                        end
                        
                    end
                end
            end
        end
    end
    All_output{1,j} = worldPos;
    outputMatrix = {};
    outputMatrix(2 : f_end + 1, :) = num2cell(worldPos(f_start : f_end, :));
    %↓outputMatrixの1行目にヘッダーを挿入する
    for(i = 1 : 3 * PNum)
      outputMatrix{1, i} = setting.header{i};
    end
    %assignin('base', 'outputMatrix', outputMatrix);
    if(judge == 1)
      if j==1
        mkdir([saveFolder 'judgeON/' num2str(date) '/data'])
      end
      filename = strcat(saveFolder, 'judgeON/', num2str(date) ,'/data/', setting.exp_info{j, 1}, '_judgeON.csv');
    elseif(judge == 0)
      if j==1
        mkdir([saveFolder 'judgeOFF/' num2str(date) ,'/data'])
      end
      filename = strcat(saveFolder, 'judgeOFF/', num2str(date) ,'/data/',setting.exp_info{j, 1}, '_judgeOFF.csv');
    end
    
    Mac_user = 1;%macユーザーなら1(厳密にいうと、MATLABのバージョンによってはwritecellが使えないため、それを補填するために下記のコードがある)
    %↓outputMatrixをfilenameでcsvファイルとして保存
    if Mac_user == 1
        a = cell2table(outputMatrix);
        writetable(a,filename,'WriteVariableNames',false);
    else
        writecell(outputMatrix, filename);
    end
    %↑Macの方だとwritecellが使えない(cell配列をcsvファイルに保存したい→一度cell配列をtableに変換してから保存(make.csvを参照))
    %↓結果のプロット、図の保存の関数(関数内で定義される変数str2の変更が必要)
    if individual_plot == 1
        plot_result(j, setting, worldPos,date);
    end
    close all;
  end
  %assignin('base', 'useCam_all', useCam_all);
  if stack_plot == 1
    day_task_pose(All_output,setting,date)
  end
  if(output_useCam == 1)
    if judge == 1
        filename2 = strcat(saveFolder,'judgeON/',date ,'/', date, '_useCam', '.csv');
    elseif judge == 0
        filename2 = strcat(saveFolder,'judgeOFF/',date ,'/', date, '_useCam', '.csv');
    end
    for ii = 1:length(setting.exp_info)
        for jj = 1:length(setting.P)
            useCam_all_header{1,PNum*2*(ii-1)+(2*jj-1)} = cellstr(strcat(setting.exp_info{ii, 1}, '_P', num2str(jj)));
            useCam_all_header{1,PNum*2*(ii-1)+(2*jj)} = '/'; 
        end
    end
    %↓タスクごとにフレーム数が違うので、このままだとcell2matができない。よってNaNを代入して配列のサイズを合わせる   
    %↓一番フレーム数の大きいタスクを探す
    for jj = 1:TrNum
        if jj == 1
            maxframe = length(usecam_all_contents{1,jj});
        elseif length(usecam_all_contents{1,jj}) > maxframe
            maxframe = length(usecam_all_contents{1,jj});
        end
    end
    %maxframeを基にNaNを代入して埋め合わせる
    for ii = 1:TrNum
        if length(usecam_all_contents{1,ii}) < maxframe
            comp_matrix = NaN(maxframe - length(usecam_all_contents{1,ii}),2*PNum);
            usecam_all_contents{1,ii} = [usecam_all_contents{1,ii} ; comp_matrix];
            %↑2*PNumは、使用したカメラ台数(現状のプログラムだと2で固定)と、ラベリングした部位(PNum)
        else
            
        end
    end
        
    c{1,1} = cell2mat(usecam_all_contents);
    [row,col] = size(c{1,1});
    for ii = 1:row
        for jj = 1:col
            contents{ii,jj} = num2cell(c{1,1}(ii,jj));
        end
    end
    useCam_all = [useCam_all_header;contents];
    if Mac_user == 1
        b = cell2table(useCam_all);
        writetable(b,filename2,'WriteVariableNames',false);
    else 
        writecell(useCam_all, filename2);
    end
  end
  %% LEDと位相を合わせるために、各タスクの三次元座標の入った配列(All_output)を.matファイルに保存する
  if judge == 1
       cd(['DLT_result/judgeON/' num2str(date)]);
  elseif judge == 0
       cd(['DLT_result/judgeOFF/' num2str(date)]);
  end
  save('task_3D_coodinate.mat','All_output')
  close all;
