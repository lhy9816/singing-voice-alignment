function [ overall_target ] = noteAlign( x_ref, fs_ref, x_usr, fs_usr, seg1, seg2, f0_1, f0_2,splt,config,ratio )
%align_note_formant 段内匹配，采用deDTW算法
%   对已经进行完毕的每一段进行段内匹配
%   采用ltc的系数或lpc的系数或sp系数共24维作为alignment的特征
%   采用窗长为50ms hopsize为25ms进行试验，每一个subsequence的长度取10,subsequence的长度必须是偶数！！
currentFolder = pwd;
addpath(genpath(currentFolder))
seg_len = length(splt(1,:));
overall_target = [];
% 针对每一段的段内进行匹配
for i=1:floor(seg_len/2)
    % 获取段的起始点与结束点以及匹配段
    usr_bg = floor(fs_usr*f0_1.temporal_positions(seg1.bg(splt(1,2*i-1))));
    usr_ed = ceil(fs_usr*f0_1.temporal_positions(seg1.ed(splt(1,2*i))));
    ref_bg = floor(fs_ref*f0_2.temporal_positions(seg2.bg(splt(2,2*i-1))));
    ref_ed = ceil(fs_ref*f0_2.temporal_positions(seg2.ed(splt(2,2*i))));
    usr_seg = x_usr(usr_bg:usr_ed);
    ref_seg = x_ref(ref_bg:ref_ed);
    % 跑一下alignment程序获得两段段内的alignment matrix
    [~,align_section] = alignAudioFeature(usr_seg,fs_usr,ref_seg,fs_ref,config,ratio);
    overall_target = [overall_target align_section'];
 
    % 如果某一段
    if i~=floor(seg_len/2)
        mute_bg = floor(fs_ref*f0_2.temporal_positions(seg2.ed(splt(2,2*i))));
        mute_ed = ceil(fs_ref*f0_2.temporal_positions(seg2.bg(splt(2,2*i+1))));
        mute_seg = x_ref(mute_bg:mute_ed);
        % 需要降采样到6144hz
        mute_seg = [resample(mute_seg, 6144, 44100)';resample(mute_seg, 6144, 44100)'];
        overall_target = [overall_target mute_seg];
    end
end
end


