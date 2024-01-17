%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
[function]

[procedure]
pre: DLT_3D_reconst.m
post: US_3D_traject.m

how to use:
DLT_3D_reconst.mを回した後に行う
used_file_infoに代入するファイル名の変更は手動で行う
変異の域値は定数ではなくて、相対的なものにしたほうがいいかも(変位が変位の平均値のn倍になった時にstartを定義する)
64行目の参照するキーポイントの座標値を変更する(パラメータ定義のセクションで変更できるようにする)
【重要】うまくトリミングできない場合は,z_criterionや、z_criterionのif文内のcountの閾値,e_frameの閾値をいじってみる
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%% set param
merged_data = [220000, 220530, 220606, 220620, 220801, 220912, 221011]; % 
contain_pre_surgery = 1; %merged_dataの中に腱付け替え前のデータ(22000)が含まれているかどうか(含まれている場合、プロットのところの条件分岐のためにこの変数を使用する) 
data_type = 'ulnar'; %ulnar or radial
point_header = ["index-nail","middle-nail","ring-nail"]; %remarkable keypoint
point_coodination = ["x","y","z"]; %axis to use
point_num = 3; %number of keypoint
z_criterion = 1.5; %刺激が入った判定に使用する,z軸の変異の域値
trim_operate = 1;
filter_h = 1; % cut off frequency[Hz] of high-pass filter
% criterion_stim_count = 6;
com_OS = 'Mac'; %NCNPのMACだとreadmatrixがバージョンの関係で使えないので、この変数によって条件分岐する(代入される値はwindowsかMac)
pre_frame = 100; %刺激が初めて入ったであろう位置を0とした時,pre,postの何フレーム分を抽出するか？
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
        reference_matrix = coodinate_info{ii,1}(:,3);%ii日目のpoint1のz軸の座標を抽出する(これを基に刺激の始まり位置を決定する)
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
            all_start_frame(1,ii) = stim_start_frame; %各日付データの刺激スタートのフレーム数
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
set(h,'Position',[0 0 1920 1080]) %figureの大きさ設定
for ii = 1:point_num 
    for jj = 1:3 %x, y, z 
        subplot(point_num,3,3*(ii-1)+jj)
        hold on;
        for kk = 1:length(merged_data) 
            target_coodinate = coodinate_info{kk,1}(:,3*(ii-1)+jj);
            if contain_pre_surgery==1
                if kk==1 %22000の時
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
%data_typeに応じて画像を保存するフォルダと画像名を変更する
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