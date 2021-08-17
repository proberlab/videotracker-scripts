function fish_plot(time, data, genox)

% from Sabine for rectangle <start>
clear lb
lb = find(genox.lightboundries ==1)/60;
lb(end+1) = size(genox.onehour{1},1);
for i = 1:size(genox.data,2)
    top(i) = max(nanmean(genox.onehour{i}'));
end
for i = 1:2:size(lb,1)-2
       rectangle('Position',[lb(i+1) 0 lb(i+2)-lb(i+1) max(top)+75],'FaceColor',[0.9608    0.9608    0.9608],'Edgecolor',[1 1 1])
       hold on;
end
% from Sabine for rectangle <end>


for j = 1:genox.number_of_genos
% colors
    if j == 1
    c = [0 0 1]; %blue
    s = 'b';
    elseif (j == 2 && genox.number_of_genos == 2)
    c =  [1 0 0]; %red
    s = 'r';
    elseif (j == 2 && genox.number_of_genos > 2)
    c = [0 1 1]; %cyan
    s = 'c';
    elseif (j == 3)
    c =  [1 0 0]; %red
    s = 'r';
    elseif j == 4 
    c = [1 0 1]; %magenta/purple
    s = 'm';
    elseif j == 5
    c = [0 1 0]; %green
    s = 'g';
    elseif j == 6 
    c = [1 1 0]; %yellow
    s = 'y';
    elseif j == 7
    c = [0 0 0]; %black
    s = 'k';
    elseif j == 8 
    c = [0.5 0.5 0.5];
    elseif j == 9
    c = [.5 .2 .8];
    elseif j == 10 
    c = [0.5 .2 .2];
    elseif j > 10
        c = [1 1 1];
    end
    
plot(time,nanmean(data{j}'),...
    'color', c);     
    
% % and to update the legend
legendname(j)=cellstr(genox.name{j});
end

% determine size for y axis based on larger value
for i = 1:genox.number_of_genos
    to_sort(i) = max(nanmean(data{i}'));
end
axis([time(1) time(end) 0 1.1*max(to_sort)]) % for 10% on biggest value

% add legend
legend(legendname);

set(gca,'TickDir','out',...
    'FontSize',12,...
    'XTick', (0:length(genox.OneMinuteTime)/60),...
    'XTickLabel', (0:length(genox.OneMinuteTime)/60),...
    'LineWidth',2, 'FontName', 'Arial')

legend('LineWidth',1)

end
