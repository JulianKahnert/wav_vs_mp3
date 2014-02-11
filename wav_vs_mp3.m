function [] = wav_vs_mp3()
% WAV_VS_MP3 converts: flac => wav => mp3 => wav
%
% This might help you to choose the right option for your mp3 encoding.
%
% IMPORTANT:
%   * make sure there is an "input" folder with a flac in the directory of
%     WAV_VS_MP3.m
%   * make sure you have "flac" and "lame" installed
%   * make sure the path of "flac" and "lame" are in the path of your
%     matlab shell (read README.txt for further instructions)
%
% Input Parameter:
%	 no input arguments needed
%
% Output Parameter:
%	 no output arguments needed
%
%--------------------------------------------------------------------------
% Example:
%   * [] = wav_vs_mp3()
%
%--------------------------------------------------------------------------
% flac tutorial
% http://xiph.org/flac/documentation_tools_flac.html#tutorial
%
% mp3 tutorial
% http://lame.cvs.sourceforge.net/viewvc/lame/lame/USAGE
%

% Author: Julian Kahnert (c) IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create                                  02-Feb-2014  JK
% Ver. 0.10 final fixes for first public release            04-Feb-2014  JK
% Ver. 0.11 file selection + wav-file input support         04-Feb-2014  JK
% Ver. 0.12 add 2 more files with +-1dB RMS in "wav_to_mp3" 11-Feb-2014  JK

%--------------------------------------------------------------------------

clc

fprintf('\n\n##########################################################\n')
fprintf('\n\n\tstart calculation\n\n')


%% initials settings
szPathPWD   = mfilename('fullpath');
szPathPWD   = szPathPWD(1:end-length(mfilename));
cd(szPathPWD)

try
    rmdir([szPathPWD 'output_rand'],'s');
end

bNewWavs    = 1;    % flac => wav => mp3 => wav
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

% CHANGES IN THE FOLLOWING LINE MIGHT HAVE AN EFFECT ON THE FUNCTION
% "wav_to_mp3"! Check out the section which creates two more files.
caLameOptions   = {'-b 320' '-V 0' '-V 3' '-V 6' '-V 9'};


caFolderSong    = dir([szPathPWD 'input' filesep '*.flac']);
caFolderSong    = [caFolderSong; dir([szPathPWD 'input' filesep '*.wav'])];
caFolderSong    = {caFolderSong(~[caFolderSong.isdir]).name};

if isempty(caFolderSong)
    error('There is no file in the input folder');

elseif length(caFolderSong) > 1
    fprintf('\nChoose one of the following files:\n\n');

    for ii = 1:length(caFolderSong)
        fprintf('( %d ) \t %s \n',ii,caFolderSong{ii});
    end

    sz = input('\nSelect a number and press enter:\n','s');
    szFileName = caFolderSong{str2double(sz)};

else
    szFileName = caFolderSong{1};

end


szFilePath      = [szPathPWD 'input' filesep szFileName];

fprintf('\n\n##########################################################\n')
fprintf('song: \t%s\n\n',szFileName)

if bNewWavs
    wav_to_mp3(szFilePath,caLameOptions);
end

caFiles = dir([szPathPWD 'output' filesep '*.wav']);
caFiles = {caFiles.name};

%% write and plot data

if bWriteFiles
    writeRandomFiles(caFiles);
end

if bPlot
    caSignal = read_songs();
    plotData(caSignal,caFiles)
end

if bSaveData
    fprintf('\nStart saving data. This takes a while, grab a coffee!\n')
    save('data.mat','caSignal','fs');
    fprintf('\nSaving completed!\n')
end

fprintf('\n\n##########################################################\n')
fprintf('\n\n')


