%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
This program coded by: Naohito Ohta
Last modification: 2023.3.23

【function】
変数定義とGUI操作によって，チェックポイントの実座標のcsvファイルと，画像座標のcsvファイルを出力する.

【preparation】:
・チェックポイントの実座標を変数のところであらかじめ定義しておく。
・所定のディレクトリ(calibration_csv -> 日付フォルダ)に，キャリブレーションフレームの4アングルからの画像を入れておく
task_dayの設定

【caution!!】
×ImagingToolboxのダウンロードが必要 -> impixelっていう関数を使う必要があるから．
→使わなくてもいいように変更した


【procedure】
pre:None
post:MoveFold,m

【改善点】
使用するチェックポイントの数を事前に決めなければいけない(変数で設定しなければいけいない)
チェックポイントを選択する際にP1～P7の順で選択しなければいけない(順不同で選べるようにしたい)
ループで回せるようにする
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
%% set param
checkpoint_num = 7; %使用するチェックポイントの数(ここの値と選んだ点の数が違うとエラー起きるから注意)
camera_num = 4;
task_day = 220113;
checkpoint_name = 'P_world_Monkey'; %チェックポイントcsvファイルの名前(拡張子は要らない)
checkpoint_value ={ 0    0    20;
                    0   60    20;
                   40    0    20;
                   40   60    20;
                    0    0   100;
                    0   60   100;
                   40    0   100}; %チェックポイントの実座標(checkpoint_num同様、選んだ数と異なるとエラー起きるから注意)     
img_csv_name = ['P_image_Monkey_' num2str(task_day)];%画像座標csvファイルの名前

%% code section
% チェックポイントのCSVファイルを作成
[csv_data] = checkpoint_func(checkpoint_num,checkpoint_value); %←入力引数はキャリブレーションフレームのチェックポイントの数
%↓テーブルをcsvファイルに変換して3D-pose-estimation/calibration_csv/日付　に保存する
if not(exist('calibration_csv'))
    mkdir calibration_csv;
    mkdir('calibration_csv',num2str(task_day))
end
csv_data = cell2table(csv_data);
writetable(csv_data,['calibration_csv/' num2str(task_day) '/' checkpoint_name '.csv'],'WriteVariableNames',false)

%% 画像座標のcsvファイルの作成(使用するキャリブレーションフレーム画像をすべて日付フォルダに入れておく)
% cd(['calibration_csv/' num2str(task_day)])
save_dir = ['calibration_csv/' num2str(task_day)];
%関数の実施
img_result_cel = img_coordinate(checkpoint_num, camera_num, save_dir);
img_csv = cell2table(img_result_cel);
writetable(img_csv,[save_dir '/' img_csv_name '.csv'],'WriteVariableNames',false);

%% define function
function [checkpoint_csv] = checkpoint_func(checkpoint_num,checkpoint_value)
    %座標の設定
    coordinate = {'','x','y','z'};
    
    %チェックポイントの設定
    for ii = 1:checkpoint_num
        checkpoint{ii,1} = ['P' num2str(ii)]; 
    end
    
    checkpoint_csv = [coordinate;checkpoint checkpoint_value];
    [row,col] = size(checkpoint_csv);
    
    %セル配列のデータ型を揃える
    for jj = 1:row
        for kk = 1:col
            if ischar(checkpoint_csv{jj,kk})
                
            else
                checkpoint_csv{jj,kk} = num2str(checkpoint_csv{jj,kk});
            end
        end
    end    
end

%% 画像座標のデータを作成して,所定の場所にcsvファイルを保存する関数
function [result] = img_coordinate(checkpoint_num, camera_num, save_dir)
    %フレームワークを作ってcell配列にまとめる(めちゃくちゃ冗長、改善した方がいい)
     margin = cell(2,1); %マージン(余白)
     num_space = cell(checkpoint_num,8);
     for ii = 1:checkpoint_num
        checkpoint{ii,1} = ['P' num2str(ii)];
     end
    
     for jj = 1:camera_num
        eval(['camera' num2str(jj) '= {"camera' num2str(jj) '"," ";"u","v"};']);
     end
     %作ったフレームワークに画像座標を代入していく
     img_list=dir([save_dir '/' '*.jpg']);
     for kk=1:length(img_list)
         calib_img= imread(img_list(kk).name);
         while true
             % 画像を表示する
             imshow(calib_img);         
             % GUIで点を選択する
             disp(['【please select P1~P' num2str(checkpoint_num) '】']);
             [img_u,img_v] = ginput(checkpoint_num); % 一つの点を選択する
             hold on;
             %選択された座標にプロットする
             colors = parula(checkpoint_num); %カラーマップの作成(青→黄色に変化)
             for ll = 1:length(img_u)
                 scatter(img_u(ll), img_v(ll), 20, colors(ll,:), 'filled')
             end
             %質問を表示する
             answer = input("【Is these plot is correct? Please push 'y' or 'n' (y/n)】 ", 's'); %入力を文字列として処理する
    
             if or(strcmpi(answer, 'y'), strcmpi(answer, ''))
                 disp("continue processing!!");
                 close all;
                 img_uv_sel{1,kk} = [img_u,img_v];
                 break;
             elseif strcmpi(answer, 'n')
                 disp("【Please start over from the beginning】");
                 close all;
                 continue
             % 答えがy/n以外の場合
             else
                 disp("【You push wrong botton.Please start over from the beginning】");
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
