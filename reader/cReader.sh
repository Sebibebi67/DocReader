#!/bin/bash


#================================== cReader.sh ==================================#


#--------------------------------- Description ----------------------------------#
#
# Reading a C file and transform it into a markdown documentation
#
#--------------------------------------------------------------------------------#


#----------------------------------- Synopsis -----------------------------------#
#
# ./cReader.sh <file>
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
waitingAuthors="FALSE"
waitingIncludes="FALSE"
waitingDeclaration="FALSE"
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

	waitingFileDescription="FALSE"
	waitingAuthors="FALSE"
	waitingIncludes="FALSE"
	waitingDeclaration="FALSE"
	waitingFunctions="FALSE"
	statusBodyFunction="FINISHED"
}


#--------------------------------------------------------------------------------#


#------------------------------------- Main -------------------------------------#

while read line; do

	# Title
	if [[ $line == *"== "*" =="* ]]; then
		title=${line//=/''}
		title=${title//'//'/''}
		title=${title//' '/''}
	  	echo -e '# **Wiki -- ['$title']('/$1')**\n'

	# Subtitle
  	elif [[ $line == *"-- "*" --"* ]]; then
	  	subtitle=${line//-/''}
		subtitle=${subtitle//'//'/''}
		subtitle=${subtitle//' '/''}

		case $subtitle in
			"Description")
				waitingFileDescription="TRUE"
				echo -e '\n## **Description**\n';;

			"Authors" )
				waitingAuthors="TRUE"
				echo -e "\n## **Authors**\n";;

			"Includes" )
				waitingIncludes="TRUE"
				echo -e "\n## **Includes**\n";;

			"Functions" )
				waitingFunctions="TRUE"
				echo -e "\n---\n## **Functions**\n";;
			*)
				;;
		esac

	# Commented line
	elif [[ $line == '// '* ]];then

		# Waiting for file description
		if [[ $waitingFileDescription == "TRUE" ]]; then
			echo ${line//'// '/''}
		

		# Waiting for Authors
		elif [[ $waitingAuthors == "TRUE" ]]; then
			echo -e "* ${line//'// '/''}"

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

	# End of paragraph
	elif [[ $line == '//--'*'--//' ]]; then
		reset

	# Waiting for Includes
	elif [[ $waitingIncludes == "TRUE" ]]; then
		if [[ $line == '#'* ]]; then
		include=${line//'#include '/''}
			if [[ $include == '<'*'>' ]]; then
				include=${include//'<'/''}
				include=${include//'>'/''}
				echo -e "* $include"
			elif [[ $include == "\""*"\"" ]]; then
				include=${include//'"'/''}

				dir=$(echo $1 | cut -d'/' -f1)
				path=$(find $dir | grep wiki.*$include)

				echo -e "* [$include](/$path)"
			fi
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

	fi



done < $1

#--------------------------------------------------------------------------------#


#================================================================================#