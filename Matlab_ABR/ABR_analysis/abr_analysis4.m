function abr_analysis4(command_str,parm_num)

%This function computes an ABR threshold based on series of AVERAGER files.

global paramsIN abr_FIG abr_Stimuli abr_root_dir abr_data_dir hearingStatus animal data han invert abr_out_dir freq date

abr_root_dir = '/media/parida/DATAPART1/Matlab/ABR/Matlab_ABR';
abr_data_dir = '/media/parida/DATAPART1/Matlab/ExpData/Baselines/';
abr_out_dir= '/media/parida/DATAPART1/Matlab/ABR/Output/';

paramsIN.abr_root_dir= abr_root_dir;
paramsIN.abr_root_dir= abr_root_dir;

if nargin < 1
    
    get_noise;
    co=[0.0000    0.4470    0.7410;
        0.8500    0.3250    0.0980;
        0.9290    0.6940    0.1250;
        0.4940    0.1840    0.5560;
        0.4660    0.6740    0.1880;
        0.3010    0.7450    0.9330;
        0.6350    0.0780    0.1840; ];
    set(groot,'defaultAxesColorOrder',co);
    
    abr_gui_initiate; %% Makes the GUI visible
    
elseif strcmp(command_str,'stimulus')
    if ~isempty(get(abr_FIG.push.edit,'string'))
        new_value = get(abr_FIG.push.edit,'string');
        set(abr_FIG.push.edit,'string',[]);
        set(abr_FIG.parm_txt(parm_num),'string',upper(new_value));
        switch parm_num
            case 1
                abr_Stimuli.cal_pic = new_value;
            case 2
                abr_Stimuli.abr_pic = new_value;
            case 3
                abr_Stimuli.start = str2double(new_value);
            case 4
                abr_Stimuli.end = str2double(new_value);
            case 5
                abr_Stimuli.start_template = str2double(new_value);
            case 6
                abr_Stimuli.end_template = str2double(new_value);
            case 7
                abr_Stimuli.num_templates = str2double(new_value);
            case 8
                abr_Stimuli.maxdB2analyze= str2double(new_value);
        end
    else
        set(abr_FIG.push.edit,'string','ERROR');
    end
    
elseif strcmp(command_str,'nextPics')
    if ~isempty(data)
        if sum(sum(~isnan(data.x)))
            ButtonName=QUESTDLG('Would you like to save?');
            if strcmp(ButtonName,'Yes')
                save_file2;
            elseif strcmp(ButtonName,'Cancel')
                return
            end
        end
    end
    
    ExpDir=fullfile(abr_data_dir,abr_Stimuli.dir);
    cd(ExpDir);
    hhh=dir('a*ABR*');
    ABRpics=zeros(1,length(hhh));
    ABRfreqs=zeros(1,length(hhh));
    for i=1:length(hhh)
        ABRpics(i)=str2double(hhh(i).name(2:5));
        ABRfreqs(i)=str2double(hhh(i).name(11:14));
    end
    
    if strcmp(get(han.abr_panel,'Box'),'on')
        firstPic=max(ParseInputPicString_V2(abr_Stimuli.abr_pic))+1;
    else
        firstPic=min(ABRpics);
    end
    
    if firstPic <= max(ABRpics)
        freqTarget=min(ABRfreqs(ABRpics==firstPic));
        picNow=firstPic;
        
        while ABRfreqs(ABRpics==picNow)==freqTarget && picNow <= max(ABRpics)
            lastPic=picNow;
            picNow=picNow+1;
        end
        new_value=[num2str(firstPic) '-' num2str(lastPic)];
    else
        new_value=abr_Stimuli.abr_pic;
    end
    
    set(abr_FIG.parm_txt(2),'string',upper(new_value));
    abr_Stimuli.abr_pic = new_value;
    
    zzz2;
    set(han.peak_panel,'Box','on');
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
    
