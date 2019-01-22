function update_picnums_for_freqval(freq_val_kHz)

global abr_FIG abr_Stimuli abr_data_dir data han

if ~isempty(data)
    if isfield(data,'x')
        if sum(sum(~isnan(data.x)))
            ButtonName=QUESTDLG('Would you like to save?');
            if strcmp(ButtonName,'Yes')
                save_file2;
            elseif strcmp(ButtonName,'Cancel')
                return
            end
        end
    end
end

ExpDir=fullfile(abr_data_dir,abr_Stimuli.dir);
cd(ExpDir);
if freq_val_kHz~=0
    allfiles=dir(['a*ABR*' num2str(round(freq_val_kHz*1e3)) '*']);
    if isempty(allfiles)
        allfiles=dir(['p*ABR*' num2str(round(freq_val_kHz*1e3)) '*']);
    end
elseif freq_val_kHz==0
    allfiles=dir('a*ABR*click*');
    if isempty(allfiles)
        allfiles=dir('p*ABR*click*');
    end
end

SPL=nan(1,length(allfiles));
ABRpics=nan(1,length(allfiles));

for i=1:length(allfiles)
    filename=allfiles(i).name;
    eval(['run(''' filename ''');']);
    eval('x=ans;')
    if ~isfield(x.Stimuli,'MaxdBSPLCalib')
        allcalfiles=dir('p*calib*');
        calfile=allcalfiles(1).name;
        x.Stimuli.MaxdBSPLCalib=read_calib_interpolated(calfile,x.Stimuli.freq_hz/1e3);
    end
    
    SPL(i)=x.Stimuli.MaxdBSPLCalib-x.Stimuli.atten_dB;
    if SPL(i)<=abr_Stimuli.maxdB2analyze+2
        ABRpics(i)=str2double(allfiles(i).name(2:5));
    end
end

ABRpics(isnan(ABRpics))=[];
new_value=MakeInputPicString(ABRpics);

set(abr_FIG.parm_txt(2),'string',upper(new_value));
abr_Stimuli.abr_pic = new_value;

zzz5;
set(han.peak_panel,'Box','on');
set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);