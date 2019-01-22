function signal_averager(command_str)

%This is the main program for collecting averaged EP data.

global PROG FIG Stimuli NelData AVdata root_dir COMM

if nargin < 1
    
    %CREATING STRUCTURES HERE
    PROG = struct('name','AVERAGE.m','date',date,'version','rp2 v2.0');
    
    push = cell2struct(cell(1,6),{'stop','print','aver','params','recall','edit'},2);
    ax1  = cell2struct(cell(1,2),{'axes','line1'},2);
    ax2  = cell2struct(cell(1,4),{'axes','ProgHead','ProgData','ProgMess'},2);
    ax3  = cell2struct(cell(1,8),{'axes','ParamHead1','ParamHead2','ParamHead3','ParamHead4','ParamData1','ParamData2','ParamData3'},2);
    FIG = struct('handle',[],'push',push,'ax1',ax1,'ax2',ax2,'ax3',ax3);
    
    eval('get_averaging_ins');
    
    if Stimuli.freq_hz == 0,
        stim_txt = 'click';
    else
        stim_txt = num2str(Stimuli.freq_hz);
    end
    eval('explist');
    
    FIG.handle = figure('NumberTitle','off','Name','Averager Interface','Units','normalized','Visible','off','position',[0 0 1 .95]);
    colordef none;
    whitebg('w');
    avplot;
    
    LoadTDT;
    
    set(FIG.handle,'Visible','on');
    drawnow;
    
elseif strcmp(command_str,'params')
    view_params;
    
elseif strcmp(command_str,'return')
    set(FIG.ax1.axes,'XLim',[0 Stimuli.record_duration],'YLim',[-3.5 3.5]);
    set(FIG.ax1.axes,'YTick',[-3.5 0 3.5]);
    set(FIG.ax1.line1,'XData',0,'YData',0);
    fnum = NelData.General.fnum +1;
    set(FIG.ax2.ProgData,'string', {PROG.name PROG.date fnum},'color',[.1 .1 .6]);
    
    if ~Stimuli.freq_hz
        stim_txt = 'click';
    else
        stim_txt = num2str(Stimuli.freq_hz);
    end
    
    set(FIG.ax3.ParamData1,'string', {Stimuli.play_duration; Stimuli.rise_fall; Stimuli.pulses_per_sec; Stimuli.record_duration; Stimuli.naves; Stimuli.amp_gain},'color',[.1 .1 .6]);
    set(FIG.ax3.ParamData2,'string', {stim_txt},'color',[.6 .1 .1]);
    set(FIG.ax3.ParamData3,'string', {Stimuli.db_atten},'color',[.6 .1 .1]);
    
    set(FIG.push.stop,'Enable','off');
    set(FIG.push.recall,'Enable','on');
    set(FIG.push.aver,'Enable','on');
    set(FIG.push.print,'Enable','on');
    set(FIG.push.params,'Enable','on');
    
