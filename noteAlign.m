function [ overall_target ] = noteAlign( x_ref, fs_ref, x_usr, fs_usr, seg1, seg2, f0_1, f0_2,splt,config,ratio )
%align_note_formant ����ƥ�䣬����deDTW�㷨
%   ���Ѿ�������ϵ�ÿһ�ν��ж���ƥ��
%   ����ltc��ϵ����lpc��ϵ����spϵ����24ά��Ϊalignment������
%   ���ô���Ϊ50ms hopsizeΪ25ms�������飬ÿһ��subsequence�ĳ���ȡ10,subsequence�ĳ��ȱ�����ż������
currentFolder = pwd;
addpath(genpath(currentFolder))
seg_len = length(splt(1,:));
overall_target = [];
% ���ÿһ�εĶ��ڽ���ƥ��
for i=1:floor(seg_len/2)
    % ��ȡ�ε���ʼ����������Լ�ƥ���
    usr_bg = floor(fs_usr*f0_1.temporal_positions(seg1.bg(splt(1,2*i-1))));
    usr_ed = ceil(fs_usr*f0_1.temporal_positions(seg1.ed(splt(1,2*i))));
    ref_bg = floor(fs_ref*f0_2.temporal_positions(seg2.bg(splt(2,2*i-1))));
    ref_ed = ceil(fs_ref*f0_2.temporal_positions(seg2.ed(splt(2,2*i))));
    usr_seg = x_usr(usr_bg:usr_ed);
    ref_seg = x_ref(ref_bg:ref_ed);
    % ��һ��alignment���������ζ��ڵ�alignment matrix
    [~,align_section] = alignAudioFeature(usr_seg,fs_usr,ref_seg,fs_ref,config,ratio);
    overall_target = [overall_target align_section'];
 
    % ���ĳһ��
    if i~=floor(seg_len/2)
        mute_bg = floor(fs_ref*f0_2.temporal_positions(seg2.ed(splt(2,2*i))));
        mute_ed = ceil(fs_ref*f0_2.temporal_positions(seg2.bg(splt(2,2*i+1))));
        mute_seg = x_ref(mute_bg:mute_ed);
        % ��Ҫ��������6144hz
        mute_seg = [resample(mute_seg, 6144, 44100)';resample(mute_seg, 6144, 44100)'];
        overall_target = [overall_target mute_seg];
    end
end
end


