function a = Get_CamParam(P_world, P_image, setting)

  PNum = setting.PNum; %�}�[�J�[�̐�  
  CNum = setting.CNum; %�J�����̐�
  P_cal = setting.P_cal; %�g�p����`�F�b�N�|�C���g�̐�

    for(j = 1 : CNum)
    %y = zeros([2 * PNum 1]); x = zeros([2 * PNum 11]);%�Ȃ���`����Ă���̂��킩��Ȃ�(���̃��[�v ���ŃT�C�Y�ς���Ă邩��Ӗ��Ȃ��Ǝv��)
        
        if j == 2 %�J����2�����A�f��Ȃ��`�F�b�N�|�C���g������̂ŁAP_cal�Ƃ͕ʂɎ����Ŏg�p����`�F�b�N�|�C���g��I�����ăJ�����p�����[�^���o��
            use_P = [2 4 5 6 7 8]; %�g�p����`�F�b�N�|�C���g�̔ԍ�   
            clear x;
            clear y;
            for i = use_P
              y((2 * i) - 1, 1)     = P_image(i, (2 * j) - 1);
              y(2 * i, 1)           = P_image(i, 2 * j);

              x((2 * i) - 1, 1 : 3) = P_world(i, :);
              x((2 * i) - 1, 4)     = 1;
              x(2 * i, 5 : 7)       = P_world(i, :);
              x(2 * i, 8)           = 1;
              x((2 * i) - 1, 9)     = - P_image(i, (2 * j) - 1) * P_world(i, 1);
              x((2 * i) - 1, 10)    = - P_image(i, (2 * j) - 1) * P_world(i, 2);
              x((2 * i) - 1, 11)    = - P_image(i, (2 * j) - 1) * P_world(i, 3);
              x(2 * i, 9)           = - P_image(i, 2 * j) * P_world(i, 1);
              x(2 * i, 10)          = - P_image(i, 2 * j) * P_world(i, 2);
              x(2 * i, 11)          = - P_image(i, 2 * j) * P_world(i, 3);
            end
        else
            clear x;
            clear y;
            for(i = 1 : P_cal)
                  y((2 * i) - 1, 1)     = P_image(i, (2 * j) - 1);
                  y(2 * i, 1)           = P_image(i, 2 * j);

                  x((2 * i) - 1, 1 : 3) = P_world(i, :);
                  x((2 * i) - 1, 4)     = 1;
                  x(2 * i, 5 : 7)       = P_world(i, :);
                  x(2 * i, 8)           = 1;
                  x((2 * i) - 1, 9)     = - P_image(i, (2 * j) - 1) * P_world(i, 1);
                  x((2 * i) - 1, 10)    = - P_image(i, (2 * j) - 1) * P_world(i, 2);
                  x((2 * i) - 1, 11)    = - P_image(i, (2 * j) - 1) * P_world(i, 3);
                  x(2 * i, 9)           = - P_image(i, 2 * j) * P_world(i, 1);
                  x(2 * i, 10)          = - P_image(i, 2 * j) * P_world(i, 2);
                  x(2 * i, 11)          = - P_image(i, 2 * j) * P_world(i, 3);
            end
        end
        a(:, j) = inv(transpose(x) * x) * transpose(x) * y;
    end
end
