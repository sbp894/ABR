function dirname = get_directory

global abr_data_dir abr_Stimuli han latcomp

d = dir(abr_data_dir);
d = d([d.isdir]==1 & strncmp('.',{d.name},1)==0); % Only directories which are not '.' nor '..'
str = {d.name};
[selection, ok] = listdlg('Name', 'File Manager', ...
    'PromptString',   'Select an Existing Data Directory:',...
    'SelectionMode',  'single',...
    'ListSize',       [300,300], ...
    'OKString',       'Re-Activate', ...
    'CancelString',   'Create new Directory', ...
    'InitialValue',    1, ...
    'ListString',      str);
drawnow;
if (ok==0 || isempty(selection))
    dirname = abr_Stimuli.dir;
else
    dirname = str{selection};
    %clear out contents of all axes
    set([han.abr_panel han.amp_panel han.lat_panel han.text_panel han.xcor_panel han.z_panel han.peak_panel],'NextPlot','replacechildren')
    plot(han.abr_panel,0,0,'-w'); plot(han.amp_panel,0,0,'-w'); plot(han.lat_panel,0,0,'-w');
    plot(han.xcor_panel,0,0,'-w'); plot(han.z_panel,0,0,'-w'); plot(han.text_panel,0,0,'-w'); plot(han.peak_panel,0,0,'-w');
    %	axis([han.abr_panel han.amp_panel han.lat_panel han.xcor_panel han.z_panel han.peak_panel],'off')
    latcomp=NaN(1,4);
end