% CODING ASSIGNMENT

% NAME:  <-------- put your name here

%%
% INSTRUCTIONS FOR SUBMISSION:
% When you complete the assignment below (Q1-16), click on "Publish" at the 
% toolbar above. Then click on the Publish icon. This will generate an html 
% file in the current folder. Please submit both your code (this .m script) 
% and the .html files by the homework due date.

%% SET UP: clean workspace, load in files
close all; clear all; clc

% read in image file
outdoorimage = imread("outdoor_image.jpg");

% mask the rectangular image with a circular mask to emulate the visual
% field
mask = createmask(outdoorimage);
visualimage = outdoorimage.*uint8(mask);

% Q1) Explain what outdoorimage, mask, and visualimage are?
% HINT: you can display these images with either imshow() or imagesc() 
% in the command window. If stuck, type in: help imagesc

%% MATLAB IMAGES: the visual field

% Here we place a blue circle to in visual field
eccentricity = 30;   % in degrees of visual angle (DVA) - (min=0, max=60)
polarangle = 90;     % in polar angle degrees (min=0, max<360)

% since we are plotting in cartesian coordinates, let's convert from polar
% this will transform eccentricity & polar angle into x, y coorindates
[x, y] = pol2cart(deg2rad(polarangle), eccentricity);

f1 = figure;              % create an empty figure
im = imshow(visualimage); % display the image in the figure
hold on                   % hold on to this plot so we can overlay the next ones

im = configur_axes(im);   % this just configures the axes properly

% plot fixation as a red 'x' (at center of the image: 0,0)
pp = plot(0,0,'rx','MarkerSize',35,'LineWidth',6);
hold on

% plot meridians of the visual field as black ('k') dashed lines
xline(0, 'k:', 'LineWidth',5) % vertical meridian
hold on
yline(0, 'k-.', 'LineWidth',5) % horizontal meridian
hold on

ax = gca;   % set the current axes to a variable called ax

% make image axes interprettable as plot axes 
% Image rows increase from top to bottom, for plots, they increase from
% bottom to top.
ax.YTickLabel = flip(ax.YTickLabel); y = -y;

% set figure size & position on your screen
f1.Position = [23 58 463 634];

% add the object in the visual field as a blue filled circle, size scales
% with eccentricity
ss = scatter(x,y,eccentricity*12.5,'b', 'LineWidth', 2); %,'filled');

% add a legend (based on the order of what you plotted)
legend(["gaze position","vertical meridian","horizontal meridian"])

% Q2) Change the color of the blue circle to red. Change the
% eccentricity to 10 and run the section. Now change the eccenticity to 50 
% run the section. What happens to the size of the blue circle?

% Q2b) Now change the polar angle to somewhere in the lower visual field. Then add 
% a title to the plot named 'The visual field' and set this title fontsize to 24.

%% MATLAB MATRICES: image features and neuron's receptive field

% The blue circle in the previous section can represent a receptive field
% (RF) of a neuron. Neurons at peripheral locations have larger 
% RFs. Each neuron has a unique receptive field location that tiles
% the visual field image. These locations don't change as long as you keep
% fixating on the red X.

% A neuron's receptive field (RF) only processes a tiny part of the
% visual field image (at least in early visual cortex) -- like within the 
% red circle you set up previously. 
% Let's select a tiny portion of the image to isolate the input to one
% neuron:

% Indexes 100 values in the X and Y direction, and keeps all the color
% values:
RF_input = outdoorimage(2560:2660,3100:3200,:);

RF_input = flip(RF_input);             % let's flip the image since we
                                       % we know neural images are flipped

mask = createmask(RF_input);           % again, let's mask it to emulate an RF
neuralimage_colored = RF_input.*uint8(mask);

 % Now let's convert it to greyscale for easy computation
neuralimage_grey = rgb2gray(neuralimage_colored);

f2 = figure;
subplot(1,2,1)
imshow(neuralimage_colored)
subplot(1,2,2)
imshow(neuralimage_grey)

% Q3) a. Title this figure 'Receptive field input'. Use sgtitle instead of
% title for subplots to make one main title. b. Title each figure:
% 'colored', and 'greyscale'.
% HINT: to do (b), you must put place the commands in the correct place in
% this section.

% Q4) Does this neural input seem to have edges? What orientation are these
% edges primarily? What region of the brain has neurons that would be 
% responsive to these edges?

%% MATLAB PLOTTING: tuning & orientation selectivity

