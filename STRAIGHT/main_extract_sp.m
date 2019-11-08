clear all;
%%%%%%%%%%%%%%%%%%%%%%%%%
%author: zhaoshuaijiang
%date: 20141223
%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%Settings%%%%%%%%%%%%
opts.F0frameUpdateInterval  = 5;   %frame shift(ms)
opts.spectralUpdateInterval = 5;   %frame shift(ms)
opts.F0searchLowerBound     = 50;  %F0 lower bound
opts.F0searchUpperBound     = 600; %F0 upper bound
fs   = 16000;
RAW_PATH = './sing/';
SP_PATH  = './sp/'; mkdir(SP_PATH);
%%%%%%%%%%%%Settings%%%%%%%%%%%%

fns_all = Utils_getFilenames(RAW_PATH, '.wav');
for i = 1:length(fns_all)
    fprintf('Extract the %d th file\n',i);
    raw =  Utils_readFeature([RAW_PATH fns_all{i} '.raw'],'int16',1); %int16 not short
    [f0raw,ap]=exstraightsource(raw,fs);
    sp = exstraightspec(raw,f0raw,fs);
    save([SP_PATH fns_all{i} '.sp'],'-ascii','sp');
end

