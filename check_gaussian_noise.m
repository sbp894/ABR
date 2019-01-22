function [NoiseMean,NoiseStd,TestResult]=check_gaussian_noise(DataDir)

%%
% DataDir=[pwd '\NELData\SP-2016_07_04-Q265-Baseline\'];
CurDir=pwd;
AllFreq=[0.5 1 2 4 8]*1e3;
addpath(pwd);

%%
NoiseData=cell(length(AllFreq),11); % Hardcoded to 11
StimStart=6.2e-3;

%%
for freq_var=1:length(AllFreq)
    allfiles=dir([DataDir '\a*' num2str(AllFreq(freq_var)) '*']);
    
    %%
    for file_var=1:length(allfiles)
        picNum=sscanf(allfiles(file_var).name,'a%d_*');
        
        %%
        cd(DataDir);
        xx=loadPic(picNum);
        cd(CurDir);
        NoiseData{freq_var,file_var}=xx.AD_Data.AD_Avg_V(1:round(xx.Stimuli.RPsamprate_Hz*StimStart));
    end
end

%%
NoiseStd=zeros(numel(NoiseData),1);
NoiseMean=zeros(numel(NoiseData),1);
NoiseVector=[];
count=0;
for i=1:size(NoiseData,1)
    for j=1:size(NoiseData,2)
        count=count+1;
        NoiseStd(count)=std(NoiseData{i,j});
        NoiseMean(count)=mean(NoiseData{i,j});
        NoiseVector=[NoiseVector;NoiseData{i,j}']; %#ok<AGROW>
    end
end

NoiseMean=mean(NoiseVector);
NoiseStd=std(NoiseVector);
TestResult=chi2gof(NoiseVector);