stimuli = generate_input(outdoorimage);

 f3 = figure;
for i=1:length(stimuli)
    subplot(1,length(stimuli),i)
    imagesc(stimuli{i})
end
colormap(gray)
sgtitle('Stimuili')

mean_response = nan(1,length(stimuli));

f4 = figure;
for i=1:length(stimuli)
    subplot(1,length(stimuli),i)
    neurons_response = response_mag([], stimuli{i});
    imagesc(neurons_response)
    mean_response(i) = mean(neurons_response, 'all');
end
colormap(gray)
sgtitle('Response of a Neuron')

f3.Position = [3 574 778 123];
f4.Position = [3 370 782 124];

f5 = figure;
plot(1:5, mean_response, 'LineWidth',3)
title('Neuron tuning curve based on response few stimuli')
ylabel('Response from a Neuron')
xlabel('Orientation Preference')

ax = gca;

ax.XTick = 1:5;
ax.XTickLabel = ["0","45","90","135","0"];

% Q5) What is this neuron's preferred orientation? Look at the order of the 
% stimulus orientations and figure out what image /orientation this neuron 
% is responding to. HINT: brighter means more response.

%%

% Let's go back to the first image we cropped (neuralimage_grey). 
% This image has mostly vertical orientations.

% Let's convert to greyscale
I = double(neuralimage_grey);

% Now, let's do the reverse: instead of testing the response of a neuron to
% several stimuli, let's take several neurons with different orientation
% preferences and compare their reponses to the tiny image with vertical 
% orientation. 
% We can assume that there a few other neurons with the same RF location,
% or that the eyes moved slightly.

% Here, we set the preferred orientation to 135
neuronPref = 135;

neurons_response = response_mag(neuronPref, I);

f6 = figure;
imagesc(neurons_response)
set(gca,'YTickLabel',[],'XTickLabel',[]);
colormap(gray)
title('Response magnitude')

f6.Position = [1 517 277 180];

% Q6) Why is the neuron not responding? What happens when you change 
% neuronPref to different values? What does this mean?

%% PROBABILITY: other tuning functions e.g., orientation, contrast

f7 = figure;

% set a seed
rng(0);

% Here is a normal probability distribution (model)

subplot(2,2,1)
mu = 0;         % set mean
sigma = 1;      % set standard deviation
model_n = 10;   % set number of points (to plot)

x = linspace(-5,5,model_n); % create x-values from -5 to 5
y = normpdf(x,mu,sigma);
plot(x,y, 'k', 'LineWidth',3)
xline(mu, 'k-.', 'LineWidth',3)
yline(.5, 'k:', 'LineWidth',1)
title('The normal distribution (Bell Curve)', 'Fontsize',12)
ylabel('probability of response')
xlabel('orientation preference (deg)')
hold on

% simulated data
n = 50; % try increasing the number of data points. What happens?
datapoints = mu + sigma.*randn(n,1);
plot(datapoints,zeros(n,1),'ro');
xline(mean(datapoints), 'r-.', 'LineWidth',3)
ylim([0 1])
ax = gca;
ax.XTickLabel = {'0','90', '180'};

% Here is a cumulative normal distribution

subplot(2,2,2)
y = normcdf(x,mu,sigma);
plot(x,y, 'k', 'LineWidth',3)
xline(mu, 'k-.', 'LineWidth',3)
yline(.5, 'k:', 'LineWidth',1)
title('The cumulative normal distribution', 'Fontsize',12)
ylabel('probability of response')
xlabel('contrast level')
ax = gca;
ax.XTickLabel = {'0','0.5', '1'};
hold on

plot(datapoints,zeros(n,1),'ro');
xline(mean(datapoints), 'r-.', 'LineWidth',3)
ylim([0 1])

subplot(2,2,3) % orientation example
yangles = deg2rad(linspace(0,180,5));
mag = [ones(length(yangles), 1).*1.5]';

[x,y] = pol2cart(yangles, mag);
xstart = [1 3 5 7 9];
ystart = zeros(1,5);
xend = xstart - x;
yend = ystart + y;
xvals = [xstart; xend];
yvals = [ystart; yend];

for i=1:5
    plot(xvals(:,i), yvals(:,i), '-','LineWidth',4, 'Color', 'k');
    hold on
    %plot(xvals(2,i), yvals(2,i), oris(i),'MarkerSize', 10, ...
    %    'MarkerFaceColor','k', 'MarkerEdgeColor','k');
