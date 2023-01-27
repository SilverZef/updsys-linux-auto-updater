LogDisplay="/home/silveros/Scr/UPDSYS_Final/LogDisplay"

col1="\e[38;2;148;23;226m"		#purple by default 
col2="\e[38;2;65;220;76m"		#green by default
col3="\e[38;2;255;165;0m"		#orange by default(used for errors)
res="\e[0m"

path="Log.txt"

Remove() #saves/removes log file after updates, log file is used for progress report or error checking
{
	clear
	ch=""
	printf "${col1}Delete $1 Log File ? (y) [y/n/h]: $res"
	read ch
	ch=${ch,}  #Lower Casing ch

	if [[ "$ch" == "" || "$ch" == "y" ]] #as it is if-elif no return required but if expanded upon please add return after each recursive call
	then
		rm "$1_$path" 
	elif [[ "$ch" == "h" ]]
	then
		printf "$col1\nThe Default is y therefore Entering Nothing, y or Y will Remove $path"
		printf "\nEntering n or N will NOT Remove $path and will Save the Log File as $1_$path"
		printf "\nEntering h or H will Print this"
		sleep 6
		Remove "$1"		 #calls remove again to ask, i.e it keeps asking until a valid argument is entered
	elif [[ "$ch" != "n" ]]
	then
		printf "$col3\nInvalid Option See Options Within () or Enter h or H for Valid Options\n"
		sleep 3
		Remove "$1"
	fi
}

Update() #executes commands for repo updates
{
	clear    

	comm1="sudo zypper refresh"
	comm2="sudo zypper dup -y --allow-vendor-change --force-resolution" 
	comm3="sudo flatpak update -y"
	if [[ "$1" == "Zypper" ]]
	then
		printf "\e[1;1f${col2}Status:$col1 Zypper Refresh Begun!"
		printf "\e[5;1f${col2}Running: $col1$comm1"
		printf "\e[7;1f${col3}ERRORS: \e[8;1f"
		$comm1 > "$1_$path"
		clear
		printf "\e[1;1f${col2}Status:$col1 Zypper Upgrade Begun!"
		printf "\e[5;1f${col2}Running: $col1$comm2"
		printf "\e[7;1f${col3}ERRORS: \e[8;1f"
		$comm2 >> "$1_$path"
		printf "\e[1;1f${col2}Status:$col1 Finished Zypper Upgrade!!\e[8;1f"
	elif [[ "$1" == "Flatpak" ]]
	then
		printf "\e[1;1f${col2}Status:$col1 Flatpak Update Begun!"
		printf "\e[5;1f${col2}Running: $col1$comm3"
		printf "\e[7;1f${col3}ERRORS: \e[8;1f"
		$comm3 > "$1_$path"
		printf "\e[1;1f${col2}Status:$col1 Finished Flatpak Update !!\e[8;1f"
	fi
	echo -e "\nUPGRADE_FINISHED" >> "$1_$path" #USED AS A SIGNAL FOR LOGDISPLAY TO EXIT
}

Run() #Calls the neccessary functions for each updates
{
	declare -i index=0 #makes sure a new file is created to not erase previous update logs
	while [ -e "$1_$path" ]
	do
		path="Log_$index.txt"
		index+=1
	done
	
	Update "$1" &
	$LogDisplay "$1_$path" &
	wait
}

killgroup()#function used to kill all running commands and scripts
{
	echo -e "${col3}EXITING ... $res"
	rm "Zypper_$path"
	rm "Flatpak_$path"
	kill 0
}

trap killgroup SIGINT #SIGINT represents ctrl + c, so this redirects to killgroup function whenever ctrl-c is pressed

#Translates user entered arguments into usable arguments for each function
arg1=""
arg2=""	
if [[ "$1" == "0" || "$1" == "a" || "$1" == "A" || "$1" == "z" || "$1" == "Z" || "$1" == "1" ]]
then
	arg1="Zypper"
fi
if [[ "$1" == "f" || "$1" == "F" || "$1" == "2" ]]
then
	arg1="Flatpak"
fi
if [[ "$1" == "0" || "$1" == "a" || "$1" == "A" || "$2" == "f" || "$2" == "F" ]]
then
	arg2="Flatpak"
fi
if [[ "$2" == "z" || "$2" == "Z" ]]
then
	arg2="Zypper"
fi
if [[ "$arg1" == "" && "$arg2" == "" ]] #if there are no upgrades to be conducted i.e invalid args are entered it prints this
then
	printf "$col1  *********************HELP*********************\n"
	printf "$col2 |                Valid Arguments               |\n"
	printf "$col1 |----------------------------------------------|\n"
	printf "$col2 |         0 or a or A for Both Updates         |\n"
	printf "$col2 |z and f in your Preferred Order to Update Both|\n"
	printf "$col2 |        1 or z or Z for Zypper Update         |\n"
	printf "$col2 |      2 or f or F for Flatpak Update          |\n"
	printf "$col3 |    Any Other Configuration for this Screen   |\n"
	printf "$col1  ********************************************** $res\n"
	exit 1
fi

clear

printf "${col1}Super User Access Required Enter Password: $col2\n"
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

if [[ "$arg1" != "" ]]
then
	Run "$arg1"
fi
if [[ "$arg2" != "" ]]
then
	Run "$arg2"
fi
if [[ "$arg1" != "" ]]
then
	Remove "$arg1"
fi
if [[ "$arg2" != "" ]]
then
	Remove "$arg2"
fi

exit 0
