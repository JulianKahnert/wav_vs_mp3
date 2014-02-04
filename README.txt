README - wav_VS_mp3


This is a MacOSX installing tutorial for all codecs, which are
required for the "wav_vs_mp3.m" Matlab-function.


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
		sudo pico /Applications/MATLAB_R2012a_Student.app/bin/matlab
	* include the following line under "#!/bin/sh":
		export PATH="$PATH:/usr/local/bin"


commands:
* flac -d Roy.flac
* lame -V 0  Roy_mp3.wav
* lame --decode file.mp3
