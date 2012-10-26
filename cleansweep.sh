#!/bin/bash

################################################################################
# script that probes 1 port within a range of IP addresses, grabs banners+source
# By: Greg Foss -- @Heinzarelli
# Available for download at: http://gregfoss.com
# v1.74 - Updated 8/15/2012
################################################################################

#banner
echo ""
echo     "   __|  |                        __|                          "
echo     "  (     |   -_)   _' |    \    \__ \ \ \  \ /  -_)   -_)  _ \ "
echo     " \___| _| \___| \__,_| _| _|   ____/  \_/\_/ \___| \___| .__/ "
echo     "                                                        _|    "
echo     "                                                 version 1.74 "
echo     "                                          greg.foss@owasp.org "
echo ""

#ask how they would like to scan
echo "Select an option below"
echo "-----------------------------"
echo "    [1]  Portsweep - import IP addresses from a file"
echo "    [2]  Portsweep - custom network range"
echo "    [3]  Portsweep - class-c network range"
echo "    [4]  Pingsweep - custom network range"
echo "    [5]  Pingsweep - class-c network range"
echo "    [6]  Exit"
echo "-----------------------------"
echo ""
echo -e "so... what'll it be? \c "
read choice
echo ""
echo "     -----------------------------"
echo ""

#choice 1
if [ $choice = "1" ]; then
	echo ""
	#capture input
	echo "*Note - Files must contain IP addresses separated by tabs, spaces, or separate lines*"
	echo ""
	echo -e "Enter the filename: \c "
	read file
	if [ -e $file ]; then
		echo "     ["$file"] exists"
		echo ""
	else
		echo "     ["$file"] does not exist..."
		echo ""
		exit 2
	fi
	echo -e "Which port would you like to scan? \c "
	read port
	echo ""
	echo "Scanning IP ranges in the file ("$file") for port "$port"..."
	echo ""
	#check port with nmap
		nmap -sV -P0 -oG - -iL $file -p $port | grep "Ports: "$port"/open" >> "nmap.tmp"
		trap "exit 2" 2
		sleep 1
	#set output variables
	network=$file
	id=$port
fi

#choice 2
if [ $choice = "2" ]; then
	echo ""
	echo -e "Which host range would you like to scan? (ex: 192.168.0) \c "
	read range
	echo -e "Enter the starting host (ex: 1) \c "
	read start
	echo -e "Enter the ending host (ex: 255) \c "
	read end
	echo -e "Which port would you like to scan? \c "
	read port
	echo ""
	echo "Scanning "$range"."$start"-"$end" for port "$port"..."
	echo ""
	#check port with nmap
	if [ $start -lt $end ]; then
		nmap -sV -P0 -oG - $range.$start-$end -p $port | grep "Ports: "$port"/open" >> "nmap.tmp"
		trap "exit 2" 2
		sleep 1
	else
		echo "Um... no... that won't work..."
		echo "Enter a range between 0 and 255"
	fi
	#set output variables
	network=$range"."$start"-"$end
	id=$port
fi

#choice 3
if [ $choice = "3" ]; then
	#capture input
	echo -e "Which host range would you like to scan? (ex: 192.168.0) \c "
	read  range
	echo "This script will scan hosts "$range".0-255"
	echo -e "Which port would you like to scan? \c "
	read port
	echo ""
	echo "Scanning "$range".0/24 for port "$port"..."
	echo ""
	#check port with nmap
		nmap -sV -P0 -oG - $range.0-255 -p $port | grep "Ports: "$port"/open" >> "nmap.tmp"
		trap "exit 2" 2
		sleep 1
	#set output variables
	network=$range."0-255"
	id=$port
fi

