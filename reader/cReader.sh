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
waitingFunctions="FALSE"
statusBodyFunction="FINISHED"
functionDescription=""
checkDescription="FALSE"
checkInput="FALSE"
checkOutput="FALSE"
checkAuthors="FALSE"

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
	waitingFunctions="FALSE"
	statusBodyFunction="FINISHED"
	resetFunctionDescription
	# echo reset
}

resetFunctionDescription(){

	functionDescription=""
	checkDescription="FALSE"
	checkInput="FALSE"
	checkOutput="FALSE"
	checkAuthors="FALSE"

}

addDescription(){
	functionDescription="$functionDescription""$1"
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
	elif [[ $line == *"("*")"* && $waitingFunctions == "TRUE" ]]; then
		resetFunctionDescription
		statusBodyFunction="WAITING_BODY"

		functionName=$(echo $line | cut -d'(' -f1 | rev | cut -d' ' -f1 | rev )


		addDescription "### **$functionName**"

	elif [[ $statusBodyFunction == "WAITING_BODY" ]]; then

			if [[ $line == '*/' ]]; then
				if [[ $checkDescription == "TRUE" && $checkInput == "TRUE" && $checkOutput == "TRUE" && $checkAuthors == "TRUE" ]]; then
					echo -e "$functionDescription\n\n"
				fi
				statusBodyFunction="FINISHED"
				resetFunctionDescription
			else
				param=${line//'* '/''}
				case ${param%% *} in
					"Description" )
						checkDescription="TRUE"
						addDescription "\n\n*Description :* "
						addDescription "$(echo -e "$param\n" | cut -d: -f2)"
						;;
					"Input" )
						checkInput="TRUE"
						addDescription "\n\n*Input :*\n"
						;;
					"Output" )
						checkOutput="TRUE"
						addDescription "\n\n*Output :*\n"
						;;
					"Authors" )
						checkAuthors="TRUE"
						addDescription "\n\n*Authors :*\n"
						;;
					"/**" | "*")
						# nothing
						;;
					*)
						addDescription "$param";;
				esac
			fi

	# else
	# 	echo "$line"


	# # Reading Function Documentation
	# elif [[ $line == "###"* ]]; then
	# 	if [[ $statusBodyFunction == "FINISHED" ]]; then
	# 		statusBodyFunction="WAITING_BEGIN"
	# 	elif [[ $statusBodyFunction == "WAITING_BEGIN" ]]; then
	# 		statusBodyFunction="WAITING_END"
	# 	elif [[ $statusBodyFunction == "WAITING_END" ]]; then
	# 		statusBodyFunction="FINISHED"
	# 		echo -e "___"
	# 	fi

	fi



done < $1

#--------------------------------------------------------------------------------#


#================================================================================#