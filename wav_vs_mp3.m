function [] = wav_vs_mp3(bNewWavs,bWriteFiles)
% WAV_VS_MP3 converts: flac => wav => mp3 => wav
%
% This might help you to choose the right option for your mp3 encoding.
% Please read the README.txt first!
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
%
% EXTRACT FORM THE LAME ENCODER USAGE TXT:
%> ==========================================
%> VBR quality setting
%> ==========================================
%>  -V n Enable VBR encoding
%>
%> Encodes using the VBR algorithm, at the indicated quality.
%> 0=highest quality, bigger files. 9.999=lowest quality, smaller files.
%> Decimal values can be specified, like: 4.51
%>
%> On average, the resulting bitrates are as follows:
%> Setting       Average bitrate (kbps)
%>     0             245
%>     2             190
%>     3             175
%>     4             165
%>     5             130
%>
%> Using -V 7 or higher (lower quality) is not recommended.
%> ABR usually produces better results.

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

szPathPWD   = fileparts(which(mfilename('fullpath')));
cd(szPathPWD)

% setting defaults
if nargin < 5
    % default quality settings
    caLameOptions   = {'-b 320' '-V 0' '-V 3' '-V 6' '-V 9'};
end
if nargin < 2
    bWriteFiles = 1;    % write random wav-files to listen in each file
end
if nargin < 1
    bNewWavs = 1;       % flac => wav => mp3 => wav
end

if isunix
    % Include usr/local binaries (necessary on OSX for brew versions)
    PATH = getenv('PATH');
    setenv('PATH', [PATH ':/usr/local/bin']);
end

if exist(fullfile(szPathPWD,'output_rand'), 'dir')
    rmdir(fullfile(szPathPWD,'output_rand'),'s');
end
if bNewWavs && exist(fullfile(szPathPWD,'output'), 'dir')
    rmdir(fullfile(szPathPWD,'output'),'s');
end


%% input data

caFolderSong    = dir(fullfile(szPathPWD,'input','*.flac'));
caFolderSong    = [caFolderSong; dir(fullfile(szPathPWD,'input','*.wav'))];
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

szFilePath      = fullfile(szPathPWD,'input',szFileName);

fprintf('\n\n##########################################################\n')
fprintf('song: \t%s\n\n',szFileName)


%% create new files

