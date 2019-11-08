function  [splt]= segmentAlign(seg_user, seg_ref, x_user, x_ref, fs_user, fs_ref, f0_p_user, f0_p_ref, config_first, config_regular)
% align at segment level
% input: seg_user, seg_ref: struct, recording the beginning and end of each segment and segment number
%        x_user, x_ref:     source mono-channel audio
%        fs_user, fs_ref:   frequency
%        f0_p_user, f0_p_ref: f0_parameter, including the timestep, f0 value in this timestep and voiced/unvoiced information
%        config.first:      feature used when aligning the beginning of the two audio
%        config.regular:    feature used when aligning the rest of the two audio
% output: splt:             alignment between the segment index

%% 寻找第一段
ref_seg_len = 3;                                                           % 对于每次匹配，ref段的匹配滑动窗长为3，超出这个范围不予考虑
ref_dist_scale = zeros(1, ref_seg_len);

first_usr_seg_len = seg_user.ed(1) - seg_user.bg(1);                       % 第一轨usr的时长，由于karaoke的等时性可以认为user段和ref段唱相同乐句的时长几乎一致
usr_sig_bg = floor(fs_user*f0_p_user.temporal_positions(seg_user.bg(1)));  % 获取user第一句话的开始timestep
it=1;
% 保证第一轨足够长，有一句话的长度，这里选为260000
while 1 
    usr_sig_ed = floor(fs_user*f0_p_user.temporal_positions(seg_user.ed(it)));
    usr_sig_leng = usr_sig_ed-usr_sig_bg;
    if usr_sig_leng > 260000
        break;
    end
    it=it+1;
end
% 确定ref中对应user第一句的起始段
for i=1:ref_seg_len
   ref_sig_bg = floor(fs_ref*f0_p_ref.temporal_positions(seg_ref.bg(i)));
    it=i;
    while 1
        ref_sig_ed = floor(fs_user*f0_p_user.temporal_positions(seg_ref.ed(it)));
        ref_sig_leng = ref_sig_ed-ref_sig_bg;
        % 当ref唱的一或几段的长度与user第一段长度相当或者大于user第一段长度时(由于user唱的长度一般小于ref，所以一旦大于就认为时长上匹配)，认为这两段在长度上可能匹配
        if abs(ref_sig_leng-usr_sig_leng)<0.1*usr_sig_leng | ref_sig_leng-usr_sig_leng>0.1*usr_sig_leng
            break;
        end
        it=it+1;
    end
   % 根据config_first的参数进行声学参数匹配，获得该对user和ref段的声学上的相似度
   [ref_dist_scale(i),~] = alignAudioFeature( x_user(usr_sig_bg:usr_sig_ed),fs_user, x_ref(ref_sig_bg:ref_sig_ed), fs_ref, config_first);
end

 %获取头部匹配段，按照最大相似度从ref_seg_len个候选ref中选取与第一个user段匹配的头部
 % 对dtw_dist
 % [score, first_ref_alg] = min(ref_dist_scale);
 % 对corr
 [score, first_ref_alg] = max(ref_dist_scale);
 seg_ref.fst = first_ref_alg;
 
 %% 之后每次从usr上面拿出来一些进行顺次匹配，ref轨和usr轨就顺次向后挪，每一次如果有usr没有唱的就要有对应的迟疑时间
 splt = [];
 cur_usr_idx=1;                                                            % 当前最后一个已匹配user段
 cur_ref_idx = first_ref_alg;                                              % 当前最后一个已匹配ref段
 sen_length_shd=800000; % 最长的可能切割出的第一段设置为近20s
