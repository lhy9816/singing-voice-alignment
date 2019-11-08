function  [end_usr_idx, end_ref_idx] = findNextMatch(seg1,seg2,cur_usr_idx,cur_ref_idx)
% find_next_match 找到下一个匹配的usr与ref的两段各自的起止位置
% input:
%       seg1 -- usr     seg2 -- ref
%       cur_usr_idx -- 现在即将要匹配的usr轨序数
%       cur_ref_idx -- 现在即将要匹配的ref轨序数
%       
%  output:
%       end_usr_idx 匹配结束的usr轨序数
%       end_ref_idx 匹配结束的ref轨序数

% 中心思想是从cur_usr_idx到end_usr_idx这段时长和cur_ref_idx到end_ref_idx这段时长尽可能相近
end_usr_idx = cur_usr_idx;
end_ref_idx = cur_ref_idx;
u_len = double(seg1.ed(cur_usr_idx)-seg1.bg(cur_usr_idx)+1);
r_len = double(seg2.ed(cur_ref_idx)-seg2.bg(cur_ref_idx)+1);
delta=u_len;
while 1
    %u_bg = seg1.bg(cur_usr_idx);  r_bg=seg2.bg(cur_ref_idx);
    
    if abs(u_len-r_len)<max(0.2*delta,90) | (r_len-u_len<0.31*delta & r_len>u_len)
        % 考虑到歌手总是唱的长一点，所以将歌手唱长的时间扩大至0.31
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


