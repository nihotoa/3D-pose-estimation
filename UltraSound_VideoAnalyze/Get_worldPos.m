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
      u1 = imagePos(jj,1+2*(i-1));%カメラ1からの画像座標を抽出する
      v1 = imagePos(jj,2*i);
      u2 = imagePos(jj,PNum*2+1+2*(i-1)); %カメラ2からの画像座標を代入する
      v2 = imagePos(jj,PNum*2+2+2*(i-1));
      a1 = a(:,use_cam(1,1)); %カメラパラーメータの抽出
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
%Cに使用する2台のカメラの番号を代入する
%{
  n2 = 1; C = [];
  for(n = 1 : CNum)
    if(useCam(P(1, i), n) ~= 0)
      C(n2) = useCam(P(i), n);
      n2 = n2 + 1;
    end
  end
%}

%↓三次元座標の再構成(詳しくは酒井さん資料のP20,P21を参照) tempがpdfのXに対応するベクトル.Xが再構成された3次元座標であり、
%{
  for(f = f_start : f_end)
    y = []; A = []; temp = [];

      for(n = 1 : length(C))
        u = imagePos(f, 2 * PNum * (C(n) - 1) + 2 * P(i) - 1);
        v = imagePos(f, 2 * PNum * (C(n) - 1) + 2 * P(i));

        y(2 * C(n) - 1, 1) = u - a(4, C(n));
        y(2 * C(n), 1)       = v - a(8, C(n));

        for(m = 1 : 3)
          A(2 * C(n) - 1, m) = a(m, C(n)) - a(8 + m, C(n)) * u;
          A(2 * C(n), m)       = a(4 + m, C(n)) - a(8 + m, C(n)) * v;
        end
      end
      temp = inv(transpose(A) * A) * transpose(A) * y;
      X(f, 3 * P(i) - 2) = temp(1, 1);
      X(f, 3 * P(i) - 1) = temp(2, 1);
      X(f, 3 * P(i))     = temp(3, 1);
  end
%}