if bNewWavs
    if exist(fullfile(szPathPWD,'output'), 'dir')
        rmdir(fullfile(szPathPWD,'output'),'s');
    end
    mkdir(fullfile(szPathPWD,'output'));
    
    szPOut = fullfile(szPathPWD,['output' filesep]);
    
    % temp file to solve problem with spaces in filename
    szFileTemp = strrep(szFilePath(length(szPathPWD)+length('input')+2:end),' ','_');
    szFileTemp = strrep(szFileTemp,'''','_');
    
    if strcmp(szFileTemp(end-2:end),'lac')
        copyfile(szFilePath,fullfile(szPathPWD,'output',szFileTemp));
        
        % flac => wav
        fprintf('\n\t flac => wav \n')
        
        szCommand = sprintf('flac -d %s%s -o %sreference.wav',szPOut,szFileTemp,szPOut);
        fprintf([szCommand '\n'])
        [bError,~] = system(szCommand);
        if bError
            error('Something went wrong here!') %#%
        end
    else
        copyfile(szFilePath,fullfile(szPathPWD,'output','reference.wav'));
    end
    
    % wav => mp3
    fprintf('\n\t wav => mp3 \n')
    for k = 1:length(caLameOptions)
        szCommand = sprintf('lame %s %sreference.wav %s%s.mp3',...
            caLameOptions{k},szPOut,szPOut,strrep(caLameOptions{k}(2:end),' ','_'));
        
        fprintf([szCommand '\n'])
        [~,~] = system(szCommand);
    end
    
    % mp3 => wav
    fprintf('\n\t mp3 => wav \n')
    
    stMP3Files = dir(fullfile(szPOut,'*.mp3'));
    for i = 1:length(stMP3Files)
        szCommand = sprintf('lame --decode %s%s %s%swav',szPOut,stMP3Files(i).name,szPOut,stMP3Files(i).name(1:end-3));
        fprintf([szCommand '\n'])
        [~,~] = system(szCommand);
    end
    
    % Section which creates two more WAV-Files. The adding of +1dB
    % might result in clipping of the signal.
    %   * original with -1dB RMS
    [y, fs] = audioread(fullfile(szPOut,'reference.wav'));
    y = y * 10^(-1/20);
    audiowrite(fullfile(szPOut,'reference_min1dB.wav'),y,fs);
    
    %   * V 6 with +1dB RMS
    [y, fs] = audioread(fullfile(szPOut,'V_6.wav'));
    y = y * 10^(+1/20);
    audiowrite(fullfile(szPOut,'V_6_add1dB.wav'),y,fs);
    
    delete(fullfile(szPOut,'*.mp3'),fullfile(szPOut,'*.flac'));
end

caFiles = dir(fullfile(szPathPWD,'output','*.wav'));
caFiles = {caFiles.name};


%% write files

if bWriteFiles
    if exist(fullfile(szPathPWD,'output_rand'), 'dir')
        rmdir(fullfile(szPathPWD,'output_rand'),'s');
    end
    mkdir(fullfile(szPathPWD,'output_rand'));
    
    [~,txt] = system('lame');
    caLameVersion = textscan(txt,'%s','Delimiter','\n');
    
    iFID = fopen(fullfile(szPathPWD,'output_rand','quality.md'),'w','n','UTF-8');
    
    fprintf(iFID,'# Infos\n\n');
    fprintf(iFID,'encoder: %s\n\n',caLameVersion{1}{1});
    fprintf(iFID,'| quality | bitrate (kBit/s) |\n');
    fprintf(iFID,'|---------|---------|\n');
    fprintf(iFID,'| reference | reference signal |\n');
    fprintf(iFID,'| reference_min1dB | reference signal -1dB |\n');
    fprintf(iFID,'| b_320 | 320 |\n');
    fprintf(iFID,'| V_0 | average 245 |\n');
    fprintf(iFID,'| V_3 | average 175 |\n');
    fprintf(iFID,'| V_6 | average 115 |\n');
    fprintf(iFID,'| V_6_add1dB | average 115 |\n');
    fprintf(iFID,'| V_9 | average < 85  |\n');
    
    fprintf(iFID,'\n# Results\n\n');
    fprintf(iFID,'| track | quality |\n');
    fprintf(iFID,'|------|---------|\n');   
      
    %#% resample workaroung
    [~,fs_ref] = audioread(fullfile(szPathPWD,'output','reference.wav'));
    
    vRand = randperm(length(caFiles));
    for k = 1:length(caFiles)
        [y,fs] = audioread(fullfile(szPathPWD,'output',caFiles{vRand(k)}));
        
        if fs ~= fs_ref
            y   = resample(y,fs_ref,fs);
            fs  = fs_ref;
            warning(['Audio data resampled:' caFiles{vRand(k)}])
            audiowrite(fullfile(szPathPWD,'output_rand',[num2str(k) '.wav']),y,fs);
        else
            copyfile(fullfile(szPathPWD,'output',caFiles{vRand(k)}),...
                fullfile(szPathPWD,'output_rand',[num2str(k) '.wav']))
        end
        
        fprintf(iFID,'| %i | %s |\n',...
            k,caFiles{vRand(k)}(1:end-4));        
    end

    % create plots
    hWin = figure('Position',[-1908 404 548 329],'PaperPositionMode','auto');
    for kk = 1:length(caFiles)
        [vSig,fs] = audioread(['output_rand' filesep num2str(kk) '.wav']);
        
        NFFT    = 2^11;
        window  = hamming(NFFT);
        noverlap= NFFT/2;
        [pxx,f] = pwelch(vSig,window,noverlap,NFFT,fs);
        plot(f,10*log10(pxx))
        
        xlim([0 44100/2])
        grid on
        xlabel('Frequency (Hz)','FontName','Arial','FontSize',10)
        ylabel('Magnitude (dB)','FontName','Arial','FontSize',10)
        
        title([num2str(kk) '.wav'])
        print(['output_rand' filesep num2str(kk)],'-dpng')
    end
    delete(hWin)
    
    % figures in markdown
    for kk = 1:length(caFiles)
        fprintf(iFID,'\n![image](%s)\n', [num2str(kk) '.png']);
    end
    
    fclose(iFID);
    fprintf('Files are in folder "output_rand"!\n')
end

fprintf('\n\n##########################################################\n')
fprintf('\n\n')

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