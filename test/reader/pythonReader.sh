#!/bin/bash


#================================ shellReader.sh ================================#


#--------------------------------- Description ----------------------------------#
#
# Reading a python file and transform it into a markdown documentation
#
#--------------------------------------------------------------------------------#


#----------------------------------- Synopsis -----------------------------------#
#
# ./pythonReader.sh <file>
#
#--------------------------------------------------------------------------------#


#----------------------------------- Options ------------------------------------#
#
# <file> : the file to read
#
#--------------------------------------------------------------------------------#


#----------------------------------- Authors ------------------------------------#
#
# Sébastien HERT
#
#--------------------------------------------------------------------------------#


#----------------------------------- Imports ------------------------------------#

DEFAULT="\e[0m"
BOLT="\e[1m"
UNDERLINED="\e[4m"

RED="\e[38;5;196m"
GREEN="\e[38;5;40m"
YELLOW="\e[38;5;226m"
BLUE="\e[38;5;33m"
ORANGE="\e[38;5;208m"
PURPLE="\e[38;5;165m"

#--------------------------------------------------------------------------------#


#------------------------------- Global Variables -------------------------------#

waitingFileDescription="FALSE"
waitingBash="FALSE"
waitingOption="FALSE"
waitingAuthors="FALSE"
waitingImports="FALSE"
waitingFunctions="FALSE"
statusBodyFunction="FINISHED"
importWritten="UNKNOWN"

#--------------------------------------------------------------------------------#


#---------------------------------- Functions -----------------------------------#

reset(){
	###
	# Description : Resets the global Variables
	#
	# Input :
	# - None
	#
	# Output :
	# - None
	#
	# Authors :
	# - Sébastien HERT
	###

	if [[ $waitingBash == "TRUE" ]]; then
		echo -e "\`\`\`\n"
	fi

	if [[ $waitingImports == "TRUE" && $importWritten == "UNKNOWN" ]]; then
		echo -e "ø\n"
	fi
	# importWritten="TRUE"
	waitingBash="FALSE"
	waitingOption="FALSE"
	waitingAuthors="FALSE"
	waitingImports="FALSE"
	waitingFileDescription="FALSE"
	waitingFunctions="FALSE"
}


#--------------------------------------------------------------------------------#


#------------------------------------- Main -------------------------------------#

while read line; do

	# Title
	if [[ $line == *"== "*" =="* ]]; then
		title=${line//'= '/''}
		title=${title//' ='/''}
		title=${title//=/''}
		title=${title//'#'/''}
	  	echo -e '# **Wiki -- ['$title']('/$1')**\n'

	# Subtitle
  	elif [[ $line == *"-- "*" --"* ]]; then
	  	subtitle=${line//-/''}
		subtitle=${subtitle//'#'/''}
		subtitle=${subtitle//' '/''}

		case $subtitle in
			"Description")
				waitingFileDescription="TRUE"
				echo -e '\n## **Description**\n';;

			"Synopsis" )
				waitingBash="TRUE"
				echo -e "\n## **Synopsis**\n\n\`\`\`bash";;

			"Options" )
				waitingOption="TRUE"
				echo -e "\n## **Options**\n";;

			"Authors" )
				waitingAuthors="TRUE"
				echo -e "\n## **Authors**\n";;

			"Imports" )
				waitingImports="TRUE"
				echo -e "\n## **Imports**\n";;

			"Functions" )
				waitingFunctions="TRUE"
				echo -e "\n---\n## **Functions**\n---\n";;

			"Constructor" )
				waitingFunctions="TRUE"
				echo -e "\n---\n## **Constructor**\n"
			;;

			"Methods" )
				waitingFunctions="TRUE"
				echo -e "\n## **Methods**\n"
			;;

			
			*)
				;;
		esac

	# Commented line
	elif [[ $line == '# '* ]];then

		# Waiting for file description
		if [[ $waitingFileDescription == "TRUE" ]]; then
			echo ${line//'# '/''}

		# Waiting for Synopsis bash comments
		elif [[ $waitingBash == "TRUE" ]]; then
			echo -e "${line//'# '/''}"
		
		# Waiting for Options
		elif [[ $waitingOption == "TRUE" ]]; then

			# Options names
			if [[ $line == "# +"* ]]; then
				echo -e "\n### **${line//'# + '/''}**\n"
			
			# Options Choices
			elif [[ $line == "#  *"* ]]; then
				display="${line//'#  *'/''}"
				display=${display//'-'/'-**'}
				display=${display//','/'**,'}
				display=${display//' :'/'** :'}
				echo -e '* '$display
			
			# Options body
			elif [[ $line == '# '* ]]; then
				echo -e "${line//'#'*' '/''}"
			fi

		# Waiting for Authors
		elif [[ $waitingAuthors == "TRUE" ]]; then
			echo -e "* ${line//'# '/''}"

		fi
	

	# Waiting for Imports
	elif [[ $waitingImports == "TRUE" && $line == 'from'*'import'* ]]; then
		importWritten="TRUE"
		import=$(echo $line | cut -d' ' -f2)
		if [[ $title == 'Class'* ]]; then
			fileName=${title//'Class'/''}'.py'
		else 
			fileName=$title
		fi
		filePath=${1//$fileName/$import}.py
		if [[ -f $filePath ]]; then
			echo '* ['$import']('$import'.md)'
		else
			echo '* '$import
		fi

	# Reading a Function
	elif [[ $line == "def"* && $waitingFunctions == "TRUE" ]]; then
		statusBodyFunction="WAITING_BEGIN"
		function=${line//'def'/''}
		function=${function//' '/''}
		function=${function//'('*'):'/''}
		echo -e "### **"$function"**"

	# Reading Function Documentation
	elif [[ $line == *"'''"* ]]; then
		if [[ $statusBodyFunction == "FINISHED" ]]; then
			statusBodyFunction="WAITING_BEGIN"
		elif [[ $statusBodyFunction == "WAITING_BEGIN" ]]; then
			statusBodyFunction="WAITING_END"
		elif [[ $statusBodyFunction == "WAITING_END" ]]; then
			statusBodyFunction="FINISHED"
			echo -e "___"
		fi

	# Waiting for Function description
	elif [[ $statusBodyFunction == "WAITING_END" ]]; then
		param=${line//'# '/''}
		case ${param%% *} in
			"Description" )
				echo -e "\n*Description :* "
				echo -e "$param\n" | cut -d: -f2
				;;
			"Input" )
				echo -e "\n*Input :*\n"
				;;
			"Output" )
				echo -e "\n*Output :*\n"
				;;
			"Authors" )
				echo -e "\n*Authors :*\n"
				;;
			"" )
				;;
			*)
				echo -e "$param";;
		esac


	# End of paragraph
	elif [[ $line == '#--'*'--#' ]]; then
		reset

 	fi
done < $1

#--------------------------------------------------------------------------------#


#================================================================================#