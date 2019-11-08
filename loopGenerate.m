% ����ѭ��ģʽ�����д�����������ж��룬�Բ�ͬ��configs�����Լ�ѡȡ�����Ĺ��ױ�ֵratio����grid search
% �ҵ�����ʵĲ������䣬�����ɶ�����user�κ�reference�Σ��ֱ��������������������
clear
% data ��ʾ���д洢��contextFile��λ��
data = {'song1_user1_workspace.mat', 'song1_user2_workspace.mat', 'song2_user1_workspace.mat', 'song2_user2_workspace.mat', 'song3_user1_workspace.mat', 'song3_user2_workspace.mat',};
% data = {'song1_user1_workspace.mat'};
% res��ʾ�������ӱ��
res = {'song1_1','song1_2','song2_1','song2_2','song3_1','song3_2',};
% configs�����п���ѡ��alignment�Ĳ�����
configs = {{'ltc'}, {'lpc'}, {'sp'}, {'ltc','lpc'}, {'lpc','sp'}, {'sp','ltc'}};
% ��һ������ƥ��ʱ���׶�alignment�Ĳ�����ȷ��reference�κ�user�ζ��׶���Ķ������
config_first = { 'ltc'};
%config_regulars={{'lpc'},{'ltc'}};
% config_regulars ��һ������ƥ��ʱ�����׶�����Ķ���aligmentʹ�õĲ���
config_regulars = {{'lpc','ltc'}};
% config_ins�� �ڶ�������ƥ��ʱʹ�õĲ���
config_ins = {{'lpc'}};
%config_ins={{'lpc'},{'ltc'},{'lpc','ltc'}};
% ratios ���config_ins���ж��������lpc������ռ�ı���
ratios = [1.2];

% ��ʼѭ������
for i=1:length(data)
    % ����user�Ͷ�Ӧreference�ε�F0����
    load(data{i});
    for j=1:length(ratios)
        % config_first/_regulars_ins�����������ֲ�����ratio����ǰlpc����������Ĳ����ı�ֵ
        ratio=ratios(j);
        for cr=1:length(config_regulars)
            config_regular=config_regulars{cr};
            [splt] = segmentAlign(seg1, seg2, x_user, x_ref, fs_user, fs_ref, f0_parameter_user, f0_parameter_ref, config_first, config_regular);
            for o=1:length(config_ins)
                config_in=config_ins{o};
                align_res = noteAlign(x_ref, fs_ref, x_user, fs_user, seg1, seg2, f0_parameter_user, f0_parameter_ref,splt,config_in, ratio);
                para=[];
                for k=1:length(config_regular)
                    para=[para '_cr_' char(config_regular{k})];
                end
                for k=1:length(config_in)
                    para=[para '_ci_' char(config_in{k})];
                end
                para=[para '_' num2str(ratio)];
                if ~exist('OTPT_deDTW','dir')==0
                    mkdir('OTPT_deDTW');
                end
                audiowrite(['OTPT_deDTW/ltc_se_' res{i} para '.ogg'], align_res', 6144);
                %audiowrite(['output/ltc28_' res{i} para '.ogg'], align_res', 6144);
            end
        end
    end
end