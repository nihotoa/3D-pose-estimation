%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
coded by: Naohito Ohta
Last Modification : 2023/03/24
【fucntion】
・MovieElectionで得られた動画を用いて，カメラ間で同期できているもののみを抽出して保存する(同期できていないものを消す)
※前の関数は，各カメラフォルダにおいて，独立にタスク以外の動画を消した．
この関数は，タスク動画であっても，すべてのカメラの同期がとれていないものは消す(より深い層の仕分け)
【procedure】
pre:MovieElection
post:DLT_3D_reconst.m

【修正箇所】:
success_matrix==0の時の処理を考える
主観的すぎる．汎用性が低い(カメラ4つの時にしか対応していない)
将来的にloopで回したいのであれば，閾値を実験日別に変更することはできないので，自動で閾値を設定するようなアルゴリズムを考えるべき

【コメント】
・自動ではなく半自動みたいな関数だと思って使う
・処理自体は軽い & ツールボックスも使っていない
・正直別アングルから撮られた同じタスクなのかを判定するのは難しい(将来的にはやりたい)から，現状は汎用性のアップと，コードの可読性を上げることを目標にする
・閾値も手動でどうにかなると思う
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%% set param
exp_day = 20220427; 
camera_num = 4; 
e_frame = 2;%許容するカメラ間の誤差フレーム数
R_threshold = [220 235 0 220]; %camera1,2,4のR値のthreshold(camera2が全体的に白飛びしがちなので、閾値あげた)
trial_div_threshold = 3; %カメラ間のトライアル数にいくつ以上の違いがあったら，エラーを返すか？  
%% code section
folderList = dir(['referenceMovie/' num2str(exp_day) '/camera*']); %cameraと名のつくフォルダを全部folderに代入 (次のfor文の可読性を上げるための変数)
load(['referenceMovie/' num2str(exp_day) '/movie_information.mat']) %MovieElectionで作られるファイル
for ii = 1:camera_num
    clear sensor_timing
    pre_file_num = length(all_task_frame_count{1,ii}); %カメラiiの動画数
    success_count = 0;
    failed_count = 0;
    for jj = 1:pre_file_num %ファイル数分だけループ
        if ii==3 %カメラ3の時(アングルが悪くて不具合があったので，一つだけ条件を変えた)
            count = 0;
            frame_RGB_value = cell2mat(camera_RGB{ii,1}(1:all_task_frame_count{1,ii}(jj,1),jj));
            judge_matrix = zeros(length(frame_RGB_value),1);
            for kk = 1:length(frame_RGB_value)
                reference_matrix = frame_RGB_value(kk,:);
                if reference_matrix(1,1) > 210 && sum(reference_matrix(1,2:3)) < 250 %R値が210以上　かつ　GB値の合計が250以下の時,1を代入
                    judge_matrix(kk,1) = 1;
                end
            end
            %judge_matrix = ((frame_RGB_value(1) > 200) && (sum(frame_RGB_value) < 700)); %R値が200より大きい値を取る かつ　RGB値の合計が700を下回るとき1を、それ以外のとき0を返す(RGB値の合計が700以上だと、白飛びしている可能性が高い) 
            %ループで,色の切り替わりのフレーム数を探す
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
            if count == 2 %立ち上がりと立ち下がりが１回ずつ(成功タスク)
                success_count = success_count + 1;
                sensor_timing(success_count,1) = timing2_video;
                sensor_timing(success_count,2) = timing3_video;
            else
                failed_count = failed_count + 1;
                failed_trial_num{1,ii}(failed_count,1) =jj;
            end
        else %camera3以外の時
            count = 0;
            frame_red_value = camera_RGB{ii}(1:all_task_frame_count{ii}(jj),jj); %タスクjjの前フレームのRGB値のRの値
            judge_matrix = (frame_red_value > R_threshold(ii)); %R値が230より大きい値を取るかどうかで0,1を返す 
            %ループで,色の切り替わりのフレーム数を探す
            for kk = 1:length(judge_matrix)-1 
                change_timing = judge_matrix(kk+1,1) - judge_matrix(kk,1);
                if change_timing == 1 %立ち上がり
                    timing2_video = kk;
                    count = count + 1;
                elseif change_timing == -1 %立ち下がり
                    timing3_video = kk;
                    count = count + 1;
                end
            end
            if count == 2 && timing2_video > 10 %立ち上がりと立ち下がりが１回ずつ(成功タスク)※timing2_videoも条件に含まれていることに注意
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
%↓カメラ間のトライアル数に大きな違いがないかどうか確認
trial_diviation = abs(diff(all_success_trial_num));
result = not(all(trial_diviation <= trial_div_threshold));
if result
    error('【タスク間の成功トライアル数が大きく異なります．閾値設定を見直してもう一度やり直してください】')
