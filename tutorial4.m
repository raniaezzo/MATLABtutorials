%% WELCOME TO THE FOURTH MATLAB TUTORIAL! 
clear all; close all; clc; rng();

%% CUSTOM FUNCTIONS

% I made my own function. It takes no input, but will always say 'hello':

% Here, I am calling the function
% Run this section, and check the output in the Command Window:
myownfunction()

% Where is the function defined?
% functions are required to either be at the bottom of a script, or saved
% as their own files. In this tutorial, you will find all functions at the
% end of the script in section "DEFINED FUNCTIONS"

%% MAKING A MORE INTERESTING FUNCTION

% Okay, myownfunction is not so interesting. It doesn't manipulate anything
% because there is no input. 

name = ''; % add your name inside the ''

message4class(name)

% notice, that the function input here (when calling it) is a variable called
% name. But the input in the function definition (below) is called studentname.

% It doesn't matter if the variable names match when calling & defining inputs!
% The important thing is that there are the same number of inputs in the
% same order.

%% YOU TRY MAKING A FUNCTION

% Let's imagine someone would like to participate in your experiment.
% But you have an age threshold of 18. You want to automate the system
% to tell the interested person whether they are eligible.

% If they are 18 or older, you can print out: "You are eligible."
% If they are younger than 18, print out: "Sorry, you are NOT eligible."

age = 17; % let's say they input their age 17

% let's call your function HERE (but you define it at the bottom the script):
check_eligibility(age)

%% FUNCTION WITH INPUT & OUTPUT

% we so far only looked at functions without output
% sometimes, we want the function to not only display a message,
% but to assign some value to a variable

% Let's use the age variable above to determine how many year are
% left to invite the interested person to participate

output = functionwith_output(age)

% The output is the number of years needed before they can participate.
% Does this look correct?
% _________________

%% OTHER DATA STRUCTURES: TABLES

% We already learned about some arrays (scalars, vectors, matrices). E.g., [1,2]
% In these arrays, you can store numbers, characters, strings, etc.

% Matrices/vectors are BEST to use if all of your data is numerical
    % PRO: This will make your analysis faster and data handling easier
    % CON: You cannot use different data types in a matrix, so it is less
    % flexible
    
% Tables and cell arrays are two alternatives with more flexibility that
% will be introduced below:
    
% Tables are great ways to store data that you would otherwise but in a
% matrix, but maybe you have a mixture of string and numbers for different
% columns.

subject_names = ['S01'; 'S02'; 'S03'; 'S04'; 'S05'; 'S06'; ...
    'S07'; 'S08']; % array of strings

% and another column with the age of each subject
subject_age = [26; 19; 22; 24; 37; 31; 21; 19];

% and another column with the sex of each subject
subject_sex = ['F'; 'F'; 'M'; 'F'; 'M'; 'M'; 'F'; 'F'];

% we cannot combine this data into one data matrix, because they are
% different data types. So let's make a table:

combined_data = table(subject_names, subject_age, subject_sex)

% Nice! That looks pretty good. 

% Can you see how the three columns are different data types?

class(combined_data.subject_names)  % charater vector
class(combined_data.subject_age)    % numeric vector (doubles)
class(combined_data.subject_sex)    % character vector

%% Working with tabular data

% But how do I access/index this data from this
% variable called combined_data? 

% Let's print out the second name of subject_names
combined_data.subject_names

combined_data(2,1) % use () to output a table with only that row/col

combined_data{2,1} % use {} to extract actual value

% Let's add another column called 'randomnumbers' to our table

combined_data.randomnumbers = rand(8,1); % randn(8,1) gives a column of
                                          % 8 random numbers uniformly
                                          % distributed between 0 and 1
                                         
% Now we can use logic to create a new table including only the rows that 
% 'randomnumbers' value is > 0.5
new_table = combined_data(combined_data.randomnumbers>0.5,:)

% save this new_table
save('new_table')

% where did it save? (Look at your Current Folder Browser. Is it there?)
% __________________

% which subjects are in this new table?
% _________________

% You can even do quick stats using the 'group summary' function
% that is used for tables!

% Here we find the mean of 'randomnumbers' for males and females separately
sexMean = groupsummary(combined_data,"subject_sex","mean",'randomnumbers')

% You can do the same for other common statistics: sum, min, max, range, median, 
% mode, var (variance), std (standard deviation)