elseif strcmp(command_str,'average')
    % Print Title and description.
    set(FIG.ax1.axes,'XLim',[0 Stimuli.record_duration],'YLim',[-3.5 3.5]);
    set(FIG.ax1.axes,'YTick',[-3.5 0 3.5]);
    fnum = NelData.General.fnum +1;
    set(FIG.ax2.ProgData,'string', {PROG.name PROG.date fnum},'color',[.1 .1 .6]);
    set(FIG.ax2.ProgMess,'String','Starting averaging routine...');
    if Stimuli.freq_hz == 0,
        stim_txt = 'click';
    else
        stim_txt = num2str(Stimuli.freq_hz);
    end
    
    set(FIG.ax3.ParamData1,'string',{Stimuli.play_duration; Stimuli.rise_fall; Stimuli.pulses_per_sec; Stimuli.record_duration; Stimuli.naves; Stimuli.amp_gain},'color',[.1 .1 .6]);
    set(FIG.ax3.ParamData2,'string',{stim_txt},'color',[.6 .1 .1]);
    set(FIG.ax3.ParamData3,'string',{Stimuli.db_atten},'color',[.6 .1 .1]);
    
    set(FIG.push.stop,'Enable','on');
    set(FIG.push.recall,'Enable','off');
    set(FIG.push.aver,'Enable','off');
    set(FIG.push.print,'Enable','off');
    set(FIG.push.params,'Enable','off');
    drawnow;
    
    %use these default values if no inputs are specified
    scale = Stimuli.amp_gain/1e6;
    period = 1000/Stimuli.pulses_per_sec; %trigger interval in msecs
    buf = ceil(Stimuli.record_duration*Stimuli.SampRate);
    AVdata = zeros(buf,4);
    AVdata(:,1)= ([1:buf] / Stimuli.SampRate)';
    set(FIG.ax1.line1,'XData',AVdata(:,1),'YData',AVdata(:,4));
    
    updateTDT;
    invoke(COMM.RP2_2,'SetTagVal','Npls',Stimuli.naves+2);
    invoke(COMM.RP2_2,'SetTagVal','ToneDur',Stimuli.play_duration);
    invoke(COMM.RP2_2,'SetTagVal','PulsLo',period-Stimuli.play_duration);
    invoke(COMM.RP2_2,'SetTagVal','nAVG',Stimuli.naves/2);
    invoke(COMM.RP2_2,'SetTagVal','nSize',buf);
    invoke(COMM.RP2_2,'Run');
    
    %play-record loop
    set(FIG.ax2.ProgMess,'String','Averaging in progress...');
    invoke(COMM.RP2_2,'SoftTrg',1);
    tic;
    while toc<.1, drawnow; end
    invoke(COMM.RP2_2,'SoftTrg',2);
    
    numstm = 0;
    shiftready = 0;
    
    for counter = 10:10:Stimuli.naves
        update = 1;
        while ~length(get(FIG.push.stop,'Userdata'))
            stage=invoke(COMM.RP2_2,'ReadTagV','Stage',0,1);
            if (stage==1) & (~shiftready)
                shiftready = 1;
            elseif (stage==2) & (shiftready)
                numstm = numstm+2;
                invoke(COMM.RP2_1,'SetTagVal','Scale',mod(numstm,4)-1);
                shiftready = 0;
            end
            nGood=invoke(COMM.RP2_2,'ReadTagV','nGood',0,1);
            if nGood*2 == counter & update
                update = 0;
                AVdata(:,2) = invoke(COMM.RP2_2,'ReadTagV','av_data',0,buf)'./nGood./scale;
                AVdata(:,3) = invoke(COMM.RP2_2,'ReadTagV','av_data',buf,buf)'./nGood./scale;
                AVdata(:,4) = (AVdata(:,2)+AVdata(:,3))/2;
                set(FIG.ax1.line1,'YData',AVdata(:,4));
                ylimup = max(0.01,ceil(max(AVdata(:,4))*12)/10);
                ylimdown = min(0.01,floor(min(AVdata(:,4))*12)/10);
                set(FIG.ax1.axes,'YLim',[ylimdown ylimup]);
                set(FIG.ax1.axes,'YTick',[ylimdown ylimup]);
                set(FIG.ax2.ProgMess,'String',counter,'FontSize',32);
                drawnow;
                break
            end
        end
    end
    
    if get(FIG.push.stop,'Userdata')
        set(FIG.ax2.ProgMess,'String','Stopping Averager...','FontSize',12);
    end
    
    invoke(COMM.PA5_1,'SetAtten',120.0);
    invoke(COMM.RP2_1,'Halt');
    invoke(COMM.RP2_2,'Halt');
    
    %************ Saving Data ******************
    ButtonName=questdlg('Do you wish to save these data?', ...
        'Save Prompt', ...
        'Yes','No','Comment','Yes');
    
    switch ButtonName,
        case 'Yes',
            comment='No comment.';
        case 'Comment'
            comment=add_comment_line;
    end
    
    if strcmp(ButtonName,'Yes') |  strcmp(ButtonName,'Comment'),
        NelData.General.fnum = make_average_text_file(comment);
        UpdateExplist(NelData.General.fnum);
    end
    set(FIG.push.stop,'Userdata',[]);
    set(FIG.push.stop,'Enable','off');
    set(FIG.push.recall,'Enable','on');
    set(FIG.push.aver,'Enable','on');
    set(FIG.push.print,'Enable','on');
    set(FIG.push.params,'Enable','on');
    set(FIG.ax2.ProgMess,'String','Ready for input...','fontSize',12);
    drawnow;
    
elseif strcmp(command_str,'stimulus')
    new_value = get(FIG.push.edit,'string');
    set(FIG.push.edit,'string',[]);
    if length(new_value),
        if strncmp(new_value,'c',1),
            Stimuli.freq_hz = 0;
            set(FIG.ax3.ParamData2,'String','click');
        else
            Stimuli.freq_hz = str2num(new_value);
            set(FIG.ax3.ParamData2,'String',new_value);
        end
        eval('update_params');
    else
        set(FIG.push.edit,'string','ERROR!');
    end
    
elseif strcmp(command_str,'attenuation')
    new_value = get(FIG.push.edit,'string');
    set(FIG.push.edit,'string',[]);
    if length(new_value),
        Stimuli.db_atten = str2num(new_value);
        set(FIG.ax3.ParamData3,'String',new_value);
        eval('update_params');
    else
        set(FIG.push.edit,'string','ERROR!');
    end
    
elseif strcmp(command_str,'stop')
    set(FIG.push.stop,'Userdata',1);
    
elseif strcmp(command_str,'recall')
    eval('read_avg_file');
    set(FIG.push.stop,'Enable','off');
    set(FIG.push.recall,'Enable','on');
    set(FIG.push.aver,'Enable','on');
    set(FIG.push.print,'Enable','on');
    set(FIG.push.params,'Enable','on');
    drawnow;
    
elseif strcmp(command_str,'print')
    set(gcf,'PaperOrientation','Landscape','PaperPosition',[0 0 11 8.5]);
    if ispc
        print('-dwinc','-r200','-noui');
    else
        print('-PNeptune','-dpsc','-r200','-noui');
    end
end