#choice 4
if [ $choice = "4" ]; then
	echo ""
	echo -e "Which host range would you like to scan? (ex: 192.168.0) \c "
	read range
	echo -e "Enter the starting host (ex: 1) \c "
	read start
	echo -e "Enter the ending host (ex: 255) \c "
	read end
	echo ""
	echo "Scanning "$range"."$start"-"$end"..."
	echo ""
	#check host with nmap
	if [ $start -lt $end ]; then
		nmap -sP -oG - $range.$start-$end | grep "Status: Up" >> "nmap.tmp"
		trap "exit 2" 2
		sleep 1
	else
		echo "Um... no... that won't work..."
		echo "Enter a range between 0 and 255"
		trap "exit 2" 2
	fi
	#set output variables
	network=$range"."$start"-"$end
	port="0"
	id="pingsweep"
fi

#choice 5
if [ $choice = "5" ]; then
	echo ""
	#capture input
	echo -e "Which host range would you like to scan? (ex: 192.168.0) \c "
	read  range
	echo "This script will pingsweep hosts "$range".0-255"
	echo ""
	echo "Sweeping "$range".0/24..."
	echo ""
	#check host with nmap
		nmap -sP -oG - $range.0-255 | grep "Status: Up" >> "nmap.tmp"
		trap "exit 2" 2
		sleep 1
	#set output variables
	network=$range."0-255"
	port="0"
	id="pingsweep"
fi

#choice 6
if [ $choice = "6" ]; then
	echo ""
	echo "Thank you, come again!"
	echo ""
	exit 2
fi

#undefined choice
if [ $choice -gt "6" ]; then
	echo ""
	echo "um... that's not a choice..."
	echo ""
	exit 2
fi
if [ $choice -lt "1" ]; then
	echo ""
	echo "um... that's not a choice..."
	echo ""
	exit 2
fi

#store ip addresses, hostnames, and services of discovered systems in files
cat nmap.tmp | awk '{print $2}' >> "sweep.tmp"
cat nmap.tmp | awk '{print $3}' >> "sweep-systems.tmp"
cat nmap.tmp | awk '{print $5 $6 $7 $8 $9 $10}' | grep -o "//.*" >> "service.tmp"
hits=$(cat sweep.tmp | wc -l);

#port 21 ftp banner grabbing
if [ $port = "21" ]; then
	echo ""
	echo "grabbing FTP banners..."
	echo ""
	if [ -f sweep.tmp ]
		then
		for i in $(cat sweep.tmp); do
			echo "     "$i
			echo "" >> "banner-grab.tmp"
			echo $i >> "banner-grab.tmp"
			echo -ne "\n\n" | nc -nnv -w2 $i 21 2>&1 >> "banner-grab.tmp"
			echo "     ----------     " >> "banner-grab.tmp"
			trap "exit 4" 4
		done
	fi
fi

#port 22 ssh banner grabbing
if [ $port = "22" ]; then
	echo ""
	echo "grabbing SSH banners..."
	echo ""
	if [ -f sweep.tmp ]
		then
		for i in $(cat sweep.tmp); do
			echo "     "$i
			echo "" >> "banner-grab.tmp"
			echo $i >> "banner-grab.tmp"
			echo -ne "\n" | nc -nnv -w2 $i 22 2>&1 >> "banner-grab.tmp"
			echo "     ----------     " >> "banner-grab.tmp"
			trap "exit 4" 4
		done
	fi
fi

#port 23 telnet banner grabbing
if [ $port = "23" ]; then
	echo ""
	echo "grabbing Telnet banners..."
	echo ""
	if [ -f sweep.tmp ]
		then
		for i in $(cat sweep.tmp); do
			echo "     "$i
			echo "" >> "banner-grab.tmp"
			echo $i >> "banner-grab.tmp"
			echo -ne "\n" | nc -nn -w2 $i 23 2>&1 >> "banner-grab.tmp"
			echo "     ----------     " >> "banner-grab.tmp"
			trap "exit 4" 4
		done
	fi
fi

#port 25 smtp banner grabbing
if [ $port = "25" ]; then
	echo ""
	echo "grabbing SMTP banners..."
	echo ""
	if [ -f sweep.tmp ]
		then
		for i in $(cat sweep.tmp); do
			echo "     "$i
			echo "" >> "banner-grab.tmp"
			echo $i >> "banner-grab.tmp"
			nc -nnv -w2 $i 25 2>&1 >> "banner-grab.tmp"
			echo "     ----------     " >> "banner-grab.tmp"
			trap "exit 4" 4
		done
	fi
