clear;
%% set param
current_dir = pwd;
data_type = 'ulnar';
target_date = [220000,220530,220606,220620];
point_num = 3;
fig_dir = [current_dir '/merged_coodination/' data_type '/' num2str(target_date(1)) 'to' num2str(target_date(end)) '_' num2str(length(target_date)) '/'];
%% code section
h = openfig([fig_dir data_type '_stim_vector.fig']);
set(h,'Position',[0 0 1920 1080]) %figure�̑傫���ݒ�

% �}����]����,�r�f�I�ɂ��ĕۑ�
cd(fig_dir);
v = VideoWriter([data_type '-vector.mp4'],'MPEG-4'); %����t�@�C�����쐬���A�󂯎M�����(2�ڂ̈����͓���̃R�[�f�b�N)
open(v);

for n = 1:360
    view([n, 30]);
    drawnow; % �`��X�V
    frame = getframe(h); %���݂�figure�̏�Ԃ��擾
    writeVideo(v,frame); %�󂯎M�ɓ����ۑ�
end
cd(current_dir);
close all;