%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%100�ȏ�̃g���C�A�����������Ƃ��AmoviefileList�̏�����ύX���邽�߂̊֐�
%(�f�t�H���g����11���100���O�ɗ��Ă��܂�����)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function movie_fileList = ArrangeMovielist(movie_fileList)
    above_count=1;
    count = 1;
    for jj = 1:length(movie_fileList)
        check_fileList = movie_fileList(jj);
        %���t�@�C��������g���C�A�����̕����𔲂��o����trial_num�ɑ������
        temp = check_fileList.name;
        temp = extractAfter(temp,'trial_');
        trial_num = str2double(extractBefore(temp,'.avi'));
        if trial_num >= 100
            above_hundred(above_count,:) = movie_fileList(jj,:);
            above_count = above_count+1;
        else
            temp_list(count,:) = movie_fileList(jj,:);
            count=count+1;
        end
    end
    if exist('above_hundred') %�^�X�N��100��ȏ�ł���Ȃ��
        movie_fileList = [temp_list;above_hundred];
    end
end