end
set(gca,'XTick',[], 'YTick', [])
ax = gca;
ax.Color = [.75 .75 .75]; % change background to gray
xlim([0 10])
ylim([-5.5 6])
title('DISPLAY OF ORIENTATIONS')

subplot(2,2,4) % contrast example
contrasts = [.7 .7 .7; .55 .55 .55; .3 .3 .3; ...
    .15 .15 .15; 0 0 0];
xvals = repmat([1 3 5 7 9], [2,1,1]);
yvals = [-ones(1,5)*0.05; ones(1,5)*0.05];
hold on
for i=1:5
    plot(xvals(:,i), yvals(:,i), '-','LineWidth',4, 'Color', contrasts(i,:));
    hold on
end
set(gca,'XTick',[], 'YTick', [])
ax = gca;
ax.Color = [.75 .75 .75]; % change background to gray
xlim([0 10])
ylim([-0.3 .3])
title('DISPLAY OF CONTRASTS')

f7.Position = [1 176 904 504];
sgtitle('A Neuron selective to vertical orientation ')

% Q7) Why did I set a seed in this section? I did not do this earlier in the code.
% Does it matter?

% Q8) Why is the tuning plot not very smooth?
% One reason is related to the stimulus images (these are not isolated orientation
% signals (other orientations are included in the image).

% Q9) What is the relation between these two plots? Try increasing the model_n
% variable to a very large number. This will make the plot look more
% smooth. Why? It's a model -- so we are not increasing data points. What
% are we increasing?
% HINT: Anything you plot in matlab (even a smooth curve) will involve
% interpretting an array of numbers.

% Q10) What happens when you change n from 50 to 1000? Why? Is this a
% different question from Q9?

% Q11) Change the values of sigma and mu in the code and re-run the section. 
% What happens? Why?

% Q12) The bottom row of the plot shows two fundamental image features
% that neurons are sensitive to. Please describe what happens to the neural
% activity for each image feature (orientation & contrast). What are some 
% other examples of fundamental image features?
% HINT: see figure 3.6, 3.7 & 3.8 in S&P Readings.


%% MATLAB COMPUTING: t-tests

% Let's imagine we have access to some neural data. We have 2 samples
% of data. Each element (neuron) in the vectors groupA and groupB represents 
% the response (mean spike rate) when motion stimuli is presented in their 
% receptive fields (compared to baseline spike rate).
% groupA contains 100 neurons in one brain region, and groupB has 100 neurons
% in another brain region.

% We would like to test whether:
% (a) either of these neuronal groups motion selective.
% (b) there is a difference in the response between these two groups.

% Here is some simulated data
groupA = randn(50,1);
groupB = .5*randn(50,1)+0.3;

% let's plot the data
figure
subplot(1,2,1)
xoffset_A = .5*(rand(length(groupA),1))+.75; 
xoffset_B = .5*(rand(length(groupB),1))+1.75;
scatter(ones(length(groupA),1),groupA, 'bo', 'filled', 'jitter','on','jitterAmount',0.15, ...
    'MarkerEdgeAlpha',.1, 'MarkerFaceAlpha',.1) 
hold on
scatter(2*ones(length(groupB),1), groupB, 'ro', 'filled', 'jitter','on','jitterAmount',0.15, ...
    'MarkerEdgeAlpha',.1, 'MarkerFaceAlpha',.1)
hold on
% <----------------- insert boxplot function here
ylabel('motion response - baseline (spikes/s)')
xlim([0,3])

% Now compute the mean for each group, and do NOT suppress these
% lines with semicolons
disp('Mean for groupA is:')
% compute mean for groupA here
% groupA_mean =    <---------- uncomment this line & write equation
disp('Mean for groupB is:')
% compute mean for groupB here
% groupB_mean =    <---------- uncomment this line & write equation

% Now compute the standard error of the mean (SEM), and do NOT suppress
% (as above): formula is standard deviation / square root of the sample
% size.
disp('SEM for groupA is:')
% compute SEM for groupA here
% groupA_SEM =    <---------- uncomment this line & write equation
disp('SEM for groupB is:')
% compute SEM for groupB here
% groupB_SEM =    <---------- uncomment this line & write equation

% Now create a plot with the SEM
subplot(1,2,2)
scatter(ones(length(groupA),1),groupA, 'filled', 'bo', 'jitter','on','jitterAmount',0.15, ...
    'MarkerEdgeAlpha',.1, 'MarkerFaceAlpha',.1)