fi

#port 80 http banner grabbing
if [ $port = "80" ]; then
	echo ""
	echo "grabbing HTTP banners..."
	echo ""
	if [ -f sweep.tmp ]
		then
		for i in $(cat sweep.tmp); do
			echo "" >> "banner-grab.tmp"
			echo $i >> "banner-grab.tmp"
			echo -ne "HEAD / HTTP/1.0\n\n" | nc -nn -w2 $i 80 2>&1 >> "banner-grab.tmp"
			echo "     ----------     " >> "banner-grab.tmp"
			trap "exit 4" 4
		done
		echo -e "Would you like to pull the source from discovered hosts? (y/n) \c "
		read choice
		if [ $choice = y ]; then
			echo ""
			echo "Pulling the source of discovered web pages..."
			echo ""
			for i in $(cat sweep.tmp); do
				echo "     "$i
				echo "" >> "source.tmp"
				echo $i >> "source.tmp"
				curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)" -m 30 -s http://$i >> "source.tmp"
				echo "     ----------     " >> "source.tmp"
				trap "exit 4" 4
			done
		else
			echo "cool, moving on..."
			echo ""
		fi
	fi
fi

#port 101 pop mail banner grabbing
if [ $port = "101" ]; then
	echo ""
	echo "grabbing POP Mail banners..."
	echo ""
	if [ -f sweep.tmp ]
		then
		for i in $(cat sweep.tmp); do
			echo "     "$i
			echo "" >> "banner-grab.tmp"
			echo $i >> "banner-grab.tmp"
			nc -nnv -w2 $i 101 2>&1 >> "banner-grab.tmp"
			echo "     ----------     " >> "banner-grab.tmp"
			trap "exit 4" 4
		done
	fi
fi

#port 443 https source and cipher strength extraction
if [ $port = "443" ]; then
	echo ""
	echo "Grabbing SSL certs..."
	if [ $choice = "1" ]; then
		echo "" >> "ssl.tmp"
		nmap --script ssl-cert -p 443 -iL $file | sed -n '3,$p'| head -n -2 >> "ssl.tmp"
		echo "     ----------     " >> "ssl.tmp"
		trap "exit 4" 4
	else
		echo "" >> "ssl.tmp"
		nmap --script ssl-cert -p 443 $network | sed -n '3,$p'| head -n -2 >> "ssl.tmp"
		echo "     ----------     " >> "ssl.tmp"
		trap "exit 4" 4
	fi
	echo ""
	echo -e "Would you like to pull the source from discovered hosts? (y/n) \c "
	read choice
	if [ $choice = y ]; then
		echo ""
		echo "Pulling the source of discovered https webpages..."
		echo ""
		for i in $(cat sweep.tmp); do
			echo "     "$i
			echo "" >> "source.tmp"
			echo $i >> "source.tmp"
			curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)" -m 30 -k -s https://$i >> "source.tmp"
			echo "     ----------     " >> "source.tmp"
			trap "exit 4" 4
		done
	else
		echo "cool, moving on..."
		echo ""
	fi
fi

#port 1433 ms-sql server banner grabbing
if [ $port = "1433" ]; then
	echo ""
	echo "grabbing MS-SQL Server banners..."
	echo ""
	if [ -f sweep.tmp ]
		then
		for i in $(cat sweep.tmp); do
			echo "     "$i
			echo "" >> "banner-grab.tmp"
			echo $i >> "banner-grab.tmp"
			nc -nnv -w2 $i 1433 2>&1 >> "banner-grab.tmp"
			echo "     ----------     " >> "banner-grab.tmp"
			trap "exit 4" 4
		done
	fi
fi

