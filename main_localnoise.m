%% Function to load ABR data from  a DataDir, time warp the waveforms and create another compatible DataDir_warped
% The new data is twice the length of original data. The first half is the
% aligned data. The second half is noise that is aligned to the template.
% Created by SP
% 19 Aug, 2016

%%
clear;
close all;
clc;


%% Parameters
AllFreq=[0.5 1 2 4 8]*1e3;
nTemplate=1;
TemplateSPL=50;

%% Create a directory if not present
CurDir=pwd;
addpath(CurDir);

if exist('NELData','dir')
    RefDir=[pwd '\NELData\'];
else
    RefDir=pwd;
end
DataDir=uigetdir(RefDir,'Select the ABR data directory');
NoiseVector=concat_noise(DataDir);

% DataDir=[RefDir 'MH-2016_08_05-Q259_NH_BL_VP\'];
TargetDir=[fileparts(DataDir(1:end-1)) filesep DataDir(length(RefDir)+1:end-1) '_warped' filesep];
mkdir(TargetDir);


for freq_var=1:length(AllFreq)
    allfiles=dir([DataDir '\a*ABR_' num2str(AllFreq(freq_var)) '*']);
    search_string='a%d_*';
    if isempty(allfiles)
        allfiles=dir([DataDir '\p*ABR_' num2str(AllFreq(freq_var)) '*']);
        search_string(1)='p';
    end
    
    picNum=sscanf(allfiles(1).name,search_string);
    
    
    %%
    cd(DataDir);
    xx=loadPic(picNum);
    cd(CurDir);
    if iscell(xx.AD_Data.AD_Avg_V)
        ABRSigLength=length(xx.AD_Data.AD_Avg_V{1});
    else
        ABRSigLength=length(xx.AD_Data.AD_Avg_V);
    end
    DataForCurFreq=zeros(length(allfiles),ABRSigLength);
    
    for file_var=1:length(allfiles)
        picNum=sscanf(allfiles(file_var).name,search_string);
        
        %%
        cd(DataDir);
        xx=loadPic(picNum);
        if ~isfield(xx.Stimuli,'MaxdBSPLCalib')
            calibfname=dir('*calib*');
            xx.Stimuli.MaxdBSPLCalib=read_calib_interpolated(calibfname(1).name,AllFreq(freq_var)/1e3);
        end
        cd(CurDir);
        
        if iscell(xx.AD_Data.AD_Avg_V)
            DataForCurFreq(file_var,:)=xx.AD_Data.AD_Avg_V{1};
        else
            DataForCurFreq(file_var,:)=xx.AD_Data.AD_Avg_V;
        end
        
        if abs(xx.Stimuli.MaxdBSPLCalib-xx.Stimuli.atten_dB-TemplateSPL)<5
            TemplateIndex=file_var+1-nTemplate:file_var;
        end
        
    end
    template=sum(DataForCurFreq(TemplateIndex,:),1);
    
    for file_var=1:length(allfiles)
        picNum=sscanf(allfiles(file_var).name,search_string);
        cd(DataDir);
        xx=loadPic(picNum);
        cd(CurDir);
        [xx.AD_Data.AD_Avg_V,xx.AD_Data.WarpedInd]=apply_dtw(template,DataForCurFreq(file_var,:));
        xx.Stimuli.noise=NoiseVector;
        xx.AD_Data.AD_All_V=[];
        
        write_nel_data([TargetDir sprintf('a%.4d_ABR_%d',picNum,AllFreq(freq_var))],xx,0);
    end
end

allCALIBfiles=dir([DataDir '\*calib*']);
for file_var=1:length(allCALIBfiles)
    copyfile([DataDir filesep allCALIBfiles(file_var).name],TargetDir);
end

