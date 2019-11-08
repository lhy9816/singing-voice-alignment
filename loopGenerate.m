% 按照循环模式对所有待对齐歌曲进行对齐，对不同的configs参数以及选取参数的贡献比值ratio进行grid search
% 找到最合适的参数搭配，并生成对齐后的user段和reference段，分别输出与左声道和右声道
clear
% data 表示所有存储的contextFile的位置
data = {'song1_user1_workspace.mat', 'song1_user2_workspace.mat', 'song2_user1_workspace.mat', 'song2_user2_workspace.mat', 'song3_user1_workspace.mat', 'song3_user2_workspace.mat',};
% data = {'song1_user1_workspace.mat'};
% res表示所有曲子编号
res = {'song1_1','song1_2','song2_1','song2_2','song3_1','song3_2',};
% configs是所有可以选作alignment的参数组
configs = {{'ltc'}, {'lpc'}, {'sp'}, {'ltc','lpc'}, {'lpc','sp'}, {'sp','ltc'}};
% 第一级段落匹配时，首段alignment的参数，确定reference段和user段段首对齐的对齐参数
config_first = { 'ltc'};
%config_regulars={{'lpc'},{'ltc'}};
% config_regulars 第一级段落匹配时，除首段以外的段落aligment使用的参数
config_regulars = {{'lpc','ltc'}};
% config_ins是 第二级段落匹配时使用的参数
config_ins = {{'lpc'}};
%config_ins={{'lpc'},{'ltc'},{'lpc','ltc'}};
% ratios 如果config_ins中有多个参数，lpc参数所占的比重
ratios = [1.2];

% 开始循环计算
for i=1:length(data)
    % 加载user和对应reference段的F0曲线
    load(data{i});
    for j=1:length(ratios)
        % config_first/_regulars_ins中若存在两种参数，ratio代表前lpc参数与另外的参数的比值
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