#port 3306 mysql server banner grabbing
if [ $port = "3306" ]; then
	echo ""
	echo "grabbing MySQL banners..."
	echo ""
	if [ -f sweep.tmp ]
		then
		for i in $(cat sweep.tmp); do
			echo "     "$i
			echo "" >> "banner-grab.tmp"
			echo $i >> "banner-grab.tmp"
			nc -nnv -w2 $i 3306 2>&1 >> "banner-grab.tmp"
			echo "     ----------     " >> "banner-grab.tmp"
			trap "exit 4" 4
		done
	fi
fi

#port 8080 HTTP banner grabbing
if [ $port = "8080" ]; then
	echo ""
	echo "grabbing HTTP 8080 banners..."
	echo ""
	if [ -f sweep.tmp ]
		then
		for i in $(cat sweep.tmp); do
			echo "     "$i
			echo "" >> "banner-grab.tmp"
			echo $i >> "banner-grab.tmp"
			echo -ne "HEAD / HTTP/1.0\n\n" | nc -nn -w2 $i 8080 2>&1 >> "banner-grab.tmp"
			echo "     ----------     " >> "banner-grab.tmp"
			trap "exit 4" 4
		done
		echo -e "Would you like to pull the source of discovered web pages? (y\n) \c"
		read choice
		if [ $choice = "y" ]; then
			echo ""
			echo "Pulling the source of discovered webpages"
			echo ""
			for i in $(cat sweep.tmp); do
				echo "     "$i
				echo "" >> "source.tmp"
				echo $i >> "source.tmp"
				curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)" -m 30 -s http://$i:8080 >> "source.tmp"
				echo "     ----------     " >> "source.tmp"
				trap "exit 4" 4
			done
		else
			echo "cool, moving on..."
		fi
	fi
fi

#port 8443 https source and cipher strength extraction
if [ $port = "8443" ]; then
	echo ""
	echo "Grabbing SSL certs..."
	if [ $choice = "1" ]; then
		echo "" >> "ssl.tmp"
		nmap --script ssl-cert -p 8443 -iL $file | sed -n '3,$p'| head -n -2 >> "ssl.tmp"
		echo "     ----------     " >> "ssl.tmp"
		trap "exit 4" 4
	else
		echo "" >> "ssl.tmp"
		nmap --script ssl-cert -p 8443 $network | sed -n '3,$p'| head -n -2 >> "ssl.tmp"
		echo "     ----------     " >> "ssl.tmp"
		trap "exit 4" 4
	fi
	echo ""
	echo -e "Would you like to pull the source from discovered hosts? (y/n) \c "
	read choice
	if [ $choice = y ]; then
		echo ""
		echo "Pulling the source of discovered https webpages..."
		echo ""
		for i in $(cat sweep.tmp); do
			echo "     "$i
			echo "" >> "source.tmp"
			echo $i >> "source.tmp"
			curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)" -m 30 -k -s https://$i:8443 >> "source.tmp"
			echo "     ----------     " >> "source.tmp"
			trap "exit 4" 4
		done
	else
		echo "cool, moving on..."
	fi
fi

#write banner, localhost IP and date to the report file
echo "" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
echo     "   __|  |                        __|                          " >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
echo     "  (     |   -_)   _' |    \    \__ \ \ \  \ /  -_)   -_)  _ \ " >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
echo     " \___| _| \___| \__,_| _| _|   ____/  \_/\_/ \___| \___| .__/ " >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
echo     "                                                        _|    " >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
echo     "                                                 version 1.74 " >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
echo     "                                          greg.foss@owasp.org " >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
echo "" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"

#format results and write output to file
echo "Scan Date: "`date '+%m%d%Y'` >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
echo "" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"

#portsweep
if 	[ $id = $port ]; then
	echo $hits" system(s) in the "$network" network block with Port "$port" open:" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	echo "" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	echo "---[IP Addresses  |  Hostnames  |  Server Banners]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	paste sweep.tmp sweep-systems.tmp service.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	echo "" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
fi