elseif strcmp(command_str,'directory')
    abr_Stimuli.dir = get_directory;
    set(han.abr_panel,'Box','off');
    set(han.peak_panel,'Box','off');
    set(abr_FIG.dir_txt,'string',abr_Stimuli.dir);
    
    if strcmp(get(han.abr_panel,'Box'),'off')
        animal= cell2mat(cellfun(@(x) sscanf(char(x{1}), '-Q%d*'), regexp(abr_Stimuli.dir,'(-Q\d+_)','tokens'), 'UniformOutput', 0));
        paramsIN.animal= animal;
        if contains(lower(abr_Stimuli.dir), {'nh', 'pre'})
            hearingStatus = 'NH';
        elseif contains(lower(abr_Stimuli.dir), {'hi', 'pts', 'tts', 'post'})
            hearingStatus= 'HI';
        end
        paramsIN.hearingStatus= hearingStatus;
        axes(han.text_panel);
        text(0.04,0.95,['Q' num2str(paramsIN.animal) ':'],'FontSize',14,'horizontalalignment','left','VerticalAlignment','bottom')
        set(han.abr_panel,'Box','on');
    end
    
    
elseif strcmp(command_str,'process')
    zzz2;
    set(han.peak_panel,'Box','on');
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'refdata')
    if strcmp(get(han.peak_panel,'Box'),'on')
        refdata;
    else
        msgbox('Load new ABR files before plotting reference data')
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'cbh')
    if strcmp(get(han.peak_panel,'Box'),'on')
        plot_data2;
    else
        msgbox('Load new ABR files before plotting reference data')
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'cbh2')
    if strcmp(get(han.peak_panel,'Box'),'on')
        AVG_refdata2;
    else
        msgbox('Load new ABR files before plotting reference data')
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'invert')
    invert=get(han.invert,'Value');
    zzz2;
    
elseif strcmp(command_str,'change_weights')
    if strcmp(get(han.peak_panel,'Box'),'on')
        change_weights;
    else
        msgbox('Load ABR files before optimizing model fit')
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'peak1')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak2('p',1);
    else
        msgbox('Load new ABR files before marking peaks');
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'trou1')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak2('n',1)
    else
        msgbox('Load new ABR files before marking peaks');
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'peak2')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak2('p',2)
    else
        msgbox('Load new ABR files before marking peaks')
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'trou2')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak2('n',2)
    else
        msgbox('Load new ABR files before marking peaks')
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'peak3')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak2('p',3)
    else
        msgbox('Load new ABR files before marking peaks')
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'trou3')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak2('n',3)
    else
        msgbox('Load new ABR files before marking peaks')
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'peak4')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak2('p',4)
    else
        msgbox('Load new ABR files before marking peaks')
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'trou4')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak2('n',4)
    else
        msgbox('Load new ABR files before marking peaks')
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'peak5')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak2('p',5)
    else
        msgbox('Load new ABR files before marking peaks')
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'trou5')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak2('n',5)
    else
        msgbox('Load new ABR files before marking peaks')
    end
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'autofind')
    peak1af2;
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'print')
    set(gcf,'PaperOrientation','portrait');
    curChinDir= strrep(strcat(abr_out_dir, 'Q',num2str(animal),'_',hearingStatus,'_',date, filesep), '-', '_');
    if ~isdir(curChinDir)
        mkdir(curChinDir);
    end
    if freq~=0
        fName= strrep(strcat(curChinDir, 'Q',num2str(animal),'_',hearingStatus,'_', num2str(freq), 'Hz','_',date), '-', '_');
    else
        fName= strrep(strcat(curChinDir, 'Q',num2str(animal),'_',hearingStatus,'_', 'click','_',date), '-', '_');
    end
    saveas(gcf, fName, 'tiff');
    % % % %     set(gcf,'PaperOrientation','Landscape','PaperPosition',[0 0 11 8.5]);
    % % % %     if ispc
    % % % %         print('-dwinc','-r200');
    % % % %     else
    % % % %         print('-PNeptune','-dpsc','-r200','-noui');
    % % % %     end
    
elseif strcmp(command_str,'file')
    if strcmp(get(han.abr_panel,'Box'),'on')
        save_file2
    else
        msgbox('Data not saved')
    end
    
elseif strcmp(command_str,'edit') % added by GE 15Apr2004
    
elseif strcmp(command_str,'close')
    update_params3;
    closereq;
    cd(fileparts(abr_root_dir(1:end-1)));
    
elseif strcmp(command_str,'freq_proc')
    update_picnums_for_freqval(parm_num);
end