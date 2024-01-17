%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DLT_3D_reconst.mのなかで定義される
%１日のタスクの重ね合わせ,平均をプロットして出力(平均の方はcsvファイルにしてDLT_resultに保存する)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = day_task_pose(All_output,setting)
    h = figure();
    h.WindowState = 'maximized';
    for ii = 1:length(All_output)
        [row,~] = size(All_output{1,ii});
        if ii == 1 
            Maxframe = row;
        elseif row > Maxframe
            Maxframe = row;
        end
    end
    PNum = setting.PNum;
    CNum = setting.CNum;
    saveFolder = setting.saveFolder;
    for ii = 1:(PNum*3)
        subplot(PNum,3,ii)
        for jj = 1:length(All_output)
            xlim([1 Maxframe])
            grid on
            grid minor
            hold on
            plot(All_output{1,jj}(:,ii),'LineWidth',1.2)
        end
        title(setting.header(1,ii));
        %{
        eval(['point' num2str(ii) '_x{1,jj} = All_output{1,' num2str(jj) '}(:,' num2str(3*ii-2) ');'])
        eval(['point' num2str(ii) '_y{1,jj} = All_output{1,' num2str(jj) '}(:,' num2str(3*ii-1) ');'])
        eval(['point' num2str(ii) '_z{1,jj} = All_output{1,' num2str(jj) '}(:,' num2str(3*ii) ');'])
        %}
    end
    saveas(gcf,[saveFolder 'judgeON/day_task_judgeON.png'])
    close all;
        %{
        eval(['point' num2str(ii) '_x = cell2mat(point' num2str(ii) '_x);'])
        eval(['point' num2str(ii) '_y = cell2mat(point' num2str(ii) '_y);'])
        eval(['point' num2str(ii) '_z = cell2mat(point' num2str(ii) '_z);'])
        %}
end

