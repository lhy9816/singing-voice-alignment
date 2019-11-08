function [ feature,Y ] = singingFeatureExtraction( x,fs,config,ratio )
% extract feature matrix according to config
% input: skim
% output: feature: (frameNum, winLen)
%         Y0: lpc value matrix with size (frameNum, winLen)
if nargin==3
    ratio=1;
end
x = resample(x,6144,fs);                              % ������֮�����Դ�ź�
fs=6144;
winL=256;
hop=floor(winL/4);
p_first=10;                                            % config_first����Ԥ��ϵ��ѡȡ�ĸ���
p=13;                                                  % config_ins����Ԥ��ϵ������
x_mean=mean(x);
for i=1:length(x)
   if x(i)==0
      x(i)=x_mean*2*rand(1);
   end
end
% ����config�а���ʲô����lpc�����γɵ�lpc matrix��Ҫ������Ϊ����user��ref�ε�corr�Ĳο�
[Y0,~ ] = lp_spectra( x,fs,winL-p_first,hop,p_first );
Y=Y0(:,40:230);                                       % ȡ��50-2500hz֮�䣬�����Ҫ��ǰ���fs��winLͬ���޸�

feature=[];
for i=1:length(config)
   if strcmp(config{i},'lpc')
       lpccs_out=extract_lpcc(x,fs,winL,hop,p);
       feature=[feature ratio*lpccs_out];
   end
   if strcmp(config{i},'ltc')
       ltc_out=extract_ltc(x,fs,winL,hop);
       feature=[feature ltc_out/ratio];
   end
   if strcmp(config{i},'sp')
       sp_out = extract_sp(x,fs,winL,hop);
       feature=[feature sp_out/ratio];
   end
end

%% LP spectra
function lpccs_out=extract_lpcc(x,fs,winL,hop,p)
    [ Y1,args ] = lp_spectra( x,fs,winL-p,hop,p );
    lpccs=lpc2lpccm(args,p,p);  
    lpccs_out=matrix_norm(lpccs');
end
%% straight
% extract f0
function sp_out = extract_sp(x,fs,winL,hop)
    % compute stright spectrum based on Straight algorithm
    y=enframe(x,winL,hop);
    frameNum = size(y,1);
    analysisParams.F0frameUpdateInterval=10.5;
    analysisParams.F0defaultWindowLength=4;
    analysisParamsSP.FOdefaultWindowLength=4;
    [f0raw,ap]=exstraightsource(x,fs,analysisParams);
    [sp,spPara] = exstraightspec(x,f0raw,fs,analysisParamsSP);
    % sp������������������ƫ��ҳ���Щƫ��
    sp=resize_sp(sp,frameNum);
    sp_out=matrix_norm(sp');
end
%sp=10*log10(sp/1e-4);
% go and extract cc
%strcc=extractCepsCoef(sp, 16);
% time = size(sp,2);
% freq=size(sp,1);
% %=====================================================%
% figure
% imagesc((1:time),(1:freq),abs(sp((1:freq),:))); % ����Y��ͼ��  
% axis xy; ylabel('Ƶ��/Hz');xlabel('ʱ��/s');
% title('����ͼ ');
% m = 256; LightYellow = [0.0 0.0 0.0];
% MidRed = [0.5 0.5 0.5]; Black = [1 1 1];
% Colors = [Black; MidRed; LightYellow];
% colormap(SpecColorMap(m,Colors)); 
%% LTC
function ltc_out=extract_ltc(x,fs,winL,hop)
    % compute 28th order cepstral analysis of
    % source signals and choose the 3 to 12 lower order
    % coefficients representing vocal tract characteristics
    pm=28;
    y=enframe(x,winL,hop);
    frameNum = size(y,1);
    ltc=zeros(frameNum,12);
    z=ifft(log(abs(fft(y',pm))));
    ltc=z(3:12,:);
    ltc_out=matrix_norm(ltc');
end
end

function y=matrix_norm(x)
% normalize the matrix to 0-1
% times * freqs
FlattenedData = x(:)';                              % չ������Ϊһ�У�Ȼ��ת��Ϊһ�С�
MappedFlattened = mapminmax(FlattenedData, 0, 1);   % ��һ����
y = reshape(MappedFlattened, size(x)); 
end

function y=resize_sp(sp,len)
% resize sp and set its time step equal to shape
len_sp=size(sp,2);
y=[];
if len_sp > len
    erase_num=len_sp-len;
    erase_interval=floor(len_sp/erase_num);
    i=1;
    while i<=len_sp
       if size(y,2)==len
            break;
       end
       if mod(i,erase_interval)
           y=[y sp(:,i)];
       end
       i=i+1;
    end
elseif len_sp < len
   add_num=len-len_sp;
   add_interval=floor(len/add_num);
   add_column=mean(sp,2);
   y=[];
   i=1;
   while i<=len
       if size(y,2)==len
           break;
       end
       if ~mod(i,add_interval)
           y=[y add_column];
       end
       if i<=len_sp
           y=[y sp(:,i)];
       end
       i=i+1;
   end
else
    y=sp;
end
end



