function  [splt]= segmentAlign(seg_user, seg_ref, x_user, x_ref, fs_user, fs_ref, f0_p_user, f0_p_ref, config_first, config_regular)
% align at segment level
% input: seg_user, seg_ref: struct, recording the beginning and end of each segment and segment number
%        x_user, x_ref:     source mono-channel audio
%        fs_user, fs_ref:   frequency
%        f0_p_user, f0_p_ref: f0_parameter, including the timestep, f0 value in this timestep and voiced/unvoiced information
%        config.first:      feature used when aligning the beginning of the two audio
%        config.regular:    feature used when aligning the rest of the two audio
% output: splt:             alignment between the segment index

%% Ѱ�ҵ�һ��
ref_seg_len = 3;                                                           % ����ÿ��ƥ�䣬ref�ε�ƥ�们������Ϊ3�����������Χ���迼��
ref_dist_scale = zeros(1, ref_seg_len);

first_usr_seg_len = seg_user.ed(1) - seg_user.bg(1);                       % ��һ��usr��ʱ��������karaoke�ĵ�ʱ�Կ�����Ϊuser�κ�ref�γ���ͬ�־��ʱ������һ��
usr_sig_bg = floor(fs_user*f0_p_user.temporal_positions(seg_user.bg(1)));  % ��ȡuser��һ�仰�Ŀ�ʼtimestep
it=1;
% ��֤��һ���㹻������һ�仰�ĳ��ȣ�����ѡΪ260000
while 1 
    usr_sig_ed = floor(fs_user*f0_p_user.temporal_positions(seg_user.ed(it)));
    usr_sig_leng = usr_sig_ed-usr_sig_bg;
    if usr_sig_leng > 260000
        break;
    end
    it=it+1;
end
% ȷ��ref�ж�Ӧuser��һ�����ʼ��
for i=1:ref_seg_len
   ref_sig_bg = floor(fs_ref*f0_p_ref.temporal_positions(seg_ref.bg(i)));
    it=i;
    while 1
        ref_sig_ed = floor(fs_user*f0_p_user.temporal_positions(seg_ref.ed(it)));
        ref_sig_leng = ref_sig_ed-ref_sig_bg;
        % ��ref����һ�򼸶εĳ�����user��һ�γ����൱���ߴ���user��һ�γ���ʱ(����user���ĳ���һ��С��ref������һ�����ھ���Ϊʱ����ƥ��)����Ϊ�������ڳ����Ͽ���ƥ��
        if abs(ref_sig_leng-usr_sig_leng)<0.1*usr_sig_leng | ref_sig_leng-usr_sig_leng>0.1*usr_sig_leng
            break;
        end
        it=it+1;
    end
   % ����config_first�Ĳ���������ѧ����ƥ�䣬��øö�user��ref�ε���ѧ�ϵ����ƶ�
   [ref_dist_scale(i),~] = alignAudioFeature( x_user(usr_sig_bg:usr_sig_ed),fs_user, x_ref(ref_sig_bg:ref_sig_ed), fs_ref, config_first);
end

 %��ȡͷ��ƥ��Σ�����������ƶȴ�ref_seg_len����ѡref��ѡȡ���һ��user��ƥ���ͷ��
 % ��dtw_dist
 % [score, first_ref_alg] = min(ref_dist_scale);
 % ��corr
 [score, first_ref_alg] = max(ref_dist_scale);
 seg_ref.fst = first_ref_alg;
 
 %% ֮��ÿ�δ�usr�����ó���һЩ����˳��ƥ�䣬ref���usr���˳�����Ų��ÿһ�������usrû�г��ľ�Ҫ�ж�Ӧ�ĳ���ʱ��
 splt = [];
 cur_usr_idx=1;                                                            % ��ǰ���һ����ƥ��user��
 cur_ref_idx = first_ref_alg;                                              % ��ǰ���һ����ƥ��ref��
 sen_length_shd=800000; % ��Ŀ����и���ĵ�һ������Ϊ��20s
