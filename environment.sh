#!/bin/bash

## Winbuntu - The Ubuntu Linux Environment for Windows 10
## An awesome Linux environment that runs using WSL on Windows 10
##
## Author: Adam Thompson <adam@serialphotog.com>

#####
# Color definitions
#####
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

#####
# The environment configuration
#####
typeset -A config # init array
config=( # set default values in config array
    [gitRepo]="https://github.com/serialphotog/winbuntu-config.git"
    [workingDir]="/tmp/winbuntu/"
    [guiCommand]="i3"
)

#####
# Global Vars
#####
SESSION_CONF_PATH='/etc/dbus-1/session.conf'

#####
# Installer Functions
#####

# Installs git on the system
function install_git()
{
	echo "Installing git..."
	sudo -s apt-get -y install git

	if type "git" > /dev/null; then
		echo -e "${GREEN}Git successfully installed${NC}"
	fi
}

# Installs Xterm
function install_xterm()
{
	echo "Installing xterm..."
	sudo -s apt-get -y install xterm

	if type "xterm" > /dev/null; then
		echo -e "${GREEN}Xterm successfully installed${NC}"
	fi
}

#####
# Core Functions
#####

# Checks that required apps are present
function check_required_apps()
{
	if ! type "git" > /dev/null; then
		echo -e "${RED}Git not found${NC}"
		install_git
	else
		echo -e "${GREEN}Found git${NC}"
	fi

	if ! type "xterm" > /dev/null; then
		echo -e "${RED}Xterm not found${NC}"
		install_xterm
	else
		echo -e "${GREEN}Found Xterm${NC}"
	fi
}

# Clones our configuration repository
function clone_setup() 
{
	# Make sure the working directory exists
	mkdir -p ${config[workingDir]}
	git clone ${config[gitRepo]} ${config[workingDir]}
}

# Installs required packages from repo file
function install_packages()
{
	# Check that PACKAGES file exists
	if [ -f ${config[workingDir]}/PACKAGES ]; then
		echo -e "${GREEN}Found PACKAGES file. Installing...${NC}"
		for i in `cat ${config[workingDir]}/PACKAGES`
		do
			if ! dpkg-query -W -f='${Status} ${Version}\n' ${i} | grep "^install ok" > /dev/null ; then
				echo "Installing package ${i}"
				sudo apt-get install -y ${i}
			else
				echo "Pakcage ${i} is already installed. Skipping..."
			fi
		done
	else
		echo -e "${RED}No PACKAGES file found. Skipping package installation...${NC}"
	fi
}

# Installs the dotfiles
function dotfiles()
{
	if [ -d ${config[workingDir]}dotfiles ]; then
		cp -rf ${config[workingDir]}dotfiles/. ~/
	else
		echo -e "${RED}Dotfiles dir not found. Skipping..."
	fi
}

# Run all config scripts in scripts dir
function run_scripts()
{
	if [ -d ${config[workingDir]}scripts ]; then
		echo -e "${GREEN}Found scripts directory. Running...${NC}"
		for script in ${config[workingDir]}scripts/* 
		do
			chmod +x $script
			$script
		done
	else
		echo -e "${RED}No scripts directory found. Skipping...${NC}"
	fi
}

# Launches the GUI interface
function gui()
{
	if [ -z "${config[guiCommand]//}" ]; then
		echo -e "${RED}No gui command specified. Skipping...${NC}"
	else
		DISPLAY=localhost:0 exec ${config[guiCommand]}
	fi
}

# Applies the dbus fix
function dbus_fix()
{
	# Delete old session.conf if exists
	if [ -e $SESSION_CONF_PATH ]; then
		sudo rm $SESSION_CONF_PATH
	fi

	#Download new session.conf and apply fix
	SESSION_CONF_GIST='https://gist.githubusercontent.com/serialphotog/444917d8e8e327d873cc5bf1a0fa2232/raw/ea271023ae692d9e1eff875531fd90f543935eaf/winbuntu-session.conf'
	curl -k $SESSION_CONF_GIST > '/tmp/session.conf'
	sudo -s cp '/tmp/session.conf' $SESSION_CONF_PATH
}

# Checks if the dbus fix has been applied
function check_dbus_fix()
{
	DBUS_FIX='<listen>tcp:host=localhost,port=0</listen>'

	if [ -e $SESSION_CONF_PATH ] && grep -q $DBUS_FIX $SESSION_CONF_PATH; then
		echo -e "${GREEN}Detected dbus fix.${NC}"
	else
		echo -e "${RED}No dbus fix found. Applying it now...${NC}"
		dbus_fix
	fi
}

# The main runtime 
function main()
{
	check_required_apps
	clone_setup
	install_packages
	dotfiles
	run_scripts
	check_dbus_fix
	gui
}

#####
# Run the environment setup
#####
main