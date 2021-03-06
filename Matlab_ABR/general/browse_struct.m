function browse_struct(s, title,f_units, max_width, max_struct_elem)
%

% AF 11/8/01

struct_name = inputname(1);
if ((exist('title','var') ~= 1) | isempty(title))
   title = 'browse structure';
   if (~isempty(struct_name))
      title = [title ' ''' struct_name ''''];
   end
end
if (exist('f_units','var') ~= 1)
   f_units = {};
end
if (exist('max_width','var') ~= 1)
   max_width  = Inf;
end
if (exist('max_struct_elem','var') ~= 1)
   max_struct_elem = 3;
end

str = struct2str(s,f_units,max_width,max_struct_elem);
if (~isempty(struct_name))
   str = cat(1,{struct_name},str);
end

tot_height = min(length(str)+4, 40);

screen_size  = get_screen_size('char');
% aspec_ratio  = screen_size(3)/screen_size(4);
fig_pos = [screen_size(3)/5  screen_size(4)-tot_height-4 ...
      screen_size(3)*3/5  tot_height];

h_fig = figure( ...
   'NumberTitle',         'off',...
   'Name',                title, ...
   'Units',               'char', ...
   'position',            fig_pos, ...
   'keypress',            'Struct2Form(get(gcbf,''CurrentCharacter''));', ...
   'color',               get(0,'DefaultuicontrolBackgroundColor')... 
   );

uicontrol('Parent', h_fig,...
   'Style', 'listbox',...
   'Units', 'char',...
   'Position', [1 1 fig_pos(3)-2 fig_pos(4)-2],...
   'HorizontalAlignment','left', ...
   'FontName', 'FixedWidth',...
   'FontSize', 9,...
   'Enable', 'inactive',...
   'Value', [],...
   'Max',tot_height-2, ...
   'BackgroundColor',[1 1 1], ...
   'String',str,...
   'Tag', 'strList');
