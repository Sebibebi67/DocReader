#!/bin/bash


#================================ shellReader.sh ================================#


#--------------------------------- Description ----------------------------------#
#
# Reading a Java file and transform it into a markdown documentation
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


#------------------------------- Global Variables -------------------------------#

waitingFileDescription="FALSE"
waitingAuthors="FALSE"
waitingImports="FALSE"
waitingFunctions="FALSE"
statusBodyFunction="FINISHED"
importWritten="UNKNOWN"
functionDoc=""
description=""
input=""
output=""
authors=""
waitingDescription="FALSE"
override="FALSE"

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

	if [[ $waitingImports == "TRUE" && $importWritten == "UNKNOWN" ]]; then
		echo -e "ø\n"
	fi

	waitingAuthors="FALSE"
	waitingImports="FALSE"
	waitingFileDescription="FALSE"
	waitingFunctions="FALSE"
	resetDescription
}

resetDescription(){
	###
	# Description : Restarts the description Strings
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

	waitingDescription="FALSE"
	description=""
	input=""
	output=""
	authors=""
	override="FALSE"
}


#--------------------------------------------------------------------------------#


#------------------------------------- Main -------------------------------------#

while read line; do

	# Title
	if [[ $line == *"== "*" =="* ]]; then
		title=${line//'= '/''}
		title=${title//' ='/''}
		title=${title//=/''}
		title=${title//'//'/''}
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

			"Package" )
				waitingPackage="TRUE"
				echo -e "\n## **Package**\n";;

			"Imports" )
				waitingImports="TRUE"
				echo -e "\n## **Imports**\n";;


			"Constructors" | "Setters" | "Getters" | "Methods" )
				waitingFunctions="TRUE"
				echo -e "\n---\n## **$subtitle**\n"
			;;

			
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
	
	# Waiting for package
	elif [[ $waitingPackage == "TRUE" && $line == 'package'* ]]; then
		package=${line/'package '/''}
		package=${package/';'/''}
		echo $package


	# Waiting for Imports
	elif [[ $waitingImports == "TRUE" && $line == 'import'* ]]; then
		importWritten="TRUE"
		import=$(echo $line | cut -d' ' -f2)
		import=${import//';'/''}

		dir=$(echo $1 | cut -d'/' -f1)
		path=$(find $dir | grep $import.java)

		if [[ -f $path ]]; then
			newPath='/'${path/'.java'/'.md'}
			newPath=${newPath/$dir/$dir/wiki/}
			echo '* ['$import']('$newPath')'
		else
			echo '* '$import
		fi
	
	# Extends a class of implements interfaces
	# elif [[ $line == "public"*"extends"*"implements"* ]]; then
		# line=${line/'extends'/:}
		# line=${line/'implements'/:}
		# line=${line/'{'/''}
		# extends=$(echo $line | cut -d':' -f2  )
		# implements=$(echo $line | cut -d':' -f3  )
		# implements=${implements//','/"\n *"}
		# echo -e "\n## **SuperClass**\n$extends\n"
		# echo -e "\n## **Interfaces**\n* $implements\n"
	elif [[ $line == 'public'*' class'*'{' ]]; then

		# Extends a class
		if [[ $line == "public"*"extends"* ]]; then
			# copyLine=$line
			copyLine=${line/'extends'/:}
			copyLine=${copyLine/'implements'/:}
			copyLine=${copyLine/'{'/''}
			extends=$(echo $copyLine | cut -d':' -f2  )
			extends=${extends//' '/''}

			dir=$(echo $1 | cut -d'/' -f1)
			path=$(find $dir | grep $extends.java)

			echo -e "\n## **SuperClass**"
			if [[ -f $path ]]; then
				newPath='/'${path/'.java'/'.md'}
				newPath=${newPath/$dir/$dir/wiki/}
				echo "[$extends]($newPath)"
			else
				echo "$extends"
			fi
		fi

		# Implements interfaces
		if [[ $line == "public"*"implements"* ]]; then
		# echo done
			# copyLine=$line
			copyLine=${line/'implements'/:}
			copyLine=${copyLine/'{'/''}
			# echo $line
			implements=$(echo $copyLine | cut -d':' -f2  )

			dir=$(echo $1 | cut -d'/' -f1)

			echo -e "\n## **Interfaces**"
			implements=${implements//','/" "}

			for i in $implements; do
				path=$(find $dir | grep $i.java)

				if [[ -f $path ]]; then
					newPath='/'${path/'.java'/'.md'}
					newPath=${newPath/$dir/$dir/wiki/}
					echo "* [$i]($newPath)"

				else
					echo "* $i"
				fi
				# echo $i
			done
		fi


	# Reading a Function
	elif [[ $waitingFunctions == "TRUE" ]]; then
		if [[ $line == "public"* || $line == "private"* || $line == "protected"* ]]; then
			statusBodyFunction="WAITING_BEGIN"
			access=$(echo $line | cut -d' ' -f1)
			# echo $access
			function=$(echo $line | cut -d'(' -f1 )
			function=$(echo $function | rev | cut -d' ' -f1 | rev )
			echo -e "### **"$function"**\n"
			echo -e "\n*Description :* $description\n"

			if [[ $override == "TRUE" ]]; then
				echo -e "\n*Override*\n"
			fi


			echo -e "\n*Input :*"
			if [[ $input != "" ]]; then
				echo -e "$input"
			else
				echo -e "* None"
			fi

			echo -e "\n*Output :*"
			if [[ $output != "" ]]; then
				echo -e "$output"
			else
				echo -e "* None"
			fi	
			echo -e "\n*Authors :*\n$authors"
			resetDescription

		# Reading Function Documentation
		elif [[ $line == *"/**" ]]; then
			waitingDescription="TRUE"
		elif [[ $line == *'*'* ]]; then
			arg=${line/'* '/''}
			arg=$(echo "$arg" | cut -d' ' -f1)
			case $arg in
				'@param' )
					input=$input"*${line/'* @param'/''}\n"
					waitingDescription="FALSE"
					;;

				'@return' )
					output=$output"*${line/'* @return'/''}\n"
					waitingDescription="FALSE"
					;;

				'@author')
					authors=$authors"*${line/'* @author'/''}\n"
					waitingDescription="FALSE"
					;;
				'@'* | '*' | *)
					# nothing
					;;
			esac
			if [[ $waitingDescription == "TRUE" && $line != '*' ]]; then
				description=${line/'* '/''}
			fi
		fi

	if [[ $line == "@Override" ]]; then
		override="TRUE"
	fi

	# End of paragraph
	elif [[ $line == '//--'*'--//' ]]; then
		reset

 	fi
done < $1

#--------------------------------------------------------------------------------#


#================================================================================#