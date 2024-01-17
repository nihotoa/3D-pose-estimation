%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Coded by: Naohito Ohta
Last modification: 2023.03.23
【function】
・make_csvで得られたcsvデータを，解析に必要な場所に移す
・移すフォルダと，移す場所はそれぞれGUIで選択する

【procedure】
pre:make_csv.m
post:DLT_3D_reconst.m
【課題点】
現状はcalibration_csvの中身をMonkeyExp ->calibrationの中に移動するためだけの用途なので，拡張性を広げるために，functionにした方がいいかも
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%% code section
% コピー元のフォルダを選択するダイアログを表示する
disp('【コピー元の日付フォルダを選んでください　(caliblation_csv -> date)】')
source_folder = uigetdir('','コピー元のフォルダを選択してください。');
[~, file_name, ~] = fileparts(source_folder);
% コピー先のフォルダを選択するダイアログを表示する
disp('【コピー元の日付フォルダを選んでください　(MonkeyExp_DLT -> calibration)】')
destination_folder = uigetdir('','コピー先のフォルダを選択してください。');
destination_folder = [destination_folder '/' file_name ];

if not(exist(destination_folder))
    mkdir(destination_folder)
end
% コピー元のフォルダの中身をコピー先のフォルダにコピーする
copyfile(source_folder, destination_folder);
