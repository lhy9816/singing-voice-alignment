function  [end_usr_idx, end_ref_idx] = findNextMatch(seg1,seg2,cur_usr_idx,cur_ref_idx)
% find_next_match �ҵ���һ��ƥ���usr��ref�����θ��Ե���ֹλ��
% input:
%       seg1 -- usr     seg2 -- ref
%       cur_usr_idx -- ���ڼ���Ҫƥ���usr������
%       cur_ref_idx -- ���ڼ���Ҫƥ���ref������
%       
%  output:
%       end_usr_idx ƥ�������usr������
%       end_ref_idx ƥ�������ref������

% ����˼���Ǵ�cur_usr_idx��end_usr_idx���ʱ����cur_ref_idx��end_ref_idx���ʱ�����������
end_usr_idx = cur_usr_idx;
end_ref_idx = cur_ref_idx;
u_len = double(seg1.ed(cur_usr_idx)-seg1.bg(cur_usr_idx)+1);
r_len = double(seg2.ed(cur_ref_idx)-seg2.bg(cur_ref_idx)+1);
delta=u_len;
while 1
    %u_bg = seg1.bg(cur_usr_idx);  r_bg=seg2.bg(cur_ref_idx);
    
    if abs(u_len-r_len)<max(0.2*delta,90) | (r_len-u_len<0.31*delta & r_len>u_len)
        % ���ǵ��������ǳ��ĳ�һ�㣬���Խ����ֳ�����ʱ��������0.31
        break;
    end
    if end_ref_idx>seg2.cnt | end_usr_idx>seg1.cnt
       break; 
    end
    if (u_len > r_len & end_ref_idx <= seg2.cnt)
        if end_ref_idx == seg2.cnt
            break;
        end
        end_ref_idx = end_ref_idx+1;
        if end_ref_idx>seg2.cnt
            break;
        end
       
        delta=seg2.ed(end_ref_idx)-seg2.ed(end_ref_idx-1)+1;
        r_len = r_len+(seg2.ed(end_ref_idx)-seg2.ed(end_ref_idx-1)+1);
    elseif (u_len < r_len & end_usr_idx <= seg1.cnt)
       if end_usr_idx == seg1.cnt
          break; 
       end
        end_usr_idx = end_usr_idx+1;
        if end_usr_idx>seg1.cnt
            break;
        end
        
        delta=seg1.ed(end_usr_idx)-seg1.ed(end_usr_idx-1)+1;
        u_len = u_len+(seg1.ed(end_usr_idx)-seg1.ed(end_usr_idx-1)+1);
    end
end
end


