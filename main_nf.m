%% Function to load ABR data from  a DataDir, time warp the waveforms and create another compatible DataDir_warped
% The new data is twice the length of original data. The first half is the
% aligned data. The second half is noise that is aligned to the template.
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
NoiseTimeFromEnd=0.01; % 10ms 

for freq_var=1:length(AllFreq)
    allfiles=dir([DataDir '\a*' num2str(AllFreq(freq_var)) '*']);
    picNum=sscanf(allfiles(1).name,'a%d_*');
    
    %%
    cd(DataDir);
    xx=loadPic(picNum);
    cd(CurDir);
    DataForCurFreq=zeros(2*length(allfiles),length(xx.AD_Data.AD_Avg_V));
    
    for file_var=1:length(allfiles)
        picNum=sscanf(allfiles(file_var).name,'a%d_*');
        
        %%
        cd(DataDir);
        xx=loadPic(picNum);
        cd(CurDir);
        
        DataForCurFreq(file_var,:)=xx.AD_Data.AD_Avg_V;
        flipped_data=fliplr(xx.AD_Data.AD_Avg_V);
        Ind2ReplacedBy=ceil(NoiseTimeFromEnd*xx.Stimuli.RPsamprate_Hz);
        flipped_data=repmat(flipped_data(1:Ind2ReplacedBy),1,ceil(length(xx.AD_Data.AD_Avg_V)/xx.Stimuli.RPsamprate_Hz/NoiseTimeFromEnd));
        flipped_data=flipped_data(1:length(xx.AD_Data.AD_Avg_V));
        DataForCurFreq(length(allfiles)+file_var,:)=flipped_data;
        if abs(xx.Stimuli.MaxdBSPLCalib-xx.Stimuli.atten_dB-60)<1
            TemplateIndex=file_var;
        end
    end
    
    for file_var=setdiff(1:length(allfiles),TemplateIndex)
        picNum=sscanf(allfiles(file_var).name,'a%d_*');
        cd(DataDir);
        xx=loadPic(picNum);
        cd(CurDir);
        temp_aligned=apply_dtw(DataForCurFreq(TemplateIndex,:),DataForCurFreq(file_var,:));
        temp_aligned_with_nf=apply_dtw(DataForCurFreq(TemplateIndex,:),DataForCurFreq(length(allfiles)+file_var,:));
        xx.AD_Data.AD_Avg_V=[temp_aligned temp_aligned_with_nf];
        write_nel_data([TargetDir sprintf('a%.4d_ABR_%d',picNum,AllFreq(freq_var))],xx,0);
    end
    cd(DataDir);
    picNum=sscanf(allfiles(TemplateIndex).name,'a%d_*');
    xx=loadPic(picNum);
    xx.AD_Data.AD_Avg_V=repmat(xx.AD_Data.AD_Avg_V,1,2);
    
    cd(CurDir);
    write_nel_data([TargetDir sprintf('a%.4d_ABR_%d',picNum,AllFreq(freq_var))],xx,0);
end

allCALIBfiles=dir([DataDir '\*calib*']);
for file_var=1:length(allCALIBfiles)
    copyfile([DataDir filesep allCALIBfiles(file_var).name],TargetDir);
end