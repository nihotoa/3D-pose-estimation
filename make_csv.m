%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
This program coded by: Naohito Ohta
Last modification: 2023.3.23

�yfunction�z
�ϐ���`��GUI����ɂ���āC�`�F�b�N�|�C���g�̎����W��csv�t�@�C���ƁC�摜���W��csv�t�@�C�����o�͂���.

�ypreparation�z:
�E�`�F�b�N�|�C���g�̎����W��ϐ��̂Ƃ���ł��炩���ߒ�`���Ă����B
�E����̃f�B���N�g��(calibration_csv -> ���t�t�H���_)�ɁC�L�����u���[�V�����t���[����4�A���O������̉摜�����Ă���
task_day�̐ݒ�

�ycaution!!�z
�~ImagingToolbox�̃_�E�����[�h���K�v -> impixel���Ă����֐����g���K�v�����邩��D
���g��Ȃ��Ă������悤�ɕύX����


�yprocedure�z
pre:None
post:MoveFold,m

�y���P�_�z
�g�p����`�F�b�N�|�C���g�̐������O�Ɍ��߂Ȃ���΂����Ȃ�(�ϐ��Őݒ肵�Ȃ���΂������Ȃ�)
�`�F�b�N�|�C���g��I������ۂ�P1�`P7�̏��őI�����Ȃ���΂����Ȃ�(���s���őI�ׂ�悤�ɂ�����)
���[�v�ŉ񂹂�悤�ɂ���
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
%% set param
checkpoint_num = 7; %�g�p����`�F�b�N�|�C���g�̐�(�����̒l�ƑI�񂾓_�̐����Ⴄ�ƃG���[�N���邩�璍��)
camera_num = 4;
task_day = 220113;
checkpoint_name = 'P_world_Monkey'; %�`�F�b�N�|�C���gcsv�t�@�C���̖��O(�g���q�͗v��Ȃ�)
checkpoint_value ={ 0    0    20;
                    0   60    20;
                   40    0    20;
                   40   60    20;
                    0    0   100;
                    0   60   100;
                   40    0   100}; %�`�F�b�N�|�C���g�̎����W(checkpoint_num���l�A�I�񂾐��ƈقȂ�ƃG���[�N���邩�璍��)     
img_csv_name = ['P_image_Monkey_' num2str(task_day)];%�摜���Wcsv�t�@�C���̖��O

%% code section
% �`�F�b�N�|�C���g��CSV�t�@�C�����쐬
[csv_data] = checkpoint_func(checkpoint_num,checkpoint_value); %�����͈����̓L�����u���[�V�����t���[���̃`�F�b�N�|�C���g�̐�
%���e�[�u����csv�t�@�C���ɕϊ�����3D-pose-estimation/calibration_csv/���t�@�ɕۑ�����
if not(exist('calibration_csv'))
    mkdir calibration_csv;
    mkdir('calibration_csv',num2str(task_day))
end
csv_data = cell2table(csv_data);
writetable(csv_data,['calibration_csv/' num2str(task_day) '/' checkpoint_name '.csv'],'WriteVariableNames',false)

%% �摜���W��csv�t�@�C���̍쐬(�g�p����L�����u���[�V�����t���[���摜�����ׂē��t�t�H���_�ɓ���Ă���)
% cd(['calibration_csv/' num2str(task_day)])
save_dir = ['calibration_csv/' num2str(task_day)];
%�֐��̎��{
img_result_cel = img_coordinate(checkpoint_num, camera_num, save_dir);
img_csv = cell2table(img_result_cel);
writetable(img_csv,[save_dir '/' img_csv_name '.csv'],'WriteVariableNames',false);

%% define function
function [checkpoint_csv] = checkpoint_func(checkpoint_num,checkpoint_value)
    %���W�̐ݒ�
    coordinate = {'','x','y','z'};
    
    %�`�F�b�N�|�C���g�̐ݒ�
    for ii = 1:checkpoint_num
        checkpoint{ii,1} = ['P' num2str(ii)]; 
    end
    
    checkpoint_csv = [coordinate;checkpoint checkpoint_value];
    [row,col] = size(checkpoint_csv);
    
    %�Z���z��̃f�[�^�^�𑵂���
    for jj = 1:row
        for kk = 1:col
            if ischar(checkpoint_csv{jj,kk})
                
            else
                checkpoint_csv{jj,kk} = num2str(checkpoint_csv{jj,kk});
            end
        end
    end    
end

%% �摜���W�̃f�[�^���쐬����,����̏ꏊ��csv�t�@�C����ۑ�����֐�
function [result] = img_coordinate(checkpoint_num, camera_num, save_dir)
    %�t���[�����[�N�������cell�z��ɂ܂Ƃ߂�(�߂��Ⴍ����璷�A���P������������)
     margin = cell(2,1); %�}�[�W��(�]��)
     num_space = cell(checkpoint_num,8);
     for ii = 1:checkpoint_num
        checkpoint{ii,1} = ['P' num2str(ii)];
     end
    
     for jj = 1:camera_num
        eval(['camera' num2str(jj) '= {"camera' num2str(jj) '"," ";"u","v"};']);
     end
     %������t���[�����[�N�ɉ摜���W�������Ă���
     img_list=dir([save_dir '/' '*.jpg']);
     for kk=1:length(img_list)
         calib_img= imread(img_list(kk).name);
         while true
             % �摜��\������
             imshow(calib_img);         
             % GUI�œ_��I������
             disp(['�yplease select P1~P' num2str(checkpoint_num) '�z']);
             [img_u,img_v] = ginput(checkpoint_num); % ��̓_��I������
             hold on;
             %�I�����ꂽ���W�Ƀv���b�g����
             colors = parula(checkpoint_num); %�J���[�}�b�v�̍쐬(�����F�ɕω�)
             for ll = 1:length(img_u)
                 scatter(img_u(ll), img_v(ll), 20, colors(ll,:), 'filled')
             end
             %�����\������
             answer = input("�yIs these plot is correct? Please push 'y' or 'n' (y/n)�z ", 's'); %���͂𕶎���Ƃ��ď�������
    
             if or(strcmpi(answer, 'y'), strcmpi(answer, ''))
                 disp("continue processing!!");
                 close all;
                 img_uv_sel{1,kk} = [img_u,img_v];
                 break;
             elseif strcmpi(answer, 'n')
                 disp("�yPlease start over from the beginning�z");
                 close all;
                 continue
             % ������y/n�ȊO�̏ꍇ
             else
                 disp("�yYou push wrong botton.Please start over from the beginning�z");
                 close all;
                 continue;
             end
         end
     end
     %frame_work = cell2table(frame_work);
     %writetable(frame_work,'sample2.csv','WriteVariableNames',false)
     img_uv = num2cell(cell2mat(img_uv_sel));
     result = [margin,camera1,camera2,camera3,camera4;checkpoint,img_uv];
end