%  usr_voice_ed=floor(fs_user*f0_p_user.temporal_positions(seg_user.ed(end)));
%  ref_voice_ed=floor(fs_ref*f0_p_ref.temporal_positions(seg_ref.ed(end)));
 delta_sen_len=200;
 % 保证待匹配的ref和user段都在segment的数量内
 while cur_usr_idx <= seg_user.cnt & cur_ref_idx <= seg_ref.cnt
      end_usr_idx = zeros(1,ref_seg_len);
      end_ref_idx = zeros(1,ref_seg_len);
      len_range = zeros(1,ref_seg_len);
     for i=1:ref_seg_len
        bg_ref_idx=min(cur_ref_idx+i-1,seg_ref.cnt);
        % user段第一个已经匹配，这里人为指定与user匹配的第一段ref是cur_ref_idx
        if cur_usr_idx==1 & bg_ref_idx~=cur_ref_idx
            ref_dist_scale(i)=-1e10;
            len_range(i)=10000;
            continue;
        end
        % 找出user是否少唱一句，这里认为只有usr少唱，ref不会少唱
        if cur_usr_idx>1
            %interval_step=get_interval_step(seg1.bg(cur_usr_idx),seg1.ed(cur_usr_idx-1),seg1.bg(cur_usr_idx-1),seg2.bg(bg_ref_idx),seg2.ed(splt(2,end)),seg2.bg(splt(2,end-1)),bg_bg_rt);
           interval_step=get_interval_step(seg_user.bg(cur_usr_idx),seg_user.ed(cur_usr_idx-1),seg_user.bg(cur_usr_idx-1),seg_ref.bg(bg_ref_idx),seg_ref.ed(splt(2,end)),seg_ref.bg(splt(2,end-1)), 1);
           % interval_step过长，说明user有一段unvoiced停留时间过长，在这种情况下认为user可能少唱了一句，这两段匹配的相似度人为设为-1e10
           if interval_step>delta_sen_len
               ref_dist_scale(i)=-1e10;
               len_range(i)=10000;
               continue;
           end
        end
        % find_next_match会找到长度上user和ref最匹配的几段，即[cur_user_idx(i)~end_usr_idx(i)]和[cur_ref_idx(i)~end_ref_idx(i)]这些段匹配
        [end_usr_idx(i), end_ref_idx(i)] = findNextMatch(seg_user,seg_ref,cur_usr_idx,bg_ref_idx);
        usr_sig_bg = floor(fs_user*f0_p_user.temporal_positions(seg_user.bg(cur_usr_idx)));
        usr_sig_ed = floor(fs_user*f0_p_user.temporal_positions(seg_user.ed(end_usr_idx(i))));
        % 如果匹配的段时长太长(超过20s)，放弃该段，认为无法匹配
        if usr_sig_ed-usr_sig_bg>sen_length_shd
            ref_dist_scale(i)=1e10;
            len_range(i)=10000;
            continue;
        end
       
        ref_sig_bg = floor(fs_ref*f0_p_ref.temporal_positions(seg_ref.bg(bg_ref_idx)));
        ref_sig_ed = floor(fs_ref*f0_p_ref.temporal_positions(seg_ref.ed(end_ref_idx(i))));
        
        len_range(i)=usr_sig_ed - usr_sig_bg;
        % 保持进行比较的两段长度在一句以上以防止过小匹配
        if len_range(i) < 250000
            usr_sig_ed=min(usr_sig_bg+250000,length(x_user));
            ref_sig_ed=min(ref_sig_bg+250000,length(x_ref));
        end
        % 对找出的ref与user段进行声学参数相似度计算
        [ref_dist_scale(i),~] = alignAudioFeature( x_user(usr_sig_bg:usr_sig_ed),fs_user, x_ref(ref_sig_bg:ref_sig_ed), fs_ref,config_regular);
     end
     
     if all(~(diff(end_usr_idx)))                                           % 如果end_usr_idx里面所有的结束值都一样
         mincost_match_idx = 1;                                             % 直接选第一个
     else
        [~, mincost_match_idx] = max(ref_dist_scale);                       % 否则选相似度最大的
     end
     splt_ref_bg = cur_ref_idx+mincost_match_idx-1;                         % 更新splt匹配列表
     splt = [splt'; cur_usr_idx splt_ref_bg]';
     splt = [splt'; end_usr_idx(mincost_match_idx) end_ref_idx(mincost_match_idx)]';

     cur_usr_idx = end_usr_idx(mincost_match_idx)+1;                        % user与ref的最后匹配segment index向前推进
     cur_ref_idx = end_ref_idx(mincost_match_idx)+1;
 end
end

function step=get_interval_step(usr_bg,usr_last_ed,usr_last_bg, ref_bg,ref_last_ed,ref_last_bg,ratio)
% get minimum step between segments
% 两句话中本句开头和上句结尾(_step1)之间的时间间隔
usr_step1=double(usr_bg-usr_last_ed);
usr_step2=double(usr_bg-usr_last_bg);
ref_step1=double(ref_bg-ref_last_ed);
ref_step2=double(ref_bg-ref_last_bg);
step=min(abs(usr_step1-ref_step1), ratio*abs(usr_step2-ref_step2));
end