#!/bin/bash

######################################################################################################
#       Script : maximoUserInstall.sh                                                               #
#       Author : roshdevau                                                                           #
#       Description : Script to install the IBM Maximo as a non-root user                            #
#       Usage : ./maximoUserInstall.sh DB_PASSWORD DB_SERVER MAXIMO_INSTALL_URL                      #
#       Change History :                                                                             #
#       Date            Author              Version     Description                                  #
#       20 August 2020  roshdevau            0.1        Original Version                             #
#                                                                                                    #
######################################################################################################
if [[ $# -le 1 ]];then
    echo "Usage: $0 DB_PASSWORD DB_SERVER"
    exit 1
else
    DB_PASSWORD=$1
    DB_SERVER=$2
fi

# Create the Launchpad folders if they dont exist
if [[ -d /apps ]]; then
	echo "/apps folder exists and thus create the Launchpad folder"
	if [[ ! -d /apps/Launchpad ]]; then
		mkdir -p /apps/Launchpad
	fi
else 
	echo "Ensure /apps folder is created and owned by the operating Non-Root user" 
	exit
fi

#Store current work directory
WORKDIR=`pwd`
echo "Current working directory " $WORKDIR

# Move to Launchpad
cd /apps/Launchpad

# Check for file existence else download
if [[ ! -f MAM_7.6.1.0_LINUX64.tar.gz ]]; then
	wget http://fujitsu-eam-fileshare.s3.amazonaws.com/761Installers/Linux/MAM_7.6.1.0_LINUX64.tar.gz
fi

tar xvzf MAM_7.6.1.0_LINUX64.tar.gz

## Ceate Response Files
cd -
if [[ ! -f $WORKDIR/createResponseFile.sh ]]; then 
	echo "$WORKDIR/createResponseFile.sh does not exist.."
	exit
fi 
$WORKDIR/createResponseFile.sh $DB_PASSWORD $DB_SERVER
echo "Installing the IBM Installation Manager"
/apps/Launchpad/Install/IM/installer.linux.x86_64/userinstc -acceptLicense -installationDirectory /apps/IBM/InstallationManager/eclipse

echo "Installing Maximo 761"
export BYPASS_PRS=True
/apps/IBM/InstallationManager/eclipse/tools/imcl -input /apps/Launchpad/ResponseFile_MAM_Install_Unix.xml -acceptLicense -log /apps/Launchpad/Log_MAM_Install_Unix.xml

# Configure SMP folder with the Oracle DB
echo "Configure Maximo with Oracle DB"
/apps/IBM/SMP/ConfigTool/scripts/reconfigurePae.sh -action deployConfiguration -bypassJ2eeValidation -inputfile /apps/Launchpad/MAM_Config.properties -deployDemoData

if [[ $? -eq 0 ]]; then
	echo "Successfully configured  Maximo. Proceed to building Maximo UI"
	/apps/IBM/SMP/maximo/deployment/was-liberty-default/buildmaximo-xwar.sh
	/apps/IBM/SMP/maximo/deployment/was-liberty-default/buildmaximoui-war.sh
	
	echo "Proceed to building Maximo CRON"
        /apps/IBM/SMP/maximo/deployment/was-liberty-default/buildmaximocron-war.sh
	
	$WORKDIR/buildMaximoImages.sh
	
else 
	echo "Maximo configuration failed"
	exit
fi

