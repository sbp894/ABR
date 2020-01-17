function NoiseVector=concat_noise(DataDir)

%%
% DataDir=[pwd '\NELData\SP-2016_07_04-Q265-Baseline\'];
global han

CurDir=pwd;
AllFreq=[0.5 1 2 4 8]*1e3;
addpath(pwd);

%%
NoiseVector=[];


if han.rm_rect.Value
    noiseStart=20.8e-3;
    noiseEnd= 30e-3;
else 
    noiseStart=0;
    noiseEnd= 6.2e-3;
end

%%
for freq_var=1:length(AllFreq)
    allfiles=dir([DataDir filesep 'a*' num2str(AllFreq(freq_var)) '*']);
    search_string='a%d_*';
    if isempty(allfiles)
        allfiles=dir([DataDir filesep 'p*' num2str(AllFreq(freq_var)) '*']);
        search_string(1)='p';
    end
    
    %%
    for file_var=1:length(allfiles)
        picNum=sscanf(allfiles(file_var).name,search_string);
        
        %%
        cd(DataDir);
        xx=loadPic(picNum);
        cd(CurDir);
        if iscell(xx.AD_Data.AD_Avg_V)
            xx.AD_Data.AD_Avg_V=xx.AD_Data.AD_Avg_V{1};
        end
        fs= xx.Stimuli.RPsamprate_Hz;
        indStart= max(1, round(fs*noiseStart));
        indEnd= min(round(fs*noiseEnd), length(xx.AD_Data.AD_Avg_V));
        temp_snippet=xx.AD_Data.AD_Avg_V(indStart:indEnd);
        temp_snippet=temp_snippet-mean(temp_snippet);
        NoiseVector=[NoiseVector,temp_snippet]; %#ok<AGROW>
    end
end
