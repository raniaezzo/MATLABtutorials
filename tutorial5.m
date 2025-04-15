%% WELCOME TO THE FIFTH (DEBUGGING) MATLAB TUTORIAL! 
clear all; close all; clc; rng();

%% PRACTICING DEBUGGING
% We are now going to work on debugging code. This code combines
% what you have learned about arrays, plotting, if-statements, 
% and more.

% TRY & FIX THE ERRORS BELOW. Click "Run" to produce the error. They will
% occur in the order as listed below. Use the line # printed in the red
% message in the command window to help debug.

% The code below has the following hard errors (red error messages
% that break the code):
    % 1) loading the pupil data gives an error. Why?
        % When loading a variable, the function load is looking for
        % the file name (or path with file name). What data class should
        % the input be?
    % 2) Unrecognized function or variable 'cond_data'. Why is cond_data
        % not defined? Check where it is defined within the loop. Are either of
        % those if / else conditions met? Print the output in the command
        % window.
        % HINT: it is important to distinguish between character arrays 
        % and string arrays.
    % 3) Unrecognized property 'FontSize' from f1. Print out the f1
        % variable (the figure handle). Is this the correct variable to use for
        % setting the fontsize?
    % 4) Error in scatter plot, because x & y have to be the same length.
        % For each loop iteration, there is supposed to be 8 values (1 per
        % subject). The y seems OK, but the x is much larger than expected.
        % This has something to do with the n_subjects variable. 
        % Can you find where the problem originates and fix it?

% And the following soft errors (no error message but output doesn't 
% look correct):
    % 5) x label of the plots in Fig1 have "!" instead of the actual value
        % think about how to include a variable string with sprintf
    % 6) In figure 2 (f2), subplot 2: we plotted a bar plot that was
        % is supposed to be visible that is not. These bars are supposed to
        % be behind the Average data points. 
        % Where did this bar plot go? Can you fix this?
        % HINT: google 'MATLAB how to retain current plot when adding new 
        % plots'
        
% Once you finish debugging those 6 errors, explore the script and 
% answer the prompts to learn more about subplots, data interpretation, 
% linear models, and basic stats

%% LOADING IN DATA

load('pupildata_filtered')
timing = load('stimulusTiming', 'stimulusTiming');
events = timing.stimulusTiming;

baseline_mean = mean(pupildata(:,1:events(1)),2);
dark_mean = mean(pupildata(:,events(1):events(2)),2);
bright_mean = mean(pupildata(:,events(3):events(4)),2);

%% FIGURE 1: COMBINING LOOPS & PLOTTING FOR SUBPLOTS

conditions = ["dark", "bright"];
colors = ['b','g'];

f1 = figure

for ci=1:length(conditions)
    
    if strcmp(conditions(ci), 'dark')
        cond_data = dark_mean;
    elseif strcmp(conditions(ci), 'bight')
        cond_data = bright_mean;
    end
    
    subplot(1, 2, ci) 
    scatter(cond_data, baseline_mean, 50, colors(ci), 'filled')
    axis equal    % sets equal aspect ratio between units of axes
    axis square   % makes the axes square
    hold on
    plot(0:7, 0:7, '--k')
    ax = gca
    ax.FontSize = 18;
    title('Mean pupil size per subject')
    xlabel(sprintf('Mean (mm) during %s stimulus', conditions(ci)))
    ylabel('Mean (mm) during gray baseline')
    if ci == 1
        max_lim = max([get(gca,'XLim'), get(gca,'YLim')]);
    end
    xlim([0, max_lim])
    ylim([0, max_lim])
end

f1.Position = [360 333 900 364];

% What is this data telling you? If the data points mostly fell on the identity
% line (the black dashed line), the values between the 2 conditions would
% be equal. What is the difference in pupil size for the dark and bright
% stimulus condition?
% ____________________

%% FIGURE 2: DIFFERENT TYPES OF SUBPLOTS IN ONE FIGURE
%n_subjects = length(pupildata);
n_subjects = size(pupildata,1);
data_mean = [bright_mean, baseline_mean, dark_mean];

f2 = figure;
f2.Position = [100 100 1140 500];
sgtitle('Pupil size per lighting condition', 'FontSize', 24)

subplot(1,2,1)
bar(data_mean)
legend('bright','grey','dark')
ax = gca
ax.FontSize = 18;
xlabel('Subject')
ylabel('pupil size (mm)')
ax.XTickLabel = {'S01';'S02';'S03';'S04';'S05';'S06';'S07'; 'S08'}
ax.Title.String = 'Subjectwise data';

subplot(1,2,2)
b = bar(mean(data_mean))
hold on
b.FaceAlpha = 0.5
xvals = repmat([1:3],n_subjects,1);
for ni=1:3
    s = scatter(xvals(:,ni), data_mean(:,ni), 65, 'filled', 'MarkerFaceColor', ...
        [0 .5 .5], 'MarkerFaceAlpha', 0.3)
    hold on
end
ax = gca % RE: remove this 
ax.FontSize = 18;
ax.XTickLabel = {'bright', 'grey', 'dark'}
ax.Title.String = 'Average data';
hold on
err = (std(data_mean,[],1)/sqrt(size(data_mean,1)));  % SEM
e = errorbar([1 2 3], mean(data_mean), err, 'k');
e.LineStyle = 'none';
e.LineWidth = 2;
ylabel('pupil size (mm)')

%% FIGURE 3: MODEL FITTING & BASIC STATS

range_data = range(pupildata,2);
performance = [.75, .88, .67, .82, .80, .77, .70, .66];

% Plot of how pupil size range relates to performance (they are asked
% to press a button if they detect any changes on the monitor:
% 1 is maximum possible performance, and 0 is minimum possible performance.)

figure
s = scatter(range_data, performance, 65, 'filled', 'MarkerFaceColor', ...
        [0 .5 .5])
hold on
mdl = fitlm(range_data,performance)
plot(mdl)
xlabel('pupil size range (mm)')
ylabel('performance (% correct)')
xlim([1 7])
ylim([.50 1])
title('Relation of pupil size range & performance')
ax = gca
ax.FontSize = 18

% What is the slope & intercept of the model (the fitted line)?
% ___________________

% Is there a correlation between these two variables? Does the additional
% slope term (x1) explain the data significantly better that a simple
% intercept-only model?
% HINT: look at the stats!
% __________________