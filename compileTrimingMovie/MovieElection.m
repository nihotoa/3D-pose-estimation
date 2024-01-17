%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
coded by: Naohito Ohta
Last Modification : 2023/03/22
�yhow to use�z:
compileTrimingMovie���J�����g�f�B���N�g���ɂ��Ďg�p����
referenceMovie���ɓ��t�t�H���_���쐬���A���̓��t�t�H���_���ɁA�g�p�����S�J��������̃g���~���O�ς�movie�����Ă���
�yfunction�z:
�T�C�Y�̏���������or�傫�����铮��(���炩�ɒ�������A�Z�����铮�� = �^�X�N�ł͂Ȃ�����)���폜����
�^�X�N����ȊO��r�����A�Ăѐ��񂷂�
(�e�J�����ɂ����āC�Ɨ��ɍs��)
�y���O�����z�FreferenceMovie/day_folder(ex. 20220525)/�Ƀg���~���O�ς݂̓��悪�����Ă��铮������Ă�������
�폜�����̂�,����̖��O���^�X�N���ɕύX����
�y���_�z
�J����4�䕪��RGB�l�킩��Ȃ��ƁA��������̂����
臒l�����Ȃ��ςŌ��߂Ă���̂ŁC��O���N�������Ƃ��ɂ͂����Ă��邩�m�F����p���Ȃ�
�d�����̂��߂̏���������ϓI������ �� �ėp�����Ȃ�
�ǂݍ��݂��������ď������d������


�yprocedure�z
pre: Nothing
post:GetSuccessMovie.m
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%% set param
exp_day = 20220427; %������(����t�H���_�̖��O)
camera_num = 4; %�J�����̑䐔
min_capacity = 0.5*10^6; %�t�@�C���̗e�ʂ̍ŏ��l(10^6��MB��\���Ă���)
max_capacity = 100*10^6; %�t�@�C���e�ʂ̍ő�l

%% code section
folderList = dir(['referenceMovie/' num2str(exp_day) '/camera*']); %camera�Ɩ��̂��t�H���_��S��folder�ɑ�� (����for���̉ǐ����グ�邽�߂̕ϐ�)
for ii = 1:camera_num
    clear failed_trial_name;
    movie_fileList = dir(['referenceMovie/' num2str(exp_day) '/' folderList(ii).name '/camera*.avi']);
    movie_fileList = ArrangeMovielist(movie_fileList);
    count=1;
    for jj = 1:length(movie_fileList)
        %�������𖞂����Ȃ�(�傫������,���������铮��t�@�C��)�̖��O��z��(failed_trial_name)�ɂ܂Ƃ߂�
        if movie_fileList(jj).bytes > min_capacity && movie_fileList(jj).bytes < max_capacity 
            
        else
            failed_trial_name{count,1} = movie_fileList(jj).name;
            count = count+1;
        end   
    end
    %failed_trial_name�Ɠ������O�̃t�@�C������������
    if exist('failed_trial_name')
        for kk = 1:length(failed_trial_name)
            delete(['referenceMovie/' num2str(exp_day) '/' folderList(ii).name '/' failed_trial_name{kk,1}]);
        end
    end
    %���O�����ԂɕύX���Ă���
    new_movie_fileList = dir(['referenceMovie/' num2str(exp_day) '/' folderList(ii).name '/camera*.avi']); %�폜�����t�@�C���������āA�Ăу��X�g��
    new_movie_fileList = ArrangeMovielist(new_movie_fileList);
    movie_file_num(1,ii) = length(new_movie_fileList);
    cd (['referenceMovie/' num2str(exp_day) '/' folderList(ii).name])
    for jj = 1:length(new_movie_fileList)
        %�t�@�C�������ύX��Ɠ���(�ς���K�v���Ȃ�)�Ȃ�
        if strcmp(new_movie_fileList(jj).name,sprintf(['camera' num2str(ii) '_trial_%02d.avi'],jj))
            
        else
            movefile(new_movie_fileList(jj).name,sprintf(['camera' num2str(ii) '_trial_%02d.avi'],jj))
        end
    end
    cd ../../../
