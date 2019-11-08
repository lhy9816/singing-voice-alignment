function [score,res] = alignAudioFeature(x_u,fs_ori_u,x_r,fs_ori_r,config ,ratio)
if nargin==5
    ratio=1;
end
[x_usr, fs, y_usr, y_usr_t] = read_wav(x_u,fs_ori_u);
[x_ref, ~, y_ref, y_ref_t] = read_wav(x_r,fs_ori_r);
y_usr_n = y_usr_t * fs;
y_ref_n = y_ref_t * fs;

% 根据config中的参数进行声学feature的计算
[user_dtw,Y_usr] = singingFeatureExtraction(x_u,fs_ori_u,config,ratio);
[ref_dtw,Y_ref] = singingFeatureExtraction(x_r,fs_ori_r,config,ratio);

% 根据feature进行的DTW，获取aligment matrix
[~,~,match_route]=deDTW(user_dtw, ref_dtw);

% 计算重新align后的user和ref段的相似性
score=compute_corr([Y_usr user_dtw],[Y_ref ref_dtw],match_route);
y_tar_t = frame2time(size(match_route,1),256,256/4,6144);
y_tar_n = y_tar_t * fs;
% 将短的那一段拉伸为与长的那一段一样长
tar_usr = strechAudioLpc(x_usr, y_tar_n, match_route(:,1));
tar_ref = strechAudioLpc(x_ref, y_tar_n, match_route(:,2));
res=[tar_usr' tar_ref'];
% sound(res,fs);
end

function score=compute_corr(user_coef,ref_coef,match_route)
% compute correlation between user_coefficient and ref_coefficient with
% matlab built-in function corr2
usr_mat=[];
ref_mat=[];
for i=1:size(match_route,1)
    usr_mat=[usr_mat; user_coef(match_route(i,1),:)];
    ref_mat=[ref_mat; ref_coef(match_route(i,2),:)];
end
score=corr2(usr_mat,ref_mat);
end

function tar = strechAudioLpc(x, y_n, match)
% strech the shorter audio in user and ref
tar = x(1:y_n(1))';
for i=2:length(y_n)
    tar = [tar x(y_n(match(i))-63:y_n(match(i)))'];
end
end


function [x, fs, y, y_t] = read_wav(x,fs)
% read and downsample original audio to desired sr
% input: x: original signal
%        fs: original fs
% output: x, fs: signal fs after downsampling
%         y: signal after enframing
%         y_t: begintime for each frame
x = resample(x,6144,fs);                              % 降采样之后的声源信号
fs=6144;
winL=256;
hop=floor(winL/4);
y=enframe(x,winL,hop);
y_t = frame2time(size(y,1),winL, hop,fs);
end