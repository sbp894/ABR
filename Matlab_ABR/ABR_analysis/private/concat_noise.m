function NoiseVector=concat_noise(DataDir)

%%
% DataDir=[pwd '\NELData\SP-2016_07_04-Q265-Baseline\'];
CurDir=pwd;
AllFreq=[0.5 1 2 4 8]*1e3;
addpath(pwd);

%%
NoiseVector=[];
StimStart=6.2e-3;

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
        temp_snippet=xx.AD_Data.AD_Avg_V(1:round(xx.Stimuli.RPsamprate_Hz*StimStart));
        temp_snippet=temp_snippet-mean(temp_snippet);
        NoiseVector=[NoiseVector,temp_snippet]; %#ok<AGROW>
    end
end