%  usr_voice_ed=floor(fs_user*f0_p_user.temporal_positions(seg_user.ed(end)));
%  ref_voice_ed=floor(fs_ref*f0_p_ref.temporal_positions(seg_ref.ed(end)));
 delta_sen_len=200;
 % ��֤��ƥ���ref��user�ζ���segment��������
 while cur_usr_idx <= seg_user.cnt & cur_ref_idx <= seg_ref.cnt
      end_usr_idx = zeros(1,ref_seg_len);
      end_ref_idx = zeros(1,ref_seg_len);
      len_range = zeros(1,ref_seg_len);
     for i=1:ref_seg_len
        bg_ref_idx=min(cur_ref_idx+i-1,seg_ref.cnt);
        % user�ε�һ���Ѿ�ƥ�䣬������Ϊָ����userƥ��ĵ�һ��ref��cur_ref_idx
        if cur_usr_idx==1 & bg_ref_idx~=cur_ref_idx
            ref_dist_scale(i)=-1e10;
            len_range(i)=10000;
            continue;
        end
        % �ҳ�user�Ƿ��ٳ�һ�䣬������Ϊֻ��usr�ٳ���ref�����ٳ�
        if cur_usr_idx>1
            %interval_step=get_interval_step(seg1.bg(cur_usr_idx),seg1.ed(cur_usr_idx-1),seg1.bg(cur_usr_idx-1),seg2.bg(bg_ref_idx),seg2.ed(splt(2,end)),seg2.bg(splt(2,end-1)),bg_bg_rt);
           interval_step=get_interval_step(seg_user.bg(cur_usr_idx),seg_user.ed(cur_usr_idx-1),seg_user.bg(cur_usr_idx-1),seg_ref.bg(bg_ref_idx),seg_ref.ed(splt(2,end)),seg_ref.bg(splt(2,end-1)), 1);
           % interval_step������˵��user��һ��unvoicedͣ��ʱ��������������������Ϊuser�����ٳ���һ�䣬������ƥ������ƶ���Ϊ��Ϊ-1e10
           if interval_step>delta_sen_len
               ref_dist_scale(i)=-1e10;
               len_range(i)=10000;
               continue;
           end
        end
        % find_next_match���ҵ�������user��ref��ƥ��ļ��Σ���[cur_user_idx(i)~end_usr_idx(i)]��[cur_ref_idx(i)~end_ref_idx(i)]��Щ��ƥ��
        [end_usr_idx(i), end_ref_idx(i)] = findNextMatch(seg_user,seg_ref,cur_usr_idx,bg_ref_idx);
        usr_sig_bg = floor(fs_user*f0_p_user.temporal_positions(seg_user.bg(cur_usr_idx)));
        usr_sig_ed = floor(fs_user*f0_p_user.temporal_positions(seg_user.ed(end_usr_idx(i))));
        % ���ƥ��Ķ�ʱ��̫��(����20s)�������öΣ���Ϊ�޷�ƥ��
        if usr_sig_ed-usr_sig_bg>sen_length_shd
            ref_dist_scale(i)=1e10;
            len_range(i)=10000;
            continue;
        end
       
        ref_sig_bg = floor(fs_ref*f0_p_ref.temporal_positions(seg_ref.bg(bg_ref_idx)));
        ref_sig_ed = floor(fs_ref*f0_p_ref.temporal_positions(seg_ref.ed(end_ref_idx(i))));
        
        len_range(i)=usr_sig_ed - usr_sig_bg;
        % ���ֽ��бȽϵ����γ�����һ�������Է�ֹ��Сƥ��
        if len_range(i) < 250000
            usr_sig_ed=min(usr_sig_bg+250000,length(x_user));
            ref_sig_ed=min(ref_sig_bg+250000,length(x_ref));
        end
        % ���ҳ���ref��user�ν�����ѧ�������ƶȼ���
        [ref_dist_scale(i),~] = alignAudioFeature( x_user(usr_sig_bg:usr_sig_ed),fs_user, x_ref(ref_sig_bg:ref_sig_ed), fs_ref,config_regular);
     end
     
     if all(~(diff(end_usr_idx)))                                           % ���end_usr_idx�������еĽ���ֵ��һ��
         mincost_match_idx = 1;                                             % ֱ��ѡ��һ��
     else
        [~, mincost_match_idx] = max(ref_dist_scale);                       % ����ѡ���ƶ�����
     end
     splt_ref_bg = cur_ref_idx+mincost_match_idx-1;                         % ����spltƥ���б�
     splt = [splt'; cur_usr_idx splt_ref_bg]';
     splt = [splt'; end_usr_idx(mincost_match_idx) end_ref_idx(mincost_match_idx)]';

     cur_usr_idx = end_usr_idx(mincost_match_idx)+1;                        % user��ref�����ƥ��segment index��ǰ�ƽ�
     cur_ref_idx = end_ref_idx(mincost_match_idx)+1;
 end
end

function step=get_interval_step(usr_bg,usr_last_ed,usr_last_bg, ref_bg,ref_last_ed,ref_last_bg,ratio)
% get minimum step between segments
% ���仰�б��俪ͷ���Ͼ��β(_step1)֮���ʱ����
usr_step1=double(usr_bg-usr_last_ed);
usr_step2=double(usr_bg-usr_last_bg);
ref_step1=double(ref_bg-ref_last_ed);
ref_step2=double(ref_bg-ref_last_bg);
step=min(abs(usr_step1-ref_step1), ratio*abs(usr_step2-ref_step2));
end