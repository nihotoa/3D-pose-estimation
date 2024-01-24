%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
[function]
read the displacement data for stimulation,  calculate the average value of
the displacement for each day,  and over lay and plot.

[procedure]
pre: US_3D_traject.m
post: nothing

% [caustion]
point_scalar

[改善点]
全日分(pre1日, post6日分)にしか対応していないことに注意
今は暫定的なスパイク検出をしているが,もっと信号処理に基づいて行った方がいい.
今のやり方だと, 日付*point数分だけGUI操作しなきゃいけないので大変すぎる.
(例)周波数解析
離散フーリエ変換して,スパイクを構成する周波数帯を求めて, 閾値を決定し, その閾値を使用してエッジ検出をする
(SN比から求める方法)
やること順:
1. (OK!!)5日分で出力できるようにする
2. (OK!!)1pointと3pointの両方で出力できるように,1subplot部分を関数化した後、switchで条件分岐
3. 全体的にコードを簡潔にする(2つ目のファイル選択のdispの修正)

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%% set param
days_list = [220000, 220530, 220606, 220620, 220801, 220912, 221011];
% days_list = [220000, 220620, 220801, 220912, 221011];
data_type = 'radial'; %  'ulnar' / 'radial'
points_name = {'index-nail', 'middle-nail', 'ring-nail'};
trim_range = [-60 60];  % [frame] how long range you want to plot?
shooting_frame_rate = 120;
spike_ratio_threshold = 0.7;
make_stim_data = 0; %wheter you want to make stimulation data(if this is your first time running with this setting, set this to 1)
plot_type = 'each'; % 'each' / 'all' 

%% code section
stim_file_common_path = fullfile(pwd, 'merged_coodination', data_type);

% load data
disp("Please select folder which contains 'stim_scalar.mat'")
disp(['(ex.)' num2str(days_list(1)) 'to' num2str(days_list(end)) '_' num2str(length(days_list))])
data_fold_path = uigetdirEX(stim_file_common_path);
load(fullfile(data_fold_path, 'stim_scalar.mat'), 'point_scalar');


% Find the number of points
[~, marker_point_num] = size(point_scalar{1});

%% Assign data for plot to matrix
if make_stim_data
    matrix_for_stim_plot_average = cell(marker_point_num, 1);
    matrix_for_stim_plot_std = cell(marker_point_num, 1);
    
    for ii = 1:marker_point_num
        matrix_for_stim_plot_average{ii} = zeros(length(days_list), trim_range(2) - trim_range(1));
        matrix_for_stim_plot_std{ii} = zeros(length(days_list), trim_range(2) - trim_range(1));
        for jj = 1:length(days_list)
            ref_data = point_scalar{jj}(:, ii);
            % GUIで最大振幅の値を取得
            while true
                disp(['Please select the top of spike(' num2str(days_list(jj)) ': point' num2str(ii) ' -ulnar)'])
                plot(ref_data)
                datacursormode on
                dlg = warndlg("Please push 'OK' after export 'cursor_info'");
                uiwait(dlg)
                close all;
                try
                    stim_top_displacement = cursor_info.Position(2);
                catch
                    disp("'cursor_info' is not output. Please try again")
                    continue
                end
                clear cursor_info
                break
            end
            % trim data around spike
            displacement_threshold = stim_top_displacement * spike_ratio_threshold;
            candidate_index_list = find(ref_data > displacement_threshold);
            stim_start_index_list = omit_continuous_values(candidate_index_list);
    
            start_index = 1;
            matrix_for_average = zeros(length(stim_start_index_list), trim_range(2) - trim_range(1));
            for kk = 1:length(stim_start_index_list) % trial of stimulations
                if kk ~= length(stim_start_index_list)
                    end_index = find(candidate_index_list == stim_start_index_list(kk+1))-1;
                else % last trial
                    end_index = length(candidate_index_list);
                end
                % もし閾値を超えるデータが連続地ではなくて点だったら、それは刺激じゃないので無視する(continue)
                if start_index == end_index
                    start_index = start_index + 1;
                    continue
                end
                search_range = candidate_index_list(start_index:end_index);
                peak_index = find(ref_data==max(ref_data(search_range)));
                try
                    matrix_for_average(kk, :) = ref_data((peak_index + trim_range(1)) + 1 : peak_index+trim_range(2));
                catch  % trim範囲が前か後にoverしてしまった場合
                    if (peak_index + trim_range(1)) + 1 < 0 % trimの前が足りなかった場合
                        continue
                    end
                    % もしtrimの後ろが足りなかった場合(前trialまでで切ってbreak)
                    matrix_for_average = matrix_for_average(1:kk-1, :);
                    break
                end
                start_index = end_index + 1;
            end
            % calc mean & std of spike waveform
            none_zero_row_idx = any(matrix_for_average, 2);
            matrix_for_average = matrix_for_average(none_zero_row_idx, :);
            spike_average = mean(matrix_for_average);
            spike_std = std(matrix_for_average);
            % store these data
            matrix_for_stim_plot_average{ii}(jj, :) = spike_average;
            matrix_for_stim_plot_std{ii}(jj, :) = spike_std;
        end
    end
    %%  save data
    stim_average_data = matrix_for_stim_plot_average;
    stim_std_data = matrix_for_stim_plot_std;
    save_data_location = fullfile(pwd, 'trimmed_stim_data');
    if not(exist(save_data_location))
        mkdir(save_data_location);
    end
    save(fullfile(save_data_location, [data_type '_trimmed_stim_data(' num2str(trim_range(1)) '_to_' num2str(trim_range(2)) ' frame_' num2str(length(days_list)) 'days).mat']), 'stim_average_data', 'stim_std_data', "days_list");
