%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Coded by: Naohito Ohta
Last modification:2022/07/01

[function]

[procedure]
pre: CompairUsdata.m
post: vector_movie.m or plot_average_stim_displacement.m

使い方:
UltraSound_VideoAnalyzeをカレントディレクトリにして実行する
用途:
各マーカー部位の3次元座標のスカラー変化をプロットするプログラム
ベクトルは考慮していないので、ベクトルを考慮して3次元座標上で表したい時は追加のコードを考える必要がある
三次元座標上のxlim,ylim,zlimは定数で指定しているので適宜変更すること

% 注意点
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%% set param
data_type = 'ulnar';
% target_date = [220000, 220530, 220606, 220620, 220801, 220912, 221011];
target_date = [220000, 220620, 220801, 220912, 221011]; 
point_num = 3;
contain_pre_surgery=1; % pre_surgeryのデータを含んでいるかどうか
point_header = ["index-nail","middle-nail","ring-nail"]; %図にタイトルつける時に必要なやつ
%% code section

%トリミングした刺激付近の座標情報が入っている.MATファイルの中身を取得する
current_dir = pwd;
file_dir = [current_dir '/merged_coodination/' data_type '/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_'  num2str(length(target_date)) '/stim_start_frame.mat' ];
load(file_dir);

%各フレーム間のユークリッド距離を求める(ベクトルは加味しない)
%スカラーを代入する行列をあらかじめ0行列で作っておく
point_scalar = cell(length(target_date),1);
for ii = 1:length(target_date)
    point_scalar{ii,1} = zeros(length(coodinate_info{ii,1})-1,point_num);
end
%実際にスカラーを求めてpoint_scalarに代入していく※スカラーは始まりのフレームのx,y,zを原点として、各フレームの原点からの距離をスカラーとした
for ii = 1:length(target_date)
    for jj =1:point_num
        for kk = 1:length(coodinate_info{ii,1})-1
            V_pre = [0 0 0];
            %V_pre = coodinate_info{ii,1}(kk,3*jj-2:3*jj); %基準となる座標(x,y,z)
            V_post = coodinate_info{ii,1}(kk+1,3*jj-2:3*jj); %基準となる座標の1フレーム後の座標(x,y,z)
            %↓V_preかV_postのいずれかにNaN値が含まれていた場合,point_scalarにNaNを代入して次のループへ行く
            if ~isempty(find(isnan(V_post), 1))
                point_scalar{ii,1}(kk,jj) = NaN;
                continue;
            end
            dV = V_post-V_pre; %座標の変位
            n = norm(dV); %変位(ユークリッドノルム)
            %↓3次元プロット用にノルムが最大となる時のxyz軸の要素を記録しておく
            if kk == 1
                max_norm = n;
                max_coodination{ii,jj} = V_post; 
            elseif n > max_norm
                max_norm = n;
                max_coodination{ii,jj} = V_post; 
            end
            point_scalar{ii,1}(kk,jj) = n;
        end
    end
end
%得られたデータを基にプロットしていく
h = figure;
set(h,'Position',[0 0 1920 1080]) %figureの大きさ設定
for ii = 1:point_num
    subplot(point_num,1,ii)
    hold on
    for jj = 1:length(target_date)
        target_coodinate = point_scalar{jj,1}(:,ii);
        if contain_pre_surgery==1
            if jj==1 %22000の時
                 plot(target_coodinate,'color','b','LineWidth',2);
            else
                p_color = ((255*(jj-1))/(length(target_date)-1))-0.0001;
                color_ele = p_color/255 ; 
                plot(target_coodinate,'color',[color_ele,0,0],'LineWidth',2);
            end
        else
            p_color = ((255*jj)/(length(target_date)))-0.0001;
            color_ele = p_color/255 ; 
            plot(target_coodinate,'color',[color_ele,0,color_0],'LineWidth',2);
        end
    end
    title(point_header(ii),'fontsize',22)
    grid on;
    yline(0,'k','LineWidth',1);
    hold off
end
%図とデータを保存する
switch data_type
    case 'ulnar'
        mkdir(['merged_coodination/ulnar/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) ]);
        saveas(gcf,['merged_coodination/ulnar/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) '/ulnar_stim_scalar.fig' ]);
        saveas(gcf,['merged_coodination/ulnar/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) '/ulnar_stim_scalar.png' ]);
        save(['merged_coodination/ulnar/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) '/stim_scalar.mat' ],'point_scalar')
    case 'radial'
        mkdir(['merged_coodination/radial/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) ]);
        saveas(gcf,['merged_coodination/radial/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) '/radial_stim_scalar.fig' ]);
        saveas(gcf,['merged_coodination/radial/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) '/radial_stim_scalar.png' ]);
        save(['merged_coodination/radial/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) '/stim_scalar.mat' ],'point_scalar')
end
close all;

%３次元座標に変異をプロットしていく
quiver3(0,0,0,2,0,0,'color','k','LineWidth',2)
hold on
quiver3(0,0,0,0,2,0,'color','k','LineWidth',2)
quiver3(0,0,0,0,0,2,'color','k','LineWidth',2)
for ii = 1:length(target_date)
    for jj = 1:point_num
        if jj==1
            max_norm = norm(max_coodination{ii,jj});
            point_index = jj;
        elseif norm(max_coodination{ii,jj})>max_norm
            max_norm = norm(max_coodination{ii,jj});
            point_index = jj;
        end
    end
    ref_coodination{ii,1} = max_coodination{ii,point_index};
end
for ii = 1:length(target_date)
    if contain_pre_surgery==1
        target_coodinate = ref_coodination{ii,1};
        if ii==1 %22000の時
             quiver3(0,0,0,target_coodinate(1),target_coodinate(2),target_coodinate(3),'color','b','LineWidth',2);
        else
            p_color = ((255*(ii-1))/(length(target_date)-1))-0.0001;
            color_ele = p_color/255 ; 
            quiver3(0,0,0,target_coodinate(1),target_coodinate(2),target_coodinate(3),'color',[color_ele,0,0],'LineWidth',2);
        end
    else
        p_color = ((255*ii)/(length(target_date)))-0.0001;
        color_ele = p_color/255 ; 
        quiver3(0,0,0,target_coodinate(1),target_coodinate(2),target_coodinate(3),'color',[color_ele,0,0],'LineWidth',2);
    end
end
xlim([-10 10])
ylim([-10,10])
zlim([-15 15])
xlabel('x (mm)','fontsize',16)
ylabel('y (mm)','fontsize',16)
zlabel('z (mm)','fontsize',16)

switch data_type
    case 'ulnar'
        mkdir(['merged_coodination/ulnar/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) ]);
        saveas(gcf,['merged_coodination/ulnar/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) '/ulnar_stim_vector.fig' ]);
        saveas(gcf,['merged_coodination/ulnar/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) '/ulnar_stim_vector.png' ]);
    case 'radial'
        mkdir(['merged_coodination/radial/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) ]);
        saveas(gcf,['merged_coodination/radial/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) '/radial_stim_vector.fig' ]);
        saveas(gcf,['merged_coodination/radial/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) '/radial_stim_vector.png' ]);
end
close all;
