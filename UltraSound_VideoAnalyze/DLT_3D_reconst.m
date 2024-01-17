%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
[function]
DLT�@��p���āA�R�������W�𓱏o����v���O����
�ڍׂȎg�����͏��؂���̂��ꂽ�e�N�X�g�t�@�C���̒��ɏ����Ă���

[procedure]
pre: nothing
post: US_3D_traject

[pre preparation]
Save the csv file of the actual coordinates and image coordinates of the calibration frame in 'calibration' folder
(P_image_US~.csv & P_world_US.csv)


���O����:
Calibration�t�H���_�̒��ɃL�����u���[�V�����t���[���̎����W�Ɖ摜���W��csv�t�@�C����ۑ����Ă���
DLC_csvfile�̒���Deeplabcut��csv�t�@�C����S�ĕۑ����Ă���(csv�t�@�C���̓����Ă���t�H���_�̖��O�͕ϐ�data_type�Ƃ��킹��)
63�s�ڂ́Acsv�t�@�C���̐ړ���̎w���Y��Ȃ�
DeepLabCut�œ��悩��csv�t�@�C�����o�͂���O�ɁA����̖��O��ύX����(CSV�t�@�C���̖��O�̕ύX�ƃf�B���N�g���̍쐬���s���֐�������Ă���������)
220000���F�t���ւ��O�̎h���ɑ΂��铮���͌���
�֐������Ƃ�����DLC_csvfile/num2str(date)/data_type�Ƃ����f�B���N�g�����쐬��(�l������data_type�̃f�B���N�g���́A�S�č��)�Anas-model��csv�t�@�C�����Q�Ƃ��Ď����Ă��適�߂�ǂ���������A�蓮�ł���Ă���������
Get_WorldPos�̃J�����p�����[�^a�ƎQ�Ƃ��Ă���imagePos����̍��W�f�[�^���Ή����Ă��邩�ǂ����m�F����
�m�F���@:�L�����u���[�V������csv�t�@�C���̃J����1�̃A���O����,datalist�ōŏ��ɎQ�Ƃ����t�@�C���̃J�����A���O�������������OK
(��)�L�����u���[�V�����̃J�����P�̃A���O����L�Łi���O�ɔc�����Ă����j�Adatalist(66�s��.�̂���93�s�ڂ�temp�ɑ�������)�ōŏ��ɎQ�Ƃ����t�@�C����L����̃A���O���ł����OK(L�͍�)


[���ӓ_]
�������ɑΉ����Ă��Ȃ�(�ϐ�'date'�̃f�[�^�^��double�^)

[���P�_]
P_image_US~.csv��P_world_US.csv��GUI����ŉ摜����쐬�ł���悤�ȃR�[�h���쐬����.
DLC_csvfile�̑I����GUI�ōs����悤�ɂ���
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
%% set param
  setting.PNum = 3; %�}�[�J�[�̐�
  setting.CNum = 2; %�J�����̐�
  setting.P_cal = 8; %�`�F�b�N�|�C���g�̐�
  criterion = 0.9; %judge = 1�̎��Ɏg�p�����l 
  norm_cri = 30;%judge = 1�̎��Ɏg�p����B�O�t���[���Ƃ̋���(�m����)��臒l�ݒ� 
  individual_plot = 1; %�X�̃^�X�N�̌��ʂ��o�͂��邩�ǂ���
  stack_plot = 0; %�܂Ƃ߂��^�X�N�̌��ʂ��o�͂��邩�ǂ���(���̕ϐ���US�̃R�[�h�ł͎g�p���Ȃ�)
  date = 221011; %���t
  data_type = 'ulnar'; %�h������(ulnar,radial)
  
  setting.judge = 1;  output_useCam = 0; %output_usecam��, �J����2��̏ꍇ�͕K�v�Ȃ�
  judge = setting.judge;

  setting.header = {'index-nail X', 'index-nail Y', 'index-nail Z', ...
                    'middle-nail X', 'middle-nail Y', 'middle-nail Z'...
                    'ring-nail X','ring-nail Y','ring-nail Z'}; %csv�t�@�C���̃w�b�_�[(���ʂ̕ۑ�(outputMatrix)�Ɏg�p����)


  %% code section
  projectFolder = pwd;
  setting.saveFolder = strcat(projectFolder, '/DLT_result/'); %mac,windows�ŕύX���K�v
  saveFolder = setting.saveFolder;

  % Get calibration information
  calfileName = strcat('P_image_US_', num2str(date), '.csv'); %calibration

  %calibration�t�H���_����2��csv�t�@�C���̒��g��ǂݍ���
  P_image = csvread([projectFolder '/calibration/' num2str(date) '/' calfileName], 2, 1);%(3,2)��(1,1)�ɂȂ�悤�ɃI�t�Z�b�g
  P_world = csvread([projectFolder '/calibration/' num2str(date) '/P_world_US.csv'], 1, 1);

  % Estimation camera parameter
  CamParam = Get_CamParam(P_world, P_image, setting); %function which generate CamereaParameter

  PNum = setting.PNum;  CNum = setting.CNum;
  
  % Get list of csv files
%   folderName = [projectFolder '/DLC_csvfile/' num2str(date) '/' data_type];%�J�����g�f�B���N�g���̃p�X��'\DLC_csvfile'��A���������̂�foulderName�ɑ��
%   datalist  =  dir([folderName, '/FDS*.csv']); %./�t�@�C��������ƃG���[�f�����璍��(./�t�@�C���΍�Őړ���cam���g�p���Ă���) %���̍s��*.csv�̑O��ύX����
DLC_csv_fold_path = fullfile(pwd, 'DLC_csvfile', num2str(date), data_type);
disp('Please select 2 csvfile(beacause these data is got from right and left angle camera)')
datalist = uigetfile(fullfile(DLC_csv_fold_path, '*.csv'), 'MultiSelect','on', '*.csv');
if isempty(datalist)
    error_msg = "datalist�ւ̓��͂��s�K�؂ł��A�p�����[�^�̃t�@�C������ύX���Ă�������";
    disp(error_msg)
end
  
%   datalist  =  {datalist.name}.';
  TrNum     = length(datalist) / CNum; % �^�X�N�̎��s��(csv�t�@�C���̐�/�J�����̐�)

  for(j = 1 : TrNum)
    if j~=1
        clear imagePos;
        clear likelihood;
    end

    % Get experiment date and rat name(����CSV�t�@�C����6~13�����܂ł���(6~13���������傤�ǃg���C�A���̖��O�̂Ƃ��ɕC�G����))
    setting.exp_info{j, 1} = extractBefore(datalist{j}, 8);%datalist��13�����ڂ܂ł���
    %setting.exp_info{j, 1} = extractAfter(datalist{j}, 8); %setting.exp_info{j, 1}��6�����ڈȍ~����
    disp(setting.exp_info{j, 1});

    % Read csv file of 2D coordinates position on image(._�t�@�C��������������ăG���[�f�����Ƃ����邩�璍�ӂ���)
    for(n = 1 : CNum)
      disp(datalist{j + TrNum * (n - 1)});
      temp = csvread([projectFolder '/DLC_csvfile/' num2str(date) '/' data_type '/' datalist{j + TrNum * (n - 1)}], 3, 1);%J:���^�X�N�ڂ�, TRNUM : �^�X�N�̑��� N:�J�����̔ԍ��@(��F�S��1�Ȃ�J�����P����̃^�X�N1��csv�t�@�C����ǂݍ���)
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
        imagePos(:, 2 * PNum * (n - 1) + 2 * i - 1)  = temp(f_start : f_end , 3 * i - 2); % x position
        imagePos(:, 2 * PNum * (n - 1) + 2 * i)      = temp(f_start : f_end , 3 * i - 1); % y position
        likelihood(:, PNum * (n - 1) + i)            = temp(f_start : f_end , 3 * i);
      end
    end

    [setting.useCam, setting.usecam_all_contents_sel, setting.P] = New_Select_Camera(setting, likelihood);
    useCam = setting.useCam;
    usecam_all_contents_sel = setting.usecam_all_contents_sel;
    usecam_all_contents{1,j} = usecam_all_contents_sel;

    % 3D coordinates reconstruction
    worldPos = zeros([f_end 3 * PNum]);
    worldPos_temp = zeros([f_end 3 * PNum]);
    %���}�[�J�[���ƂɎO�������W�ϊ�����wordlPos�ɑ��
    for(i = 1 : length(setting.P))
      worldPos_temp = Get_worldPos(i, imagePos, CamParam, setting);
      worldPos = worldPos + worldPos_temp;
    end
    
    if judge == 1
        for ii = 1:PNum
            for jj = 1:length(likelihood)
                selected_cam = eval(['useCam.point' num2str(ii) '(' num2str(jj) ',:)']);
                if jj == 1
                    if likelihood(jj,ii)>criterion && likelihood(jj,ii+PNum)>criterion %�|�C���gi�ɂ����āA�I�΂ꂽ2��̃J������likelyhood���Q��Ƃ�criterion�𒴂��鎞
                        
                    else
                        worldPos(jj,(ii*3)-2) = 0/0; %0/0����NaN���o�͂����
                        worldPos(jj,(ii*3)-1) = 0/0; 
                        worldPos(jj,(ii*3)) = 0/0; 
                    end
                else
                    if isnan(worldPos(jj-1,(ii*3)-2:ii*3))
                        if likelihood(jj,ii)>criterion && likelihood(jj,ii+PNum)>criterion
                        
                        else
                            worldPos(jj,(ii*3)-2) = 0/0; %0/0����NaN���o�͂����
                            worldPos(jj,(ii*3)-1) = 0/0; 
                            worldPos(jj,(ii*3)) = 0/0; 
                        end
                    else
                        if  likelihood(jj,ii)>criterion && likelihood(jj,ii+PNum)>criterion && norm(worldPos(jj,(3*ii)-2:(3*ii))-worldPos(jj-1,(3*ii)-2:(3*ii)))<norm_cri
                   
                        else
                            worldPos(jj,(ii*3)-2) = 0/0; %0/0����NaN���o�͂����
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
    %��outputMatrix��1�s�ڂɃw�b�_�[��}������
    for(i = 1 : 3 * PNum)
      outputMatrix{1, i} = setting.header{i};
    end
    %assignin('base', 'outputMatrix', outputMatrix);
    if(judge == 1)
      mkdir([saveFolder 'judgeON/' num2str(date) '/' data_type])
      filename = [saveFolder 'judgeON/' num2str(date) '/' data_type '/' data_type '_US_judgeON(' num2str(date) ').csv'];
    elseif(judge == 0)
      mkdir([saveFolder 'judgeOFF/' num2str(date) '/' data_type])
      filename = [saveFolder 'judgeOFF/' num2str(date) '/' data_type '/' data_type '_US_judgeOFF(' num2str(date) ').csv'];
    end
    
    Mac_user = 1;%mac���[�U�[�Ȃ�1(�����ɂ����ƁAMATLAB�̃o�[�W�����ɂ���Ă�writecell���g���Ȃ����߁A������U���邽�߂ɉ��L�̃R�[�h������)
    %��outputMatrix��filename��csv�t�@�C���Ƃ��ĕۑ�
    if Mac_user == 1
        a = cell2table(outputMatrix);
        writetable(a,filename,'WriteVariableNames',false);
    else
        writecell(outputMatrix, filename);
    end
    %��Mac�̕�����writecell���g���Ȃ�(cell�z���csv�t�@�C���ɕۑ�����������xcell�z���table�ɕϊ����Ă���ۑ�(make.csv���Q��))
    %�����ʂ̃v���b�g�A�}�̕ۑ��̊֐�(�֐����Œ�`�����ϐ�str2�̕ύX���K�v)
    if individual_plot == 1
        plot_result(j, setting, worldPos,date,data_type); %j�̓^�X�N��
    end
    close all;
  end
  %assignin('base', 'useCam_all', useCam_all);
  if stack_plot == 1
    day_task_pose(All_output,setting)
  end
  if(output_useCam == 1)
    filename2 = strcat(saveFolder, date, '_useCam', '.csv');
    for ii = 1:length(setting.exp_info)
        for jj = 1:length(setting.P)
            useCam_all_header{1,PNum*2*(ii-1)+(2*jj-1)} = cellstr(strcat(setting.exp_info{ii, 1}, '_P', num2str(jj)));
            useCam_all_header{1,PNum*2*(ii-1)+(2*jj)} = '/'; 
        end
    end
    %���^�X�N���ƂɃt���[�������Ⴄ�̂ŁA���̂܂܂���cell2mat���ł��Ȃ��B�����NaN�������Ĕz��̃T�C�Y�����킹��   
    %����ԃt���[�����̑傫���^�X�N��T��
    for jj = 1:TrNum
        if jj == 1
            maxframe = length(usecam_all_contents{1,jj});
        elseif length(usecam_all_contents{1,jj}) > maxframe
            maxframe = length(usecam_all_contents{1,jj});
        end
    end
    %maxframe�����NaN�������Ė��ߍ��킹��
    for ii = 1:TrNum
        if length(usecam_all_contents{1,ii}) < maxframe
            comp_matrix = NaN(maxframe - length(usecam_all_contents{1,ii}),2*PNum);
            usecam_all_contents{1,ii} = [usecam_all_contents{1,ii} ; comp_matrix];
            %��2*PNum�́A�g�p�����J�����䐔(����̃v���O��������2�ŌŒ�)�ƁA���x�����O��������(PNum)
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

  close all;
