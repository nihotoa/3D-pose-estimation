%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
coded by: Naohito Ohta
Last Modification : 2023/03/22
【how to use】:
compileTrimingMovieをカレントディレクトリにして使用する
referenceMovie内に日付フォルダを作成し、その日付フォルダ内に、使用した全カメラからのトリミング済みmovieを入れておく
【function】:
サイズの小さすぎるor大きすぎる動画(明らかに長すぎる、短すぎる動画 = タスクではない動画)を削除する
タスク動画以外を排除し、再び整列する
(各カメラにおいて，独立に行う)
【事前準備】：referenceMovie/day_folder(ex. 20220525)/にトリミング済みの動画が入っている動画を入れておくこと
削除したのち,動画の名前をタスク順に変更する
【問題点】
カメラ4台分のRGB値わからないと、整理するのが難しい
閾値をかなり主観で決めているので，例外が起こったときにはじけているか確認する術がない
仕分けのための条件分が主観的すぎる → 汎用性がない
読み込みが多すぎて処理が重すぎる


【procedure】
pre: Nothing
post:GetSuccessMovie.m
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%% set param
exp_day = 20220427; %実験日(動画フォルダの名前)
camera_num = 4; %カメラの台数
min_capacity = 0.5*10^6; %ファイルの容量の最小値(10^6はMBを表している)
max_capacity = 100*10^6; %ファイル容量の最大値

%% code section
folderList = dir(['referenceMovie/' num2str(exp_day) '/camera*']); %cameraと名のつくフォルダを全部folderに代入 (次のfor文の可読性を上げるための変数)
for ii = 1:camera_num
    clear failed_trial_name;
    movie_fileList = dir(['referenceMovie/' num2str(exp_day) '/' folderList(ii).name '/camera*.avi']);
    movie_fileList = ArrangeMovielist(movie_fileList);
    count=1;
    for jj = 1:length(movie_fileList)
        %↓条件を満たさない(大きすぎる,小さすぎる動画ファイル)の名前を配列(failed_trial_name)にまとめる
        if movie_fileList(jj).bytes > min_capacity && movie_fileList(jj).bytes < max_capacity 
            
        else
            failed_trial_name{count,1} = movie_fileList(jj).name;
            count = count+1;
        end   
    end
    %failed_trial_nameと同じ名前のファイルを消去する
    if exist('failed_trial_name')
        for kk = 1:length(failed_trial_name)
            delete(['referenceMovie/' num2str(exp_day) '/' folderList(ii).name '/' failed_trial_name{kk,1}]);
        end
    end
    %名前を順番に変更していく
    new_movie_fileList = dir(['referenceMovie/' num2str(exp_day) '/' folderList(ii).name '/camera*.avi']); %削除したファイルを除いて、再びリスト化
    new_movie_fileList = ArrangeMovielist(new_movie_fileList);
    movie_file_num(1,ii) = length(new_movie_fileList);
    cd (['referenceMovie/' num2str(exp_day) '/' folderList(ii).name])
    for jj = 1:length(new_movie_fileList)
        %ファイル名が変更先と同じ(変える必要がない)なら
        if strcmp(new_movie_fileList(jj).name,sprintf(['camera' num2str(ii) '_trial_%02d.avi'],jj))
            
        else
            movefile(new_movie_fileList(jj).name,sprintf(['camera' num2str(ii) '_trial_%02d.avi'],jj))
        end
    end
    cd ../../../
