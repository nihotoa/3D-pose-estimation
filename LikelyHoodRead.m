%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
coded by Naohito Ohta
last modification : 2022.2.1
Please conduct this code by the directory of '3D-pose-estimation' 
deeplabcut�ɂ���Đ������ꂽ�t�@�C�����A�킩��₷���悤�ɖ��O��ς�����A�f�B���N�g�����ړ������肵����A��͂���t�@�C��
���P�_�F
�v���b�g���������ŁA�f�[�^���ǂ����ɕۑ�������͂��Ă��Ȃ��̂ŁA�K�v�ȃf�[�^��mat�t�@�C���ɕۑ�����Ȃǂ̃R�[�h�������ׂ�
�v���b�g���^�X�N���ƂɂȂ��Ă���̂ŁA�^�X�N�̕��ς�A������݂��������Ȃǂ��o����悤�ɃR�[�h��t�������Ă����ׂ�
(��)���ʂ��Ƃ�,�^�X�N����80%��3D�č\���\�ȃ^�X�N�͑S�^�X�N�̉����ɓ����邩�H�Ȃ�
�yprocedure�z
pre: nothing
post: nothing
�ymemo�z
�E�摜��ۑ����Ă��邾���D���S�ɓƗ����Ă���C�ق��̊֐��Ƃ̑��ݍ�p�͂Ȃ��D
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
cd deeplabcut-csv/deeplabcut;
%% parameterSetting
camera_num = 4;
exp_day = '02-07';
day = '1';
parts = {'thumb1','index1','index2','index3'};
likelyhood_criterion = 0.7;
%project_name = '4camera-3Dproject';%��deeplabcut�̃v���W�F�N�g����������(���󂱂̃t�H���_���̃t�@�C���͉�͂Ɏg���Ă��Ȃ��̂ŕs�v)
movie_fold_name = ['4camera'];%��deeplabcut�̓���t�H���_�̖��O��������

%% ConductProgram
GenerateFile(camera_num,exp_day,day,movie_fold_name);
[organized_data] = OrganizeInfo(camera_num,exp_day,day);

row = size(organized_data,1); %�J������
col = size(organized_data,2); %�^�X�N��
csv_length = size(organized_data{1,1},2);
%% organized_data����likelyhood�̏�񂾂������o��&���ꂼ��̃^�X�N�̕��ʕʂ�likelyhood���o��
%% ��݂���csv�t�@�C����likely_hood�����𔲂��o����All_likelyhood�ɑ��
for ii = 1:row
    for jj = 1:col
        likelyhood_sel=organized_data{ii,jj}(:,4:3:csv_length);
        All_likelyhood{ii,jj}=likelyhood_sel;
    end
end

%% �^�X�N���ƂɁA�e�}�[�J�[���ʂ́A�e�J���������likelyhood���v���b�g���ۑ�(ii:�^�X�N�� jj:�}�[�J�[�������p�[�c�̐� kk:�J�����̐�) 
for ii= 1:size(All_likelyhood,2)
    figure('Position',[0,0,800,600]);
    for jj=1:length(parts)
        subplot(length(parts),1,jj);
        count=1;
        for kk = 1:camera_num
            %judge_likelyhood=zero()
            %judge_likelyhood{ii,1}{jj,1}(kk,:)=All_likelyhood{kk,ii}(:,jj);
            
            %len_frame�͂��ׂẴJ��������̃t���[�����𑵂��邽�߂̂���(�J�����ԂŃ^�X�N�̃t���[����1����邱�Ƃ����΂��΂���̂ŁA�S���̃J�����ŏ��Ȃ����̃t���[�����ɓ��ꂷ��)
            if count==1
                len_frame=length(All_likelyhood{kk,ii});
                count=count-1;
            else
                if length(All_likelyhood{kk,ii})<len_frame
                    len_frame=length(All_likelyhood{kk,ii});
                end
            end
            judge_likelyhood_sel1{kk,1}=All_likelyhood{kk,ii}(1:len_frame,jj).';
            plot(All_likelyhood{kk,ii}(:,jj));
            ylim([0,1]);
            hold on;
        end
        legend('camera1','camera2','camera3','camera4')
        title(parts{1,jj})
        judge_likelyhood{ii,1}{jj,1}=cell2mat(judge_likelyhood_sel1);
    end
    hold off;
    sgtitle(['task' num2str(ii) '-likelyhood'])
    mkdir('likelyhood-figure')
    cd('likelyhood-figure')
    mkdir(['day' day])
    cd(['day' day])
    mkdir('likelyhood')
    cd('likelyhood')
    saveas(gcf,['task' num2str(ii) '-likelyhood.png']);
    close all;
    cd ../../../
end    
%% DLT�@��p�����ۂɁA�e�}�[�J�[���ʂ��e�t���[���łR�����č\���ł��邩���v���b�g����(�v���b�g�̓^�X�N���Ƃɕۑ������@ii:�^�X�N�� jj:�}�[�J�[�������p�[�c�̐� kk:�J�����̐� ll:)
for ii=1:size(All_likelyhood,2)
    figure('Position',[0,0,800,600]);
    for jj=1:length(parts)
        subplot(length(parts),1,jj);
        for kk=1:length(camera_num)
            %judge_likelyhood����l�𒴂��Ă��邩�����Ă��Ȃ�����0,1�ŕ\���čđ������
            %ll,mm�͍s�Ɨ�̐��B(�璷�ȃR�[�h�A���P���K�v)
            for ll = 1:size(judge_likelyhood{ii,1}{jj,1},1)
                for mm = 1:size(judge_likelyhood{ii,1}{jj,1},2)
                    if judge_likelyhood{ii,1}{jj,1}(ll,mm)>likelyhood_criterion
                        judge_likelyhood{ii,1}{jj,1}(ll,mm)=1;
                    else
                        judge_likelyhood{ii,1}{jj,1}(ll,mm)=0;
                    end
                end
            end
            %judge_ID:�C�ӂ̃t���[���ɂ����āA���liklyhood�̒l�𖞂����Ă���J�����̐�
            %possible_ID:judge_ID�����ƂɁA�C�ӂ̃t���[����3D�č\�����\����0,1�ŕԂ����ϐ�(judge_ID��2�ȏ�Ȃ�1���Ƃ�)
            judge_ID=sum(judge_likelyhood{ii,1}{jj,1});
            for nn=1:length(judge_ID)
                if judge_ID(1,nn)>=2
                    possible_ID(1,nn) = 1;
                else
                    possible_ID(1,nn) = 0;
                end
            end
            plot(judge_ID)
            hold on
            plot(possible_ID);
            ylim([0,4]);
        end
        legend('Number of cameras that meet the requirements','whether caliblation is possible')
        title(parts{1,jj})
    end
    hold off;
    sgtitle(['task' num2str(ii) '-judge whether calibration is possible. '])
    mkdir('likelyhood-figure')
    cd('likelyhood-figure')
    mkdir(['day' day])
    cd(['day' day])
    mkdir('judge')
    cd('judge')
    saveas(gcf,['task' num2str(ii) '-judge.png']);
    close all;
    cd ../../../
end


%% FileNameChange AND Move
%{
���O�����F
1.3D-pose-estimation/deeplabcut-csv�̒���deeplabcut�Ƃ����t�H���_������Ă���
2.������t�H���_�̒���deeplabcut�̉�͍ς݃f�[�^(csv�t�@�C���̃t�H���_�Ɠ���̃t�H���_)
�i��j4�̃J��������B�e�����ꍇ�A���̃f�B���N�g���̃t�H���_��2(����t�H���_��CSV�t�H���_)�~4(�J������) = 8�̃t�H���_������͂�
%}
function []=GenerateFile(camera_num,exp_day,day,movie_fold_name)
 for ii = 1:camera_num
     cd([movie_fold_name '(camera' num2str(ii) ')' ]);
     fileList = dir([exp_day '*.csv']); 
     for jj = 1:length(fileList)
         str = fileList(jj).name;
         %csv�t�@�C���̖��O�̕ύX
         if strcmp(str,[exp_day '-camera' num2str(ii) '-task' num2str(jj) '.csv'])
            
         else
             movefile(str,[exp_day '-camera' num2str(ii) '-task' num2str(jj) '.csv']);
         end
         %csv�t�@�C���̈ړ�(deeplabcut-csv�𒆌p���āA�e�J������day�t�H���_�Ɉړ�����)
         cd ../../
         copyfile(['deeplabcut/' movie_fold_name '(camera' num2str(ii) ')/' exp_day '-camera' num2str(ii) '-task' num2str(jj) '.csv']);
         mkdir(['camera' num2str(jj)],['day' day]);
         movefile([exp_day '-camera' num2str(ii) '-task' num2str(jj) '.csv'],['camera' num2str(ii) '/day' day] );
         %����t�H���_�Ɉړ�
         cd(['deeplabcut/4camera(camera' num2str(ii) ')' ]);
     end
     %deeplabcut�t�H���_�Ɉړ�
     cd ../
 end
 %3D-pose-estimation�t�H���_�Ɉړ�
 cd ../../
end
%% Incorporate Likelyhood per parts
%{
 �e�}�[�J�[�̍��W��csv�t�@�C����ǂݍ���Ő�����������
 �K�v�ȃt�@�C���͑O�̏����i�K�ő����Ă���̂ŁA�V�K�ɕK�v�Ȃ��̂͂Ȃ�
 ������organized_data��(�J�������~�^�X�N����double�^)
%}
function [organized_data] = OrganizeInfo(camera_num,exp_day,day)
 for ii = 1:camera_num
     %GenerateFile�ō쐬����csv�t�@�C�����Q�Ƃ���
     cd(['deeplabcut-csv/camera' num2str(ii) '/day' day])
     fileList = dir([exp_day '*.csv']); 
     for jj=1:length(fileList)
         %csv�t�@�C���̃C���|�[�g
         import_csv = readtable([exp_day '-camera' num2str(ii) '-task' num2str(jj) '.csv']);
         %csv�t�@�C���̒��̕K�v�ȃf�[�^�݂̂��e�[�u���ɂ��Ď��o��
         organized_data_sel = table2array(import_csv(3:end,:));
         %���o�����f�[�^��cell�z��i���������g��str)�Ȃ̂ŁA�����double�^�ɒ������(�璷�A���P�􂠂肻��)
         cell_size=size(organized_data_sel);
         row = cell_size(1,1);
         col = cell_size(1,2);
         for kk = 1:row
             for ll = 1:col
                 organized_data_sel{kk,ll}=str2double(organized_data_sel{kk,ll});
             end
         end
         organized_data_sel=cell2mat(organized_data_sel);
         %�������܂�
         %���e�J�����̍��W�f�[�^����̕ϐ��ɂ܂Ƃ߂�
         organized_data{ii,jj}=organized_data_sel;
     end
     cd ../../../
 end
end