hold on
scatter(2*ones(length(groupA),1),groupB, 'filled', 'ro','jitter','on','jitterAmount',0.15, ...
    'MarkerEdgeAlpha',.1, 'MarkerFaceAlpha',.1)
xlim([0,3])
ax = gca; x_range = range(ax.XLim); pwidth = x_range*.1;
hold on
%errorbar(1,mean(groupA),groupA_SEM, 'b', 'LineWidth',2)
%hold on
%errorbar(2, mean(groupB),groupB_SEM, 'r', 'LineWidth',2)
%hold on
%plot([1-pwidth,1+pwidth],[groupA_mean, groupA_mean], 'b', 'LineWidth',2);
%hold on
%plot([2-pwidth,2+pwidth],[groupB_mean, groupB_mean], 'r', 'LineWidth',2);  
%hold on
xlim([0,3])

sgtitle('Mean motion response from two groups of neurons')

% Use the ttest function to compute if groupA response
% are significantly different from 0:
% NOTE: ttest function is for one sample, or paired-sample ttest
[n1, p1, ci1] = ttest(groupA);
[n2, p2, ci2] = ttest(groupB);

% Use ttest2 to see if the groups are statistically significant from each 
% other
% NOTE: ttest2 function is for independent samples ttest
[n3, p3,ci3] = ttest2(groupA, groupB);

% Q13) Use the boxplot matlab function to plot both groupA and groupB in the
% same line of code. What is represented by these plots? What are the error
% bars? What is the red line? What is the blue box? The plus signs?
% HINT: look at documentation.

% Q14) Why are some y-values negative? We know that neurons cannot
% negatively fire, so what do these negative nalues mean?

% Q15) Compute the mean & standard error of the mean (SEM) for groupA and group B
% above. NOTE: keep the variable name suggested, and then uncomment the
% errorbar(), hold on, & plot() lines that are commented in the subplot 2 to 
% plot these values.

% Q16) Which group, based on the statistics is sensitive to motion? Is the
% activity in each group significantly different from one another?
% HINT: check the output from the t-tests.


%% functions

% DO NOT CHANGE ANYTHING UNDER THIS LINE  ~~~~~~~~~

function mask = createmask(outdoorimage)

    % compute dimensions of image (height, width, and colors)
    [imageH, imageW, imageC] = size(outdoorimage);
    
    % initialize mask matrix of all zeros
    mask = zeros(imageH, imageW);

    [y x] = size(mask); %define y,x as size of array
    r = imageH/2; %define radius of a circle
    for i=1:y
        for j=1:x
            if ((i-y/2)^2)+((j-x/2)^2)<(r^2);  %define origin is at the center
                mask(i,j) = 1;  %define array inside the circle eq. = 1
            end
        end
    end 
end

function im = configur_axes(im)
    %axis on
    im.Parent.XLim = [-60 60]; % less data (b/c) height is smaller
    im.Parent.YLim = [-60 60]; % cut off excess black edges
    im.XData = [-80 80];       % keep original shape to avoid stretching
    im.YData = [-60 60];       % squeeze proportional: imageH/imageW*80
end


function stimuli = generate_input(outdoorimage)
    I1 = outdoorimage(2400:2500,1180:1280,:); % horizontal
    I2 = outdoorimage(2440:2540,1580:1680,:); % 45
    I3 = outdoorimage(2300:2400,1480:1580,:);
    %I3 = outdoorimage(2560:2660,3100:3200,:); %Vertical
    I4 = outdoorimage(2540:2640,1780:1880,:); % 135
    I5 = outdoorimage(2400:2500,1180:1280,:); % horizontal
    
    all_I = {I1; I2; I3; I4; I5};
    
    stimuli = {};
    for i=1:length(all_I)
        RF_input = flip(all_I{i});
        mask = createmask(RF_input); 
        neuralimage_colored = RF_input.*uint8(mask);
        neuralimage_grey = double(rgb2gray(neuralimage_colored));
        stimuli{i} = neuralimage_grey;
    end
end


function mag = response_mag(neuronA, I)
    if isempty(neuronA)
        neuronA = [90];
    end
    neuronA = neuronA+90; % transform to colloqial orientation
    wavelength = 5;
    g = gabor(wavelength,[neuronA]);
    mag = imgaborfilt(I,g);
end