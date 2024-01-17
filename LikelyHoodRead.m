%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
coded by Naohito Ohta
last modification : 2022.2.1
Please conduct this code by the directory of '3D-pose-estimation' 
deeplabcutによって生成されたファイルを、わかりやすいように名前を変えたり、ディレクトリを移動したりした後、解析するファイル
改善点：
プロットしただけで、データをどこかに保存したりはしていないので、必要なデータをmatファイルに保存するなどのコードを書くべき
プロットがタスクごとになっているので、タスクの平均や、条件を設けた割合などを出せるようにコードを付け足していくべき
(例)部位ごとに,タスク内の80%が3D再構成可能なタスクは全タスクの何％に当たるか？など
【procedure】
pre: nothing
post: nothing
【memo】
・画像を保存しているだけ．完全に独立しており，ほかの関数との相互作用はない．
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
%project_name = '4camera-3Dproject';%←deeplabcutのプロジェクト名を代入する(現状このフォルダ内のファイルは解析に使っていないので不要)
movie_fold_name = ['4camera'];%←deeplabcutの動画フォルダの名前を代入する

%% ConductProgram
GenerateFile(camera_num,exp_day,day,movie_fold_name);
[organized_data] = OrganizeInfo(camera_num,exp_day,day);

row = size(organized_data,1); %カメラ数
col = size(organized_data,2); %タスク数
csv_length = size(organized_data{1,1},2);
%% organized_dataからlikelyhoodの情報だけを取り出す&それぞれのタスクの部位別のlikelyhoodを出す
%% よみこんだcsvファイルのlikely_hoodだけを抜き出してAll_likelyhoodに代入
for ii = 1:row
    for jj = 1:col
        likelyhood_sel=organized_data{ii,jj}(:,4:3:csv_length);
        All_likelyhood{ii,jj}=likelyhood_sel;
    end
end

%% タスクごとに、各マーカー部位の、各カメラからのlikelyhoodをプロットし保存(ii:タスク回数 jj:マーカーをつけたパーツの数 kk:カメラの数) 
for ii= 1:size(All_likelyhood,2)
    figure('Position',[0,0,800,600]);
    for jj=1:length(parts)
        subplot(length(parts),1,jj);
        count=1;
        for kk = 1:camera_num
            %judge_likelyhood=zero()
            %judge_likelyhood{ii,1}{jj,1}(kk,:)=All_likelyhood{kk,ii}(:,jj);
            
            %len_frameはすべてのカメラからのフレーム数を揃えるためのもの(カメラ間でタスクのフレームが1ずれることがしばしばあるので、全部のカメラで少ない方のフレーム数に統一する)
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
%% DLT法を用いた際に、各マーカー部位が各フレームで３次元再構成できるかをプロットする(プロットはタスクごとに保存される　ii:タスク数 jj:マーカーをつけたパーツの数 kk:カメラの数 ll:)
for ii=1:size(All_likelyhood,2)
    figure('Position',[0,0,800,600]);
    for jj=1:length(parts)
        subplot(length(parts),1,jj);
        for kk=1:length(camera_num)
            %judge_likelyhoodを基準値を超えているか超えていないかの0,1で表して再代入する
            %ll,mmは行と列の数。(冗長なコード、改善が必要)
            for ll = 1:size(judge_likelyhood{ii,1}{jj,1},1)
                for mm = 1:size(judge_likelyhood{ii,1}{jj,1},2)
                    if judge_likelyhood{ii,1}{jj,1}(ll,mm)>likelyhood_criterion
                        judge_likelyhood{ii,1}{jj,1}(ll,mm)=1;
                    else
                        judge_likelyhood{ii,1}{jj,1}(ll,mm)=0;
                    end
                end
            end
            %judge_ID:任意のフレームにおいて、基準のliklyhoodの値を満たしているカメラの数
            %possible_ID:judge_IDをもとに、任意のフレームで3D再構成が可能かを0,1で返した変数(judge_IDが2以上なら1をとる)
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
事前準備：
1.3D-pose-estimation/deeplabcut-csvの中にdeeplabcutというフォルダを作っておく
2.作ったフォルダの中にdeeplabcutの解析済みデータ(csvファイルのフォルダと動画のフォルダ)
（例）4つのカメラから撮影した場合、このディレクトリのフォルダは2(動画フォルダとCSVフォルダ)×4(カメラ数) = 8個のフォルダがあるはず
%}
function []=GenerateFile(camera_num,exp_day,day,movie_fold_name)
 for ii = 1:camera_num
     cd([movie_fold_name '(camera' num2str(ii) ')' ]);
     fileList = dir([exp_day '*.csv']); 
     for jj = 1:length(fileList)
         str = fileList(jj).name;
         %csvファイルの名前の変更
         if strcmp(str,[exp_day '-camera' num2str(ii) '-task' num2str(jj) '.csv'])
            
         else
             movefile(str,[exp_day '-camera' num2str(ii) '-task' num2str(jj) '.csv']);
         end
         %csvファイルの移動(deeplabcut-csvを中継して、各カメラのdayフォルダに移動する)
         cd ../../
         copyfile(['deeplabcut/' movie_fold_name '(camera' num2str(ii) ')/' exp_day '-camera' num2str(ii) '-task' num2str(jj) '.csv']);
         mkdir(['camera' num2str(jj)],['day' day]);
         movefile([exp_day '-camera' num2str(ii) '-task' num2str(jj) '.csv'],['camera' num2str(ii) '/day' day] );
         %動画フォルダに移動
         cd(['deeplabcut/4camera(camera' num2str(ii) ')' ]);
     end
     %deeplabcutフォルダに移動
     cd ../
 end
 %3D-pose-estimationフォルダに移動
 cd ../../
end
%% Incorporate Likelyhood per parts
%{
 各マーカーの座標のcsvファイルを読み込んで整理したもの
 必要なファイルは前の処理段階で揃っているので、新規に必要なものはない
 得られるorganized_dataは(カメラ数×タスク数のdouble型)
%}
function [organized_data] = OrganizeInfo(camera_num,exp_day,day)
 for ii = 1:camera_num
     %GenerateFileで作成したcsvファイルを参照する
     cd(['deeplabcut-csv/camera' num2str(ii) '/day' day])
     fileList = dir([exp_day '*.csv']); 
     for jj=1:length(fileList)
         %csvファイルのインポート
         import_csv = readtable([exp_day '-camera' num2str(ii) '-task' num2str(jj) '.csv']);
         %csvファイルの中の必要なデータのみをテーブルにして取り出す
         organized_data_sel = table2array(import_csv(3:end,:));
         %取り出したデータがcell配列（しかも中身がstr)なので、それをdouble型に直す作業(冗長、改善策ありそう)
         cell_size=size(organized_data_sel);
         row = cell_size(1,1);
         col = cell_size(1,2);
         for kk = 1:row
             for ll = 1:col
                 organized_data_sel{kk,ll}=str2double(organized_data_sel{kk,ll});
             end
         end
         organized_data_sel=cell2mat(organized_data_sel);
         %↑ここまで
         %↓各カメラの座標データを一つの変数にまとめる
         organized_data{ii,jj}=organized_data_sel;
     end
     cd ../../../
 end
end