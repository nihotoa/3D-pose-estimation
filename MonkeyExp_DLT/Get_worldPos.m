function X = Get_worldPos(i, imagePos, CamParam, setting)
  %iはマーカーiを意味している
  f_start = setting.f_start; f_end = setting.f_end;
  PNum = setting.PNum;  
  CNum = setting.CNum;
  useCam = setting.useCam;
  P = setting.P;
  a = CamParam;
  X = zeros([f_end 3 * PNum]);
  
  for jj = 1:length(imagePos)
      use_cam = eval(['useCam.point' num2str(i) '(jj,:);' ]);
      u1 = imagePos(jj,((2*i)-1)+8*(use_cam(1,1)-1));
      v1 = imagePos(jj,(2*i)+8*(use_cam(1,1)-1));
      u2 = imagePos(jj,((2*i)-1)+8*(use_cam(1,2)-1));
      v2 = imagePos(jj,(2*i)+8*(use_cam(1,2)-1));
      a1 = a(:,use_cam(1,1));
      a2 = a(:,use_cam(1,2));
      
      y = [u1-a1(4,1);v1-a1(8,1);u2-a2(4,1);v2-a2(8,1)];
      A = [a1(1,1)-a1(9,1)*u1,a1(2,1)-a1(10,1)*u1,a1(3,1)-a1(11,1)*u1;
           a1(5,1)-a1(9,1)*v1,a1(6,1)-a1(10,1)*v1,a1(7,1)-a1(11,1)*v1;
           a2(1,1)-a2(9,1)*u2,a2(2,1)-a2(10,1)*u2,a2(3,1)-a2(11,1)*u2;
           a2(5,1)-a2(9,1)*v2,a2(6,1)-a2(10,1)*v2,a2(7,1)-a2(11,1)*v2];
      temp = inv(transpose(A)*A)*transpose(A)*y;
      X(jj,1+3*(i-1)) = temp(1,1);
      X(jj,2+3*(i-1)) = temp(2,1);
      X(jj,3+3*(i-1)) = temp(3,1);
  end
end

