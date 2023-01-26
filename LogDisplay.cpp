#include <iostream>
#include <fstream>
#include <sys/ioctl.h>

using namespace std;

int GetWidth();
string GetLastLine(string Path);

int main(int argv, char* args[])
{
	if(argv != 3)
		return 1;
	string PakName = args[1], Path = args[2];
	if(PakName != "Zypper" && PakName != "Flatpak")
		return 1;
	string col1 = "\e[38;2;148;23;226m", col2 = "\e[38;2;65;220;76m", col3 = "\e[38;2;255;165;0m";
	string Progress = "", Terminator = "UPGRADE_FINISHED";
	string ResetCursor = "\e[8;1f";
	string ClearLine = "\e[2K", GoSecondRow = "\e[3;1f";
	while(Progress != Terminator)
	{
		Progress = GetLastLine(Path);
		int Prog_Len = GetWidth() - PakName.size() - 11;//Allowed length for Progress = Window width - length of pakname - length of the displayed string " Progress: "
		cout.flush();									//Makes sure everything is printed before moving cursor
		cout<<GoSecondRow<<ClearLine<<col2<<PakName<<" Progress: "<<col1<<Progress.substr(0, Prog_Len);
		cout<<ResetCursor<<col3; 
	}
}

int GetWidth()
{
	struct winsize w;
	ioctl(fileno(stdout), TIOCGWINSZ, &w);
	return (int)(w.ws_col);
}

string GetLastLine(string Path)
{
	ifstream File(Path);
	string LastLine = "";
	File.seekg(-2, std::ios_base::end);         //Start at end of file and skips the \n at the end
	while(File.get() != '\n')
	{
		File.seekg(-2, std::ios_base::cur);     //It offsets +1 from .get to continue backwards 
		if(File.tellg() <= 0)
		{
			File.seekg(0);
			break;
		}
	}
	getline(File, LastLine);
	File.close();
	return LastLine;
}
