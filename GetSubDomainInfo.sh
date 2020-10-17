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
echo "                                                                                 |                            |"
echo "                                                                                 | V1.6 By Anthony & Jonathan |"
echo "                                                                                 |____________________________|"
echo ""
}

install_packages(){


	cat /etc/os-release |grep "arch" 2> /dev/null > /dev/null #Check si l'OS est de type Arch Linux
	if [ $? -eq 0 ]; then
		
		pacman -Qi dnsutils nmap whois 2>/dev/null > /dev/null
		if [ $? -eq 0 ]; then
			echo -e "	${GREEN}Dependances => OK${NOCOLOR}"
			echo ""
			return 0
		
		else
			echo -e "${YELLOW}Installation des dépendances en cours...${NOCOLOR}"
			sudo pacman --noconfirm -S 'bind' nmap whois 2>/dev/null > /dev/null
			if [ $? -eq 0 ]; then
				
				echo -e "	${GREEN}Dépendances => installées${NOCOLOR}"
				echo ""
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
			echo ""
			return 0
		
		else
    
		echo -e "${YELLOW}Installation des dépendances en cours...${NOCOLOR}"
		sudo apt update 2>/dev/null > /dev/null && sudo apt install -y dnsutils nmap whois 2>/dev/null > /dev/null
			if [ $? -eq 0 ]; then
				echo -e "	${GREEN}Dépendances => installées${NOCOLOR}"
				echo ""
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

	IP=$(timeout --foreground 5 nslookup $1 | tail -2 | cut -d' ' -f 2)
	if [[ $IP =~ ((^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$)) ]]; then
		echo ""
		echo -e "	${GREEN}[+]${NOCOLOR} IP : $IP"
		return 0
	elif [[ $IP =~ (([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])) ]]; then
		ipv6=1
		echo ""
		echo -e "	${GREEN}[+]${NOCOLOR} IP : $IP"
		return 0
	else
		echo ""
		echo -e "${RED}Impossible d'obtenir l'IP${NOCOLOR}"
		exit 1
	fi

}

getMailServers(){

	MX=$(host -t mx $1 |cut -d' ' -f 7 | sed 's/.$//' | sed 's/^/\t/')
	echo "$MX"


}


getSubdomains(){

	tput sc
	echo -e "${RED}Attention cela va utiliser une wordlist, si vous voulez continuer appuyez sur 'o'${NOCOLOR}"
	read reponse
	tput cuu1
	tput el
	tput cuu1
	tput el
	if [ "$reponse" == "o" ]; then
		file='./Subdomain.txt'

		while read -r line; do
			ndd="${line}.$1"
			result=$(nslookup $ndd 2>/dev/null)

			echo $result | grep "can't find" 2>/dev/null > /dev/null
			if [ $? -eq 1 ]; then
				IP_subdomain=$(echo $result | rev | cut -d" " -f1 |rev )
				echo -e "\t${YELLOW}$ndd: ${NOCOLOR} $IP_subdomain"
			fi
		done < $file
	fi




}



getPorts(){

	if [ "$ipv6" != 1 ]; then
		nmap -F $1 | grep "tcp\|udp" | grep "open" | sed 's/^/\t/'
	
	elif [ "$ipv6" == 1 ]; then
		nmap -6 -F $1 | grep "tcp\|udp" | grep "open" | sed 's/^/\t/'
	fi
}


locateIP(){

	localisation=$(timeout --foreground 5 curl -s http://ip-api.com/json/$IP)
	
	if [ "$localisation" != *"fail"* ]; then
		localisation=$(echo $localisation | grep -Eo "city.*" | cut -d'"' -f 3)

			if [ -z "$localisation" ]; then
				
				echo -e "	${RED}[-]${NOCOLOR} Localisation indisponible"
				return 0

			else
				echo -e "	${GREEN}[+]${NOCOLOR} Localisation : $localisation"
				return 0
			fi
	else
		return 1
	fi
	
}







init
if [[ $# -ne 1 ]]; then
	
	echo -e "${RED}Vous devez passer le nom de domaine en argument${NOCOLOR}"
	echo -e "${YELLOW}Exemple: ./GetSubDomainInfo exemple.com${NOCOLOR}"
	exit 1
fi 
echo -e "${YELLOW}Verification des dependances...${NOCOLOR}" && install_packages
getWordlist
echo -en "${YELLOW}\nRésolution de ${GREEN}$1${NOCOLOR}" && getIP $1 && locateIP
echo -e "${YELLOW}\nListe des serveurs mails : ${NOCOLOR}" && getMailServers $1
echo -e "${YELLOW}\nListe des ports ouvert : ${NOCOLOR}" && getPorts $IP
echo -e "${YELLOW}\nSous domaines pour ${GREEN}$1${NOCOLOR} : ${NOCOLOR}" && getSubdomains $1
