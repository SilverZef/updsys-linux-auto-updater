col1="\e[38;2;148;23;226m"		# Purple by default 
col2="\e[38;2;65;220;76m"		# Green by default
col3="\e[38;2;255;165;0m"		# Orange by default(used for errors)
res="\e[0m"                             # Used to reset every active ansi sequence(usually colors)
TERMINATOR="UPGRADE_FINISHED"           # Signal sent by Update() to Update Record and then read by WriteProgress(), Terminates WriteProgress() once read

BaseName="Log" 		# Common base name used by each Update Record
RecordNames=("$BaseName.txt" "$BaseName.txt") # Stores the names of all update Records

Update1="Zypper"
Update2="Flatpak"

Remove()	# Prompts to Remove update records after updates, $1 is Update Name, $2 is the Update Order
{
	clear
	ch=""
	printf "%b" "${col1}Delete $1 Update Record: ${RecordNames[$2]}? (y) [y/n/h]: $res"
	read -r ch
	ch=${ch,}  #Lower Casing ch

	if [[ "$ch" == "" || "$ch" == "y" ]]    # Contains Recursive calls add return if there is any code beyond if-elif
	then
		rm "${RecordNames[$2]}" 	# It uses $2 to access the update record for the given update
	elif [[ "$ch" == "h" ]]
	then
		printf "%b\n" "$col1\nThe Default is y therefore Entering Nothing, y or Y will Remove $1 Record"
		printf "%b\n" "Entering n or N will NOT Remove $1 Record and will Save the $1 Record"
		printf "%b\n" "Entering h or H will Print this"
		sleep 7
		Remove "$1"	"$2"	 
	elif [[ "$ch" != "n" ]]
	then
		printf "%b\n" "$col3\nInvalid Option See Options Within [] or Enter h or H for Valid Options"
		sleep 4
		Remove "$1" "$2"
	fi
}

Update()	# Executes commands for repo updates stores in a update record, $1 is update name, $2 is update record
{
	clear    
	
	comm1="zypper refresh ; zypper dup -y --allow-vendor-change --force-resolution" 
	comm2="flatpak update -y"
	CommToRun=""
	
	printf "%b" "\e[1;1f${col2}Status:$col1 $1 Upgrade Begun!"
	printf "%b" "\e[7;1f${col3}ERRORS: \e[8;1f"

	if [[ "$1" == "$Update1" ]]
	then
		CommToRun="$comm1"
	elif [[ "$1" == "$Update2" ]]
	then
		CommToRun="$comm2"
	fi

	printf "%b" "\e[5;1f${col2}Running: $col1$CommToRun"
	eval "$CommToRun" > "$2"						# eval combines all commands within CommToRun in a single process and pipes them to update record
	printf "%b" "\e[1;1f${col2}Status:$col1 Finished $1 Update !!\e[8;1f"
	printf "%s\n" "$TERMINATOR" >> "$2"					# Writes Variable TERMINATOR to update record to signal to WriteProgress() to Stop
}

WriteProgress()	# Writes 'Progress: ' Section by reading update records, $1 is update record 
{
	Progress=" "
	GoThirdRow="\e[3;1f" 	  
	ClearLine="\e[2K"         
	ResetCursor="\e[8;1f"
	
	while [ "$Progress" != "$TERMINATOR" ]
	do
		Prog_Len=$(tput cols)-10				# Allowable Length for Progress is equal to terminal width - 10(length of displayed 'Progress: ')
		Progress=$(tail -n 1 "$1")				# Gets Last Line from update record
		printf "%b" "$GoThirdRow$ClearLine${col2}Progress: $col1${Progress:0:$Prog_Len}$ResetCursor$col3"
	done
}

Run()	# Calls the neccessary functions for each updates, $1 is the update to be done and $2 is the update order
{
		
	declare -i index=1			# Makes sure the current update isnt writing into an already existing update record
	while [ -e "$1_${RecordNames[$2]}" ]    # Checks if the current record name exists
	do
		RecordNames[$2]="${BaseName}_${index}.txt"
		index+=1
	done
	RecordNames[$2]="$1_${RecordNames[$2]}" # Adds $1 permenantly to the record as we know it doesnt exist
	
	Update "$1" "${RecordNames[$2]}" &
	WriteProgress "${RecordNames[$2]}" &
	wait
}

Center() # $1 is the string to be printed at the start, $2 is the string to be centered, $3 is the string to be printed at the end, $4 is the width within which the string should be centered
{
	printf "%b" "$1"
	declare -i NoSpaces=$(( $(( $4 - ${#2} )) / 2 ))
	Spaces=$(printf '%*s' "$NoSpaces" | tr ' ' " ")	                # Copied, essentially it stores NoSpaces number of " " in Spaces
	printf "%s" "$Spaces$2$Spaces"					# Prints $1 with padding(known as spaces) i.e it centers the given string
	if [[ $(( 2 * NoSpaces + ${#2} )) != "$4" ]]		        # Prints an extra space which might have been lost in integer / 2
	then
		printf " "
	fi
	printf "%b\n" "$3"								# $3 Represents Terminator i.e string after centered string
}

killgroup()
{
	echo -e "${col3}EXITING ... $res"
	kill 0
}
trap killgroup SIGINT				# SIGINT represents ctrl + c, so this redirects to killgroup function whenever ctrl-c is pressed

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
	printf "%b\n" "$col1  *********************HELP*********************"
	Center "$col2 |" "Valid Arguments" "|" 46 
	printf "%b\n" "$col1 |----------------------------------------------|"
	Center "$col2 |" "0 for Both Updates" "|" 46
	Center "$col2 |" "1 and 2 in your Preferred Order to Update Both" "|" 46
	Center "$col2 |" "1 for $Update1 Update" "|" 46
	Center "$col2 |" "2 for $Update2 Update" "|" 46
	Center "$col3 |" "Any Other Configuration for this Screen" "|" 46
	printf "%b\n" "$col1  ********************************************** $res"
    exit 1
fi

printf "%b\n" "${col1}Super User Access Required Enter Password: $col2"
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

clear

if [[ "$arg1" != "" ]]
then
	Run "$arg1" "0"
fi
if [[ "$arg2" != "" ]]
then
	Run "$arg2" "1"
fi
if [[ "$arg1" != "" ]]
then
	Remove "$arg1" "0"
fi
if [[ "$arg2" != "" ]]
then
	Remove "$arg2" "1"
fi

exit 0
