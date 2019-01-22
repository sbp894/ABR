function [data] = noise_cal

global FIG Stimuli root_dir

set(FIG.ax2.ProgMess,'String','Measuring amplitude of reference tone...');
drawnow;

PAco1=actxcontrol('PA5.x',[0 0 1 1]);
invoke(PAco1,'ConnectPA5','GB',1);
invoke(PAco1,'SetAtten',Stimuli.attencal);

RPco1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RPco1,'ConnectRP2','GB',1);
invoke(RPco1,'LoadCof',fullfile(root_dir,'calibrate','object','tone_DAC.rco'));
invoke(RPco1,'Run');
invoke(RPco1,'SoftTrg',1);

tic;
while toc < 2
    if length(get(FIG.push.stop,'Userdata'))
        invoke(RPco1,'Halt');
        invoke(PAco1,'SetAtten',120);
        set(FIG.ax2.ProgMess,'String','Aborting QuickCal...');
        data = -1;
        pause(1);
        return
    else
        drawnow;
    end
end

npts = invoke(RPco1,'GetTagVal','index');
dac = invoke(RPco1,'ReadTagV','DAC',0,npts);
invoke(RPco1,'Halt');

tone = dac - mean(dac);

j = 5000:length(tone);
zcross = find(tone(j-1)<=0 & tone(j)>=0);

npers = 0;
magSum = 0;
for k = 2:length(zcross);
    wave=tone(zcross(k-1):zcross(k));
    magSum = magSum + max(wave)-min(wave);
    npers = npers + 1;
end

v16k = magSum/npers*0.3535;

set(FIG.ax2.ProgMess,'String','Measuring speaker transfer function...');
drawnow;

RPco1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RPco1,'ConnectRP2','GB',1);
invoke(RPco1,'LoadCof',fullfile(root_dir,'calibrate','object','noise_DAC.rco'));
invoke(RPco1,'Run');
invoke(RPco1,'SoftTrg',1);

tic;
while toc < 5
    if length(get(FIG.push.stop,'Userdata'))
        invoke(RPco1,'Halt');
        invoke(PAco1,'SetAtten',120);
        set(FIG.ax2.ProgMess,'String','Aborting QuickCal...');
        data = -1;
        pause(1);
        return
    else
        drawnow;
    end
end

npts = invoke(RPco1,'GetTagVal','index');
src = invoke(RPco1,'ReadTagV','source',0,npts);
dac = invoke(RPco1,'ReadTagV','DAC',0,npts);

invoke(RPco1,'Halt');
invoke(PAco1,'SetAtten',120);

[Txy,f]=tfe(src,dac,1024,97656.3,1024,512,'none');
FrqRange = find(f>=Stimuli.frqlo*1000 & f<=Stimuli.frqhi*1000);

dbSPL = 20*log10(abs(Txy(FrqRange)));
freq  = f(FrqRange)/1000;

set(FIG.ax2.ProgMess,'String','Converting to dB SPL...');
drawnow;

data_file = strcat('mic',Stimuli.nmic,'.m');
command_line = sprintf('%s%s%c','[mic]=',strrep(lower(data_file),'.m',''),';');
eval(command_line);
FrqLoc = max(find(mic.CalData(:,1) <= Stimuli.frqcal));
dbSPL16k = 20 * log10(v16k) - mic.dBV;
CalLoc = min(find(freq >=Stimuli.frqcal));
mag16k = dbSPL(CalLoc);

cal = dbSPL16k - mag16k;

for index = 1:length(freq)
    FrqLoc = max(find(mic.CalData(:,1) <= freq(index)));
    dbSPL(index) = dbSPL(index) + mic.CalData(FrqLoc,2) + cal;
end

data = zeros(length(freq),5);
data(:,1) = freq;
data(:,2) = dbSPL+Stimuli.attencal;

set(FIG.ax2.ProgMess,'String','Finished...');
drawnow;
