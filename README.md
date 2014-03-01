#CleanSweep

v1.74 - Updated 10/25/2012 
Greg Foss - @Heinzarelli
http://gregfoss.com

--------------------------------------------------

Simple script that probes a range of IP addresses looking for specific ports
Nothing new, just makes a clean report and can pull banners and source-code

Utilizes the following tools / dependencies...
	[ ] nmap for portscanning, ping sweeps and more...
	[ ] netcat for banner-grabbing
	[ ] libcurl to pull the source of web pages
	[ ] unix2dos to formats output so that your manager can read the report ;-)

--------------------------------------------------

#Usage

make sure you have the proper dependencies:
	nmap
	netcat
	libcurl / curl
	unix2dos

make the script executable for the user, group and all others:
	$ chmod a+x cleansweep.sh

run:
	$ ./cleansweep.sh

	/-------------------------------------------------------\
	|	[..]						|
	|Select an option below					|
	|-----------------------------				|
	|    [1]  Portsweep - import IP addresses from a file	|
	|    [2]  Portsweep - custom network range		|
	|    [3]  Portsweep - class-c network range		|
	|    [4]  Pingsweep - custom network range		|
	|    [5]  Pingsweep - class-c network range		|
	|    [6]  Exit						|
	|-----------------------------				|
	|	[..]						|
	\-------------------------------------------------------/

make your selection and the script will do the rest...

--------------------------------------------------

this script will run on:
	Linux
	Unix
	OSX
	Windows (via Cygwin)

--------------------------------------------------

#Changelog

	10/25/2012
		Now tracking in GitHub!

	7/19/2012
		Added services for banner grabbing
		Resolved issues with recording network ranges
		Improved speed and accuracy of the script

	6/21/2012
		public release
		
--------------------------------------------------

#License

Copyright (c) 2014, Greg Foss
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of Greg Foss nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

--------------------------------------------------
