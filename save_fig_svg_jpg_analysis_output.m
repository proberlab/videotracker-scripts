function save_fig_svg_jpg_analysis_output(name, genox)
% save_fig_svg_jpg_analysis_output(name, genox)
% A function by GO to save a figure in all three formats.
% It saves the files in folder ../_analysis_output
% name = the suffix to add to the figure
% genox = the data passed into the funciton; it only serves to input the
%		the folder to save in (genox.working_path) and 
%		the prefix (genox.data_filename)	

% save  fig
hgsave(strcat('../analysis_output/', genox.data_filename, '_', name, '.fig'))

% save svg
set(gcf, 'paperunits', 'centimeters', 'paperposition', [0 0 24 15])
print('-dsvg', '-r300', ['../analysis_output/', genox.data_filename, '_', name, '.svg'])

% save  jpg
set(gcf, 'paperunits', 'centimeters', 'paperposition', [0 0 24 15])
print('-dtiff', '-r300', ['../analysis_output/', genox.data_filename, '_', name, '.jpg'])

end
