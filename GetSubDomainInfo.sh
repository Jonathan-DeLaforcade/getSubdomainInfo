#!/bin/bash

NOCOLOR='\033[0m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
GREEN='\033[1;32m'

init(){
clear
echo "  ____________________________________________________________________________________________________________ "
echo " |    ___       _          _____       _     ____                         _             _____        __       |"
echo " |  / ____|    | |        / ____|     | |   |  __ \                      (_)           |_   _|      / _|      |"
echo " | | |  __  ___| |_      | (___  _   _| |__ | |  | | ___  _ __ ___   __ _ _ _ __         | |  _ __ | |_ ___   |"
echo " | | | |_ |/ _ \ __|      \___ \| | | | '_ \| |  | |/ _ \| __   _ \ / _  | |  _ \        | | |  _ \|  _/ _ \  |"
echo " | | |__| |  __/ |_       ____) | |_| | |_) | |__| | (_) | | | | | | (_| | | | | |      _| |_| | | | |  (_) | |"
echo " |  \_____|\___|\__|     |_____/ \____|____/|_____/ \___/|_| |_| |_|\____|_|_| |_|     |_____|_| |_|_| \___/  |"
echo " |____________________________________________________________________________________________________________|"
echo "                                                                                   |                          |"
echo "                                                                                   | V1 By Anthony & Jonathan |"
echo "                                                                                   |__________________________|"
echo ""
}

install_packages(){


	cat /etc/os-release |grep "arch" 2> /dev/null > /dev/null #Check si l'OS est de type Arch Linux
	if [ $? -eq 0 ]; then
		
		pacman -Qi dnsutils nmap whois 2>/dev/null > /dev/null
		if [ $? -eq 0 ]; then
			
			echo -e "	${GREEN}Dependances => OK${NOCOLOR}"
			return 0
		
		else

		sudo pacman --noconfirm -S 'bind' nmap whois > /dev/null
			if [ $? -eq 0 ]; then
				clear
				echo -e "	${GREEN}Dépendances => installées${NOCOLOR}"
				return 0
			else
				echo -e "${RED}Erreur lors de l'installation des dépendences${NOCOLOR}"
				exit 1
			fi
		fi
	
	fi

	cat /etc/os-release |grep "Ubuntu\|debian" 2> /dev/null > /dev/null #Check si l'OS est de type Ubuntu
	if [ $? -eq 0 ]; then
		
		dpkg -s dnsutils nmap whois 2>/dev/null > /dev/null
		if [ $? -eq 0 ]; then
			
			echo -e "	${GREEN}Dépendances => OK${NOCOLOR}"
			return 0
		
		else

		sudo apt update > /dev/null && sudo apt install -y dnsutils nmap whois > /dev/null
			if [ $? -eq 0 ]; then
				
				clear
				echo -e "	${GREEN}Dépendances => installées${NOCOLOR}"
				return 0
			else
				echo -e "${RED}Erreur lors de l'installation des dépendences${NOCOLOR}"
				exit 1
			fi
		fi
	
	fi


}

getWordlist(){
	if [ -f Subdomain.txt ]; then
		echo -e "${YELLOW}Mise a jour de la wordlist...${NOCOLOR}"
		rm Subdomain.txt
	else
		echo -e "${YELLOW}Telechargement de la wordlist...${NOCOLOR}"
	fi
	wget https://raw.githubusercontent.com/Jonathan-DeLaforcade/getSubdomainInfo/main/Subdomain.txt 2>/dev/null&
	wait
	if [ -f Subdomain.txt ]; then
		echo -e "	${GREEN}Wordlist => OK ${NOCOLOR}"
	fi
}

getIP(){

	IP=$(nslookup $1 | tail -2 | cut -d' ' -f 2)
	echo $IP

}

getMailServers(){

	MX=$(host -t mx $1 |cut -d' ' -f 7 | sed 's/.$//')
	echo "$MX"


}


getSubdomains(){

	echo -e "${RED}attention cela va utiliser une wordlist, si vous voulez continuer appuyez sur o${NOCOLOR}"
	read reponse

	if [ "$reponse" == "o" ]; then
		file='./Subdomain.txt'

		while IFS='\n' read -r line; do
			ndd="${line}.$1"
			result=$(nslookup $ndd 2>/dev/null)

			echo $result | grep "can't find" 2>/dev/null > /dev/null
			if [ $? -eq 1 ]; then
				IP_subdomain=$(echo $result | rev | cut -d" " -f1 |rev )
				echo -e "${YELLOW}$ndd: ${NOCOLOR} $IP_subdomain"
			fi
		done < $file
	fi




}



getPorts(){
	nmap -F $1 | grep "tcp\|udp" | grep "open"
}


init
if [[ $# -ne 1 ]]; then
	
	echo -e "${RED}Vous devez passer le nom de domaine en argument${NOCOLOR}"
	echo -e "${YELLOW}Exemple: ./GetSubDomainInfo exemple.com${NOCOLOR}"
	exit 1
fi 
echo -e "${YELLOW}Verification des dependances...${NOCOLOR}" && install_packages
getWordlist
echo -en "${YELLOW}\nAdresse IP du domaine ${GREEN}$1${NOCOLOR} : ${NOCOLOR}" && getIP $1
echo -e "${YELLOW}\nListe des serveurs mails : ${NOCOLOR}" && getMailServers $1
echo -e "${YELLOW}\nListe des ports ouvert : ${NOCOLOR}" && getPorts $1
echo -e "${YELLOW}\nSous domaines pour ${GREEN}$1${NOCOLOR} : ${NOCOLOR}" && getSubdomains $1
