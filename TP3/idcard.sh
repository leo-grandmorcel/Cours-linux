#!/usr/bin/env bash

echo "Machine name : $(hostname)"
echo "OS $(head -n 1 /etc/os-release | cut -d'"' -f2) and kernel version is $(uname -r)"
echo "IP : $(hostname -I | cut -d" " -f2)"
echo "RAM : $(free --mebi | grep Mem: | tr -s " " | cut -d" " -f3)Mebi / $(free --mebi | grep Mem: | tr -s " " | cut -d" " -f2)Mebi"
echo "Disque : $(df /dev/sda5 -h | tail -n 1 | tr -s " " | cut -d" " -f4 | rev | cut -c 2- | rev)Go Left"
echo "Top 5 processes by RAM usage : "
ps -o %mem,pid,command ax | sort -b -k1 -r | head -n 6 | tail -n 5 | tr -s " " | cut -d" " -f3-4 > /tmp/listProcess
for ((i = 1 ; i <= $(cat /tmp/listProcess | wc -l); i++)); do
	echo "- ""$(head -n $i /tmp/listProcess | tail -n 1)"
done


ss -H -ltpn | tr -s " " | cut -d" " -f4 | rev | cut -d":" -f1 |rev > /tmp/listeningPort
ss -H -ltpn | tr -s " " | cut -d" " -f6 | cut -c 10- | cut -d'"' -f1 > /tmp/portToProcess
echo "Listening ports : "
for ((i = 1 ; i <= $(cat /tmp/listeningPort | wc -l); i++)); do
		echo "- """$(head -n $i /tmp/listeningPort | tail -n 1)"" : ""$(head -n $i /tmp/portToProcess | tail -n 1)""	
done

echo
echo "Here's your random cat : $(curl -s https://api.thecatapi.com/v1/images/search | cut -d"," -f3 | cut -d'"' -f4)"

sudo rm /tmp/portToProcess 
sudo rm /tmp/listeningPort
sudo rm /tmp/listProcess
