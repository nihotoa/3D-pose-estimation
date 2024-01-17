function plot_result(j, setting, worldPos,date,data_type)
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
    str = setting.header{i};
    title(str, 'FontSize', 14, 'FontWeight', 'bold');
  end

  if(setting.judge == 1)
    str2 = string([saveFolder 'judgeON/' num2str(date) '/' data_type '/' data_type '_US_judgeON(' num2str(date) ').png']);
  elseif(setting.judge == 0)
    str2 = string([saveFolder 'judgeOFF/' num2str(date) '/' data_type '/' data_type '_US_judgeOFF(' num2str(date) ').png']);
  end
  saveas(gcf, str2);
end