end
%% カメラ間で、同じタスクを反映するようにする
for ii = 1:camera_num
    new_movie_fileList = dir(['referenceMovie/' num2str(exp_day) '/' folderList(ii).name '/camera*.avi']);
    new_movie_fileList = ArrangeMovielist(new_movie_fileList);
    %↓各カメラ、各トライアルのフレーム数を抽出して行列にまとめる
    clear task_frame_count
    %↓各タスク,各フレームのRGBのR値を入手する(camera1の時だけでいい)
    for jj = 1:length(new_movie_fileList)
        Video_datail = VideoReader([new_movie_fileList(jj).folder '/' new_movie_fileList(jj).name]); %VideoReaderを用いて、動画の詳細(再生時間、フレームレートなど)を取得する
        count = 1;
        while hasFrame(Video_datail)
            img = readFrame(Video_datail);
            image_detail{ii,jj}{1,count} = img; %画像のreadFrameの結果を代入する 
            count = count + 1;
        end
        frame_count = count-1; %ツールボックスが使えるとき
        %カメラiiからの動画のフレーム最大値を取得する
        if jj == 1
            max_frame = frame_count;
        elseif frame_count > max_frame
            max_frame = frame_count;
        end
    end

    for jj = 1:length(new_movie_fileList)
        %↓各カメラの最初のファイルを処理するときのみ実行する
        if jj == 1  
            if ii == 3
                camera_RGB{ii,1} = cell(max_frame,length(new_movie_fileList));
            else
                camera_RGB{ii,1} = zeros(max_frame,length(new_movie_fileList));
            end
        end
        %↓閾値を設定し,timing3におけるフレーム数を出力する
        frame_count = length(image_detail{ii,jj});
        for kk = 1:frame_count
            if jj == 1 && kk == 1 %各カメラの、最初のタスク、最初のフレームのとき
                calib_img= image_detail{ii,jj}{1,kk};
                while true
                    imshow(calib_img);
                    disp("【Please click the location of red LED】")
                    % GUIで点を選択する
                    [img_u,img_v] = ginput(1); % 一つの点を選択する
                    temp = [img_u,img_v];
                    temp = round(temp);
                    img_u = temp(1);
                    img_v =  temp(2);
                    hold on;
                    % 選択された座標にプロットする
                    plot(img_u,img_v,'o',...
                        'LineWidth',5,...
                        'MarkerSize',5,...
                        'MarkerEdgeColor','r')
                    % 質問を表示する
                    answer = input("【Is these plot is correct? Please push 'y' or 'n' (y/n)】 ", 's'); %入力を文字列として処理する

                    if or(strcmpi(answer, 'y'), strcmpi(answer, ''))
                        disp("【continue processing!!】");
                        close all;
                        img_uv_sel{1,kk} = [img_u,img_v];
                        break;
                    elseif strcmpi(answer, 'n')                        
                        disp("【Please start over from the beginning】");
                        close all;
                        continue;
                    % 答えがy/n以外の場合
                    else
                        % y/n以外の場合の処理を記述する
                        disp("【You push incorrect bottom.Please start over from the beginning and push 'y' or 'n'】");
                        close all;
                        continue
                    end                    
                end
                LED_pixel = [img_u,img_v]; %LEDのpixel値を代入
            end
            r = image_detail{ii,jj}{1,kk}(img_v,img_u,1); %注意!! → 第1引数がv.第2引数がu
            if ii == 3
                g = image_detail{ii,jj}{1,kk}(img_v,img_u,2);
                b = image_detail{ii,jj}{1,kk}(img_v,img_u,3);
            end

            
            if ii==3 %カメラ3の時
                camera_RGB{ii,1}{kk,jj} = [r g b];  %r値以外(g,b)も出力
            else
                camera_RGB{ii,1}(kk,jj) = r;  %r値のみ出力
            end
        end
        %delete *.jpg; %フォルダ内の画像をすべて削除
        %ここまで
        %frame_count = round(Video_datail.Duration * Video_datail.FrameRate);
        task_frame_count(jj,1) = frame_count; 
    end
    %e_movie_file_num = max(movie_file_num) - movie_file_num(1,ii);
    %task_frame_count = [task_frame_count ; NaN(e_movie_file_num,1)];
    all_task_frame_count{1,ii} = task_frame_count; 
end
%必要な変数を.matファイルにセーブする
save(['referenceMovie/' num2str(exp_day) '/movie_information.mat'],'camera_RGB','max_capacity','min_capacity','all_task_frame_count')