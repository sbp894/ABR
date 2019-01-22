function abr_setup

if exist('Matlab_ABR','dir')
    addpath([pwd filesep 'Matlab_ABR']);
    addpath([pwd filesep 'Matlab_ABR' filesep 'ABR_analysis']);
else
    %     addpath('/media/parida/DATAPART1/Matlab/ABR/ABR_DTW/Matlab_ABR');
    %     addpath('/media/parida/DATAPART1/Matlab/ABR/ABR_DTW/Matlab_ABR/ABR_analysis');
    error('change ^ two lines');
end
