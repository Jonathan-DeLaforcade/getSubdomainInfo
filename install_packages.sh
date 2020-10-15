install_packages(){


	cat /etc/os-release |grep "arch" 2> /dev/null > /dev/null #Check si l'OS est de type Arch Linux
	if [ $? -eq 0 ]; then
		
		pacman -Qi dnsutils nmap 2>/dev/null >/dev/null
		if [ $? -eq 0 ]; then
			echo -e "	${GREEN}Dependances => OK${NOCOLOR}"
			return 0
		
		else

		sudo pacman --noconfirm -S 'bind' nmap 2>/dev/null >/dev/null
			if [ $? -eq 0 ]; then
				
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
		
		dpkg -l dnsutils nmap 2>/dev/null >/dev/null
		if [ $? -eq 0 ]; then
			echo -e "	${GREEN}Dépendances => OK${NOCOLOR}"
			return 0
		
		else

		sudo apt update && sudo apt install dnsutils nmap 2>/dev/null >/dev/null
			if [ $? -eq 0 ]; then
				
				echo -e "	${GREEN}Dépendances => installées${NOCOLOR}"
				return 0
			else
				echo -e "${RED}Erreur lors de l'installation des dépendences${NOCOLOR}"
				exit 1
			fi
		fi
	
	fi


}