end
clear sensor_timing;
%↓all_senor_timingから、sensor on と sensor offの平均値を出す
all_sensor_timing = transpose(all_sensor_timing);
max_task_trial = max([length(all_sensor_timing{1,1}) length(all_sensor_timing{1,2}) length(all_sensor_timing{1,3}) length(all_sensor_timing{1,4})]);
for ii = 1:4 %(cameraの数)
    if length(all_sensor_timing{1,ii}) == max_task_trial
        %何もしない
    else
        e_task_trial = max_task_trial - length(all_sensor_timing{1,ii});
        all_sensor_timing{1,ii} = [all_sensor_timing{1,ii} ; NaN(e_task_trial,2)];
    end
end
all_sensor_timing = cell2mat(all_sensor_timing);

for ii = 1:length(all_sensor_timing)
    for jj = 1:2 %timng2とtiming3の2つの平均を出すため
        if jj==1
            average_sensor_timing = round(nanmean([all_sensor_timing(ii,1) all_sensor_timing(ii,3) all_sensor_timing(ii,5) all_sensor_timing(ii,7)]));
            sensor_timing(ii,1) = average_sensor_timing;
        elseif jj==2
            average_sensor_timing = round(nanmean([all_sensor_timing(ii,2) all_sensor_timing(ii,4) all_sensor_timing(ii,6) all_sensor_timing(ii,8)]));
            sensor_timing(ii,2) = average_sensor_timing;
        end
    end
end
%% 前セクションで得られたデータを基に、不要なファイルを消す
%failed_trial_numを基に、全カメラの不要なファイルを消し、名前を付け替える
for ii = 1:4
    pre_movie_list = dir(['referenceMovie/' num2str(exp_day) '/camera' num2str(ii) '_trimming/camera*.avi']); %すでに不要な動画が削除済みかどうか(このコードを使用した経験があるかどうか)の判定に用いる
    pre_movie_list = ArrangeMovielist(pre_movie_list);
    if length(pre_movie_list) <= all_success_trial_num(1,ii) %不要な動画ファイルがない場合
        %何も処理を行わない
    else %不要な動画ファイルがある場合(初めてこの関数を実行する時)
        for jj = transpose(failed_trial_num{1,ii})
            delete(['referenceMovie/' num2str(exp_day) '/camera' num2str(ii) '_trimming/camera' num2str(ii) '_trial_' sprintf('%02d',jj) '.avi'])
        end
    end
    %すべてのカメラの動画ファイルの名前をつけ直す
    new_movie_list = dir(['referenceMovie/' num2str(exp_day) '/camera' num2str(ii) '_trimming/camera*.avi']);
    new_movie_list = ArrangeMovielist(new_movie_list);
    cd(['referenceMovie/' num2str(exp_day) '/' folderList(ii).name])
    for jj = 1:length(new_movie_list)
        %ファイル名が変更先と同じ(変える必要がない)なら
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

%% 2段階目の選抜(ここが一番の問題点!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)
collated_matrix = zeros(length(all_timing),3);
for ii = 1:all_success_trial_num(1) %カメラ1のトライアル数分
    count=0;
    wrong_count=1;
    clear wrong_camera
    all_reference_trial = zeros(1,3);
    for jj = 1:4 %カメラ数分
        if jj==1 %camera1を参照している時
           reference_matrix = all_timing{ii,1};
        else %他のカメラとreference_matrixを比較する
            if  ii==1  %タスク1の時
                if (abs(reference_matrix(1) - all_timing{ii,jj}(1)) <= e_frame) && (abs(reference_matrix(2) - all_timing{ii,jj}(2)) <= e_frame) %tim2とtim3が誤差e_frame以内なら
                    count=count+1;
                else %一つもしくは二つのカメラがずれたとき(count==2 or count==3のとき)に使用する
                    wrong_camera(1,wrong_count)=jj;
                    wrong_count = wrong_count+1;
                end
            else
                reference_trial = collated_matrix(ii-1,jj-1)+1; %camera1のタスクiiと対応していると考えられるcamerajjのtrial数(対応していなかった場合はそのあとで処理するようになっている)
                if reference_trial==1 %前のトライアルで対応関係が一致せず,collated_matrixに0が代入されていた時
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
                if (abs(reference_matrix(1) - all_timing{reference_trial,jj}(1)) <= e_frame) && (abs(reference_matrix(2) - all_timing{reference_trial,jj}(2)) <= e_frame) %tim2とtim3が誤差e_frame以内なら %この条件式だと、clollated_matrixに000が入ったときに対処できない
                    count=count+1;
                else
                    wrong_camera(1,wrong_count)=jj;
                    wrong_count = wrong_count+1;
                end
            end
        end
    end 
    if count== 3 %すべて照合が取れている時
        if ii==1
             collated_matrix(1,:) = 1; 
        else
            collated_matrix(ii,:) = collated_matrix(ii-1,:)+1;
        end
    elseif count == 2 || count==1
        adequate_trial = zeros(1,3);
        for kk = wrong_camera %対応関係の合わないカメラの入った配列
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
        if count==3 %対応関係が一致したとき
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
            for kk=2:4 %カメラ2から4
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
            for kk=2:4 %カメラ2から4
                for ll = verified_trial(kk-1)+1: verified_trial(kk-1)+5
                    if (abs(reference_matrix(1) - all_timing{ll,kk}(1)) <= e_frame) && (abs(reference_matrix(2) - all_timing{ll,kk}(2)) <= e_frame)
                        count=count+1;
                        check_sel{1,kk-1} = ll;
                        break
                    end
                end
            end
        end
        if count==3 %この処理を行うことで、すべてのカメラの対応関係が一致したとき
            check_sel = cell2mat(check_sel);
            collated_matrix_sel = check_sel;
            collated_matrix(ii,:) = collated_matrix_sel;
        elseif count<3 %この処理を行っても対応関係が一致しなかったとき 
            collated_matrix(ii,:) = 0;
            if count>0
                check_sel = cell2mat(check_sel);
            end
            DDDDD=1; %まだ考えていないから起こったとき考える(count==0だったときはcheck_selが定義できないからエラー出るはず+それによって次のループの条件式でもエラーが出るはず)
        end
    end
