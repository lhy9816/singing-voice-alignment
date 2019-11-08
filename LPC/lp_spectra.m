function [ Y1,ars ] = lp_spectra( x,fs,L,hop,p )
% draw spectra with lp method
y=enframe(x,L+p,hop);             % L = winLen - p
frameNum = size(y,1);
winL=size(y,2);
Y1=zeros(frameNum,winL);
ars=zeros(frameNum, p);
for i=1:frameNum
   [EL,alphal,GL,k]=latticem(y(i,:),L,p); 
   ar=alphal(:,p);
   ars(i,:)=ar;
   tmp=lpcar2pf([1; -ar],winL-1);
   Y1(i,:)=tmp(1:winL);           % ��arת�ɹ�����
%    m=1:winL;
%    freq=(m-1)*fs/(2*winL);   
%    line(freq,10*log10(Y1),'color',[.6 .6 .6],'linewidth',2); ylabel('��ֵ/dB');
%    title('����Ԥ�ⷨ��������Ӧͼ��'); xlabel('Ƶ��/Hz');
end
Y1=10*log10(Y1/1e-3);
end

