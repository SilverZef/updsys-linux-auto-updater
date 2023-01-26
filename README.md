## DISCLAIMER: USE THESE SCRIPTS AT YOUR OWN RISK



## COMMANDS RAN BY SCRIPTS:
- **sudo zypper refresh**
- **sudo zypper dup --**
- **sudo flatpak update -y**



## HOW TO RUN IT?:


**Step 1)** cd to the directory where both LogDisplay.cpp and updsys.sh are

**Step 2)** Compile LogDisplay.cpp using the command: 
*g++ LogDisplay.cpp -o NAME* where NAME is any name that you choose for
the compiled file.

**Step 3)** Change the variable `LogDisplay="/home/silveros/LogDisplay"` in 
updsys.sh at line 1 to the absolute path (i.e dont use ~/... instead 
use /home/username/...) of NAME from step 2.

**Step 4)** Run the command *chmod +x updsys.sh* this allows updsys.sh to be
executable. Now you can run the script using ./updsys.sh from updsys.sh
directory.


**Additional Steps:(This allows the use of this script anywhere on 
the system)**

**Step 1)** Open *~/.bashrc* in any editor.
(Remember to make a backup before any changes)

**Step 2)** Go to the end of the file and add 
*alias com_name='path_to_updsys.sh'* , where *com_name* is any name you use 
to run the command anywhere and '' contains the path to updsys.sh.

**Step 3)** Save the file.

**Step 4)** Close and reopen terminal. And now you can run the command 
anywhere with *com_name args*.






## WHY USE IT?:

It automatically updates both flatpak and zypper repositories without 
cluttering your screen, it does that by showing current progress in a 
single line and it saves(if the user choses to) a copy of the update's 
progress in a file.




## WHAT DOES IT DO?:

**For each update(zypper and flatpak) this is the screen format:**

-------------------------------------------------------------------------
**Status:** "This shows which update is running"                           
                                                                        
**Progress:** "This shows what is currently happening"                    
                                                                        
**Running:** "This shows the command that is being executed ex: zypper dup"
                                                                        
**ERRORS:**                                                               
"Here all errors/messages dumped by each updater is displayed"         
                                                                        
-------------------------------------------------------------------------


**After each update this prompt replaces 'ERRORS:'**

Delete Log File ? (y) [y/n/h]: 

Entering nothing or y deletes the update record

Entering n saves the record as *Zypper/Flatpak_Log.txt or 
Zypper/Flatpak_Log_n.txt* where n is any +ve integer.




## HOW DOES IT WORK?:

It uses 2 programs: 

**1) updsys.sh**:

This is the main script, this runs the commands, shows status and saves
the update records and calls LogDisplay.cpp.

This script has the following functions:

- `Remove()` ---> This prompts: 'Delete Log File ? (y) [y/n/h]: ' and 
	Removes or saves the update record.

- `Execute()` ---> 
	This Executes the upgrade commands and pipes them to a temporary file 
	named as *Log.txt/Log_n.txt* using '>' operator and displays 'Status: ',
	'Running:' and 'ERRORS:' sections.

**2) LogDisplay.cpp**:

This program displays the 'Progress: ' section by continuosly reading from
Log.txt file and writing any updates to the screen.

This has the following functions:

- `GetWidth()` ---> 
	Gets Screen width used to make sure display progress does not exceed 
	screen width to limit it to a single line.
- `GetLastLine()` --->
	Reads last line in the Log.txt file which is the progress to be 
	displayed.




## HOW TO CHANGE COLORS?:

Both updsys.sh and LogDisplay.cpp have variables col1, col2 and col3
the col1 & col2 are used for general display and col3 is used for error
display. These variables are in the format `col = "\e[38;2;r;g;b;m"`
change the r, g and b part to your desired integer value to change the
color.

In updsys.sh these variables are found at line no: *3, 4 & 5*

In LogDisplay.cpp these variables are found at line no: *17*
(Do it before compilation or repeat steps 2 and 3 from the 
section **'HOW TO RUN IT?:'** after changing the variables) 

Change the variables in both files for the desired result.




## HOW TO CHANGE UPGRADE COMMANDS?:

If you want to change the default upgrade commands you can do so by
changing the variables comm1, comm2 and comm3 found in updsys.sh at 
line no: *54, 55 and 56*. comm1 variable runs zypper refresh, comm2 runs 
zypper dup and comm3 runs flatpak update.
