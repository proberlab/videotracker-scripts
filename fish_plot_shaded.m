function fish_plot_shaded(time, data, genox)

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
    s = 'b'; %blue
    elseif (j == 2 && genox.number_of_genos == 2)
    s = 'r'; %red
    elseif (j == 2 && genox.number_of_genos > 2)
    s = 'c'; %cyan
    elseif (j == 3)
    s = 'r'; % red
    elseif j == 4 
    s = 'm'; % magenta/purple
    elseif j == 5
    s = 'g'; % green
    elseif j == 6 
    s = 'y'; % yellow
    elseif j == 7
    s = 'k'; % black
    elseif j == 8 
    s = 'k'; % black
    elseif j == 9
    s = 'k'; % black
    elseif j == 10 
    s = 'k'; % black
    elseif j > 10
    s = 'k'; % black
    end
    
    sem = (nanstd(data{j}, 0, 2)/sqrt(size(data{j},2)))';
    A(j) = shadedErrorBar(time, nanmean(data{j}'), sem, 'lineprops', s);
    legendname(j)=cellstr(genox.name{j});
    
end
    

% determine size for y axis based on larger value
for i = 1:genox.number_of_genos
    to_sort(i) = max(nanmean(data{i}'));
end
axis([time(1) time(end) 0 1.1*max(to_sort)]) % for 10% on biggest value

% make legend
if genox.number_of_genos == 1
       legend([A(1).mainLine],string(cellstr(genox.name{1})))
    elseif genox.number_of_genos == 2
            legend([A(1).mainLine,A(2).mainLine],string(cellstr(genox.name{1})),string(cellstr(genox.name{2})))
    elseif genox.number_of_genos == 3
        legend([A(1).mainLine,A(2).mainLine,A(3).mainLine],string(cellstr(genox.name{1})),string(cellstr(genox.name{2})),string(cellstr(genox.name{3})))
    elseif genox.number_of_genos == 4
        legend([A(1).mainLine,A(2).mainLine,A(3).mainLine,A(4).mainLine],...
            string(cellstr(genox.name{1})),string(cellstr(genox.name{2})),string(cellstr(genox.name{3})),string(cellstr(genox.name{4})))
    elseif genox.number_of_genos == 5
        legend([A(1).mainLine,A(2).mainLine,A(3).mainLine,A(4).mainLine,A(5).mainLine],...
            string(cellstr(genox.name{1})),string(cellstr(genox.name{2})),string(cellstr(genox.name{3})),string(cellstr(genox.name{4})),string(cellstr(genox.name{5})))
    elseif genox.number_of_genos == 6
        legend([A(1).mainLine,A(2).mainLine,A(3).mainLine,A(4).mainLine,A(5).mainLine,A(6).mainLine],...
            string(cellstr(genox.name{1})),string(cellstr(genox.name{2})),string(cellstr(genox.name{3})),string(cellstr(genox.name{4})),string(cellstr(genox.name{5}))...
            ,string(cellstr(genox.name{6})))
    elseif genox.number_of_genos == 7
        legend([A(1).mainLine,A(2).mainLine,A(3).mainLine,A(4).mainLine,A(5).mainLine,A(6).mainLine,A(7).mainLine],...
            string(cellstr(genox.name{1})),string(cellstr(genox.name{2})),string(cellstr(genox.name{3})),string(cellstr(genox.name{4})),string(cellstr(genox.name{5}))...
            ,string(cellstr(genox.name{6})),string(cellstr(genox.name{7})))
    elseif genox.number_of_genos == 8
        legend([A(1).mainLine,A(2).mainLine,A(3).mainLine,A(4).mainLine,A(5).mainLine,A(6).mainLine,A(7).mainLine,A(8).mainLine],...
            string(cellstr(genox.name{1})),string(cellstr(genox.name{2})),string(cellstr(genox.name{3})),string(cellstr(genox.name{4})),string(cellstr(genox.name{5}))...
            ,string(cellstr(genox.name{6})),string(cellstr(genox.name{7})),string(cellstr(genox.name{8})))
end

set(gca,'TickDir','out',...
    'FontSize',12,...
    'XTick', (0:60:length(time)),...
    'XTickLabel', (0:60:length(time)),...
    'LineWidth',2, 'FontName', 'Arial')

legend('LineWidth',1)

end
