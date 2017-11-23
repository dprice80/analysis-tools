function [TimeLeft TimeLeftVec] = dispTimeLeft(startloop,increment,sizeloop,iteration,tstart,showloop,showtime,loopIDs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display Time-Left function v2.1 by Darren Price, UK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% USAGE:
%        dispTimeLeft(startloop, increment, sizeloop, iteration)
%        dispTimeLeft(startloop, increment, sizeloop, iteration, tstart)
%        dispTimeLeft(startloop, increment, sizeloop, iteration, tstart, showloop, showtime)
%        dispTimeLeft(startloop, increment, sizeloop, iteration, tstart, showloop, showtime, loopID)
%
% Simple function that tells you how much time you have left on a loop.
% By default the script will only show the time. If you would like to show
% the loop iteration then include first 6 arguments. You will need to assign a
% custom tic in order to assign the argument e.g. tstart = tic. For
% multiple loops (nested loops) use tstart(1) = tic. See below for more
% info...
%
% % Example 1. Basic Usage
% 
% for i = 1:100
%     tic
%     X = rand(1000,1000);
%     cov(X);
%     dispTimeLeft(1,1,100,i)
% end
%
% Loop can use non integer increments, and/or can be displayed
% occasionally. For multiple timers you can assign tic to a custom variable
% and pass it to the function. You need to pass the entire tstart vector to
% the function (tstart) not tstart(1). The loopID variable takes care of
% pulling the correct value from tstart and the function automatically keeps track of new and old
% sessions. So no need to worry about clearing the global variables.
%
% loopID = 1;
% for i = 1:0.1:10
%     tstart(loopID) = tic;
%     pause(0.1)
%   if rem(i,1) == 0
%       dispTimeLeft(1,0.1,10,i,tstart,0,1,loopID)
%   end
% end
%
% The time left will be calculated by the last 5 measurements taken unless
% there are less than 5 in which case just an average of all points
% available.
%
% If you would like to change the format of the output just change the
% character string.
%
% You cannot use this inside a while loop unless you know or have a rough idea when the loop
% will end (e.g., there will be ~100 loops so use 1,1,100 as the first 3 arguments. 
% If you know roughly when it will end then you could input the
% number of increments and make a custom index variable to count the
% iterations.
%
% i = 1;
% index = 1;
% while i < 10
%   tic
%   index = index + 1;
%   pause(0.5)
%   dispTimeLeft(1,1,10,index)
%   i = i + 1;
% end
%
% You could use the function with a non incremental sequence 
%
% seq = [1 6 4 3 8 4 23 57]; % this could change dynamically during the
%                            % loop and could still work.
% index = 1;
% for i = seq
%     tstart(loopID) = tic;
%     pause(0.1)
%     dispTimeLeft(1,1,length(seq),index)
%     index = index+1;
% end
%
% 
% % Multiple Nested Loops
% You can now have multiple loops. You can either add the last argument as
% an integer number or as a struct. Just make sure that the numeric part of
% the struct corresponds with the tstart index number. Here is a script
% that uses all the functionality of the script. Notice that you can skip
% iterations by using either the mod, rem or any other method you like.
% loopID does not need to be persistent and can change from a struct to an
% integer between different loops. However, the numeric IDs must always correspond to the
% tstart variable used in that loops.
%
% clear all
% for u = 1:10
%     tstart(1) = tic;
%     for i = 1:10
%         tstart(2) = tic;
%         pause(1)
%         if mod(i,2) == 0
%             loopID = struct('ID',2,'name','Inner');
%             dispTimeLeft(1,1,10,i,tstart,1,1,loopID)
%         end
%     end
%     loopID = 1;
%     dispTimeLeft(1,1,10,u,tstart,1,1,loopID)
% end
%
% Enjoy :)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% BSD Licence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2011, DARREN PRICE
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
%
%     * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
%     * The names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global buildInt telapsed

switch nargin
    case [1 2 3]
        error('Minimum number of arguments = 4 \n \n :: e.g. dispTimeLeft(1,0.2,20,i)')
    case 4
        showloop = 0;
        showtime = 1;
    case 5
        % tstart is set
        showloop = 0;
        showtime = 1;
    case 6
        error('Cannot have 6 arguments. Must have either 4, 5 or 7. Type "help dispTimeLeft"')
end

if ~exist('loopIDs','var')
    loopID = 1;
    loopIDs = 1;
end
% loopIDs is the structure loopID is the int variable
if isstruct(loopIDs)
    loopID = loopIDs.ID;
    loopName = loopIDs.name;
else 
    loopName = num2str(loopIDs);
    loopID = loopIDs;
end

% check if the buildInt exists as a global
if isempty(buildInt)
    buildInt = (startloop:increment:sizeloop);
end

% check if old session exists
if ~isempty(telapsed)
    if size(telapsed,1) < loopID
        telapsed(loopID,:) = 0;
    end

    if find(buildInt == iteration,1) < length(telapsed(loopID,telapsed(loopID,:) ~= 0))
        buildInt = (startloop:increment:sizeloop);
        telapsed(loopID,:) = 0;
    end
end

if exist('tstart', 'var')
    telapsed(loopID,buildInt == iteration) = toc(tstart(loopID));
else
    telapsed(loopID,buildInt == iteration) = toc;
end

telapsed2 = telapsed(loopID,telapsed(loopID,:) ~= 0);
 
mult = numel(buildInt)-find(buildInt == iteration,1);
clip = round(length(buildInt)*0.10);
if size(telapsed,1) > clip
    tpred = (mean(telapsed2(end-clip+1:end))*mult);
else
    tpred = (mean(telapsed2)*mult);
end
Hrs = floor(tpred/3600);
Min = floor(rem(tpred,3600)/60);
Sec = rem(rem(tpred,3600),60);
if showloop == 1
    disp(sprintf('Loop %0.0f of %0.0f in %s (%0.2f%%)', iteration, sizeloop, loopName,(iteration/sizeloop)*100));
end

if showtime == 1
    disp(sprintf('Estimated Time Left in Loop %s:- %0.0f Hrs %0.0f Mins %0.0f Secs',loopName,Hrs,Min,Sec));
end

switch nargout;
    case 1
        TimeLeft = sprintf('Estimated Time Left Loop %s:- %0.0f Hrs %0.0f Mins %0.0f Secs',loopName,Hrs,Min,Sec);
    case 2
        TimeLeftVec(loopID,1:3) = [Hrs Min Sec];
end

if iteration == sizeloop
   clear global buildInt telapsed;
end
