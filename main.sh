#!/bin/bash


#=================================== main.sh ====================================#


#--------------------------------- Description ----------------------------------#
#
# This file allows you to create wiki documentation from your file written with
# a particular format
#
#--------------------------------------------------------------------------------#


#----------------------------------- Synopsis -----------------------------------#
#
# ./main.sh <dir>
#
#--------------------------------------------------------------------------------#


#----------------------------------- Options ------------------------------------#
#
# <dir> : the directory you want to document
#
#--------------------------------------------------------------------------------#


#----------------------------------- Authors ------------------------------------#
#
# Sébastien HERT
#
#--------------------------------------------------------------------------------#


#----------------------------------- Imports ------------------------------------#

default="\e[0m"
bolt="\e[1m"
underlined="\e[4m"

red="\e[38;5;196m"
green="\e[38;5;40m"
yellow="\e[38;5;226m"
blue="\e[38;5;33m"
orange="\e[38;5;208m"
purple="\e[38;5;165m"

#--------------------------------------------------------------------------------#


#------------------------------- Global Variables -------------------------------#

path=$1

#--------------------------------------------------------------------------------#


#---------------------------------- Functions -----------------------------------#

function browseDir(){
	for element in $1/* ; do
		if [[ $element != *"wiki"* ]]; then
			if [[ -d $element ]]; then
				wikiDir=$(echo "${element/$path/wiki}")
				updateDir $path/$wikiDir
				browseDir $element
			elif [[ -f $element ]]; then
				extension=$(echo $element | cut -d'.' -f2)

				wikiDir=$(echo "${element/$path/wiki}")

				wikiDir=${wikiDir/".$extension"/'.md'}

				touch $path/$wikiDir

				case $extension in
					sh )
						./reader/shellReader.sh $element > $path/$wikiDir
						;;
					py )
						./reader/pythonReader.sh $element > $path/$wikiDir
						;;
					java)
						./reader/javaReader.sh $element > $path/$wikiDir
						;;
					c | h )
						./reader/cReader.sh $element > $path/$wikiDir
						;;
					js)
						;;
					*)
						;;
				esac

			fi
		fi
	done
}

function updateDir(){
	if [[ ! -d $1 ]]; then
		mkdir $1
	fi
}

#--------------------------------------------------------------------------------#


#------------------------------------- Main -------------------------------------#

if [[ $# != 1 ]]; then
	echo Error, please use an unique parameter
	exit
fi
updateDir $path/wiki
browseDir $path

#--------------------------------------------------------------------------------#


#================================================================================#