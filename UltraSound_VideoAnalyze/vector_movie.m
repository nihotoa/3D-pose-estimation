clear;
%% set param
current_dir = pwd;
data_type = 'ulnar';
target_date = [220000,220530,220606,220620];
point_num = 3;
fig_dir = [current_dir '/merged_coodination/' data_type '/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) '/'];
%% code section
h = openfig([fig_dir data_type '_stim_vector.fig']);
set(h,'Position',[0 0 1920 1080]) %figureの大きさ設定

% 図を回転させ,ビデオにして保存
cd(fig_dir);
v = VideoWriter([data_type '-vector.mp4'],'MPEG-4'); %動画ファイルを作成し、受け皿を作る(2つ目の引数は動画のコーデック)
open(v);

for n = 1:360
    view([n, 30]);
    drawnow; % 描画更新
    frame = getframe(h); %現在のfigureの状態を取得
    writeVideo(v,frame); %受け皿に動画を保存
end
cd(current_dir);
close all;