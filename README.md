## DISCLAIMER: USE THE SCRIPT AT YOUR OWN RISK


## COMMANDS RAN BY THE SCRIPT:
- **sudo zypper refresh**
- **sudo zypper dup -y --allow-vendor-change --force-resolution**
- **sudo flatpak update -y**


## HOW TO RUN IT?:

**Step 1)** Go to directory where *updsys.sh* is

**Step 2)** Run the command *chmod +x updsys.sh* this allows updsys.sh to be
executable. Now you can run the script using ./updsys.sh from updsys.sh's
directory.

**Additional Steps:(This allows the use of this script anywhere on 
the system)**

**Step 1)** Open *~/.bashrc* in any editor.
(Remember to make a backup before any changes)

**Step 2)** Go to the end of the file and add 
*alias com_name='path_to_updsys.sh'* , where *com_name* is any name you use 
to run the command anywhere and ' ' contains the path to updsys.sh.

**Step 3)** Save the file.

**Step 4)** Open terminal. And now you can run the command 
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

**After all updates this is prompted for each update:**

Delete Zypper/Flatpak Log File ? (y) [y/n/h]: 

Entering nothing or y deletes the update record

Entering n saves the record as *Zypper/Flatpak_Log.txt or 
Zypper/Flatpak_Log_n.txt* where n is any +ve integer.


## HOW DOES IT WORK?:

It uses 1 Script: **updsys.sh**

This script has the following functions:

- `Remove()` ---> This prompts: 'Delete Log File ? (y) [y/n/h]: ' and 
	Removes or saves the update record.

- `Update()` ---> 
	This executes the upgrade commands and pipes them to a temporary file 
	named as *(Zypper/Flatpak)_(Log/Log_n).txt)* using '>' / '>>' operator 
	and displays 'Status: ', 'Running:' and 'ERRORS:' sections.
	
- `WriteProgress()` --->
	This displays the *'Progress:'* section of the update by continuosly 
	reading from update record and writing it to the screen.

- `Run()` --->
	This calls all neccessary functions for each update including *Update()*
	& *WriteProgress()*


## HOW TO CHANGE COLORS?:

**updsys.sh** has variables *col1, col2 and col3* the *col1 & col2* variables
are used for general display and *col3* is used for error
display. These variables are in the format `col="\e[38;2;r;g;b;m"`
change the r, g and b part to your desired integer value to change the
color.

These variables are found at line no: *1, 2 & 3*


## HOW TO CHANGE UPGRADE COMMANDS?:

If you want to change the default upgrade commands you can do so by
changing the variables *comm1, comm2 and comm3* found in **updsys.sh** at 
line no: *37, 38 and 39*. *comm1* variable runs zypper refresh, *comm2* runs 
zypper dup and *comm3* runs flatpak update.


## HOW TO CHANGE THE NAME FOR UPDATE RECORDS?:

It is possible to change the name for update records but it will
always be in the format *UpdateName_ChosenName.txt* where *UpdateName* 
is either *Zypper* or *Flatpak* based on whichever update
its recording. *ChosenName* is by default *Log* but this can be changed.

To change *ChosenName* go to line no: *6* in **updsys.sh** and change
`RecordName="Log"` to `RecordName="NewChosenName"`.
