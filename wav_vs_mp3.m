function [out_param] = wav_vs_mp3(in_param)
% wav_vs_mp3 helps to do something usefull (fill out)
%
% Usage [out_param] = wav_vs_mp3(in_param)
%
% Input Parameter:
%	 in_param: 		 Explain the parameter, default values, and units
%
% Output Parameter:
%	 out_param: 	 Explain the parameter, default values, and units
%
%--------------------------------------------------------------------------
% Example: Provide example here if applicable (one or two lines) 
%

% Author: Julian Kahnert (c) IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create (empty) 02-Feb-2014  JK

%--------------------------------------------------------------------------

clc

fprintf('\n\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
fprintf('\n\n\tstart calculation:\n\n')


%% initials settings
szPathPWD = mfilename('fullpath');
szPathPWD = szPathPWD(1:end-length(mfilename)-1);
cd(szPathPWD)
delete('*.wav')
delete('*.mat')


bPlot       = 0;    % plot spectrogram of each audio file
bWriteFiles = 0;    % write random wav-files to listen in each file
bSaveData   = 0;    % saves data in .mat-file (this takes a while)

fs          = [];


%% input data

%   QUALITY
%
%   +0      wav-reference
%   +1      320kBit/s CBR
%   0       0, 220-260 kBit/s
%   3       3, 155-195 kBit/s
%   6       6,  95-135 kBit/s
%   9       9,  45- 85 kBit/s
%
% all:
%   * joint stereo
%   * speed: standard
caFiles         = {'+0.wav' '+1.wav' '0.wav' '3.wav' '6.wav' '9.wav' };

caFolderSong    = dir;
caFolderSong    = {caFolderSong([caFolderSong.isdir]).name};
caFolderSong    = caFolderSong(3:end);


szFolderSong    = caFolderSong{2}; %#% debug, later loop!?



caSignal = read_songs([szPathPWD filesep szFolderSong],caFiles);


%% write and plot data

if bWriteFiles
    vRand = randperm(length(caFiles));
    for i = 1:length(caFiles)
        wavwrite(caSignal{i},fs,num2str(vRand(i)))
    end
    
    fprintf('Listen to the files and press ENTER afterwards!\n')
    pause
    
    fprintf('\n\tquality result:\n')
    fprintf('\nGOOD \t \t \t \t BAD\n')
    disp(vRand)
end

if bPlot
    plotData(caSignal,caFiles)
end

if bSaveData
    fprintf('\nStart saving data. This takes a while, grab a coffee!\n')
    save('data.mat','caSignal','fs');
    fprintf('\nSaving completed!\n')
end

fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
fprintf('\n\n')


%% functions

    function caSignal = read_songs(szPath,caFiles)
        caSignal = cell(1,length(caFiles));
        for k = 1:length(caFiles)
            fprintf('read file: %s\n',caFiles{k})

            [caSignal{1,k},fs] = wavread([szPath filesep caFiles{k}]);

        end
    end

    function plotData(caSignal,caFiles)
        h = figure;
        set(gcf,'Position',[-1908 300 1772 433]);
        
        for k = 1:length(caFiles)
            fprintf('Plotting data! Press ENTER for next plot.\n')
            % semilogx(10*log10(abs(fft(caSignal{1,i}(:,1)))))
            spectrogram(caSignal{k}(:,1),2^12,0,2^12,fs,'yaxis')
            title(caFiles{k})
            pause
        end
        delete(h)
    end


end
%--------------------Licence ----------------------------------------------
% Copyright (c) <2014> Julian Kahnert
% Institute for Hearing Technology and Audiology
% Jade University of Applied Sciences 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files 
% (the "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject
% to the following conditions:
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.