end

%collated_matrixをもとに、failed_trial_numを作っていく
for ii = 1:4 % cameraの数
    if ii==1 %camera1の時(タスク数aと、照合できたタスクbの差集合をとって、照合できていないタスクを抽出する)
        a = transpose(1:all_success_trial_num(1,1)); %transposeは配列サイズを合わせるためにやっただけ
        b = find(collated_matrix(:,1)>0);
        trial_num = length(b); %選定後のトライアル数
        failed_trial_num{1,1} = transpose(setdiff(a,b));
    else %カメラ2,3,4の時
        a = transpose(1:all_success_trial_num(1,ii));
        b = collated_matrix(collated_matrix(:,ii-1)>0,ii-1);
        if b < trial_num
            trial_num = b;
        end
        failed_trial_num{1,ii} = transpose(setdiff(a,b));
    end
end

%↓実際に消していくセクション(その2) %途中でずれることを想定していないため、名前の付け替えもしていない
for ii = 1:length(failed_trial_num) 
    movie_file_list = dir(['referenceMovie/' num2str(exp_day) '/camera' num2str(ii) '_trimming/camera*.avi']);
    movie_file_list = ArrangeMovielist(movie_file_list);
    if isempty(failed_trial_num{1,ii}) %filed_trial_numが存在しないとき
        %何もしない
    else
        if trial_num >= length(movie_file_list) %動画ファイル数がトライアル数以下である(すでにこの操作が行われている時)※基本的に下回ることはないが、念のため
            %何もしない
        else
             for jj = failed_trial_num{1,ii}
                 delete(['referenceMovie/' num2str(exp_day) '/camera' num2str(ii) '_trimming/camera' num2str(ii) '_trial_' sprintf('%02d',jj) '.avi']);
             end
        end
    end
     %すべてのカメラの動画ファイルの名前をつけ直す
    new_movie_list = dir(['referenceMovie/' num2str(exp_day) '/camera' num2str(ii) '_trimming/camera*.avi']);
    new_movie_list = ArrangeMovielist(new_movie_list);
    cd(['referenceMovie/' num2str(exp_day) '/' folderList(ii).name])
    for jj = 1:length(new_movie_list)
        %ファイル名が変更先と同じ(変える必要がない)なら
        if strcmp(new_movie_list(jj).name,sprintf(['camera' num2str(ii) '_trial_%02d.avi'],jj))

        else
            movefile(new_movie_list(jj).name,sprintf(['camera' num2str(ii) '_trial_%02d.avi'],jj))
        end
    end
    cd ../../../
end
%成功タスクのtim2,tim3のタイミング情報をred_LED_timingにまとめる
red_LED_timing_2 = zeros(trial_num,4);
red_LED_timing_3 = zeros(trial_num,4);
for ii=1:4
      a = 1:all_success_trial_num(1,ii);
      b = failed_trial_num{1,ii};
      success_trial = setdiff(a,b);
      red_LED_timing_2(:,ii) = all_sensor_timing(success_trial,2*ii-1);
      red_LED_timing_3(:,ii) = all_sensor_timing(success_trial,2*ii);
end
%今後必要になる変数をまとめる
red_LED_timing_2 = round(mean(red_LED_timing_2,2));
red_LED_timing_3 = round(mean(red_LED_timing_3,2));

red_LED_timing = [red_LED_timing_2 red_LED_timing_3];
save(['referenceMovie/' num2str(exp_day) '/red_LED_timing.mat'],'red_LED_timing');