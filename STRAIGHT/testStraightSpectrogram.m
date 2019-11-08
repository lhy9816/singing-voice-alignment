% lhy test spectrogram
% 2019.3.26
DIR = '.straight/sing';
SONG = '/song3_user2_6.wav';
[x, fs] = audioread([DIR, SONG]);
% downsample to 5000 hz
x = resample(x,6144,fs);                              % ������֮�����Դ�ź�
fs=6144;
% extract f0
[f0raw,ap]=exstraightsource(x,fs);
[sp,spPara] = exstraightspec(x,f0raw,fs);
sp=10*log10(sp/1e-3);
time = size(sp,2);
freq=size(sp,1);
figure
imagesc((1:time),(1:freq),abs(sp((1:freq),:))); % ����Y��ͼ��  
axis xy; ylabel('Ƶ��/Hz');xlabel('ʱ��/s');
title('����ͼ ');
m = 256; LightYellow = [0.0 0.0 0.0];
MidRed = [0.5 0.5 0.5]; Black = [1 1 1];
Colors = [Black; MidRed; LightYellow];
colormap(SpecColorMap(m,Colors)); 
aaa=1;