% try copying the line of code above and print in the command window
% but replace "mean" with some other statstic

%% Comma separated files (CSVs) and Tab separated files (TSVs)

% You can save tables as MAT files:
save('combined_data')   % this will save the variable in your current
                        % directory as combined_data.mat
                        
% .mat files can only be opened with MATLAB software, so it's useful
% to be able to save into comma separated files (CSVs) or tab separated
% files (TSVs) as well
writetable(combined_data,'combined_data.csv'); % same thing if you replace 
                                               % csv with tsv
                                               
% Now you can navigate to your current folder (outside of MATLAB), 
% and open 'combined_data.csv' as a text file, or an excel file, etc.

% OK. Now let's clear your combined_data variable from your workspace:
clear combined_data

% You can load it back into your workspace by loading in the mat or the csv
% file like this:
load('combined_data')   % to load the .mat (MATLAB-formatted) file

% Or like this:
readtable('combined_data.csv')   % to load the csv.

% It is useful to read/write CSV's in MATLAB because sometimes data is
% available in other formats from other coding languages etc.

% Tables are BEST to use if you have separate data types across columns 
    % PRO: Tables are well-organized, and easy to interpret (e.g., you
           % you link data to metadata: 'S01 data & S01 gender')
           % there are many built-in functions that make tables easy to
           % work with
    % CON: There is a bit more of a learning curve about how to indexing 
           % values in tables compared to matrices.
           % Does not have maximum flexibility: each columnn variable must have 
           % the same # of rows

%% OTHER DATA STRUCTURES: STRUCT ARRAYS

% You can also stor data in struct arrays. 
% struct array contains the same fields

% STRUCT ARRAYS are great to use if you need more flexibility than tables 
    % PRO: you access data by field name, keeping interpretation of data
        % feasible. You can easily add new structs to the array and it 
        % will autopopulate as empty field
    % CON: all structs in the array must have the same fields
                            
% Let's create a structure array incstead of the table above
combined_data_S = table2struct(combined_data)

[data_nr, data_nc] = size(combined_data_S);

% To access data in the struct,

% Let's initialize a struct for a new subject 'S09'
combined_data_S(data_nr+1).subject_names = 'S09'

% Later, you get the information that 'S09' is male. Let's add that:
combined_data_S(9).subject_sex = 'M'

% But if you need to later match the exact value
strs ={combined_data_S.subject_names};  % returns array of each subjectname   
ind=find(ismember(strs,'S09'))  % find the index matching 'S09'
combined_data_S(ind).subject_sex = 'M' % add this string into the field
                                       % 'subject_sex'

%% OTHER DATA STRUCTURES: CELL ARRAYS

% STRUCT ARRAYS are great to use if you need maximum flexibility 
    % PRO: you can save any combination of dimensions/data types. 
       % Think of it as a matrix of cells where any type of data
       % can be stored in each cell.
    % CON: more difficult to work with because each cell is treated as 
       % a discrete unit. Also loses the header/labels so more reliance
       % on knowing what each row/col means

% Let's convert the table to a cell array
combined_data_C = table2cell(combined_data)

% Let's initialize a new row for a new subject 'S09'
combined_data_C(data_nr+1,1) = {'S09'}

% You can access/assign data from a cell array with curly brackets {}:
strs = combined_data_C(:,1)';  % returns array of each subjectname
ind=find(ismember(strs,'S09')) % find the index matching 'S09'
combined_data_C(ind,3) = {'M'} % add this cell into the cell array
                                 % based on subject_sex being col 3

% As you probably noticed, cell arrays are harder to work with,
% so it's usually easier to use matrices (if all numbers), or 
% tables (if data type is the same within each column).

%% DEFINED FUNCTIONS

function myownfunction()
    disp('Hello')
end

function message4class(studentname)
    sprintf('Hello %s! Today we will learn how to write MATLAB functions',studentname)
end

% build your own function HERE (edit the following)
function check_eligibility(age)
    if age % add logic on this line ("if age is less than 18")
        disp('edit this message') % edit display message if less than 18
    else 
        disp('edit this other message') % edit display message if >= 18
    end
end
%

function years_left = functionwith_output(years_old)
    min_eligibility = 18;
    if years_old < 18
        years_left = min_eligibility - years_old;
    else
        years_left = 0; % already eligible
    end
end