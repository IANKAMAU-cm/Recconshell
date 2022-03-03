#!/bin/bash

domain=$1
RED="\033[1;31m"
RESET="\033[0m"

info_path=$domain/info
subdomain_path=$domain/subdomains
nmap_path=$domain/nmapscan

if [ ! -d "$domain" ];then
    mkdir $domain
fi

if [ ! -d "$info_path" ];then
    mkdir $info_path
fi

if [ ! -d "$subdomain_path" ];then
    mkdir $subdomain_path
fi

if [ ! -d "$nmap_path" ];then
    mkdir $nmap_path
fi

echo -e "${RED} [+] Checking Whois info.... ${RESET}"
whois $1 > $info_path/whois.txt

echo -e "${RED} [+] Launching subfinder.... ${RESET}"
subfinder -d $domain > $subdomain_path/found.txt

echo -e "${RED} [+] Running assetfinder.... ${RESET}"
assetfinder $domain | grep $domain >> $subdomain_path/found.txt

#echo -e "${RED} [+] Running amass!Grab a coffee.... ${RESET}"
#amass enum -d $domain >> $subdomain_path/found.txt

echo -e "${RED} [+] Checking whats alive.... ${RESET}"
cat $subdomain_path/found.txt | grep $domain | sort -u | httprobe | tee -a $subdomain_path/alive.txt

cat $subdomain_path/alive.txt | sort -u | sed -e 's/^http:\/\///g' -e 's/^https:\/\///g' | tee -a $subdomain_path/alive2.txt

echo -e "${RED} [+] Starting nmap.... ${RESET}"
nmap -sV -iL $subdomain_path/alive2.txt > $nmap_path/scans.txt