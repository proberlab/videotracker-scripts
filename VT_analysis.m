%% Analysis of viewpoint data
% Grigorios Oikonomou 2019 - Basin on original script by Jason Rihel

%% Housecleaning
clear all; close all; tic;
set(0, 'DefaultFigureRenderer', 'painters'); % forcing matlab to use painter for renderer to keep svgs as vectors, not bitmaps

%% Information about the experiment
genox.genotype_filename = '20210821_genotype_3.txt'; % the name of the genotype file
genox.data_filename = '20210821_01_mutantX_UTF8_DATA_middur_TRIMMED.txt'; % the name of the data file
genox.number_of_days = 1; % how many days to generate column data for
genox.cutoff = 1; % based on the sensitivity of the videotrackers
genox.experiment = strcat(' 20210821 VT01 mutantX - cutoff = ', num2str(genox.cutoff)); % name of experiment

%% Import the genotype and data files
dataset = importdata(strcat('../matlab_data_processed/', genox.data_filename), '\t', 1);
genoset = importdata(strcat('../matlab_data_processed/', genox.genotype_filename),'\t', 2);

%% Genotype stuff
% Determine number of genotypes
genox.number_of_genos = length(genoset.data(1,1:end));

% Import genotype names and assign fish to genotypes
for i=1:genox.number_of_genos
    genox.name{i} = genoset.colheaders{i};
    genox.fishID{i} = genoset.data(~isnan(genoset.data(:,i)), i);
end

%% Sort the data into different Matlab cells based on genotypes
for i=1:genox.number_of_genos
    genox.data{i} = dataset.data(:,(genox.fishID{i}+2)); % +2 for two time columns at start
end

%% Time stuf
% Get the zeitgeber info from the dataset file (last column)
genox.zeitgeber = dataset.data(:, end);

% Get the light schedule info from zeitgeber infor. The stamp is 0 for day, 
% and 1 for night.
genox.lightschedule = genox.zeitgeber; 
genox.lightschedule(genox.lightschedule < 14) = 0; % time <14, day
genox.lightschedule(genox.lightschedule >= 14) =1; % time >= 14, night

% Get genox.time in hours (divide by 60)
for j=1:length(genox.zeitgeber)
    genox.time(j) = (j)/60;
end

