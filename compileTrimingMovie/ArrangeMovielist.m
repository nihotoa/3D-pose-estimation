%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%100以上のトライアルがあったとき、moviefileListの順序を変更するための関数
%(デフォルトだと11より100が前に来てしまうため)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function movie_fileList = ArrangeMovielist(movie_fileList)
    above_count=1;
    count = 1;
    for jj = 1:length(movie_fileList)
        check_fileList = movie_fileList(jj);
        %↓ファイル名からトライアル数の部分を抜き出してtrial_numに代入する
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
    if exist('above_hundred') %タスクが100回以上であるならば
        movie_fileList = [temp_list;above_hundred];
    end
end

