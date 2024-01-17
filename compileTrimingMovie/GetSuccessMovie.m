%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
coded by: Naohito Ohta
Last Modification : 2023/03/24
�yfucntion�z
�EMovieElection�œ���ꂽ�����p���āC�J�����Ԃœ����ł��Ă�����݂̂̂𒊏o���ĕۑ�����(�����ł��Ă��Ȃ����̂�����)
���O�̊֐��́C�e�J�����t�H���_�ɂ����āC�Ɨ��Ƀ^�X�N�ȊO�̓�����������D
���̊֐��́C�^�X�N����ł����Ă��C���ׂẴJ�����̓������Ƃ�Ă��Ȃ����̂͏���(���[���w�̎d����)
�yprocedure�z
pre:MovieElection
post:DLT_3D_reconst.m

�y�C���ӏ��z:
success_matrix==0�̎��̏������l����
��ϓI������D�ėp�����Ⴂ(�J����4�̎��ɂ����Ή����Ă��Ȃ�)
�����I��loop�ŉ񂵂����̂ł���΁C臒l���������ʂɕύX���邱�Ƃ͂ł��Ȃ��̂ŁC������臒l��ݒ肷��悤�ȃA���S���Y�����l����ׂ�

�y�R�����g�z
�E�����ł͂Ȃ��������݂����Ȋ֐����Ǝv���Ďg��
�E�������̂͌y�� & �c�[���{�b�N�X���g���Ă��Ȃ�
�E�����ʃA���O������B��ꂽ�����^�X�N�Ȃ̂��𔻒肷��͓̂��(�����I�ɂ͂�肽��)����C����͔ėp���̃A�b�v�ƁC�R�[�h�̉ǐ����グ�邱�Ƃ�ڕW�ɂ���
�E臒l���蓮�łǂ��ɂ��Ȃ�Ǝv��
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%% set param
exp_day = 20220427; 
camera_num = 4; 
e_frame = 2;%���e����J�����Ԃ̌덷�t���[����
R_threshold = [220 235 0 220]; %camera1,2,4��R�l��threshold(camera2���S�̓I�ɔ���т������Ȃ̂ŁA臒l������)
trial_div_threshold = 3; %�J�����Ԃ̃g���C�A�����ɂ����ȏ�̈Ⴂ����������C�G���[��Ԃ����H  
%% code section
folderList = dir(['referenceMovie/' num2str(exp_day) '/camera*']); %camera�Ɩ��̂��t�H���_��S��folder�ɑ�� (����for���̉ǐ����グ�邽�߂̕ϐ�)
load(['referenceMovie/' num2str(exp_day) '/movie_information.mat']) %MovieElection�ō����t�@�C��
for ii = 1:camera_num
    clear sensor_timing
    pre_file_num = length(all_task_frame_count{1,ii}); %�J����ii�̓��搔
    success_count = 0;
    failed_count = 0;
    for jj = 1:pre_file_num %�t�@�C�������������[�v
        if ii==3 %�J����3�̎�(�A���O���������ĕs����������̂ŁC�����������ς���)
            count = 0;
            frame_RGB_value = cell2mat(camera_RGB{ii,1}(1:all_task_frame_count{1,ii}(jj,1),jj));
            judge_matrix = zeros(length(frame_RGB_value),1);
            for kk = 1:length(frame_RGB_value)
                reference_matrix = frame_RGB_value(kk,:);
                if reference_matrix(1,1) > 210 && sum(reference_matrix(1,2:3)) < 250 %R�l��210�ȏ�@���@GB�l�̍��v��250�ȉ��̎�,1����
                    judge_matrix(kk,1) = 1;
                end
            end
            %judge_matrix = ((frame_RGB_value(1) > 200) && (sum(frame_RGB_value) < 700)); %R�l��200���傫���l����� ���@RGB�l�̍��v��700�������Ƃ�1���A����ȊO�̂Ƃ�0��Ԃ�(RGB�l�̍��v��700�ȏゾ�ƁA����т��Ă���\��������) 
            %���[�v��,�F�̐؂�ւ��̃t���[������T��
            for kk = 1:length(judge_matrix)-1 
                change_timing = judge_matrix(kk+1,1) - judge_matrix(kk,1);
                if change_timing == 1 
                    timing2_video = kk;
                    count = count + 1;
                elseif change_timing == -1 
                    timing3_video = kk;
                    count = count + 1;
                end
            end
            if count == 2 %�����オ��Ɨ��������肪�P�񂸂�(�����^�X�N)
                success_count = success_count + 1;
                sensor_timing(success_count,1) = timing2_video;
                sensor_timing(success_count,2) = timing3_video;
            else
                failed_count = failed_count + 1;
                failed_trial_num{1,ii}(failed_count,1) =jj;
            end
        else %camera3�ȊO�̎�
            count = 0;
            frame_red_value = camera_RGB{ii}(1:all_task_frame_count{ii}(jj),jj); %�^�X�Njj�̑O�t���[����RGB�l��R�̒l
            judge_matrix = (frame_red_value > R_threshold(ii)); %R�l��230���傫���l����邩�ǂ�����0,1��Ԃ� 
            %���[�v��,�F�̐؂�ւ��̃t���[������T��
            for kk = 1:length(judge_matrix)-1 
                change_timing = judge_matrix(kk+1,1) - judge_matrix(kk,1);
                if change_timing == 1 %�����オ��
                    timing2_video = kk;
                    count = count + 1;
                elseif change_timing == -1 %����������
                    timing3_video = kk;
                    count = count + 1;
                end
            end
            if count == 2 && timing2_video > 10 %�����オ��Ɨ��������肪�P�񂸂�(�����^�X�N)��timing2_video�������Ɋ܂܂�Ă��邱�Ƃɒ���
                success_count = success_count + 1;
                sensor_timing(success_count,1) = timing2_video;
                sensor_timing(success_count,2) = timing3_video;
            else
                failed_count = failed_count + 1;
                failed_trial_num{1,ii}(failed_count,1) =jj;
            end
        end
    end
    all_sensor_timing{ii,1} = sensor_timing;
end
all_success_trial_num = [length(all_sensor_timing{1,1}) length(all_sensor_timing{2,1}) length(all_sensor_timing{3,1}) length(all_sensor_timing{4,1})]; 
%���J�����Ԃ̃g���C�A�����ɑ傫�ȈႢ���Ȃ����ǂ����m�F
trial_diviation = abs(diff(all_success_trial_num));
result = not(all(trial_diviation <= trial_div_threshold));
if result
    error('�y�^�X�N�Ԃ̐����g���C�A�������傫���قȂ�܂��D臒l�ݒ���������Ă�����x��蒼���Ă��������z')
end
clear sensor_timing;
%��all_senor_timing����Asensor on �� sensor off�̕��ϒl���o��
all_sensor_timing = transpose(all_sensor_timing);
max_task_trial = max([length(all_sensor_timing{1,1}) length(all_sensor_timing{1,2}) length(all_sensor_timing{1,3}) length(all_sensor_timing{1,4})]);
for ii = 1:4 %(camera�̐�)
    if length(all_sensor_timing{1,ii}) == max_task_trial
        %�������Ȃ�
    else
        e_task_trial = max_task_trial - length(all_sensor_timing{1,ii});
        all_sensor_timing{1,ii} = [all_sensor_timing{1,ii} ; NaN(e_task_trial,2)];
    end
end
all_sensor_timing = cell2mat(all_sensor_timing);

for ii = 1:length(all_sensor_timing)
    for jj = 1:2 %timng2��timing3��2�̕��ς��o������
        if jj==1
            average_sensor_timing = round(nanmean([all_sensor_timing(ii,1) all_sensor_timing(ii,3) all_sensor_timing(ii,5) all_sensor_timing(ii,7)]));
            sensor_timing(ii,1) = average_sensor_timing;
        elseif jj==2
            average_sensor_timing = round(nanmean([all_sensor_timing(ii,2) all_sensor_timing(ii,4) all_sensor_timing(ii,6) all_sensor_timing(ii,8)]));
            sensor_timing(ii,2) = average_sensor_timing;
        end
    end
end
%% �O�Z�N�V�����œ���ꂽ�f�[�^����ɁA�s�v�ȃt�@�C��������
%failed_trial_num����ɁA�S�J�����̕s�v�ȃt�@�C���������A���O��t���ւ���
for ii = 1:4
    pre_movie_list = dir(['referenceMovie/' num2str(exp_day) '/camera' num2str(ii) '_trimming/camera*.avi']); %���łɕs�v�ȓ��悪�폜�ς݂��ǂ���(���̃R�[�h���g�p�����o�������邩�ǂ���)�̔���ɗp����
    pre_movie_list = ArrangeMovielist(pre_movie_list);
    if length(pre_movie_list) <= all_success_trial_num(1,ii) %�s�v�ȓ���t�@�C�����Ȃ��ꍇ
        %�����������s��Ȃ�
    else %�s�v�ȓ���t�@�C��������ꍇ(���߂Ă��̊֐������s���鎞)
        for jj = transpose(failed_trial_num{1,ii})
            delete(['referenceMovie/' num2str(exp_day) '/camera' num2str(ii) '_trimming/camera' num2str(ii) '_trial_' sprintf('%02d',jj) '.avi'])
        end
    end
    %���ׂẴJ�����̓���t�@�C���̖��O��������
    new_movie_list = dir(['referenceMovie/' num2str(exp_day) '/camera' num2str(ii) '_trimming/camera*.avi']);
    new_movie_list = ArrangeMovielist(new_movie_list);
    cd(['referenceMovie/' num2str(exp_day) '/' folderList(ii).name])
    for jj = 1:length(new_movie_list)
        %�t�@�C�������ύX��Ɠ���(�ς���K�v���Ȃ�)�Ȃ�
        if strcmp(new_movie_list(jj).name,sprintf(['camera' num2str(ii) '_trial_%02d.avi'],jj))

        else
            movefile(new_movie_list(jj).name,sprintf(['camera' num2str(ii) '_trial_%02d.avi'],jj))
        end
    end
    cd ../../../
end
clear failed_trial_num;
all_timing = cell(length(all_sensor_timing),4);
for ii = 1:4
    for jj = 1:length(all_timing)
        all_timing{jj,ii} = all_sensor_timing(jj,2*ii-1:2*ii);
    end
end

%% 2�i�K�ڂ̑I��(��������Ԃ̖��_!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)
collated_matrix = zeros(length(all_timing),3);
for ii = 1:all_success_trial_num(1) %�J����1�̃g���C�A������
    count=0;
    wrong_count=1;
    clear wrong_camera
    all_reference_trial = zeros(1,3);
    for jj = 1:4 %�J��������
        if jj==1 %camera1���Q�Ƃ��Ă��鎞
           reference_matrix = all_timing{ii,1};
        else %���̃J������reference_matrix���r����
            if  ii==1  %�^�X�N1�̎�
                if (abs(reference_matrix(1) - all_timing{ii,jj}(1)) <= e_frame) && (abs(reference_matrix(2) - all_timing{ii,jj}(2)) <= e_frame) %tim2��tim3���덷e_frame�ȓ��Ȃ�
                    count=count+1;
                else %��������͓�̃J���������ꂽ�Ƃ�(count==2 or count==3�̂Ƃ�)�Ɏg�p����
                    wrong_camera(1,wrong_count)=jj;
                    wrong_count = wrong_count+1;
                end
            else
                reference_trial = collated_matrix(ii-1,jj-1)+1; %camera1�̃^�X�Nii�ƑΉ����Ă���ƍl������camerajj��trial��(�Ή����Ă��Ȃ������ꍇ�͂��̂��Ƃŏ�������悤�ɂȂ��Ă���)
                if reference_trial==1 %�O�̃g���C�A���őΉ��֌W����v����,collated_matrix��0���������Ă�����
                    for kk = 2:ii-1
                        if collated_matrix(ii-kk,jj-1)>0
                            reference_trial = collated_matrix(ii-kk,jj-1)+1;
                            break
                        end
                    end
                end
                if reference_trial > all_success_trial_num(1)
                    count = 0;
                    break
                end
                all_reference_trial(1,jj-1) = reference_trial;
                if (abs(reference_matrix(1) - all_timing{reference_trial,jj}(1)) <= e_frame) && (abs(reference_matrix(2) - all_timing{reference_trial,jj}(2)) <= e_frame) %tim2��tim3���덷e_frame�ȓ��Ȃ� %���̏��������ƁAclollated_matrix��000���������Ƃ��ɑΏ��ł��Ȃ�
                    count=count+1;
                else
                    wrong_camera(1,wrong_count)=jj;
                    wrong_count = wrong_count+1;
                end
            end
        end
    end 
    if count== 3 %���ׂďƍ������Ă��鎞
        if ii==1
             collated_matrix(1,:) = 1; 
        else
            collated_matrix(ii,:) = collated_matrix(ii-1,:)+1;
        end
    elseif count == 2 || count==1
        adequate_trial = zeros(1,3);
        for kk = wrong_camera %�Ή��֌W�̍���Ȃ��J�����̓������z��
            for ll = collated_matrix(ii-1,wrong_camera-1)+1:collated_matrix(ii-1,wrong_camera-1)+5
                if (abs(reference_matrix(1) - all_timing{ll,kk}(1)) <= e_frame) && (abs(reference_matrix(2) - all_timing{ll,kk}(2)) <= e_frame)
                    count=count+1;
                    adequate_trial(1,kk-1) = ll;
                    break
                end
                if ll == length(all_timing)
                    break
                end
            end
        end
        if count==3 %�Ή��֌W����v�����Ƃ�
            for kk = 1:length(adequate_trial)
                if adequate_trial(kk)==0
                    adequate_trial(kk) = collated_matrix(ii-1,kk)+1;
                end
            end
            collated_matrix(ii,:) = adequate_trial;
        else
            collated_matrix(ii,:) = 0;
        end
    elseif count == 0
        if not(exist('collated_matrix_sel')) || size(check_sel,2) < 3
            clear collated_matrix_sel
            clear check_sel
            for kk=2:4 %�J����2����4
                for ll=all_reference_trial(kk-1)+1:all_reference_trial(kk-1)+5
                    if (abs(reference_matrix(1) - all_timing{ll,kk}(1)) <= e_frame) && (abs(reference_matrix(2) - all_timing{ll,kk}(2)) <= e_frame)
                        count=count+1;
                        check_sel{1,kk-1} = ll;
                        break
                    end
                end
            end
        else           
            verified_trial = collated_matrix_sel;
            clear collated_matrix_sel
            clear check_sel
            for kk=2:4 %�J����2����4
                for ll = verified_trial(kk-1)+1: verified_trial(kk-1)+5
                    if (abs(reference_matrix(1) - all_timing{ll,kk}(1)) <= e_frame) && (abs(reference_matrix(2) - all_timing{ll,kk}(2)) <= e_frame)
                        count=count+1;
                        check_sel{1,kk-1} = ll;
                        break
                    end
                end
            end
        end
        if count==3 %���̏������s�����ƂŁA���ׂẴJ�����̑Ή��֌W����v�����Ƃ�
            check_sel = cell2mat(check_sel);
            collated_matrix_sel = check_sel;
            collated_matrix(ii,:) = collated_matrix_sel;
        elseif count<3 %���̏������s���Ă��Ή��֌W����v���Ȃ������Ƃ� 
            collated_matrix(ii,:) = 0;
            if count>0
                check_sel = cell2mat(check_sel);
            end
            DDDDD=1; %�܂��l���Ă��Ȃ�����N�������Ƃ��l����(count==0�������Ƃ���check_sel����`�ł��Ȃ�����G���[�o��͂�+����ɂ���Ď��̃��[�v�̏������ł��G���[���o��͂�)
        end
    end
end

%collated_matrix�����ƂɁAfailed_trial_num������Ă���
for ii = 1:4 % camera�̐�
    if ii==1 %camera1�̎�(�^�X�N��a�ƁA�ƍ��ł����^�X�Nb�̍��W�����Ƃ��āA�ƍ��ł��Ă��Ȃ��^�X�N�𒊏o����)
        a = transpose(1:all_success_trial_num(1,1)); %transpose�͔z��T�C�Y�����킹�邽�߂ɂ��������
        b = find(collated_matrix(:,1)>0);
        trial_num = length(b); %�I���̃g���C�A����
        failed_trial_num{1,1} = transpose(setdiff(a,b));
    else %�J����2,3,4�̎�
        a = transpose(1:all_success_trial_num(1,ii));
        b = collated_matrix(collated_matrix(:,ii-1)>0,ii-1);
        if b < trial_num
            trial_num = b;
        end
        failed_trial_num{1,ii} = transpose(setdiff(a,b));
    end
end

%�����ۂɏ����Ă����Z�N�V����(����2) %�r���ł���邱�Ƃ�z�肵�Ă��Ȃ����߁A���O�̕t���ւ������Ă��Ȃ�
for ii = 1:length(failed_trial_num) 
    movie_file_list = dir(['referenceMovie/' num2str(exp_day) '/camera' num2str(ii) '_trimming/camera*.avi']);
    movie_file_list = ArrangeMovielist(movie_file_list);
    if isempty(failed_trial_num{1,ii}) %filed_trial_num�����݂��Ȃ��Ƃ�
        %�������Ȃ�
    else
        if trial_num >= length(movie_file_list) %����t�@�C�������g���C�A�����ȉ��ł���(���łɂ��̑��삪�s���Ă��鎞)����{�I�ɉ���邱�Ƃ͂Ȃ����A�O�̂���
            %�������Ȃ�
        else
             for jj = failed_trial_num{1,ii}
                 delete(['referenceMovie/' num2str(exp_day) '/camera' num2str(ii) '_trimming/camera' num2str(ii) '_trial_' sprintf('%02d',jj) '.avi']);
             end
        end
    end
     %���ׂẴJ�����̓���t�@�C���̖��O��������
    new_movie_list = dir(['referenceMovie/' num2str(exp_day) '/camera' num2str(ii) '_trimming/camera*.avi']);
    new_movie_list = ArrangeMovielist(new_movie_list);
    cd(['referenceMovie/' num2str(exp_day) '/' folderList(ii).name])
    for jj = 1:length(new_movie_list)
        %�t�@�C�������ύX��Ɠ���(�ς���K�v���Ȃ�)�Ȃ�
        if strcmp(new_movie_list(jj).name,sprintf(['camera' num2str(ii) '_trial_%02d.avi'],jj))

        else
            movefile(new_movie_list(jj).name,sprintf(['camera' num2str(ii) '_trial_%02d.avi'],jj))
        end
    end
    cd ../../../
end
%�����^�X�N��tim2,tim3�̃^�C�~���O����red_LED_timing�ɂ܂Ƃ߂�
red_LED_timing_2 = zeros(trial_num,4);
red_LED_timing_3 = zeros(trial_num,4);
for ii=1:4
      a = 1:all_success_trial_num(1,ii);
      b = failed_trial_num{1,ii};
      success_trial = setdiff(a,b);
      red_LED_timing_2(:,ii) = all_sensor_timing(success_trial,2*ii-1);
      red_LED_timing_3(:,ii) = all_sensor_timing(success_trial,2*ii);
end
%����K�v�ɂȂ�ϐ����܂Ƃ߂�
red_LED_timing_2 = round(mean(red_LED_timing_2,2));
red_LED_timing_3 = round(mean(red_LED_timing_3,2));

red_LED_timing = [red_LED_timing_2 red_LED_timing_3];
save(['referenceMovie/' num2str(exp_day) '/red_LED_timing.mat'],'red_LED_timing');