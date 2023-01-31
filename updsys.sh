col1="\e[38;2;148;23;226m"		# Purple by default 
col2="\e[38;2;65;220;76m"		# Green by default
col3="\e[38;2;255;165;0m"		# Orange by default(used for errors)
res="\e[0m"				# Used to reset every active ansi sequence(usually colors)

RecordName="Log"

Update1="Zypper"
Update2="Flatpak"

Remove()	# Saves/removes log file after updates, log file is used for progress report or error checking
{
	clear
	ch=""
	printf "${col1}Delete $1 Update Record ? (y) [y/n/h]: $res"
	read ch
	ch=${ch,}  #Lower Casing ch

	if [[ "$ch" == "" || "$ch" == "y" ]]	# Contains Recursive calls add return if there is any code beyond if-elif
	then
		rm "$1_${RecordName}.txt" 
	elif [[ "$ch" == "h" ]]
	then
		printf "$col1\nThe Default is y therefore Entering Nothing, y or Y will Remove $1 Record"
		printf "\nEntering n or N will NOT Remove $1 Record and will Save the $1 Record"
		printf "\nEntering h or H will Print this"
		sleep 7
		Remove "$1"		 
	elif [[ "$ch" != "n" ]]
	then
		printf "$col3\nInvalid Option See Options Within [] or Enter h or H for Valid Options\n"
		sleep 4
		Remove "$1"
	fi
}

Update()	# Executes commands for repo updates
{
	clear    
	
	comm1="zypper refresh ; zypper dup -y --allow-vendor-change --force-resolution" 
	comm2="flatpak update -y"
	CommToRun=""
	
	printf "\e[1;1f${col2}Status:$col1 $1 Upgrade Begun!"
	printf "\e[7;1f${col3}ERRORS: \e[8;1f"

	if [[ "$1" == "$Update1" ]]
	then
		CommToRun="$comm1"
	elif [[ "$1" == "$Update2" ]]
	then
		CommToRun="$comm2"
	fi

	printf "\e[5;1f${col2}Running: $col1$CommToRun"
	eval "$CommToRun" > "$1_${RecordName}.txt"			# eval and () combines all commands within CommToRun in a single process and pipes them to update record
	printf "\e[1;1f${col2}Status:$col1 Finished $2 Update !!\e[8;1f"
	echo -e "\nUPGRADE_FINISHED" >> "$1_${RecordName}.txt"		# Writes 'UPGRADE_FINISHED' to update record to signal to WriteProgress() to Stop
}

WriteProgress()	# Writes 'Progress: ' Section by reading update records
{
	Terminator="UPGRADE_FINISHED"
	Progress=" "
	GoThirdRow="\e[3;1f" 	  
	ClearLine="\e[2K"         
	ResetCursor="\e[8;1f"     
	
	while [ "$Progress" != "$Terminator" ]
	do
		declare -i Prog_Len=$(tput cols)-10			# Allowable Length for Progress is equal to terminal width - 10(length of displayed 'Progress: ')
		Progress=$(tail -n 1 "$1_${RecordName}.txt")		# Gets Last Line from update record
		printf "\n$GoThirdRow$ClearLine"			# '\n' acts as if printf was flushed before printing (Hopefully!) 
		printf "${col2}Progress: $col1${Progress:0:$Prog_Len}"
		printf "$ResetCursor$col3"
	done
}

Run()	# Calls the neccessary functions for each updates
{
	OriginalRecordName="$RecordName"
	declare -i index=1				# Makes sure the current update isnt writing into an already existing update record
	while [ -e "$1_${RecordName}.txt" ]
	do
		RecordName="${OriginalRecordName}_${index}"
		index+=1
	done
	
	Update "$1" &
	WriteProgress "$1" &
	wait
}

Center()
{
	printf "$2"										# $2 Represents Initiater i.e string before centered string
	declare -i NoSpaces=$(( $(( $4 - ${#1} )) / 2 ))
	Spaces=`printf '%*s' "$NoSpaces" | tr ' ' " "`		# Copied, essentially it stores NoSpaces number of " " in Spaces
	printf "$Spaces$1$Spaces"				# Prints $1 with padding(known as spaces) i.e it centers the given string
	if [[ $(( 2 * $NoSpaces + ${#1} )) != $4 ]]		# Prints an extra space which might have been lost in integer / 2
	then
		printf " "
	fi
	printf "$3\n"									# $3 Represents Terminator i.e string after centered string
}

killgroup()
{
	echo -e "${col3}EXITING ... $res"
	kill 0
}
trap killgroup SIGINT			# SIGINT represents ctrl + c, so this redirects to killgroup function whenever ctrl-c is pressed

# Translates user entered arguments into usable arguments for each function
arg1=""
arg2=""	
if [[ "$1" == "0" || "$1" == "1" ]]
then
	arg1="$Update1"
fi
if [[ "$1" == "2" ]]
then
	arg1="$Update2"
fi
if [[ "$1" == "0" || "$2" == "2" ]]
then
	arg2="$Update2"
fi
if [[ "$2" == "1" ]]
then
	arg2="$Update1"
fi
if [[ "$arg1" == "" && "$arg2" == "" ]] 
then
	printf "$col1  *********************HELP*********************\n"
	Center "Valid Arguments" "$col2 |" "|" 46 
	printf "$col1 |----------------------------------------------|\n"
	Center "0 for Both Updates" "$col2 |" "|" 46
	Center "1 and 2 in your Preferred Order to Update Both" "$col2 |" "|" 46
	Center "1 for $Update1 Update" "$col2 |" "|" 46
	Center "2 for $Update2 Update" "$col2 |" "|" 46
	Center "Any Other Configuration for this Screen" "$col3 |" "|" 46
	printf "$col1  ********************************************** $res\n"
    exit 1
fi

printf "${col1}Super User Access Required Enter Password: $col2\n"
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

clear

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