#pingsweep
if [ $id = "pingsweep" ]; then
	echo $hits" system(s) in the "$network" network block responded to ping requests:" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	echo "" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	echo "---[IP Addresses]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	paste sweep.tmp sweep-systems.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	echo "" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
fi

#append http headers if available
if [ $port = "21" ]; then
	echo "---[FTP Banners - Port 21]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	if [ -f banner-grab.tmp ]
		then
		cat banner-grab.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	fi
	echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
fi
if [ $port = "22" ]; then
	echo "---[SSH Banners - Port 22]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	if [ -f banner-grab.tmp ]
		then
		cat banner-grab.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	fi
	echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
fi
if [ $port = "23" ]; then
	echo "---[Telnet Banners - Port 23]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	if [ -f banner-grab.tmp ]
		then
		cat banner-grab.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	fi
	echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
fi
if [ $port = "25" ]; then
	echo "---[SMTP Banners - Port 25]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	if [ -f banner-grab.tmp ]
		then
		cat banner-grab.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	fi
	echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
fi
if [ $port = "80" ]; then
	echo "---[HTTP Banners - Port 80]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	if [ -f banner-grab.tmp ]
		then
		cat banner-grab.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
		echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	fi
	if [ -f source.tmp ]
		then
		echo "" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
		echo "---[HTTP Source - Port 80]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
		cat source.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
		echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	fi
fi
if [ $port = "101" ]; then
	echo "---[POP Mail Banners - Port 101]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	if [ -f banner-grab.tmp ]
		then
		cat banner-grab.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	fi
	echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
fi
if [ $port = "443" ]; then
	echo "---[HTTPS Certificate Information - Port 443]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	if [ -f ssl.tmp ]
		then
		cat ssl.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
fi
	if [ -f source.tmp ]
		then
		echo ""
		echo "---[HTTPS Source- Port 443]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
		cat source.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	fi
	echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
fi
if [ $port = "1433" ]; then
	echo "---[MS-SQL Server Banners - Port 1433]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	cat banner-grab.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
fi
if [ $port = "3306" ]; then
	echo "---[MySQL Banners - Port 3306]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	if [ -f banner-grab.tmp ]
		then
		cat banner-grab.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	fi
	echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
fi
if [ $port = "8080" ]; then
	echo "---[HTTP Banners - Port 8080]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	if [ -f banner-grab.tmp ]
		then
		cat banner-grab.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	fi
	echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	if [ -f source.tmp ]
		then
		echo "" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
		echo "---[HTTP Source - Port 8080]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
		cat source.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
		echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	fi
fi
if [ $port = "8443" ]; then
	echo "---[HTTPS Certificate Information - Port 8443]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	if [ -f ssl.tmp ]
		then
		cat ssl.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
		echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	fi
	if [ -f source.tmp ]
		then
		echo ""
		echo "---[HTTPS Source- Port 8443]---" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
		cat source.tmp >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
	fi
	echo "-----------------------------" >> ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
fi

#write output to screen
cat ""$id"--"$network"--"`date '+%m%d%Y'`".txt" | sed -n '13,$p'
echo ""
echo "     Scan results have been saved to ["$id"--"$network"--"`date '+%m%d%Y'`".txt]     "

#write output to DOS / Windows format so that your manager will be able to read the file ;-)
echo ""
unix2dos ""$id"--"$network"--"`date '+%m%d%Y'`".txt"
echo ""

#clean up and exit
if [ -f nmap.tmp ]
then
    rm nmap.tmp
fi
if [ -f sweep.tmp ]
then
    rm sweep.tmp
fi
if [ -f sweep-systems.tmp ]
then
    rm sweep-systems.tmp
fi
if [ -f service.tmp ]
then
    rm service.tmp
fi
if [ -f banner-grab.tmp ]
then
    rm banner-grab.tmp
fi
if [ -f source.tmp ]
then
    rm source.tmp
fi
if [ -f ssl.tmp ]
then
    rm ssl.tmp
fi

#end
exit 1
done
