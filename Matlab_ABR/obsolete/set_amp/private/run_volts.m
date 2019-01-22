function run_volts

global NelData FIG Stimuli prog_dir

volts = 0;

PAco1=actxcontrol('PA5.x',[0 0 1 1]);
for dev = 1:2
    invoke(PAco1,'ConnectPA5','GB',dev);
    invoke(PAco1,'SetAtten',120.0);
end

RPco1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RPco1,'ConnectRP2','GB',1);
if Stimuli.freq_hz,
    invoke(RPco1,'LoadCof',fullfile(prog_dir,'object','set_tone.rco'));
    invoke(RPco1,'SetTagVal','freq',Stimuli.freq_hz);
else
    invoke(RPco1,'LoadCof',fullfile(prog_dir,'object','set_noise.rco'));
    invoke(RPco1,'SetTagVal','LowCutOff',Stimuli.low);
    invoke(RPco1,'SetTagVal','HiCutOff',Stimuli.high);
end
invoke(RPco1,'SetTagVal','chan',Stimuli.chan);
invoke(RPco1,'Run');

invoke(PAco1,'ConnectPA5','GB',Stimuli.chan);
invoke(PAco1,'SetAtten',Stimuli.atten);

tic;
while ~length(get(FIG.push.edit,'Userdata')),
    if toc>1,
        volts = invoke(RPco1,'ReadTagV','RMSvolts',0,1);
        rms_str = sprintf('%s %6.3f','rms =',volts);
        set(FIG.ax1.ProgMess,'String',rms_str);
        NelData.General.Volts = volts;
        tic;
    end
    
    param_num = get(FIG.push.save,'Userdata');
    if param_num,
        switch param_num,
        case 1,
            invoke(RPco1,'Halt');
            if Stimuli.freq_hz,
                invoke(RPco1,'LoadCof',fullfile(prog_dir,'object','set_tone.rco'));
                invoke(RPco1,'SetTagVal','freq',Stimuli.freq_hz);
            else
                invoke(RPco1,'LoadCof',fullfile(prog_dir,'object','set_noise.rco'));
                invoke(RPco1,'SetTagVal','LowCutOff',Stimuli.low);
                invoke(RPco1,'SetTagVal','HiCutOff',Stimuli.high);
            end
            invoke(RPco1,'SetTagVal','chan',Stimuli.chan);
            invoke(PAco1,'ConnectPA5','GB',Stimuli.chan);
            invoke(PAco1,'SetAtten',Stimuli.atten);
            invoke(PAco1,'ConnectPA5','GB',mod(Stimuli.chan,2)+1);
            invoke(PAco1,'SetAtten',120.0);
            invoke(RPco1,'Run');
        case 2
            invoke(PAco1,'ConnectPA5','GB',Stimuli.chan);
            invoke(PAco1,'SetAtten',Stimuli.atten);
        case 3
            num_freqs = 0;
            max_volts = 0.1;
            while 1,
                frqlst(num_freqs+1) = (Stimuli.frqlo/1000)*2.0^(num_freqs/Stimuli.oct_steps);	
                if frqlst(num_freqs + 1) > (Stimuli.frqhi/1000), break; end
                num_freqs = num_freqs + 1;
            end
            bin_average = zeros(1,num_freqs);
            
            for bin = 1: num_freqs
                if length(get(FIG.push.edit,'Userdata')), break; end
                invoke(RPco1,'SetTagVal','center',frqlst(bin)*1000);
                curr_rms = zeros(1,5);
                for count = 1:5
                    curr_rms(count) = invoke(RPco1,'ReadTagV','RMSband',0,1);
                    tic
                    while toc < 0.05, drawnow; end
                end
                bin_average(bin) = 1000*mean(curr_rms);
                if max_volts <= max(bin_average(1:bin)),
                    max_volts = ceil(1.25*max(bin_average(1:bin)));
                    set(FIG.ax2.axes,'YLim',[0 max_volts]);
                    set(FIG.ax2.axes,'YTick',[0 max_volts]);
                end
                set(FIG.ax2.line1,'XData',frqlst(1:bin),'YData',bin_average(1:bin));
                drawnow;
            end
            set(FIG.push.analyze,'Enable','on');
        end
    end
    param_num = 0;
    set(FIG.push.save,'Userdata',0);
    drawnow;
end

invoke(RPco1,'Halt');

for dev = 1:2
    invoke(PAco1,'ConnectPA5','GB',dev);
    invoke(PAco1,'SetAtten',120.0);
end

NelData.General.Volts = volts;