end

%% plot figure
disp(['Please select stim_data file(' data_type '_trimmed_stim_data(' num2str(trim_range(1)) '_to_' num2str(trim_range(2)) ' frame_' num2str(length(days_list)) 'days).mat)'])
[stim_data_name, stim_data_path] = uigetfileEX(fullfile(pwd, 'trimmed_stim_data'));
load(fullfile(stim_data_path, stim_data_name), 'stim_average_data', 'stim_std_data');
x = [trim_range(1)+1 : trim_range(2)];
% transrate [frame] to [sec]
x = x / shooting_frame_rate;
cmap = colormap(turbo(length(days_list)));
close all;

% give the whole title(to use for filenames)
switch data_type
    case 'radial'
        stimulated_muscle = 'EDC';
    case 'ulnar'
        stimulated_muscle = 'FDS';
end

if strcmp(plot_type, 'all')
    figure("position", [100, 100, 600, 800]);
end
for ii = 1:marker_point_num
    switch plot_type
        case 'each'
            figure("position", [100, 100, 800, 400]);
            hold on
            plot_each_point_stim(stim_average_data, ii, days_list, x, cmap, points_name, stimulated_muscle)
            legend()
            xlabel('elapsed time from stimulus[sec]', 'FontSize', 15);
            ylabel('displacement[mm]', 'FontSize', 15);
            % save figure
            saveas(gcf, fullfile(data_fold_path, [points_name{ii} '_' data_type '_stim_average(' num2str(round(x(1), 1)) '_to_' num2str(round(x(end), 1)) '[sec]).png']))
            saveas(gcf, fullfile(data_fold_path, [points_name{ii} '_' data_type '_stim_average(' num2str(round(x(1), 1)) '_to_' num2str(round(x(end), 1)) '[sec]).png']))
            close all;
        case 'all'
            subplot(marker_point_num, 1, ii)
            hold on;
            plot_each_point_stim(stim_average_data, ii, days_list, x, cmap, points_name)
            if ii == 1
                legend()
            elseif ii == marker_point_num
                xlabel('elapsed time from stimulus[sec]', 'FontSize', 15);
                ylabel('displacement[mm]', 'FontSize', 15);
                sgtitle([' Finger displacement (' stimulated_muscle ' stimulation)'], 'FontSize', 20)
                % save figure
                saveas(gcf, fullfile(data_fold_path, [data_type '_stim_average(' num2str(round(x(1), 1)) '_to_' num2str(round(x(end), 1)) '[sec]).png']))
                saveas(gcf, fullfile(data_fold_path, [data_type '_stim_average(' num2str(round(x(1), 1)) '_to_' num2str(round(x(end), 1)) '[sec]).png']))
                close all;
            end
    end
end

%% define local function
function [return_array] = omit_continuous_values(ref_array)
% If the values are consecutive,  return only the first value
return_array = [ref_array(1)];
prev_num = ref_array(1);
for ii = 2:length(ref_array)
    ref_num = ref_array(ii);
    if ref_num - prev_num > 1
        return_array = [return_array, ref_num];
    end
    prev_num = ref_num;
end
end

function [] = plot_each_point_stim(stim_average_data, ii, days_list, x, cmap, points_name, stimulated_muscle)
% pick up data
ref_average_data = stim_average_data{ii};
% ref_std_data = stim_std_data{ii};
for jj = 1:length(days_list)
    if jj == 1
        disp_name = 'pre surgery(20220530)';
    else
        disp_name = ['post' num2str(jj-1) '(' num2str(days_list(jj)) ')'];
    end
    plot(x, ref_average_data(jj, :), 'color', cmap(jj, :), DisplayName=disp_name, LineWidth=1.2)
end
% decoration
grid on;
h_axes = gca;
h_axes.XAxis.FontSize = 12;
h_axes.YAxis.FontSize = 12;
if exist("stimulated_muscle")
    title([points_name{ii} ' displacement(' stimulated_muscle ' stimulated)'], FontSize=15);
else
    title([points_name{ii} ' displacement'], FontSize=15);
end
xline(0, Color='red', LineWidth=1.2, HandleVisibility='off')
end