% To get the day number,  add the first zeitgeber value (time that you 
% started the experiment) to all time points so that you have a real-world 
% time column. Then you can divide that with 24, so you turn that to a real-world 
% day column (and add 1 since you want to start at day 1 and not day 0. And round 
% down.
 genox.daynumber = floor((genox.zeitgeber(1)+genox.time)/24)+1;

%% Lightboundries (light/dark transitions)      
% In genox.lightschedule, 0 marks lights on, 1 marks lights off
% To mark the light/dark boundaries I just need to look for positions that
% have different values than the previous position
genox.lightboundries = genox.lightschedule; %initially just copy over;
for q= 2:length(genox.lightboundries)
    if genox.lightschedule(q) == genox.lightschedule(q-1)
        genox.lightboundries(q)= 0;
    end
    if genox.lightschedule(q) ~= genox.lightschedule(q-1)
         genox.lightboundries(q)= 1;
    end
end

% Jason had this:
genox.lightboundries(1)=1;
% perhaps because when program starts you go from dark to light?
% I am not sure this is a good idea...

%% Activity Data

% 1 min bins
genox.OneMinuteTime = genox.time + genox.zeitgeber(1); % every 1 min
for i = 1:genox.number_of_genos  % loop through all genotypes (i)
    for j = 1:length(genox.data{i}(1,1:end)) % within that genotype, loop through all columns (j)
        for q = 1:length(genox.data{i})  
         genox.OneMinute{i}(q, j)= genox.data{i}(q,j);
        end
    end
end         

% 10 min bins
genox.tenminutetime = genox.time(10:10:end) + genox.zeitgeber(1); % every 10 min
for i = 1:genox.number_of_genos  % loop through all genotypes (i) 
    for j = 1:length(genox.data{i}(1,1:end)) % within that genotype, loop through all columns (j) 
        for q = 10:10:length(genox.data{i})  % within each column, loop from row 10 to end in steps of 10 
             genox.tenminute{i}(q/10, j)= sum(genox.data{i}(q-9:q,j));
         % make new cell geno.tenmnute{genotypetype#}(row = initial/10, column =
         % column/fish number) = sum(within the genotype cell, rows in groups of 10, in fish column)!!!
        end
    end
end

% 60 min bins
genox.onehourtime = genox.time(60:60:end) + genox.zeitgeber(1); % every 60 min
for i = 1:genox.number_of_genos  % loop through all genotypes (i) 
    for j = 1:length(genox.data{i}(1,1:end)) % within that genotype, loop through all columns (j) 
        for q = 60:60:length(genox.data{i})  % within each column, loop from row 60 to end in steps of 60 
         genox.onehour{i}(q/60, j)= sum(genox.data{i}(q-59:q,j));
         % make new cell geno.tenmnute{phenotype#}(row = initial/10, column =
         % column/fish number) = sum(within the genotype cell, rows in
         % groups of 10, in fish column)!!!    
        end
    end
end    

%% Activity Graphs 

% 1 min bins
figure
hold on
xlabel('Zeitgeber Time (h)')
ylabel('Average Activity (s/min)') % genox.OneMinute
title(strcat('Activity 1 min bins ', genox.data_filename(1:end-9)), 'Interpreter', 'none')
fish_plot_shaded(genox.OneMinuteTime, genox.OneMinute, genox) % fish_plot(time, data, rest)
save_fig_svg_jpg_analysis_output('_Activity_1min', genox) % save_fig_svg_jpg_analysis_output(name, rest)

% 10 min bins
figure
hold on
xlabel('Zeitgeber Time (h)')
ylabel('Average Activity (s/10 min)')
title(strcat('Activity | 10 min bins ', genox.data_filename(1:end-9)), 'Interpreter', 'none')
fish_plot_shaded(genox.tenminutetime, genox.tenminute, genox) % fish_plot(time, data, rest)
save_fig_svg_jpg_analysis_output('_Activity_10min', genox) % save_fig_svg_jpg_analysis_output(name, rest)
     
% 60 min bins
figure
hold on
xlabel('Zeitgeber Time (h)')
ylabel('Average Activity (s/h)')
title(strcat('Activity | 1 h bins ', genox.data_filename(1:end-9)), 'Interpreter', 'none')
fish_plot_shaded(genox.onehourtime, genox.onehour, genox) % fish_plot(time, data, rest)
save_fig_svg_jpg_analysis_output('_Activity_60min', genox) % save_fig_svg_jpg_analysis_output(name, rest)


%% Waking activity data
% from help:'AveWaking: Same as data, but all 0 bins are marked as NaNs.'
% The trick here is to convert all the zeroes from the activity data to NaN
% so that you can skip them when graphing

% 1 min "bins"
for i = 1:genox.number_of_genos
    genox.avewaking{i} = genox.data{i}; % first just copy the data
    genox.avewaking{i}(genox.data{i} == 0) = NaN;  % then make zeroes NaNs
end

% now to convert to 10 min bins
for i =  1:genox.number_of_genos % loop through the genotypes
    for j = 1:length(genox.avewaking{i}(1,1:end)) % within genos loop through fish/columns
        for q=10:10:length(genox.avewaking{i})
            genox.avewakechart_10min{i}(q/10,j)=nanmean(genox.avewaking{i}(q-9:q,j));
        end
    end
end

% ...and to 60 min bins
for i =  1:genox.number_of_genos % loop through the genotypes
    for j = 1:length(genox.avewaking{i}(1,1:end)) % within genos loop through fish/columns
        for q=60:60:length(genox.avewaking{i})
            genox.avewakechart1h{i}(q/60,j) = nanmean(genox.avewaking{i}(q-59:q,j));
        end
    end
end

% ATTENTION: instead of summing like we did for the other chart data
% (activity and sleep), here we calculate the mean right away without
% taking into account the NaNs (they do not count in any way so that the
% average of [2, NaN] is 2, not 1.

%% Waking Activity Graph

% 1 min bins
figure
hold on
xlabel('Zeitgeber Time (hours)')
ylabel('Average Waking Activity (s/awake min')
title(strcat('Waking Activity | 1 min bins ',genox.data_filename(1:end-9)), 'Interpreter', 'none')
fish_plot(genox.OneMinuteTime, genox.avewaking, genox) % fish_plot(time, data, rest)
save_fig_svg_jpg_analysis_output('_WakingActivity_1min', genox) % save_fig_svg_jpg_analysis_output(name, rest)

% 10 min bins
figure
hold on
xlabel('Zeitgeber Time (hours)')
ylabel('Average Waking Activity (s/awake min')
title(strcat('Waking Activity | 10 min bins ',genox.data_filename(1:end-9)), 'Interpreter', 'none')
fish_plot_shaded(genox.tenminutetime, genox.avewakechart_10min, genox) % fish_plot(time, data, rest)
save_fig_svg_jpg_analysis_output('_WakingActivity_10min', genox) % save_fig_svg_jpg_analysis_output(name, rest)

% 60 min bins
figure
hold on
xlabel('Zeitgeber Time (hours)')
ylabel('Waking Activity (s/awake min)')
title(strcat('Waking Activity | 1 h bins ',genox.data_filename(1:end-9)), 'Interpreter', 'none') 
fish_plot_shaded(genox.onehourtime, genox.avewakechart1h, genox) % fish_plot(time, data, rest)
save_fig_svg_jpg_analysis_output('_WakingActivity_60min', genox) % save_fig_svg_jpg_analysis_output(name, rest)


%% Sleep data 
% 0 = AWAKE, 1 = SLEEP
% convert all the data values to 1 or 0 for when they are asleep of not:

% 1 min "bins"
for i = 1:genox.number_of_genos
    genox.sleep{i} = genox.data{i}; % first just copy the data
    genox.sleep{i}(genox.data{i} <= genox.cutoff) = 1; %0.1 is the minimum value given by the VT; if equal or below that, asleep
    genox.sleep{i}(genox.data{i} > genox.cutoff) = 0;% if above that, awake
end

% 10 min bins
for i = 1:genox.number_of_genos %loop through all genos
    for j=1:length(genox.sleep{i}(1,1:end)) %loop through all fish/columns in that geno
        for q=10:10:length(genox.sleep{i})
            genox.sleepchart_10min{i}(q/10, j) = sum(genox.sleep{i}(q-9:q, j));
        end
    end
end

% 60 min bins
for i = 1:genox.number_of_genos %loop through all genos
    for j=1:length(genox.sleep{i}(1,1:end)) %loop through all fish/columns in that geno
        for q=60:60:length(genox.sleep{i})
            genox.sleepchart1h{i}(q/60, j) = sum(genox.sleep{i}(q-59:q, j));
        end
    end
end
%% Sleep graphs 

% 1 min bin
figure
hold on
xlabel('Zeitgeber Time (h)')
ylabel('Sleep (min/min)')
title (strcat('Sleep | 1 min bins ', genox.data_filename(1:end-9)), 'Interpreter', 'none')
fish_plot(genox.OneMinuteTime, genox.sleep, genox) % fish_plot(time, data, rest)
save_fig_svg_jpg_analysis_output('_Sleep_1min', genox) % save_fig_svg_jpg_analysis_output(name, rest)
legend('Location','SouthEast');

% 10 min bin
figure
hold on
xlabel('Zeitgeber Time (h)')
ylabel('Sleep (min/10 min)')
title (strcat('Sleep | 10 min bins ', genox.data_filename(1:end-9)), 'Interpreter', 'none')
fish_plot_shaded(genox.tenminutetime, genox.sleepchart_10min, genox) % fish_plot(time, data, rest)
save_fig_svg_jpg_analysis_output('_Sleep_10min', genox) % save_fig_svg_jpg_analysis_output(name, rest)
legend('Location','SouthEast');

% 60 min bin
figure
hold on
xlabel('Zeitgeber Time (h)')
ylabel('Sleep (min/h)')
title (strcat('Sleep | 60 min bins ', genox.data_filename(1:end-9)), 'Interpreter', 'none')
fish_plot_shaded(genox.onehourtime, genox.sleepchart1h, genox) % fish_plot(time, data, rest)
save_fig_svg_jpg_analysis_output('_Sleep_60min', genox) % save_fig_svg_jpg_analysis_output(name, rest)
legend('Location','SouthEast');

%% Sleepcontinuity and sleepboutstart
% Sleepcontinuity is a counter of sleep bouts in the form of:
% ...0 0 0 1 2 3 4 0 1 2 3 4 5 6 7 0 0 0... 
% where 0 is awake and 1 is added for every minute spent asleep
% continuously

genox.sleepcontinuity = genox.sleep; % initially just copy the sleep data

for i=1:genox.number_of_genos  % loop through the genotypes
    for j =1:length(genox.sleepcontinuity{i}(1,1:end)) % and all fish/columns within the genotypes
        for k = 2:length(genox.sleepcontinuity{i}) % start at position #2 so that you can compare to previous position
            if genox.sleep{i}(k,j) == 1 % if the fish j of genotype i, is asleep at timepoint k...
                if genox.sleep{i}(k-1,j) == 0 % ...and awake at k-1: 
                    genox.sleepcontinuity{i}(k,j) = 1; %then sleep continuity of k = 1 (the counter starts over because the fish fell asleep
                end
                % if the fish j of genotype i, is asleep at timepoint k...
                if genox.sleep{i}(k-1,j) == 1 % ... and asleep at k-1:
                    z = 1+ genox.sleepcontinuity{i}(k-1,j); % add 1 to the sleep continuity score of the k-1
                    genox.sleepcontinuity{i}(k,j) = z; % and make the resulting value the sleep continuity score of k
                end
                % what if the sleep is awake at timepoint k (i.e. = 0)? 
                % Then the loop does nothing and sleep
                % continuity will be 0, since this is the value that was
                % put there when we copied the genox.sleep over to
                % genox.sleepcontinuity.
            end
        end
    end
    % Before leaving this loop, we can mark the beginning of every sleep
    % bout and make the genox.sleepboutstart
    % How? What we have now is: 0 0 0 1 2 3 4 5... 0 0 0 1 2 3...
    % We can make everything except the "1"s zero! Then only the beginnings
    % will be marked, which means we have a mark for each sleep bout
    genox.sleepboutstart{i} = genox.sleepcontinuity{i};
    genox.sleepboutstart{i}(genox.sleepcontinuity{i}>1) = 0; 
end      
 
%% Sleeplatency
% genox.sleeplatency is initially the same as the lightboundries (i.e.
% there is "1" in the minute when the lights change and "0" in every other
% minute. We then look for those "1"s and keep walking down from there but
% in the genox.sleep array! to look for 1

for i = 1:genox.number_of_genos % loop within the sleep data through all the genotypes i
    for j = 1:length(genox.sleep{i}(1,1:end)) % and all the fish j in that geno                                                    
            genox.sleeplatency{i}(:,j) = genox.lightboundries;  % first just copy the same lightboundries column to 
                                                                % the sleeplatency column for the current fish (j)
            for k = 1: length(genox.sleep{i})-1 % now loop through all the timepoints (rows) in that fish's data 
                                                % except the last one (since we change the next
                                                % timepoint in this loop,
                                                % see below)
                if genox.sleeplatency{i}(k,j) == 1 % if there is a boundry at timepoint k 
                                                   % (remember we just copied over the boundries to the latency)...
                    if genox.sleep{i}(k+1,j) == 0  % ...and the fish are awake at k+1(next position) (look at genox.sleep)
                        genox.sleeplatency{i}(k+1,j) = 1; % then mark the k+1 with 1 in the genox.sleeplatency
                       % Nothing happens if there is no boundry 
                       % (i.e. things stay 0).
                    end    
                end    
            end
    end
end

%% LAST BIT
% This is where the data get organized in days and nights (cells for each
% genotype and day vs night, with rows for different days and nights)
for i=1:genox.number_of_genos % loop through all the genotypes i
    for j = 1:max(genox.daynumber) % loop through all the days j
        for k = 1:length(genox.fishID{i}) % loop through all the fish k  
        
        % THIS is for EACH FISH and EACH DAY and EACH NIGHT
        %{
        % GO explanation here concerning find and intersect (relevant to all code below):
        % Look the intersect of day j and lightschedule == 0 (lights on) to define the relevant rows(timepoints) in the genox.sleep table
        % Wait! The intersect of a row (geno.daynumber == j) and a column (geno.lightschedule)? How can that be?
        % It turns out that "find" returns linear indices!
        % So find gets you the positions (in a linear index) that are first
        % of j day and then of lights on then intersect looks at the shared
        % positions  
        % Then look at the column k for fish k and sum.
        % sum for an array will give you a row with the columns summed 
        %}
            
        % Total Sleep for each fish for each day and night    
        genox.summarytable.sleep.day{i}(j,k) = sum(genox.sleep{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 0)),k));
        genox.summarytable.sleep.night{i}(j,k) = sum(genox.sleep{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 1)),k));

        % Total # of sleep bouts for each fish for each day and night
        genox.summarytable.sleepBout.day{i}(j,k) = sum(genox.sleepboutstart{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 0)),k));
        genox.summarytable.sleepBout.night{i}(j,k)= sum(genox.sleepboutstart{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 1)),k));
        
        % Total # of sleep bouts for each fish for each day and night PER HOUR
        genox.summarytable.hourly_sleep_bout_number.day{i}(j,k) = sum(genox.sleepboutstart{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 0)),k))/14;
        genox.summarytable.hourly_sleep_bout_number.night{i}(j,k)=sum(genox.sleepboutstart{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 1)),k))/10;
        
        % Mean Sleep Bout Length for  each fish for each day and night
        % Need to divide the total sleep of that day/night with the number of sleep bouts for that day/night
        genox.summarytable.sleepLength.day{i}(j,k)= genox.summarytable.sleep.day{i}(j,k)/genox.summarytable.sleepBout.day{i}(j,k);
        genox.summarytable.sleepLength.night{i}(j,k)= genox.summarytable.sleep.night{i}(j,k)/genox.summarytable.sleepBout.night{i}(j,k);
        % ATTENTION: if there have been no sleep bouts, the division of sleep/#ofbouts will give you Inf
        
        % Sleep Latency for each fish for each day and night
        genox.summarytable.sleepLatency.day{i}(j,k)=sum(genox.sleeplatency{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 0)),k));
        genox.summarytable.sleepLatency.night{i}(j,k)=sum(genox.sleeplatency{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 1)),k));
        
        % Average Activity for each fish for each day and night
        % (This is per minute since we use minute bins; multiply with 60 and you get the Hourly Activity; not really used): 
        genox.summarytable.averageActivity.day{i}(j,k)=nanmean(genox.data{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 0)),k));
        genox.summarytable.averageActivity.night{i}(j,k)=nanmean(genox.data{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 1)),k));
                
        % Total Activity for each fish for each day and night
        % Use find with genox.daynumber and genox.lightschedule to define the relevant segment of the genox.data, then use 'sum'
        % This is not particularly useful; I replaced it with Hourly Activity
        % genox.summarytable.TotalActivity.day{i}(j,k)=sum(genox.data{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 0)),k));
        % genox.summarytable.TotalActivity.night{i}(j,k)=sum(genox.data{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 1)),k));
        
        % Hourly Activity for each fish for each day and night 
        % Average activity per hour; this is the useful one!
        % Use find with genox.daynumber and genox.lightschedule to define the relevant segment of the genox.data
        % then sum and divide with 14 for day and 10 for night (number of hours respectively)
        genox.summarytable.hourly_activity.day{i}(j,k)=sum(genox.data{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 0)),k))/14;
        genox.summarytable.hourly_activity.night{i}(j,k)=sum(genox.data{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 1)),k))/10;
        
        % Hourly Sleep for each fish for each day and night
        % Use find with genox.daynumber and genox.lightschedule to define the relevant segment of the genox.data
        % then sum, then divide with 14 for day and 10 for night (number of hours respectively)
        genox.summarytable.hourly_sleep.day{i}(j,k)=sum(genox.sleep{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 0)),k))/14;
        genox.summarytable.hourly_sleep.night{i}(j,k)=sum(genox.sleep{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 1)),k))/10;
                       
        % Average Waking Activity for each fish for each day and night
        % Use find with genox.daynumber and genox.lightschedule to define the relevant segment of the genox.data, then use 'nanmean'
        genox.summarytable.averageWaking.day{i}(j,k)=nanmean(genox.avewaking{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 0)),k));
        genox.summarytable.averageWaking.night{i}(j,k)=nanmean(genox.avewaking{i}(intersect(find(genox.daynumber == j),find(genox.lightschedule == 1)),k));
        end
    end
    
        % The following is for EACH FISH and *ALL* DAYS and *ALL* NIGHTS combined    
        % Only if you want to analyze multiple days and nights together;
        % probably not a great idea?
        % You just add up/mean up the data generated in the previous section
        
        for p = 1:length(genox.fishID{i}) % already looping days and genotypes, now loop fish
            % total sleep for each fish for day/night (1, #of fish)
            genox.summarytable.sleep.daytotal{i}(p) = sum(genox.summarytable.sleep.day{i}(1:end,p));
            genox.summarytable.sleep.nighttotal{i}(p) = sum(genox.summarytable.sleep.night{i}(1:end,p));            
            % mean # of bouts for each fiss in day/night (1, #of fish)
            genox.summarytable.sleepBout.daymean{i}(p) = nanmean(genox.summarytable.sleepBout.day{i}(1:end,p));
            genox.summarytable.sleepBout.nightmean{i}(p) = nanmean(genox.summarytable.sleepBout.night{i}(1:end,p));            
            % mean bout sleepLength for each fish in day/night (1, #of fish)
            genox.summarytable.sleepLength.daymean{i}(p) = nanmean(genox.summarytable.sleepLength.day{i}(1:end,p));
            genox.summarytable.sleepLength.nightmean{i}(p) = nanmean(genox.summarytable.sleepLength.night{i}(1:end,p));             
            % mean latency for each fish in day/night(1, #of fish)
            genox.summarytable.sleepLatency.daymean{i}(p) = nanmean(genox.summarytable.sleepLatency.day{i}(1:end,p));
            genox.summarytable.sleepLatency.nightmean{i}(p) = nanmean(genox.summarytable.sleepLatency.night{i}(1:end,p));             
            % mean activity for each fish in day/night (1, #of fish)
            genox.summarytable.averageActivity.daymean{i}(p) = nanmean(genox.summarytable.averageActivity.day{i}(1:end,p));
            genox.summarytable.averageActivity.nightmean{i}(p) = nanmean(genox.summarytable.averageActivity.night{i}(1:end,p));            
            % mean waking activity for each fish in day/night (1, #of fish)
            genox.summarytable.averageWaking.daymean{i}(p) = nanmean(genox.summarytable.averageWaking.day{i}(1:end,p));
            genox.summarytable.averageWaking.nightmean{i}(p) = nanmean(genox.summarytable.averageWaking.night{i}(1:end,p));
       end
end

%{
%% Genotype averages
% Now to find the genotype averages based on the above individual fish values
% These days we do this part in PRISM, so I have commented this out
for i=1:genox.number_of_genos
           
        % MEANS:        
        % mean sleep for each day/night
        genox.summarytable.mean.sleep.day{i}= nanmean(genox.summarytable.sleep.day{i}, 2)'; 
        genox.summarytable.mean.sleep.night{i} = nanmean(genox.summarytable.sleep.night{i}, 2)';
        % mean # of sleep bouts
        genox.summarytable.mean.sleepBout.day{i}= nanmean(genox.summarytable.sleepBout.day{i}, 2)';
        genox.summarytable.mean.sleepBout.night{i}= nanmean(genox.summarytable.sleepBout.night{i}, 2)';
        % mean length of sleep bouts
        genox.summarytable.mean.sleepLength.day{i}=  nanmean(genox.summarytable.sleepLength.day{i}, 2)';
        genox.summarytable.mean.sleepLength.night{i}=  nanmean(genox.summarytable.sleepLength.night{i}, 2)';
        % mean sleep latency
        genox.summarytable.mean.sleepLatency.day{i}=  nanmean(genox.summarytable.sleepLatency.day{i}, 2)';
        genox.summarytable.mean.sleepLatency.night{i}=  nanmean(genox.summarytable.sleepLatency.night{i}, 2)';
        % mean average activity
        genox.summarytable.mean.averageActivity.day{i}=  nanmean(genox.summarytable.averageActivity.day{i}, 2)';
        genox.summarytable.mean.averageActivity.night{i}=  nanmean(genox.summarytable.averageActivity.night{i}, 2)';
        % mean average waking activity
        genox.summarytable.mean.averageWaking.day{i}=  nanmean(genox.summarytable.averageWaking.day{i}, 2)';
        genox.summarytable.mean.averageWaking.night{i}=  nanmean(genox.summarytable.averageWaking.night{i}, 2)';
        % and the mean not of each day/night, but of all days/nights
        genox.summarytable.mean.sleep.daytotal{i} = nanmean(genox.summarytable.sleep.daytotal{i});
        genox.summarytable.mean.sleep.nighttotal{i} = nanmean(genox.summarytable.sleep.nighttotal{i});
        genox.summarytable.mean.sleepBout.daymean{i} = nanmean(genox.summarytable.sleepBout.daymean{i});
        genox.summarytable.mean.sleepBout.nightmean{i} = nanmean(genox.summarytable.sleepBout.nightmean{i});
        genox.summarytable.mean.sleepLength.daymean{i} = nanmean(genox.summarytable.sleepLength.daymean{i});
        genox.summarytable.mean.sleepLength.nightmean{i} = nanmean(genox.summarytable.sleepLength.nightmean{i});
        genox.summarytable.mean.sleepLatency.daymean{i} = nanmean(genox.summarytable.sleepLatency.daymean{i});
        genox.summarytable.mean.sleepLatency.nightmean{i} = nanmean(genox.summarytable.sleepLatency.nightmean{i});
        genox.summarytable.mean.averageActivity.daymean{i} = nanmean(genox.summarytable.averageActivity.daymean{i});
        genox.summarytable.mean.averageActivity.nightmean{i} = nanmean(genox.summarytable.averageActivity.nightmean{i});
        genox.summarytable.mean.averageWaking.daymean{i} = nanmean(genox.summarytable.averageWaking.daymean{i});
        genox.summarytable.mean.averageWaking.nightmean{i} = nanmean(genox.summarytable.averageWaking.nightmean{i});

        % STANDARD DEVIATIONS: 
        genox.summarytable.std.sleep.day{i}= nanstd(genox.summarytable.sleep.day{i}, 0, 2)'; 
        genox.summarytable.std.sleep.night{i} = nanstd(genox.summarytable.sleep.night{i}, 0, 2)';      
        genox.summarytable.std.sleepBout.day{i}= nanstd(genox.summarytable.sleepBout.day{i}, 0, 2)';
        genox.summarytable.std.sleepBout.night{i}= nanstd(genox.summarytable.sleepBout.night{i}, 0, 2)';        
        genox.summarytable.std.sleepLength.day{i}=  nanstd(genox.summarytable.sleepLength.day{i}, 0, 2)';
        genox.summarytable.std.sleepLength.night{i}=  nanstd(genox.summarytable.sleepLength.night{i}, 0, 2)';        
        genox.summarytable.std.sleepLatency.day{i}=  nanstd(genox.summarytable.sleepLatency.day{i}, 0, 2)';
        genox.summarytable.std.sleepLatency.night{i}=  nanstd(genox.summarytable.sleepLatency.night{i}, 0, 2)';        
        genox.summarytable.std.averageActivity.day{i}=  nanstd(genox.summarytable.averageActivity.day{i}, 0, 2)';
        genox.summarytable.std.averageActivity.night{i}=  nanstd(genox.summarytable.averageActivity.night{i}, 0, 2)';      
        genox.summarytable.std.averageWaking.day{i}=  nanstd(genox.summarytable.averageWaking.day{i}, 0, 2)';
        genox.summarytable.std.averageWaking.night{i}=  nanstd(genox.summarytable.averageWaking.night{i}, 0, 2)';
        % and the Standard Deviations of full days/nights
        genox.summarytable.std.sleep.daytotal{i} = nanstd(genox.summarytable.sleep.daytotal{i});
        genox.summarytable.std.sleep.nighttotal{i} = nanstd(genox.summarytable.sleep.nighttotal{i});
        genox.summarytable.std.sleepBout.daymean{i} = nanstd(genox.summarytable.sleepBout.daymean{i});
        genox.summarytable.std.sleepBout.nightmean{i} = nanstd(genox.summarytable.sleepBout.nightmean{i});
        genox.summarytable.std.sleepLength.daymean{i} = nanstd(genox.summarytable.sleepLength.daymean{i});
        genox.summarytable.std.sleepLength.nightmean{i} = nanstd(genox.summarytable.sleepLength.nightmean{i});
        genox.summarytable.std.sleepLatency.daymean{i} = nanstd(genox.summarytable.sleepLatency.daymean{i});
        genox.summarytable.std.sleepLatency.nightmean{i} = nanstd(genox.summarytable.sleepLatency.nightmean{i});
        genox.summarytable.std.averageActivity.daymean{i} = nanstd(genox.summarytable.averageActivity.daymean{i});
        genox.summarytable.std.averageActivity.nightmean{i} = nanstd(genox.summarytable.averageActivity.nightmean{i});
        genox.summarytable.std.averageWaking.daymean{i} = nanstd(genox.summarytable.averageWaking.daymean{i});
        genox.summarytable.std.averageWaking.nightmean{i} = nanstd(genox.summarytable.averageWaking.nightmean{i}); 
end
%}

%% Summary for convenient export to Prism;
% All of the below is to bring the data together into genotypes organized
% in columns for analysis in Prism

blah = [];
for j=1:genox.number_of_days % for each day j you care about (diff from genox.daynumber)
    for i=1:genox.number_of_genos % and each genotype i
        genox.summary.hourly_activity.day{j}(1:length(genoset.data),1:genox.number_of_genos) = NaN;
        % make for this metric a cell with rows equal to the largest genotype 
        % and and columns for each genotype, filled with NaNs (for now) 
        genox.summary.hourly_activity.night{j}(1:length(genoset.data),1:genox.number_of_genos) = NaN;
        genox.summary.waking_activity.day{j}(1:length(genoset.data),1:genox.number_of_genos) = NaN;
        genox.summary.waking_activity.night{j}(1:length(genoset.data),1:genox.number_of_genos) = NaN;
        genox.summary.hourly_sleep.day{j}(1:length(genoset.data),1:genox.number_of_genos) = NaN;
        genox.summary.hourly_sleep.night{j}(1:length(genoset.data),1:genox.number_of_genos) = NaN;
        genox.summary.hourly_sleep_bout_number.day{j}(1:length(genoset.data),1:genox.number_of_genos) = NaN;
        genox.summary.hourly_sleep_bout_number.night{j}(1:length(genoset.data),1:genox.number_of_genos) = NaN ;
        genox.summary.average_sleep_bout_length.day{j}(1:length(genoset.data),1:genox.number_of_genos) = NaN;
        genox.summary.average_sleep_bout_length.night{j}(1:length(genoset.data),1:genox.number_of_genos) = NaN ;
        genox.summary.sleep_latency.day{j}(1:length(genoset.data),1:genox.number_of_genos) = NaN;
        genox.summary.sleep_latency.night{j}(1:length(genoset.data),1:genox.number_of_genos) = NaN;
    end
end

%% Fill in all days and nights
for j = 1:genox.number_of_days % for each day you care about
    for i = 1:genox.number_of_genos % for each genotype
        blah = genox.summarytable.hourly_activity.day{i}(j, :)';
        genox.summary.hourly_activity.day{j}(1:length(blah),i) = blah;   
% grab the metric from summarytable, then traspose it and assign to blah
% then assign blah to the appropriate slot in genox.summary
        blah = genox.summarytable.hourly_activity.night{i}(j, :)';
        genox.summary.hourly_activity.night{j}(1:length(blah),i) = blah;

        blah = genox.summarytable.averageWaking.day{i}(j, :)';
        genox.summary.waking_activity.day{j}(1:length(blah),i) = blah;

        blah = genox.summarytable.averageWaking.night{i}(j, :)';
        genox.summary.waking_activity.night{j}(1:length(blah),i) = blah;

        blah = genox.summarytable.hourly_sleep.day{i}(j, :)';
        genox.summary.hourly_sleep.day{j}(1:length(blah),i) = blah;

        blah = genox.summarytable.hourly_sleep.night{i}(j, :)';
        genox.summary.hourly_sleep.night{j}(1:length(blah),i) = blah;

        blah = genox.summarytable.hourly_sleep_bout_number.day{i}(j, :)';
        genox.summary.hourly_sleep_bout_number.day{j}(1:length(blah),i) = blah;

        blah = genox.summarytable.hourly_sleep_bout_number.night{i}(j, :)';
        genox.summary.hourly_sleep_bout_number.night{j}(1:length(blah),i) = blah;

        blah = genox.summarytable.sleepLength.day{i}(j, :)';
        genox.summary.average_sleep_bout_length.day{j}(1:length(blah),i) = blah;

        blah = genox.summarytable.sleepLength.night{i}(j, :)';
        genox.summary.average_sleep_bout_length.night{j}(1:length(blah),i) = blah;

        blah = genox.summarytable.sleepLatency.day{i}(j, :)';
        genox.summary.sleep_latency.day{j}(1:length(blah),i) = blah;

        blah = genox.summarytable.sleepLatency.night{i}(j, :)';
        genox.summary.sleep_latency.night{j}(1:length(blah),i) = blah;
    end

end

%% Make Z-score summary
for j = 1:genox.number_of_days % for each day you care about
    for i = 1:genox.number_of_genos % for each genotype
        blah = (genox.summary.hourly_activity.day{j}(:, i) - nanmean(genox.summary.hourly_activity.day{j}(:, 1)))...
            /nanstd(genox.summary.hourly_activity.day{j}(:, 1));
        genox.Zsummary.hourly_activity.day{j}(1:length(blah),i) = blah;   
% grab the metric from table, then Z-score it and assign to blah
% then assign blah to the appropriate slot in genox.Zsummary

        blah = (genox.summary.hourly_activity.night{j}(:, i) - nanmean(genox.summary.hourly_activity.night{j}(:, 1)))...
            /nanstd(genox.summary.hourly_activity.night{j}(:, 1));
        genox.Zsummary.hourly_activity.night{j}(1:length(blah),i) = blah;   

        blah = (genox.summary.waking_activity.day{j}(:, i) - nanmean(genox.summary.waking_activity.day{j}(:, 1)))...
            /nanstd(genox.summary.waking_activity.day{j}(:, 1));
        genox.Zsummary.waking_activity.day{j}(1:length(blah),i) = blah;   

        blah = (genox.summary.waking_activity.night{j}(:, i) - nanmean(genox.summary.waking_activity.night{j}(:, 1)))...
            /nanstd(genox.summary.waking_activity.night{j}(:, 1));
        genox.Zsummary.waking_activity.night{j}(1:length(blah),i) = blah;   

        blah = (genox.summary.hourly_sleep.day{j}(:, i) - nanmean(genox.summary.hourly_sleep.day{j}(:, 1)))...
            /nanstd(genox.summary.hourly_sleep.day{j}(:, 1));
        genox.Zsummary.hourly_sleep.day{j}(1:length(blah),i) = blah; 

        blah = (genox.summary.hourly_sleep.night{j}(:, i) - nanmean(genox.summary.hourly_sleep.night{j}(:, 1)))...
            /nanstd(genox.summary.hourly_sleep.night{j}(:, 1));
        genox.Zsummary.hourly_sleep.night{j}(1:length(blah),i) = blah; 

        blah = (genox.summary.hourly_sleep_bout_number.day{j}(:, i) - nanmean(genox.summary.hourly_sleep_bout_number.day{j}(:, 1)))...
            /nanstd(genox.summary.hourly_sleep_bout_number.day{j}(:, 1));
        genox.Zsummary.hourly_sleep_bout_number.day{j}(1:length(blah),i) = blah; 

        blah = (genox.summary.hourly_sleep_bout_number.night{j}(:, i) - nanmean(genox.summary.hourly_sleep_bout_number.night{j}(:, 1)))...
            /nanstd(genox.summary.hourly_sleep_bout_number.night{j}(:, 1));
        genox.Zsummary.hourly_sleep_bout_number.night{j}(1:length(blah),i) = blah;

        blah = (genox.summary.average_sleep_bout_length.day{j}(:, i) - nanmean(genox.summary.average_sleep_bout_length.day{j}(:, 1)))...
            /nanstd(genox.summary.average_sleep_bout_length.day{j}(:, 1));
        genox.Zsummary.average_sleep_bout_length.day{j}(1:length(blah),i) = blah;

        blah = (genox.summary.average_sleep_bout_length.night{j}(:, i) - nanmean(genox.summary.average_sleep_bout_length.night{j}(:, 1)))...
            /nanstd(genox.summary.average_sleep_bout_length.night{j}(:, 1));
        genox.Zsummary.average_sleep_bout_length.night{j}(1:length(blah),i) = blah;

        blah = (genox.summary.sleep_latency.day{j}(:, i) - nanmean(genox.summary.sleep_latency.day{j}(:, 1)))...
            /nanstd(genox.summary.sleep_latency.day{j}(:, 1));
        genox.Zsummary.sleep_latency.day{j}(1:length(blah),i) = blah;

        blah = (genox.summary.sleep_latency.night{j}(:, i) - nanmean(genox.summary.sleep_latency.night{j}(:, 1)))...
            /nanstd(genox.summary.sleep_latency.night{j}(:, 1));
        genox.Zsummary.sleep_latency.night{j}(1:length(blah),i) = blah;
    end

end



%% Make and save Super figure
for i=1:genox.number_of_days
    super_figure(i, genox);
    hgsave(strcat('../analysis_output/', genox.data_filename(1:end-4), '__SuperFigure_Day', num2str(i), '.fig'))
end

%% saving
save(strcat('../analysis_output/',genox.data_filename(1:end-4),'.mat'),'genox')

%% Cleanup
% I leave genox up; you can always replace with "clear all"
clearvars -except genox

%% toc!
toc
