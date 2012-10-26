CleanSweep -- v1.74 - Updated 10/25/2012 
Greg Foss - @Heinzarelli
http://gregfoss.com

#############################################################

Simple script that probes a range of IP addresses looking for specific ports
Nothing new, just makes a clean report and can pull banners and source-code

Utilizes the following tools / dependencies...
	[ ] nmap for portscanning, ping sweeps and more...
	[ ] netcat for banner-grabbing
	[ ] libcurl to pull the source of web pages
	[ ] unix2dos to formats output so that your manager can read the report ;-)

#############################################################

[[Usage]]

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

#############################################################

this script will run on:
	Linux
	Unix
	OSX
	Windows (via Cygwin)

#############################################################

CHANGELOG:

-----[10/25/2012]-----
Now tracking in GitHub!
---------------------

-----[7/19/2012]-----
Added services for banner grabbing
Resolved issues with recording network ranges
Improved speed and accuracy of the script
---------------------

-----[6/21/2012]-----
public release
---------------------