%% functions

    function writeRandomFiles(caFiles)
        try
            rmdir([szPathPWD 'output_rand'],'s');
        end
        mkdir([szPathPWD 'output_rand']);

        iFID = fopen([szPathPWD 'output_rand' filesep 'quality.txt'],'w','n','UTF-8');
        fprintf(iFID,'\n\n');
        fprintf(iFID,'####################################################\n');
        fprintf(iFID,'\n\t ###  quality results  ### \n\n\n\n');
        
        %#% resample workaroung
        [~,fs_ref] = wavread([szPathPWD 'output' filesep 'reference.wav']);
        
        vRand = randperm(length(caFiles));
        for k = 1:length(caFiles)
            [y,fs] = wavread([szPathPWD 'output' filesep caFiles{k}]);
            
            if fs ~= fs_ref
                y   = resample(y,fs_ref,fs);
                fs  = fs_ref;
            end
            
            wavwrite(y,fs,[szPathPWD 'output_rand' filesep num2str(vRand(k))]);
            fprintf(iFID,'\t file: %s.wav \t\t quality: %s \n\n',...
                num2str(vRand(k)),caFiles{k});
        end

        fprintf(iFID,'\n####################################################\n\n\n');
        fclose(iFID);

        fprintf('Files are in folder "output_rand"!\n')
    end
        
    function [caSignal,fs] = read_songs()
        stMP3Files = dir([szPathPWD 'output' filesep '*.wav']);
        caSignal = cell(1,length(stMP3Files));
        
        %#% resample workaroung
        [~,fs_ref] = wavread([szPathPWD 'output' filesep 'reference.wav']);
        
        for kk = 1:length(stMP3Files)
            fprintf('read file: %s\n',stMP3Files(kk).name)

            [caSignal{1,kk},fs] = wavread(['output' filesep stMP3Files(kk).name]);
            if fs ~= fs_ref
                caSignal{1,kk}   = resample(caSignal{1,kk},fs_ref,fs);
                fs  = fs_ref;
            end
            
        end
    end

    function plotData(caSignal,fs,caFiles)
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

    function wav_to_mp3(szFilePath,caLameOptions)
        try
            rmdir([szPathPWD 'output'],'s');
        end
        mkdir([szPathPWD 'output']);
        
        szPOut = [szPathPWD 'output' filesep];
        
        % temp file to solve problem with spaces in filename
        szFileTemp = strrep(szFilePath(length(szPathPWD)+length('input')+2:end),' ','_');
        szFileTemp = strrep(szFileTemp,'''','_');
        
        
        if strcmp(szFileTemp(end-2:end),'lac')
            copyfile(szFilePath,[szPathPWD 'output' filesep szFileTemp]);
            
            % flac => wav
            fprintf('\n\t flac => wav \n')

            szCommand   = ['flac -d ' szPOut szFileTemp ...
                ' -o '  szPOut 'reference.wav'];

            fprintf([szCommand '\n'])
            [~,~] = system(szCommand);
        else
            copyfile(szFilePath,[szPathPWD 'output' filesep 'reference.wav']);
        end
        
        % wav => mp3
        fprintf('\n\t wav => mp3 \n')
        for k = 1:length(caLameOptions)
            
            szCommand = ['lame ' caLameOptions{k} ' ' ...
                szPOut 'reference.wav ' ...
                szPOut strrep(caLameOptions{k}(2:end),' ','_') '.mp3'];
            
            fprintf([szCommand '\n'])
            [~,~] = system(szCommand);
        end

        % mp3 => wav
        fprintf('\n\t mp3 => wav \n')
        
        stMP3Files = dir([szPOut '*.mp3']);
        for i = 1:length(stMP3Files)
            
            szCommand = ['lame --decode ' ...
                szPOut stMP3Files(i).name ' ' ...
                szPOut stMP3Files(i).name(1:end-3) 'wav'];
            
            fprintf([szCommand '\n'])
            [~,~] = system(szCommand);
        end
        
        
        % Section which creates two more WAV-Files. The adding of +1dB
        % might result in clipping of the signal.
        %   * original with -1dB RMS
        [y, fs] = wavread([szPOut 'reference.wav']);
        y = y * 10^(-1/20);
        wavwrite(y,fs,[szPOut 'reference_min1dB.wav']);
        
        %   * V 6 with +1dB RMS
        [y, fs] = wavread([szPOut 'V_6.wav']);
        y = y * 10^(+1/20);
        wavwrite(y,fs,[szPOut 'V_6_add1dB.wav']);
        
        delete([szPOut '*.mp3'],[szPOut '*.flac']);
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