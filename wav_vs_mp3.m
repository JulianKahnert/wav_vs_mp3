function [] = wav_vs_mp3()
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

% flac tutorial
% http://xiph.org/flac/documentation_tools_flac.html#tutorial

% mp3 tutorial
% http://lame.cvs.sourceforge.net/viewvc/lame/lame/USAGE

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

bConvert    = 1;    % flac => wav => mp3 => wav
bWriteFiles = 1;    % write random wav-files to listen in each file
bPlot       = 0;    % plot spectrogram of each audio file
bSaveData   = 0;    % saves data in .mat-file (this takes a while)

fs          = [];


%% input data

%   QUALITY
%
%   +0      wav-reference
%   0       0, 220-260 kBit/s
%   3       3, 155-195 kBit/s
%   6       6,  95-135 kBit/s
%   9       9,  45- 85 kBit/s
%
% all:
%   * joint stereo
%   * speed: standard
caLameOptions   = {'-q 0' '-q 3' '-q 6' '-q 9'};


caFolderSong    = dir('input/*.flac'); %#% not just flacs!?
caFolderSong    = {caFolderSong(~[caFolderSong.isdir]).name};

if isempty(caFolderSong)
    error('There is no file in the input folder');
end

if bConvert
    wav_to_mp3(caFolderSong{1});
end

caSignal        = read_songs();

caFiles         = dir(['output' filesep '*.wav']);
caFiles         = {caFiles.name};

%% write and plot data

if bWriteFiles
    vRand = randperm(length(caFiles));
    for k = 1:length(caFiles)
        wavwrite(caSignal{k},fs,[num2str(vRand(k)) ])
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

    function caSignal = read_songs()
        stMP3Files = dir(['output' filesep '*.wav']);
        caSignal = cell(1,length(stMP3Files));
        
        for kk = 1:length(stMP3Files)
            fprintf('read file: %s\n',stMP3Files(kk).name)

            [caSignal{1,kk},fs] = wavread(['output' filesep stMP3Files(kk).name]);

        end
    end

    function plotData(caSignal,caFiles)
        h = figure;
        set(gcf,'Position',[-1908 300 1772 433]);
        
        for kk = 1:length(caFiles)
            fprintf('Plotting data! Press ENTER for next plot.\n')
            % semilogx(10*log10(abs(fft(caSignal{1,i}(:,1)))))
            spectrogram(caSignal{kk}(:,1),2^12,0,2^12,fs,'yaxis')
            title(caFiles{kk})
            pause
        end
        delete(h)
    end

    function wav_to_mp3(szFile)
        try
            rmdir('output','s');
        end
        mkdir('output');
        
        % temp file to solve problem with spaces in filename
        szFileTemp = strrep(szFile,' ','_');
        
        copyfile([szPathPWD filesep 'input' filesep szFile],...
            [szPathPWD filesep 'output' filesep szFileTemp]); %#% just flac
        cd output;
        
        
        % flac => wav
        fprintf('\n\t flac => wav \n')
        szFileOut   = '+0';
        szCommand   = ['flac -d ' szFileTemp ' -o ' szFileOut '.wav'];
        fprintf([szCommand '\n'])
        [~,~] = system(szCommand);

        % wav => mp3
        fprintf('\n\t wav => mp3 \n')
        for ca = caLameOptions
            szCommand = ['lame ' ca{1} ' ' szFileOut '.wav ' strrep(ca{1}(2:end),' ','_') '.mp3'];
            fprintf([szCommand '\n'])
            [~,~] = system(szCommand);
        end

        % mp3 => wav
        fprintf('\n\t mp3 => wav \n')
        stMP3Files = dir('*.mp3');
        for i = 1:length(stMP3Files)
            szCommand = ['lame --decode ' stMP3Files(i).name ' ' stMP3Files(i).name(1:end-3) 'wav'];
            fprintf([szCommand '\n'])
            [~,~] = system(szCommand);
        end

        delete('*.mp3','*.flac');
        cd ..
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