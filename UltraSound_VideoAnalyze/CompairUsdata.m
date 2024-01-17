%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
[function]

[procedure]
pre: DLT_3D_reconst.m
post: US_3D_traject.m

how to use:
DLT_3D_reconst.m���񂵂���ɍs��
used_file_info�ɑ������t�@�C�����̕ύX�͎蓮�ōs��
�ψق̈�l�͒萔�ł͂Ȃ��āA���ΓI�Ȃ��̂ɂ����ق�����������(�ψʂ��ψʂ̕��ϒl��n�{�ɂȂ�������start���`����)
64�s�ڂ̎Q�Ƃ���L�[�|�C���g�̍��W�l��ύX����(�p�����[�^��`�̃Z�N�V�����ŕύX�ł���悤�ɂ���)
�y�d�v�z���܂��g���~���O�ł��Ȃ��ꍇ��,z_criterion��Az_criterion��if������count��臒l,e_frame��臒l���������Ă݂�
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%% set param
merged_data = [220000, 220530, 220606, 220620, 220801, 220912, 221011]; % 
contain_pre_surgery = 1; %merged_data�̒����F�t���ւ��O�̃f�[�^(22000)���܂܂�Ă��邩�ǂ���(�܂܂�Ă���ꍇ�A�v���b�g�̂Ƃ���̏�������̂��߂ɂ��̕ϐ����g�p����) 
data_type = 'ulnar'; %ulnar or radial
point_header = ["index-nail","middle-nail","ring-nail"]; %remarkable keypoint
point_coodination = ["x","y","z"]; %axis to use
point_num = 3; %number of keypoint
z_criterion = 1.5; %�h��������������Ɏg�p����,z���̕ψق̈�l
trim_operate = 1;
filter_h = 1; % cut off frequency[Hz] of high-pass filter
% criterion_stim_count = 6;
com_OS = 'Mac'; %NCNP��MAC����readmatrix���o�[�W�����̊֌W�Ŏg���Ȃ��̂ŁA���̕ϐ��ɂ���ď������򂷂�(��������l��windows��Mac)
pre_frame = 100; %�h�������߂ē������ł��낤�ʒu��0�Ƃ�����,pre,post�̉��t���[�����𒊏o���邩�H
post_frame = 900; 
%% code section
% read csv file which store the data of 3D-coordination
count = 1;
for ii = merged_data
    used_file_info = dir([pwd '/DLT_result/judgeON/' num2str(ii) '/' data_type '/' data_type '*.csv']);
    switch com_OS
        case 'windows'
            coodinate_info{count,1} = readmatrix([used_file_info.folder '/' used_file_info.name]);
        case 'Mac'
            coodinate_info{count,1} = csvread([used_file_info.folder '/' used_file_info.name],1,0);
    end
    count = count+1;
end

% trimming 'coodinate_info'
if trim_operate==1
    for ii = 1:length(merged_data) 
        % Use the z-axis displacement of 'point1' as  'reference_matrix'
        reference_matrix = coodinate_info{ii,1}(:,3);%ii���ڂ�point1��z���̍��W�𒊏o����(�������Ɏh���̎n�܂�ʒu�����肷��)
        % select criterion frame to trimming by selecting operation
        % get 'start_frame'
        while true
            disp(['Please select the position of stimulation start(' data_type ': ' num2str(merged_data(ii)) ')'])
            plot(reference_matrix)
            datacursormode on
            dlg = warndlg("Please push 'OK' after export 'cursor_info'");
            uiwait(dlg)
            close all;
            try
                stim_start_frame = cursor_info.Position(1);
            catch
                disp("'cursor_info' is not output. Please try again")
                continue
            end
            all_start_frame(1,ii) = stim_start_frame; %�e���t�f�[�^�̎h���X�^�[�g�̃t���[����
            clear cursor_info
            break
        end

        % trimming coodinate_info by refering to start_frame
        % calc start frame
        if stim_start_frame-pre_frame < 0
            initial_frame = 0;
        else
            initial_frame = (stim_start_frame-pre_frame)+1;
        end
        % calc last frame
        if stim_start_frame + post_frame > length(coodinate_info{ii}) 
            last_frame = length(coodinate_info{ii});
        else
            last_frame = stim_start_frame + post_frame;
        end
        coodinate_info{ii} = coodinate_info{ii}(initial_frame:last_frame, :);
    end
end

% filtering 'coodinate_info'
for ii = 1:length(merged_data)
    ref_coodinate = coodinate_info{ii};
    [~, axis_num] = size(ref_coodinate);
    for jj = 1:axis_num
        ref_axis = ref_coodinate(:, jj);
        if any(isnan(ref_axis))
            % perform linear completion
            x = 1:length(ref_axis);
            nanIndex = isnan(ref_axis);
            x_known = x(~nanIndex);
            ref_axis_known = ref_axis(~nanIndex);
            ref_axis = interp1(x_known, ref_axis_known, x, "linear");
            if isnan(ref_axis(end))
                ref_axis(end) = ref_axis(end-1);
            end
        end
        % perform high-pass-filter
        [B,A] = butter(6, (filter_h .* 2) ./ 100, 'high');
        filtererd_ref_axis = filtfilt(B,A, ref_axis);
        coodinate_info{ii}(:, jj) = filtererd_ref_axis;
    end
end

h = figure;
set(h,'Position',[0 0 1920 1080]) %figure�̑傫���ݒ�
for ii = 1:point_num 
    for jj = 1:3 %x, y, z 
        subplot(point_num,3,3*(ii-1)+jj)
        hold on;
        for kk = 1:length(merged_data) 
            target_coodinate = coodinate_info{kk,1}(:,3*(ii-1)+jj);
            if contain_pre_surgery==1
                if kk==1 %22000�̎�
                     plot(target_coodinate,'color','b','LineWidth',2);
                else
                    p_color = ((255*(kk-1))/(length(merged_data)-1))-0.0001;
                    color_ele = p_color/255 ; 
                    plot(target_coodinate,'color',[color_ele,0,0],'LineWidth',2);
                end
            else
                p_color = ((255*kk)/(length(merged_data)))-0.0001;
                color_ele = p_color/255 ; 
                plot(target_coodinate,'color',[color_ele,0,color_0],'LineWidth',2);
            end
        end
        title(strjoin([point_header(ii) point_coodination(jj)]),'fontsize',22)
        grid on;
        yline(0,'k','LineWidth',1);
    end
end
%data_type�ɉ����ĉ摜��ۑ�����t�H���_�Ɖ摜����ύX����
switch data_type
    case 'ulnar'
        mkdir(['merged_coodination/ulnar/' num2str(merged_data(1)) 'to' num2str(merged_data(end)) '_' num2str(length(merged_data)) ]);
        saveas(gcf,['merged_coodination/ulnar/' num2str(merged_data(1)) 'to' num2str(merged_data(end)) '_' num2str(length(merged_data)) '/ulnar_stim_plot.fig' ]);
        saveas(gcf,['merged_coodination/ulnar/' num2str(merged_data(1)) 'to' num2str(merged_data(end)) '_' num2str(length(merged_data)) '/ulnar_stim_plot.png' ]);
        save(['merged_coodination/ulnar/' num2str(merged_data(1)) 'to' num2str(merged_data(end)) '_' num2str(length(merged_data)) '/stim_start_frame.mat' ],'all_start_frame','coodinate_info')
    case 'radial'
        mkdir(['merged_coodination/radial/' num2str(merged_data(1)) 'to' num2str(merged_data(end)) '_' num2str(length(merged_data)) ]);
        saveas(gcf,['merged_coodination/radial/' num2str(merged_data(1)) 'to' num2str(merged_data(end)) '_' num2str(length(merged_data)) '/radial_stim_plot.fig' ]);
        saveas(gcf,['merged_coodination/radial/' num2str(merged_data(1)) 'to' num2str(merged_data(end)) '_' num2str(length(merged_data)) '/radial_stim_plot.png' ]);
        save(['merged_coodination/radial/' num2str(merged_data(1)) 'to' num2str(merged_data(end)) '_' num2str(length(merged_data)) '/stim_start_frame.mat' ],'all_start_frame','coodinate_info')
end
close all;