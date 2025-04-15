%% WELCOME TO THE THIRD MATLAB TUTORIAL! 
clear all; close all; clc; rng();

%% CONDITIONALS: IF STATEMENTS

% It's really useful to execute a statement if a certain condition is met.

% Let's suppose you only want to code to run if you decide something is
% true.

% Here is your decision about whether it will run (1=yes, any other number=no):

decision = 1  

if decision==1 % evaluates whether the variable decision is equal to 1
    'You decided yes.'
end

% Let's break it down. We know decision is equal to 1 because you set that
% before the if statement. So, it printed 'You decided yes'.

% Change decision to 0 and rerun. What happens?

%% CONDITIONALS: IF/ELSE STATEMENTS

% let's start with the same code as above with one small addition

decision = 1

if decision==1
    'You decided yes.'
else                    % here
    'You decided no.'    % and here
end

% this prints out 'you decided no' if decision is NOT 1

% what happens if you set decision to 3?
% ___________________

%% CONDITIONALS: IF/ELSEIF/ELSE STATEMENTS

% again let's copy the code from above to build upon, with the only changes

decision = 1

if decision==1
    'You decided yes.'
elseif decision==0                   
    'You decided no.'    
else                        % here
    'You are undecided.'    % and here
end

% This prints out 'You decided yes.' ONLY if decision is 1, 
% and prints out 'You decided no.' ONLY if decision is 0,
% OTHERWISE, it will print out 'You are undecided.'

% you can also exclude the elseif and just include else!
% Try it below! It should be 5 lines of code copied from above:







%% CONDITIONALS: FOR-LOOP

% for loops are a very useful to condense code! Let's say you want to 
% print out

for i=[1,2]       % i will be the 1 in the first, and 2 in the second loop
    sprintf('Currently in loop # %i', i) 
end

% NOTE in the line above: '%i' inside the string is different from the i 
% variable (the iterator). Are they related at all? What happens if you 
% replace %i with %f? Does the loop still work? 
% __________________

% What happens if you replace i outside of the string?
% __________________

%% FOR-LOOP: HOW LONG DOES EACH ITERATION OF A LOOP TAKE?

% tic starts a stopwatch timer and toc will calculate the elapsed time
tic
disp("Let's take some time to dispay this sentence in your command window")
toc

% Add tic as a line above the the sprintf(..) and toc after the sprintf(..)
% line. Run the loop again. About how fast is each loop interation?
% _________________

% Let's add a pause right before the elapsed time is calculated.
% add a line: pause(1) to pause for 1 second right before the toc command 

% Do you see a change in the elapsed time?
% ________________

%% FOR-LOOP: ITERATING THROUGH AN ARRAY

% A very common situation is that you have an array, and you want to go
% through each element of the array, and something particular depending on
% the value

collection = randi([0,10],1,10); % this returns one row of 10 random integers
                                 % ranging from 0 to 10
                                 
% let's loop through each element of this array, and display whether the
% number is even or odd. This will require us to insert an IF STATEMENT:

for i=1:length(collection)  % here we set i = 1 to 10, starting with 1    
    current_value = collection(i);
    
    if mod(current_value,2)==0 % is even (mod checks whether the  
                               % remainder after divinding by 2 is 0
                               
        sprintf('The number %i is even.',current_value)
        
    elseif mod(current_value,2)==1 % is odd
        
        sprintf('The number %i is odd.',current_value)
        
    end
end

%% CONDITIONALS: WHILE-LOOP

% Sometimes you don't know the number of iterations you want to run.
% Under these circumstances, you want to loop to continue until some
% condition is met.

% For let's try running this code.

run_forever = 1; % 1 = true

% Uncomment the code below and "Run Section"
% WARNING: IT WILL RUN INFINITELY UNTIL YOU BREAK IT WITH CTRL+C !!!!!!
% Note: You know your code is still running when you see a pause button
% instead of a play button in the toolbar. The bottom left corner of the 
% MATLAB says "busy" as well:

% while run_forever
%     i = i+1;
% end

%% WHILE-LOOP: WHEN IT'S USEFUL

% while loops are useful, but they need to end when a certain condition is
% met. For example, you could keep increasing a number until it reaching a
% threshold, and then exit about of the while loop.

% Let's do that in a couple of ways. 

% First, let's initialize a variable by choosing a number to start with:
x=3;

% First, set an threshold

threshold = 100;  % let's add 5 to x iteratively as long as (while) 
                  % it's under the threshold value.

% method 1:

while true
    
    if x+5>threshold, break; end    % look! We can write an if statement
                                    % in one line with this syntax.
                                    % by the way, break, will end the while
                                    % loop
    x = x+5;
end

% What does this while loop do? What is the value of x?
% _______________

% Why do we have to write x+5 in the if statment, instead of x?
% ________________

%%
% method 2 (no functional difference from the code right above):

x=3;   % initialize x again, otherwise it will start from 98

while ~ (x+5>threshold)
    x = x+5;
end

% break down this syntax in words below. What is the "~" ?
% HINT: in the command window, print output for (x+5>threshold) and then
% for ~ (x+5>threshold).

%% TRY-CATCH STATEMENTS

% if you are running your code and it takes an hour and suddenly fails,
% that's really SAD. You can use try-catch statements to catch predictable
% errors and continue without error.

% For example, let's say you have a two arrays of values:

a = ones(4);  
b = zeros(3);  

try  % this will attempt to concatenate 2 matrices (a & b) of different sizes
    c = [a;b]  
catch ME  % you can catch this error, and replace the assigned value to NaN
    c = NaN  
end  

% what would happen if you just ran c = [a;b] in the command window?
% ________________


%% SWITCH-CASE

% the switch statment is not as common, but you will sometimes come across 
% it in experimental or analysis code.

% it's similar to an if / elseif / else statement, but a little 
% more compact when you have string variables to evaluate:

experimental_mode = 'practice'; % run this code, then try again running
                                % after replacing 'practice' with any of
                                % the other options (string format)
                                % 'main experiment' or 'control', or ''

switch experimental_mode
    case 'practice'
        disp('PRACTICE: output will NOT be saved.')
    case 'main experiment'
        disp('EXPERIMENT: output will be saved in main folder')
    case 'control'
        disp('CONTROL: output will be saved in main folder')
    otherwise
        disp('UNKNOWN EXPERIMENTAL MODE: output will be saved in temporary folder.')
end
