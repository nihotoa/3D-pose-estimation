%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Coded by: Naohito Ohta
Last modification:2022/07/01

[function]

[procedure]
pre: CompairUsdata.m
post: vector_movie.m or plot_average_stim_displacement.m

�g����:
UltraSound_VideoAnalyze���J�����g�f�B���N�g���ɂ��Ď��s����
�p�r:
�e�}�[�J�[���ʂ�3�������W�̃X�J���[�ω����v���b�g����v���O����
�x�N�g���͍l�����Ă��Ȃ��̂ŁA�x�N�g�����l������3�������W��ŕ\���������͒ǉ��̃R�[�h���l����K�v������
�O�������W���xlim,ylim,zlim�͒萔�Ŏw�肵�Ă���̂œK�X�ύX���邱��

% ���ӓ_
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%% set param
data_type = 'ulnar';
% target_date = [220000, 220530, 220606, 220620, 220801, 220912, 221011];
target_date = [220000, 220620, 220801, 220912, 221011]; 
point_num = 3;
contain_pre_surgery=1; % pre_surgery�̃f�[�^���܂�ł��邩�ǂ���
point_header = ["index-nail","middle-nail","ring-nail"]; %�}�Ƀ^�C�g�����鎞�ɕK�v�Ȃ��
%% code section

%�g���~���O�����h���t�߂̍��W��񂪓����Ă���.MAT�t�@�C���̒��g���擾����
current_dir = pwd;
file_dir = [current_dir '/merged_coodination/' data_type '/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_'  num2str(length(target_date)) '/stim_start_frame.mat' ];
load(file_dir);

%�e�t���[���Ԃ̃��[�N���b�h���������߂�(�x�N�g���͉������Ȃ�)
%�X�J���[��������s������炩����0�s��ō���Ă���
point_scalar = cell(length(target_date),1);
for ii = 1:length(target_date)
    point_scalar{ii,1} = zeros(length(coodinate_info{ii,1})-1,point_num);
end
%���ۂɃX�J���[�����߂�point_scalar�ɑ�����Ă������X�J���[�͎n�܂�̃t���[����x,y,z�����_�Ƃ��āA�e�t���[���̌��_����̋������X�J���[�Ƃ���
for ii = 1:length(target_date)
    for jj =1:point_num
        for kk = 1:length(coodinate_info{ii,1})-1
            V_pre = [0 0 0];
            %V_pre = coodinate_info{ii,1}(kk,3*jj-2:3*jj); %��ƂȂ���W(x,y,z)
            V_post = coodinate_info{ii,1}(kk+1,3*jj-2:3*jj); %��ƂȂ���W��1�t���[����̍��W(x,y,z)
            %��V_pre��V_post�̂����ꂩ��NaN�l���܂܂�Ă����ꍇ,point_scalar��NaN�������Ď��̃��[�v�֍s��
            if ~isempty(find(isnan(V_post), 1))
                point_scalar{ii,1}(kk,jj) = NaN;
                continue;
            end
            dV = V_post-V_pre; %���W�̕ψ�
            n = norm(dV); %�ψ�(���[�N���b�h�m����)
            %��3�����v���b�g�p�Ƀm�������ő�ƂȂ鎞��xyz���̗v�f���L�^���Ă���
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
%����ꂽ�f�[�^����Ƀv���b�g���Ă���
h = figure;
set(h,'Position',[0 0 1920 1080]) %figure�̑傫���ݒ�
for ii = 1:point_num
    subplot(point_num,1,ii)
    hold on
    for jj = 1:length(target_date)
        target_coodinate = point_scalar{jj,1}(:,ii);
        if contain_pre_surgery==1
            if jj==1 %22000�̎�
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
%�}�ƃf�[�^��ۑ�����
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

%�R�������W�ɕψق��v���b�g���Ă���
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
        if ii==1 %22000�̎�
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
