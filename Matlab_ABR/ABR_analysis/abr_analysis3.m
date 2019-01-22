function abr_analysis3(command_str,parm_num)

%This function computes an ABR threshold based on series of AVERAGER files.

global abr_FIG abr_Stimuli abr_root_dir abr_data_dir han animal 

host = lower(getenv('hostname'));
abr_root_dir = 'D:\Study Stuff\Matlab\ABR_DTW\Matlab_ABR';  % added by GE 04Mar2004.
abr_data_dir = 'D:\Study Stuff\Matlab\ABR_DTW\NELData'; % added by GE 04Mar2004.

get_noise

if nargin < 1
    
    %CREATING STRUCTURES HERE   
    push = cell2struct(cell(1,4),{'process','print','close','edit'},2);
    ax1  = cell2struct(cell(1,7),{'axes','line1','line2','line3','xlab','ylab','title'},2);
    ax2  = cell2struct(cell(1,3),{'axes','xlab','ylab'},2);
    abrs  = cell2struct(cell(1,10),{'abr1','abr2','abr3','abr4','abr5','abr6','abr7','abr8','abr9','abr10'},2);
    abr_FIG = struct('handle',[],'push',push,'ax1',ax1,'ax2',ax2,'abrs',abrs,'parm_text',[],'dir_text',[]);
    
    get_analysis_ins3; %script creates struct Stimuli
    if ~exist('abr_Stimuli')||~isfield(abr_Stimuli, 'cal_pic')
        % LQ 01/09/04 when get_analysis_ins is corrupted
        instruct_error;
    end
    
    abr_FIG.handle = figure('NumberTitle','off','Name','ABR peaks','Units','normalized','Visible','on',...
        'position',[0 0.03 1 0.92],'CloseRequestFcn','abr_analysis3(''close'');');
    colordef none;
    whitebg('w');
    
    abr_FIG.push.process = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''process'');','style','pushbutton',...
        'Units','normalized','position',[0.35 .32 0.1 .03],'string','Load ABR files');
    abr_FIG.push.refdata = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''refdata'');','style','pushbutton',...
        'Units','normalized','position',[0.35 .285 0.08 .03],'string','Show ref data');
    han.cbh = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''cbh'');','style','checkbox','Units','normalized',...
        'position',[0.44 .285 0.05 .03],'String','waves','Value',0,'BackgroundColor','w');
    abr_FIG.push.peak1 = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''peak1'');','style','pushbutton',...
        'Units','normalized','position',[0.35 0.21 0.02125 0.03],'string','P(1)');
    abr_FIG.push.trou1 = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''trou1'');','style','pushbutton',...
        'Units','normalized','position',[0.35 0.175 0.02125 0.03],'string','N(1)');
    abr_FIG.push.peak2 = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''peak2'');','style','pushbutton',...
        'Units','normalized','position',[0.37625 0.21 0.02125 0.03],'string','P(2)');
    abr_FIG.push.trou2 = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''trou2'');','style','pushbutton',...
        'Units','normalized','position',[0.37625 0.175 0.02125 0.03],'string','N(2)');
    abr_FIG.push.peak3 = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''peak3'');','style','pushbutton',...
        'Units','normalized','position',[0.40125 0.21 0.02125 0.03],'string','P(3)');
    abr_FIG.push.trou3 = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''trou3'');','style','pushbutton',...
        'Units','normalized','position',[0.40125 0.175 0.02125 0.03],'string','N(3)');
    abr_FIG.push.peak4 = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''peak4'');','style','pushbutton',...
        'Units','normalized','position',[0.4275 0.21 0.02125 0.03],'string','P(4)');
    abr_FIG.push.trou4 = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''trou4'');','style','pushbutton',...
        'Units','normalized','position',[0.4275 0.175 0.02125 0.03],'string','N(4)');
    
    han.change_weights = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''change_weights'');','style','pushbutton',...
        'Units','normalized','position',[0.07 0.86 0.07 0.02],'string','modify weights');
    
    abr_FIG.push.autofind = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''autofind'');','style','pushbutton',...
        'Units','normalized','position',[0.35 0.14 0.1 0.03],'string','AutoFind');
    
    abr_FIG.push.nextPics = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''nextPics'');','style','pushbutton',...
        'Units','normalized','position',[0.3 0.24 0.02125 0.03],'string','Nxt');
    
    abr_FIG.push.print   = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''print'');','style','pushbutton',...
        'Units','normalized','position',[0.35 0.085 0.1 0.03],'string','Print');
    abr_FIG.push.file   = uicontrol(abr_FIG.handle,'callback','abr_analysis3(''file'');','style','pushbutton',...
        'Units','normalized','position',[.35 0.05 0.1 0.03],'string','Save as File');
    abr_FIG.push.edit    = uicontrol(abr_FIG.handle,'style','edit', 'callback', 'abr_analysis3(''edit'');', ...
        'Units','normalized','position',[.22 .05 .1 .04],'string',[],'FontSize',12);
    
    axes('Position',[0 0 1 1]); axis off;
    text(0.34,0.255,'Mark peaks:','Fontsize',10,'horizontalalignment','left','VerticalAlignment','middle')
    text(0.73,0.03,'Time (ms)','FontSize',12,'horizontalalignment','center','VerticalAlignment','middle','color','k')
    text(0.27,0.40,'dB SPL','FontSize',12,'horizontalalignment','center','VerticalAlignment','middle','color','k')
    text(0.5-0.02*0.33,0.94,'dB SPL','FontSize',10,'horizontalalignment','left','VerticalAlignment','middle','color','b')
    text(0.5+0.15*0.33,0.94,'(attn)','FontSize',10,'horizontalalignment','left','VerticalAlignment','middle','color','k')
    
    axes('Position',[0 0.07 0.35 0.4]);
    axis('off');
    text(.2,.65,'Directory:','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.55,'Calibration File:','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.45,'ABR Files:','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.37,'Zoom left (ms):','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.32,'Zoom Right (ms):','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.24,'Template left (ms):','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.19,'Template right (ms):','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.09,'N of templates:','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    
    abr_FIG.parm_txt(1)  = text(.8,.55,num2str(abr_Stimuli.cal_pic),   'fontsize',10,'color','b','horizontalalignment','right',...
        'buttondownfcn','abr_analysis3(''stimulus'',1);');
    abr_FIG.parm_txt(2)  = text(.8,.45,num2str(abr_Stimuli.abr_pic),   'fontsize',10,'color','b','horizontalalignment','right',...
        'buttondownfcn','abr_analysis3(''stimulus'',2);');
    abr_FIG.parm_txt(3)  = text(.8,.37,num2str(abr_Stimuli.start),'fontsize',10,'color','b','horizontalalignment','right',...
        'buttondownfcn','abr_analysis3(''stimulus'',3);');
    abr_FIG.parm_txt(4)  = text(.8,.32,num2str(abr_Stimuli.end),  'fontsize',10,'color','b','horizontalalignment','right',...
        'buttondownfcn','abr_analysis3(''stimulus'',4);');
    abr_FIG.parm_txt(5)  = text(.8,.24,num2str(abr_Stimuli.start_template),'fontsize',10,'color','b','horizontalalignment','right',...
        'buttondownfcn','abr_analysis3(''stimulus'',5);');
    abr_FIG.parm_txt(6)  = text(.8,.19,num2str(abr_Stimuli.end_template),  'fontsize',10,'color','b','horizontalalignment','right',...
        'buttondownfcn','abr_analysis3(''stimulus'',6);');
    abr_FIG.parm_txt(7)  = text(.8,.09,num2str(abr_Stimuli.num_templates),     'fontsize',10,'color','b','horizontalalignment','right',...
        'buttondownfcn','abr_analysis3(''stimulus'',7);');
    abr_FIG.dir_txt = text(.8,.65,abr_Stimuli.dir,'fontsize',10,'color','r','horizontalalignment','right',...
        'buttondownfcn','abr_analysis3(''directory'');','Interpreter','none');
    
    set(abr_FIG.handle,'Userdata',struct('handles',abr_FIG));
    
    axes('Position',[0.50 0.07 0.33 0.86]); han.abr_panel=gca;
    title('ABR waveform','FontSize',14)
    ylabel('Tick interval = 0.5 uV','fontsize',12);
    
    axes('Position',[0.50 0.07 0.33 0.86]); han.peak_panel=gca;
    
    axes('Position',[0.86 0.07 0.1 0.86]); han.xcor_panel=gca;
    title('XCORR function','FontSize',14)
    
    axes('Position',[0.06 0.44 0.17 0.24]); han.amp_panel=gca;
    ylabel('P-P amplitude (uV)','FontSize',12)
    
    axes('Position',[0.06 0.69 0.17 0.24]); han.z_panel=gca;
    ylabel('Z score','FontSize',12)
    
    axes('Position',[0.275 0.44 0.17 0.49]); han.lat_panel=gca;
    ylabel('Latency (ms)','FontSize',12)
    
    axes('Position',[0 0 1 1]); han.text_panel=gca; axis(han.text_panel,'off',[0 1 0 1]);
    drawnow;
    
elseif strcmp(command_str,'stimulus')
    % MH 27Apr2004:  We'll change the calib # if we want!
    %         if parm_num == 1
    %             warndlg('Do not change calibration picture!','Analysis Error');
    %             set(abr_FIG.push.edit,'string',[]);
    %
    %
    if ~isempty(get(abr_FIG.push.edit,'string'))
        new_value = get(abr_FIG.push.edit,'string');
        set(abr_FIG.push.edit,'string',[]);
        set(abr_FIG.parm_txt(parm_num),'string',upper(new_value));
        switch parm_num
            case 1,
                abr_Stimuli.cal_pic = new_value;
                set(han.abr_panel,'Box','off');
            case 2,
                abr_Stimuli.abr_pic = new_value;
                %                    abr_analysis('process');  % added by GE 14Apr2004
            case 3,
                abr_Stimuli.start = str2num(new_value);
            case 4,
                abr_Stimuli.end = str2num(new_value);
            case 5,
                abr_Stimuli.start_template = str2num(new_value);
            case 6,
                abr_Stimuli.end_template = str2num(new_value);
            case 7,
                abr_Stimuli.num_templates = str2num(new_value);
        end
    else
        set(abr_FIG.push.edit,'string','ERROR');
    end
    
elseif strcmp(command_str,'nextPics')
    ExpDir=fullfile(abr_data_dir,abr_Stimuli.dir); 
    cd(ExpDir);
    hhh=dir('a*ABR*');
    for i=1:length(hhh)
        ABRpics(i)=str2num(hhh(i).name(2:5));
        ABRfreqs(i)=str2num(hhh(i).name(11:14));
    end
    
    if strcmp(get(han.abr_panel,'Box'),'on')
        firstPic=max(ParseInputPicString_V2(abr_Stimuli.abr_pic))+1;
    else
        firstPic=min(ABRpics);
    end
    
    if firstPic <= max(ABRpics)
        freqTarget=ABRfreqs(ABRpics==firstPic);
        picNow=firstPic;
        
        while ~isempty((ABRfreqs(ABRpics==picNow)==freqTarget)==1) && picNow <= max(ABRpics)
            lastPic=picNow;
            picNow=picNow+1;
        end
        new_value=[num2str(firstPic) '-' num2str(lastPic)];
    else
        new_value=abr_Stimuli.abr_pic;
    end
    
    
    set(abr_FIG.parm_txt(2),'string',upper(new_value));
    abr_Stimuli.abr_pic = new_value;
    
    if strcmp(get(han.abr_panel,'Box'),'off')
        currentDirectory=cd;
        has_chin = [findstr(currentDirectory,'chin') findstr(currentDirectory,'Chin')];
        if ~isempty(has_chin)
            suggestedID={currentDirectory(has_chin+(4:7))};
        else
            suggestedID={['']};
        end
        animal = inputdlg('Animal ID number:','',1,suggestedID);
        axes(han.text_panel); text(0.04,0.95,['Chinch. ' char(animal) ';'],...
            'FontSize',14,'horizontalalignment','left','VerticalAlignment','bottom')
        set(han.abr_panel,'Box','on');
    end;
    zzz
    set(han.peak_panel,'Box','on');
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
    
elseif strcmp(command_str,'directory')
    abr_Stimuli.dir = get_directory;
    set(han.abr_panel,'Box','off'); set(han.peak_panel,'Box','off');
    set(abr_FIG.dir_txt,'string',abr_Stimuli.dir);
    
elseif strcmp(command_str,'process')
    if strcmp(get(han.abr_panel,'Box'),'off')
        currentDirectory=cd;
        has_chin = [findstr(currentDirectory,'chin') findstr(currentDirectory,'Chin')];
        if ~isempty(has_chin)
            suggestedID={currentDirectory(has_chin+(4:7))};
        else
            suggestedID={['']};
        end
        animal = inputdlg('Animal ID number:','',1,suggestedID);
        axes(han.text_panel); text(0.04,0.95,['Chinch. ' char(animal) ';'],...
            'FontSize',14,'horizontalalignment','left','VerticalAlignment','bottom')
        set(han.abr_panel,'Box','on');
    end;
    zzz
    set(han.peak_panel,'Box','on');
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
        
elseif strcmp(command_str,'refdata')
    if strcmp(get(han.peak_panel,'Box'),'on')
        refdata
    else
        msgbox('Load new ABR files before plotting reference data')
    end;
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'cbh')
    if strcmp(get(han.peak_panel,'Box'),'on')
        plot_data
    else
        msgbox('Load new ABR files before plotting reference data')
    end;
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'change_weights')
    if strcmp(get(han.peak_panel,'Box'),'on')
        change_weights
    else
        msgbox('Load ABR files before optimizing model fit')
    end;
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'peak1')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak('p',1)
    else
        msgbox('Load new ABR files before marking peaks')
    end;
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'trou1')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak('n',1)
    else
        msgbox('Load new ABR files before marking peaks')
    end;
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'peak2')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak('p',2)
    else
        msgbox('Load new ABR files before marking peaks')
    end;
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'trou2')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak('n',2)
    else
        msgbox('Load new ABR files before marking peaks')
    end;
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'peak3')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak('p',3)
    else
        msgbox('Load new ABR files before marking peaks')
    end;
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'trou3')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak('n',3)
    else
        msgbox('Load new ABR files before marking peaks')
    end;
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'peak4')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak('p',4)
    else
        msgbox('Load new ABR files before marking peaks')
    end;
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'trou4')
    if strcmp(get(han.peak_panel,'Box'),'on')
        peak('n',4)
    else
        msgbox('Load new ABR files before marking peaks')
    end;
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'autofind')
    peak1af
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);    
    
elseif strcmp(command_str,'print')
    set(gcf,'PaperOrientation','Landscape','PaperPosition',[0 0 11 8.5]);
    if ispc
        print('-dwinc','-r200');
    else
        print('-PNeptune','-dpsc','-r200','-noui');
    end
    
elseif strcmp(command_str,'file')
    if strcmp(get(han.abr_panel,'Box'),'on')
        save_file
    else
        msgbox('Data not saved')
    end;
    
elseif strcmp(command_str,'edit') % added by GE 15Apr2004
    
elseif strcmp(command_str,'close')
    update_params3;
    closereq;
end