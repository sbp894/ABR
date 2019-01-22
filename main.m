%% Function to load ABR data from  a DataDir, time warp the waveforms and create another compatible DataDir_warped
% Created by SP
% 19 Aug, 2016

%%
clear;
close all;
clc;

%% Create a directory if not present
if ~exist('WarpedDataFolder','dir')
    mkdir('WarpedDataFolder');
end
CurDir=pwd;
addpath(CurDir);

%% Ask for data directory
if exist('NELData','dir')
    RefDir=[pwd '\NELData\'];
else 
    RefDir=pwd;
end
DataDir=uigetdir(RefDir,'Select the ABR data directory');

% DataDir=[RefDir 'MH-2016_08_05-Q259_NH_BL_VP\'];
TargetDir=[fileparts(DataDir(1:end-1)) filesep DataDir(length(RefDir)+1:end-1) '_warped' filesep];
mkdir(TargetDir);

AllFreq=[0.5 1 2 4 8]*1e3;

for freq_var=1:length(AllFreq)
    allfiles=dir([DataDir '\a*' num2str(AllFreq(freq_var)) '*']);
    picNum=sscanf(allfiles(1).name,'a%d_*');
    
    %%
    cd(DataDir);
    xx=loadPic(picNum);
    cd(CurDir);
    DataForCurFreq=zeros(length(allfiles),length(xx.AD_Data.AD_Avg_V));
    
    for file_var=1:length(allfiles)
        picNum=sscanf(allfiles(file_var).name,'a%d_*');
        
        %%
        cd(DataDir);
        xx=loadPic(picNum);
        cd(CurDir);
        
        DataForCurFreq(file_var,:)=xx.AD_Data.AD_Avg_V;
        if abs(xx.Stimuli.MaxdBSPLCalib-xx.Stimuli.atten_dB-60)<1
            TemplateIndex=file_var;
        end
    end
    
    for file_var=setdiff(1:length(allfiles),TemplateIndex)
        picNum=sscanf(allfiles(file_var).name,'a%d_*');
        cd(DataDir);
        xx=loadPic(picNum);
        cd(CurDir);
        xx.AD_Data.AD_Avg_V=apply_dtw(DataForCurFreq(TemplateIndex,:),DataForCurFreq(file_var,:));
        write_nel_data([TargetDir sprintf('a%.4d_ABR_%d',picNum,AllFreq(freq_var))],xx,0);
    end
    cd(DataDir);
    picNum=sscanf(allfiles(TemplateIndex).name,'a%d_*');
    xx=loadPic(picNum);
    [xx.AD_Data.Noise.mean,xx.AD_Data.Noise.std]=check_gaussian_noise(DataDir);
    cd(CurDir);
    write_nel_data([TargetDir sprintf('a%.4d_ABR_%d',picNum,AllFreq(freq_var))],xx,0);
end

allCALIBfiles=dir([DataDir '\*calib*']);
for file_var=1:length(allCALIBfiles)
    copyfile([DataDir filesep allCALIBfiles(file_var).name],TargetDir);
end