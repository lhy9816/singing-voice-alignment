function y = createF0(userFile, refFile, contextFile, minSegment)
% compute userfile's and referencefile's F0 curve
% input: userFile(REQ): path-to-userfile
%        refFile(REQ): path-tp-referencefile
%        contextFile(REQ): path-to-save-contextfile
%        minSegment(OPT)(default = 65): a threshold which controls the minimum segment length of a segment that can be recognized
% return: file that records the context of two F0 curves
if nargin < 4
    minSegment = 65;
end
%% read and compute userFile F0
[x_user, fs_user] = audioread(userFile);
x_user = x_user(:, 1);
x_usr = filter([1 -.99],1, x_user);                           % 预加重
f0_parameter_user = Harvest(x_user, fs_user);                 % 使用Harvard算法进行音高提取
spectrum_parameter = CheapTrick(x_user, fs_user, f0_parameter_user);   %合成时候用
fprintf('user song processed.');
%% read and compute refFile F0
[x_ref, fs_ref] = audioread(refFile);
x_ref = x_ref(:, 1);
x_ref = filter([1 -.99], 1, x_ref);                            % 预加重
f0_parameter_ref = Harvest(x_ref, fs_ref);                     % 使用Harvard算法进行音高提取

new_f0_user = smooth(f0_parameter_user.f0, 50)';                 % 使用平均滤波平滑F0曲线，50为窗宽
new_f0_ref = smooth(f0_parameter_ref.f0, 50)';
%% segment based on F0 and minSegment
seg1 = segby0(f0_parameter_user.f0, minSegment);
seg2 = segby0(f0_parameter_ref.f0, minSegment);
%[seg2,MaxmuteLen] = segby0_ref(f0_parameter_ref.f0, 70);
%seg1 = segby0_usr(f0_parameter.f0, 70,MaxmuteLen);
%save('song1_wksp_3_7.mat');
%% draw F0 curve and segment picture
subplot(2,1,1), plot(1:size(f0_parameter_user.f0, 2),f0_parameter_user.f0, 1:size(f0_parameter_user.f0, 2), seg1.vld*100, '-r');  %..f0就是F0曲线
subplot(2,1,2), plot(1:size(f0_parameter_ref.f0, 2),f0_parameter_ref.f0, 1:size(f0_parameter_ref.f0, 2), seg2.vld*100, '-r');
save(contextFile);