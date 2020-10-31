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
echo "                                                                                 | V1.8 By Anthony & Jonathan |"
echo "                                                                                 |____________________________|"
echo ""
}


install_packages(){

	YUM_PM=$(which yum 2>/dev/null)
  	APT_PM=$(which apt-get 2>/dev/null)
  	PACMAN_PM=$(which pacman 2>/dev/null)
	ARCH=$(lscpu -J |grep "Architecture" |cut -d'"' -f 8)
	
	PACKAGE_LIST="dnsutils nmap whois jq"
	
	CHECK_ANDROID=$(uname -a |cut -d' ' -f 14)
	
	if [[ ! -z $YUM_PM ]]; then #Check si le gestionnaire de paquet est YUM
		echo "YUM NOT SUPPORTED"
		exit 1
    	
	elif [[ ! -z $APT_PM ]]; then #Check si le gestionnaire de paquet est APT
		
		CHECK_COMMAND="dpkg -s $PACKAGE_LIST 2>/dev/null > /dev/null"
		INSTALL_COMMAND="sudo apt update 2>/dev/null > /dev/null && sudo apt install -y $PACKAGE_LIST 2>/dev/null > /dev/null"
		
	elif [[ ! -z $PACMAN_PM ]]; then #Check si le gestionnaire de paquet est PACMAN
		
		CHECK_COMMAND="pacman -Qi $PACKAGE_LIST 2>/dev/null > /dev/null"
		INSTALL_COMMAND="sudo pacman -S --noconfirm $PACKAGE_LIST 2>/dev/null > /dev/null"
		
    	fi

	if [ "$ARCH" == "aarch64" ] && [ "$CHECK_ANDROID" == "Android" ]; then # Permet de rendre les appareils Android sous Termux compatibles
		PACKAGE_LIST="dnsutils nmap inetutils ncurses-utils jq"
		CHECK_COMMAND="dpkg -s $PACKAGE_LIST 2>/dev/null > /dev/null"
		INSTALL_COMMAND="apt update 2>/dev/null > /dev/null && apt install -y $PACKAGE_LIST 2>/dev/null > /dev/null"


	fi



	eval $CHECK_COMMAND #Check si les packages sont installés
	if [ $? -eq 0 ]; then
			
		echo -e "	${GREEN}Dépendances => OK${NOCOLOR}"
		echo ""
		return 0
		
	else
		
		echo -e "${YELLOW}Installation des dépendances en cours...${NOCOLOR}"

		eval $INSTALL_COMMAND #Installe les packages
		if [ $? -eq 0 ]; then
			echo -e "	${GREEN}Dépendances => installées${NOCOLOR}"
			echo ""
			return 0
		else
			echo -e "${RED}Erreur lors de l'installation des dépendences${NOCOLOR}"
			exit 1
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

getIPandLocate(){
	echo ""
	Liste_IPV4=($(nslookup $1 |grep "Address" |cut -d' ' -f2 | grep -E "(([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$))"))
	Liste_IPV6=($(nslookup $1 |grep "Address" |cut -d' ' -f2 | grep -E "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))"))
	echo ""
	for IPV4 in "${Liste_IPV4[@]}"
		do
			localisation_json=$(timeout --foreground 5 curl -s http://ip-api.com/json/$IPV4)
			pays=$(echo $localisation_json | jq -r '.country')
			region=$(echo $localisation_json | jq -r '.region')
			ville=$(echo $localisation_json | jq -r '.city')
			CP=$(echo $localisation_json | jq -r '.zip')
			echo -e "	${GREEN}[+]${NOCOLOR} IPV4 : ${GREEN}$IPV4${NOCOLOR}"
			
			if [ "$localisation_json" == *"fail"* ]; then
				echo -e "		${YELLOW}[+]${NOCOLOR} Localisation : ${RED}Indisponible${NOCOLOR}"
				echo ""
				
			elif [ "$localisation_json" == "" ]; then
				echo -e "		${YELLOW}[+]${NOCOLOR} Localisation : ${RED}Indisponible${NOCOLOR}"
				echo ""
			
			else
				echo -e "		${YELLOW}[+]${NOCOLOR} Pays : ${GREEN}$pays${NOCOLOR}"
				echo -e "		${YELLOW}[+]${NOCOLOR} Region : ${GREEN}$region${NOCOLOR}"
				echo -e "		${YELLOW}[+]${NOCOLOR} Ville : ${GREEN}$ville${NOCOLOR}"
				echo -e "		${YELLOW}[+]${NOCOLOR} CP : ${GREEN}$CP${NOCOLOR}"
				echo ""
			fi

		done

	for IPV6 in "${Liste_IPV6[@]}"
		do
			localisation_json=$(timeout --foreground 5 curl -s http://ip-api.com/json/$IPV6)
			pays=$(echo $localisation_json | jq -r '.country')
			region=$(echo $localisation_json | jq -r '.region')
			ville=$(echo $localisation_json | jq -r '.city')
			CP=$(echo $localisation_json | jq -r '.zip')
			echo -e "	${GREEN}[+]${NOCOLOR} IPV6 : ${GREEN}$IPV6${NOCOLOR}"
			
			if [ "$localisation_json" == *"fail"* ]; then
				echo -e "		${YELLOW}[+]${NOCOLOR} Localisation : ${RED}Indisponible${NOCOLOR}"
				echo ""
				
			elif [ "$localisation_json" == "" ]; then
				echo -e "		${YELLOW}[+]${NOCOLOR} Localisation : ${RED}Indisponible${NOCOLOR}"
				echo ""
			
			else
				echo -e "		${YELLOW}[+]${NOCOLOR} Pays : ${GREEN}$pays${NOCOLOR}"
				echo -e "		${YELLOW}[+]${NOCOLOR} Region : ${GREEN}$region${NOCOLOR}"
				echo -e "		${YELLOW}[+]${NOCOLOR} Ville : ${GREEN}$ville${NOCOLOR}"
				echo -e "		${YELLOW}[+]${NOCOLOR} CP : ${GREEN}$CP${NOCOLOR}"
				echo ""
			fi
		done
}

getMailServers(){

	MX=$(host -t mx $1 |cut -d' ' -f 7 | sed 's/.$//' | sed 's/^/\t/')
	echo "$MX"


}


getSubdomains(){

	tput sc
	echo -e "${RED}Attention, une wordlist va être utilisée. Souhaitez-vous continuer ? ${YELLOW}(o/n)${NOCOLOR}"
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
	else
		echo -e "	${RED}Scan des sous domaines annulé${NOCOLOR}"
		return 0
	fi




}



getPorts(){

	for IPV4 in "${Liste_IPV4[@]}"
		do
			
			echo -e "${GREEN}[+]${NOCOLOR} Ports ouverts sur l'IP ${GREEN}${IPV4}${NOCOLOR} : " && nmap -F $IPV4 | grep "tcp\|udp" | grep "open" | sed 's/^/\t/'
			echo ""
		done

	for IPV6 in "${Liste_IPV6[@]}"
		do
			echo -e "${GREEN}[+]${NOCOLOR} Ports ouverts sur l'IP ${GREEN}${IPV6}${NOCOLOR} : " && nmap -6F $IPV6 | grep "tcp\|udp" | grep "open" | sed 's/^/\t/'
			echo ""
		done

}


init
if [[ $# -ne 1 ]]; then
	
	echo -e "${RED}Vous devez passer le nom de domaine en argument${NOCOLOR}"
	echo -e "${YELLOW}Exemple: ./GetSubDomainInfo exemple.com${NOCOLOR}"
	exit 1
fi 
echo -e "${YELLOW}Verification des dependances...${NOCOLOR}" && install_packages
getWordlist
echo -en "${YELLOW}\nRésolution DNS de ${GREEN}$1${NOCOLOR}${YELLOW}...${NOCOLOR}" && getIPandLocate $1
echo -e "${YELLOW}\nListe des serveurs mails : ${NOCOLOR}" && getMailServers $1
echo -e "${YELLOW}\nListe des ports ouvert : ${NOCOLOR}" && getPorts $IPV4 $IPV6
echo -e "${YELLOW}\nSous domaines pour ${GREEN}$1${NOCOLOR} : ${NOCOLOR}" && getSubdomains $1
