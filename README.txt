README - wav_vs_mp3.m


MATLAB function to compare different MP3 qualities.


Please read README.txt first and contact me at
julian.kahnert(at)student.jade-hs.de for additional questions.


##### USAGE #####

The "wav_vs_mp3.m" Matlab function converts a flac or wav file via
different command line orders into MP3-files. These files will be
converted with different quality settings, which can manually be
cahnged in the "CHANGE HERE THE MAJOR SETTINGS" section of the
Matlab function.
After the first conversion the MP3 files will be converted back into
wav files, which can be burned on a CD for listening tests.

## Procedure ##
	* install codec (see INSTALLATION section)
	* put a wav or flac file in the "input" folder
	* start the "wav_vs_mp3.m" function via Matlab
	* step which will be done by matlab:
		- convert:	flac => wav 	(if input is a flac file)
		- convert: 	wav  => mp3 	(in different qualities)
		- convert: 	mp3  => wav 	(each of the mp3 files)
		- randomised output of files with a mapping txt file
	* now you can listen to the files (1.wav, 2.wav, 3.wav, ...) in
		the "output_rand" folder and compare them
	* check if your own ranking is correct by looking in the
		"quality.txt" file

## Advanced ##
( 1 )	(De)Activate the boolean variables ( 0 / 1 )...
			* bNewWavs
				conversation: flac => wav => mp3 => wav

			* bWriteFiles
				writes random wav files (1.wav, 2.wav, 3.wav, ...)
				and "quality.txt" in the "output_rand"-folder to
				prepare a listening test

			* bPlot
				plots spectrogram of each audio file

			* bSaveData
				saves all audio data in a "data.mat"-file, which
				is the same as "wavread(...)" for each file
				(ATTENTION: This might take a while!)

		... for the described behavior of the wav_vs_mp3 function.

( 2 )	Change strings in the "caLameOptions"-cellarray.
		The cellarray contains the parameters for the lame encoder.
		Each element will create a mp3/wav file.
		You can change it like it is shown in in the following examples:
			* add elments:
			{'-V 0' '-V 3'} 		=> {'-b 320' '-V 0' '-V 3'}

			* delete eletems:
			{'-V 3' '-V 6' '-V 9'} 	=> {'-V 3' '-V 6'}
			
			* change elements:
			{'-b 320' '-V 0'} 		=> {'-b 320 -m j' '-V 0'}
			(example for joint stereo)

		For more parameter information type "lame --longhelp" in your
		terminal or have a look on: http://lame.sourceforge.net/using.php



##### INSTALLATION #####

This is a MacOSX installing tutorial for all codecs, which are
required for the "wav_vs_mp3.m"-Matlab-function.

1. download and install FLAC library
	* link:	http://xiph.org/flac/download.html

2. download and install LAME library
	* download source code from: http://lame.sourceforge.net/download.php
	* install LAME via terminal:
		- cd PATHTO/lame-...
		- sudo ./configure
		- sudo make
		- sudo make install

3. include lame and flac path in matlab shell
	* find lame path:
		which lame
	* find falc path:
		which flac
	* open editor to include path in shell:
		sudo pico /Applications/<MATLAB_VERSION>.app/bin/matlab
	* include the following line under "#!/bin/sh":
		export PATH="$PATH:<PATH_OF_WHICH_LAME/FLAC>"

4. start "wav_vs_mp3.m" via Matlab and follow the instructions

> commands for flac & lame:
> * flac -d 500Hz_sine.flac
> * lame -V 0  500Hz_sine.wav
> * lame --decode file.mp3



##### Licence #####

Copyright (c) <2014> Julian Kahnert
Institute for Hearing Technology and Audiology
Jade University of Applied Sciences 
Permission is hereby granted, free of charge, to any person obtaining 
a copy of this software and associated documentation files 
(the "Software"), to deal in the Software without restriction, including 
without limitation the rights to use, copy, modify, merge, publish, 
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject
to the following conditions:
The above copyright notice and this permission notice shall be included 
in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.