% Parallel processing in Matlab workshop
% Darren Price, CBU, Cambridge 2017

clear
close all
clc

% CBU Cluster Example, running independent jobs

addpath /hpc-software/matlab/cbu/

S = cbu_scheduler();
S.NumWorkers = 2;
S.SubmitArguments = '-l mem=1GB -l walltime=1:00:00';

% You should first determine how much memory and how many hours you need to
% run your code.

%% Job1 will output 1 argument
J = [];
J.task = @(x) rand(x);
J.n_return_values = 1;
J.input_args = {5};
J.depends_on = 0;

cbu_qsub(J, S)

% You will find all your job information in the Job folders (example
% below). You might need to wait some time for the files to be saved
pause(20)
IN = load(sprintf('%s/Job1/Task1.in.mat',S.JobStorageLocation));
OUT = load(sprintf('%s/Job1/Task1.out.mat',S.JobStorageLocation));

S.JobStorageLocation = '/home/dp01/teaching/cbu_parallel_workshop/';


%% Job2 will display the result with no output args

% clear all job folders using a unix command
!rm -Rfv /home/dp01/teaching/cbu_parallel_workshop/Job*

J = [];
J.task = @(x) disp(rand(x));
J.n_return_values = 0; % important
J.input_args = {5};
J.depends_on = 0;

ID = cbu_qsub(J, S);

% Check the diary. This contains output normally sent to the command
% window. This is useful for debugging if something goes wrong.

% this is how to construct a unix string based on the job id and storage location
% This is the recommended way to create strings for loading and saving files in
% matlab in general see "help sprintf"
[~,t] = unix(sprintf('more %s/Job%d/Task1.diary.txt', S.JobStorageLocation, ID));
disp(t) % Print output to the screen



%% Job3 will use an external function to save variables to specified
% location. You should create a function (using a file) that takes two
% input arguments (one of which being the save path)


% NOTE: Here is the code for fun1.m. You need to save this to the same folder as
% cbu_scheduler_example.m
% 
% function [x, y] = fun1(z, subjectid)
% 
%     x = z*2;
%     y = z*3;
%     
% save(sprintf('/imaging/dp01/output_subject_%s.mat',subjectid),'x','y')

% fun1.m cannot use plotting functions. Instead save the data to disk and
% plot locally with a graphics enabled instance of matlab

% Note, below we have added a addtitional paths. You can add multiple paths
% in a cell array. You need to add the paths for each element of J. You
% generally only need to add one path at a time.

J = [];
J(1).task = @fun1;
J(1).AdditionalPaths = {'/home/dp01/teaching/cbu_parallel_workshop' '/path/two' '/path/three'}; 
J(1).n_return_values = 2; % important
J(1).input_args = {10, 'ID1'};
J(1).depends_on = 0;

J(2).task = @fun1;
J(2).AdditionalPaths = '/home/dp01/teaching/cbu_parallel_workshop';
J(2).n_return_values = 2; % important
J(2).input_args = {10, 'ID2'};
J(2).depends_on = 0;

J(3).task = @fun1;
J(3).AdditionalPaths = '/home/dp01/teaching/cbu_parallel_workshop';
J(3).n_return_values = 2; % important
J(3).input_args = {10, 'ID3'};
J(3).depends_on = 0;

ID = cbu_qsub(J, S);

pause(20)
out = load(sprintf('%s/Job%d/Task1.out.mat', S.JobStorageLocation, ID(1)));


%% Create J in a loop with additional paths

IDs = {'ID1' 'ID2' 'ID3'};
for ii = 1:3
    J(ii).task = @fun1;
    J(ii).AdditionalPaths = {'/home/dp01/teaching/cbu_parallel_workshop'};
    J(ii).n_return_values = 2; % important
    J(ii).input_args = {10, IDs{ii}};
    J(ii).depends_on = 0;
end

ID = cbu_qsub(J, S);

% Load 1 of the job output .mat files
pause(20)
out = load(sprintf('%s/Job%d/Task1.out.mat', S.JobStorageLocation, ID(1)))


%% parfor loop (recommended for smaller jobs)
clear 

% cbupool is a wrapper for parpool with corrected settings
delete(gcp)
cbupool(3)
parfor ii = 1:3
  % build magic squares in parallel
  q{ii} = magic(ii + 2);
end

for ii=1:length(q)
  % plot each magic square
  figure, imagesc(q{ii});
end


% Things that won't work

% 1. Index must be consecutive integers
parfor ii = [1:2:10]
    n = f(ii);
  % build magic squares in parallel
  q{ii} = magic(n + 2);
end

% Instead, use 
f = 1:2:10;
parfor ii = 1:5
    n = f(ii);
  % build magic squares in parallel
  q{ii} = magic(n + 2);
end


% Using an index of an index is BAD, and the error message is quite
% unambiguous. "Error: The variable q in a parfor cannot be classified."
cheatindex = [10:-1:1];
parfor ii = 1:10
  % build magic squares in parallel
  q{cheatindex(ii)} = magic(ii + 2);
  disp(labindex)
end


% For most jobs taking a few hours, you can use parfor to run a function
% taht contains your entire analysis code.
IDlist = {'ID1' 'ID2' 'ID3'};
NumericalInput = [1 4 6]; % just some arbitrary numbers
parfor ii = 1:3
    [x(ii), y(ii)] = fun1(NumericalInput(ii), IDlist{ii}) % this was also save variables to disk
end

disp(x)
disp(y)
ls /imaging/dp01/output_subject_*
% results in
% /imaging/dp01/output_subject_ID1.mat  
% /imaging/dp01/output_subject_ID2.mat
% /imaging/dp01/output_subject_ID3.mat


%% cbupool with Arguments (example for a very large job)
% You should not request large amounts of resources unless you need them.
% This increases the chances of your job crashing unexpectedly and also
% takes longer to start.
delete(gcp)
P=cbupool(96);
P.ResourceTemplate='-l nodes=^N^,mem=196GB,walltime=96:00:00';
parpool(P) 


% For smaller jobs (i.e. 20 subjects taking 2 hours each) use this. 2GB per worker is
% usually enough, but you should calculate this before hand to ensure you
% request enough memory.

delete(gcp)
P=cbupool(20);
P.ResourceTemplate='-l nodes=^N^,mem=40GB,walltime=4:00:00';
parpool(P) 

% put your parfor loop here

delete(gcp) % Important to delete it when you are finished to free up resources for other users

%% Inspecting gcp
% You can check it's methods
methods(gcp)

% addAttachedFiles       disp                   listAutoAttachedFiles  parfevalOnAll          
% delete                 display                parfeval               updateAttachedFiles    

% in order to run any methods of gcp you need to assign it to a variable

g = gcp;

g.listAutoAttachedFiles


%% Other examples from the intranet page http://intranet.mrc-cbu.cam.ac.uk/computing/cluster-demo
cd /hpc-software/example_scripts/workshop/
edit matlab_scheduler.m
edit matlab_analysis.m 
