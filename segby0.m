function seg = segby0(f0, minLen)
% segment F0 based on voice-unvoiced duration
% input: f0: f0 curve
% 	     minLen: the minimum duration for a segment that can be recognized as voiced segment
len = size(f0, 2);
cnt = 0;
vld = zeros(1, len);
blk_idx = zeros(1, len);
bg = zeros(1, len);
ed = zeros(1, len);
flg = 0;
last_fake_first=-1e10;      % ��һ����Ϊʱ��̫�̶���Ĩȥ�ĶεĿ�ʼ
for i = 1:len
    if flg == (f0(i)>30) %��ʶλ�Ǹ�ʶγ���
        vld(i) = flg;
        continue;
    else
        if flg == 0 %δ�����ʶΣ����ֵ�һ������f0
%             if i-last_fake_first <100
%                 cnt=cnt+1;
%                 bg(cnt)=last_fake_first;
%                 for kk=last_fake_first:i
%                     vld(kk)=1;
%                 end
%             else
%                 cnt = cnt + 1;
%                 bg(cnt) = i;
%             end
            cnt = cnt + 1;
            bg(cnt) = i;
            flg = 1;
        else %��ʶν��������ֵ�һ����f0
            ed(cnt) = i-1;
            flg = 0;
            if ed(cnt) - bg(cnt) < minLen
                %last_fake_first=bg(cnt);
                cnt = cnt - 1;
                tmp = i-1;
                while vld(tmp) == 1
                    vld(tmp) = 0;
                    tmp = tmp - 1;
                end
            end
        end
        vld(i) = flg;
    end
end
%Ϊÿһ��f0��Ч����
% flag=0;
% idx=0;
% for i=1:len
%    if(vld(i)==1 & flag==0)
%        blk_idx(i)= idx;
%        flag=1;
%        idx = idx + 1;
%    elseif(vld(i)==0 & flag==1)
%        flag=0;
%        blk_idx(i)
% end

if ed(cnt) < bg(cnt)        %���һ��ǿ�ƽ���
    ed(cnt) = len;
end
% Ѱ���Ƿ���������֮���к�Сһ�εģ�����һ�κ�ǰ�����κϲ�
bg_fix=[bg(1)];
ed_fix = [];
for i=1:cnt-1
    if bg(i+1)-ed(i)<100
        int_len=bg(i+1)-ed(i)+1;
        int_bg = ed(i)+1;    int_ed = bg(i+1)-1;
        sound_seg=find(f0(int_bg:int_ed)>30);                   % �м��intervalֻ��һ������������������
        if ~isempty(sound_seg) & (sound_seg(end)-sound_seg(1)+1 == length(sound_seg)) & ...
            sum(f0(int_bg:int_ed)>30)>int_len/2                  % �м��interval����һ����������������һ���ֲ���ȥ
            continue;
        else
            ed_fix = [ed_fix ed(i)];
            bg_fix = [bg_fix bg(i+1)];
        end
    else
       ed_fix = [ed_fix ed(i)];
       bg_fix = [bg_fix bg(i+1)];
    end
end
ed_fix = [ed_fix ed(cnt)];
bg = bg_fix;    ed = ed_fix;
cnt = length(bg);
%�ϲ��μ��ϵ
bg_modify=[]; bg_modify = [bg_modify bg(1)];
ed_modify = [];
for i=1:cnt-1
    if bg(i+1)-ed(i)<=42 % ������ֱ�Ӻ���һ��
        continue;
    else
        bg_modify = [bg_modify bg(i+1)];
        ed_modify = [ed_modify ed(i)];
    end
end
ed_modify = [ed_modify ed(cnt)];
% �ٴӺ���ǰ����һ�£���ÿһ�ο�ʼ��ʱ��ǰ����ֵĽ�С�����β���
i = length(bg_modify);
while i>=1
   flag=0;
   idx = bg_modify(i)-1;
   j=idx;
   if i>1
       while j > max(ed_modify(i-1),idx-34)
           if f0(j)>30
              while f0(j)>30 
                 j=j-1; 
              end
              tmp_bg=j+1;
              bg_modify(i)=tmp_bg;
              flag=1;
              continue;
           end
           j=j-1;
       end
   else
       while j > idx-34
           if f0(j)>30
              while f0(j)>30 
                 j=j-1; 
              end
              tmp_bg=j+1;
              bg_modify(i)=tmp_bg;
              flag=1;
              continue;
           end
           j=j-1;
        end
   end
   if flag==1
       continue;
   end
   i=i-1;
end
%%
for i=1:length(ed_modify)
    for j=bg_modify(i):ed_modify(i)
       vld(j)=1; 
    end
end
seg.bg = bg_modify;
seg.ed = ed_modify;
seg.cnt = length(bg_modify);
seg.vld = vld;


end
