#!/bin/bash


#================================ shellReader.sh ================================#


#--------------------------------- Description ----------------------------------#
#
# Reading a shell file and transform it into a markdown documentation
#
#--------------------------------------------------------------------------------#


#----------------------------------- Synopsis -----------------------------------#
#
# ./shellReader.sh <file>
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


#------------------------------- Global Variables -------------------------------#

waitingFileDescription="FALSE"
waitingBash="FALSE"
waitingOption="FALSE"
waitingAuthors="FALSE"
waitingFunctions="FALSE"
statusBodyFunction="FINISHED"

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
	waitingBash="FALSE"
	waitingOption="FALSE"
	waitingAuthors="FALSE"
	waitingFileDescription="FALSE"
	waitingFunctions="FALSE"
}


#--------------------------------------------------------------------------------#


#------------------------------------- Main -------------------------------------#

while read line; do

	# Title
	if [[ $line == *"== "*" =="* ]]; then
		title=${line//=/''}
		title=${title//'#'/''}
		title=${title//' '/''}
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

			"Functions" )
				waitingFunctions="TRUE"
				echo -e "\n---\n---\n## **Functions**\n";;
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
				*)
					echo -e "$param";;
			esac
		fi

	# Reading a Function
	elif [[ $line == *"(""){" ]]; then
		statusBodyFunction="WAITING_BEGIN"
		echo -e "### **"${line//'(){'/''}"**"

	# Reading Function Documentation
	elif [[ $line == "###"* ]]; then
		if [[ $statusBodyFunction == "FINISHED" ]]; then
			statusBodyFunction="WAITING_BEGIN"
		elif [[ $statusBodyFunction == "WAITING_BEGIN" ]]; then
			statusBodyFunction="WAITING_END"
		elif [[ $statusBodyFunction == "WAITING_END" ]]; then
			statusBodyFunction="FINISHED"
			echo -e "___"
		fi




	# End of paragraph
	elif [[ $line == '#--'*'--#' ]]; then
		reset

 	fi
done < $1

#--------------------------------------------------------------------------------#


#================================================================================#