end
%% �J�����ԂŁA�����^�X�N�𔽉f����悤�ɂ���
for ii = 1:camera_num
    new_movie_fileList = dir(['referenceMovie/' num2str(exp_day) '/' folderList(ii).name '/camera*.avi']);
    new_movie_fileList = ArrangeMovielist(new_movie_fileList);
    %���e�J�����A�e�g���C�A���̃t���[�����𒊏o���čs��ɂ܂Ƃ߂�
    clear task_frame_count
    %���e�^�X�N,�e�t���[����RGB��R�l����肷��(camera1�̎������ł���)
    for jj = 1:length(new_movie_fileList)
        Video_datail = VideoReader([new_movie_fileList(jj).folder '/' new_movie_fileList(jj).name]); %VideoReader��p���āA����̏ڍ�(�Đ����ԁA�t���[�����[�g�Ȃ�)���擾����
        count = 1;
        while hasFrame(Video_datail)
            img = readFrame(Video_datail);
            image_detail{ii,jj}{1,count} = img; %�摜��readFrame�̌��ʂ������� 
            count = count + 1;
        end
        frame_count = count-1; %�c�[���{�b�N�X���g����Ƃ�
        %�J����ii����̓���̃t���[���ő�l���擾����
        if jj == 1
            max_frame = frame_count;
        elseif frame_count > max_frame
            max_frame = frame_count;
        end
    end

    for jj = 1:length(new_movie_fileList)
        %���e�J�����̍ŏ��̃t�@�C������������Ƃ��̂ݎ��s����
        if jj == 1  
            if ii == 3
                camera_RGB{ii,1} = cell(max_frame,length(new_movie_fileList));
            else
                camera_RGB{ii,1} = zeros(max_frame,length(new_movie_fileList));
            end
        end
        %��臒l��ݒ肵,timing3�ɂ�����t���[�������o�͂���
        frame_count = length(image_detail{ii,jj});
        for kk = 1:frame_count
            if jj == 1 && kk == 1 %�e�J�����́A�ŏ��̃^�X�N�A�ŏ��̃t���[���̂Ƃ�
                calib_img= image_detail{ii,jj}{1,kk};
                while true
                    imshow(calib_img);
                    disp("�yPlease click the location of red LED�z")
                    % GUI�œ_��I������
                    [img_u,img_v] = ginput(1); % ��̓_��I������
                    temp = [img_u,img_v];
                    temp = round(temp);
                    img_u = temp(1);
                    img_v =  temp(2);
                    hold on;
                    % �I�����ꂽ���W�Ƀv���b�g����
                    plot(img_u,img_v,'o',...
                        'LineWidth',5,...
                        'MarkerSize',5,...
                        'MarkerEdgeColor','r')
                    % �����\������
                    answer = input("�yIs these plot is correct? Please push 'y' or 'n' (y/n)�z ", 's'); %���͂𕶎���Ƃ��ď�������

                    if or(strcmpi(answer, 'y'), strcmpi(answer, ''))
                        disp("�ycontinue processing!!�z");
                        close all;
                        img_uv_sel{1,kk} = [img_u,img_v];
                        break;
                    elseif strcmpi(answer, 'n')                        
                        disp("�yPlease start over from the beginning�z");
                        close all;
                        continue;
                    % ������y/n�ȊO�̏ꍇ
                    else
                        % y/n�ȊO�̏ꍇ�̏������L�q����
                        disp("�yYou push incorrect bottom.Please start over from the beginning and push 'y' or 'n'�z");
                        close all;
                        continue
                    end                    
                end
                LED_pixel = [img_u,img_v]; %LED��pixel�l����
            end
            r = image_detail{ii,jj}{1,kk}(img_v,img_u,1); %����!! �� ��1������v.��2������u
            if ii == 3
                g = image_detail{ii,jj}{1,kk}(img_v,img_u,2);
                b = image_detail{ii,jj}{1,kk}(img_v,img_u,3);
            end

            
            if ii==3 %�J����3�̎�
                camera_RGB{ii,1}{kk,jj} = [r g b];  %r�l�ȊO(g,b)���o��
            else
                camera_RGB{ii,1}(kk,jj) = r;  %r�l�̂ݏo��
            end
        end
        %delete *.jpg; %�t�H���_���̉摜�����ׂč폜
        %�����܂�
        %frame_count = round(Video_datail.Duration * Video_datail.FrameRate);
        task_frame_count(jj,1) = frame_count; 
    end
    %e_movie_file_num = max(movie_file_num) - movie_file_num(1,ii);
    %task_frame_count = [task_frame_count ; NaN(e_movie_file_num,1)];
    all_task_frame_count{1,ii} = task_frame_count; 
end
%�K�v�ȕϐ���.mat�t�@�C���ɃZ�[�u����
save(['referenceMovie/' num2str(exp_day) '/movie_information.mat'],'camera_RGB','max_capacity','min_capacity','all_task_frame_count')