function plot_result(j, setting, worldPos,date)
  % jは何タスク目かを表してる(TrNum)
  % Position of each marker
  h = figure();
  h.WindowState = 'maximized';
  f1 = setting.f_start; f2 = setting.f_end;
  PNum = setting.PNum;
  saveFolder = setting.saveFolder;

  for(i = 1 : 3 * PNum)
    subplot(PNum, 3, i)
    xlim([f1 f2])
    grid on
    grid minor
    hold on
    plot(f1 : f2, worldPos(f1 : f2, i), 'b', 'LineWidth', 1.2)
    str = strrep(setting.exp_info(j), '_', ' ');
    str = strcat(str, ', ', setting.header(i));
    title(str, 'FontSize', 14, 'FontWeight', 'bold');
  end

  if(setting.judge == 1)
    if j==1
        mkdir([saveFolder 'judgeON/' num2str(date) '/image']);
    end
    str2 = string(strcat(saveFolder, 'judgeON/', num2str(date) , '/image/',setting.exp_info(j), '_judgeON.png'));
  elseif(setting.judge == 0)
    if j==1
        mkdir([saveFolder 'judgeOFF/' num2str(date) '/image']);
    end
    str2 = string(strcat(saveFolder, 'judgeOFF/', num2str(date) ,'/image/',setting.exp_info(j), '_judgeOFF.png'));
  end
  saveas(gcf, str2);
end