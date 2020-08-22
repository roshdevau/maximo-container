#!/bin/bash

######################################################################################################
#       Script : createResponseFile.sh                                                               #
#       Author : roshdevau                                                                           #
#       Description : Script to create Response Files to support non-root user installation          #
#       Usage : ./createResponseFile.sh DB_PASSWORD DB_SERVER                                        #
#       Change History :                                                                             #
#       Date            Author              Version     Description                                  #
#       20 August 2020  roshdevau           0.1         Original Version                               #
#                                                                                                    #
######################################################################################################

## Global Variables

## Function to create WAS Response File##

### Create a Maximo Response File ###
createMAMResponse () {
cat > /apps/Launchpad/ResponseFile_MAM_Install_Unix.xml <<EOF
<?xml version='1.0' encoding='UTF-8'?>
<agent-input>
  <server>
<!-- Provide the repository location for the Maximo Asset Management V7.6.1 offering package        -->
<!-- Use a URL or Universal Naming Convention path to specify the location of remote repositories.  -->
<!-- To specify a local repository, provide a directory path                                        -->
<!-- Uncompress product image files in the root directory \Launchpad. If you choose a different     -->
<!--  directory, update the path specified for the repository location.                             -->
    <repository location='/apps/Launchpad/Install/ProductInstallerRepository'/>
    <repository location='/apps/Launchpad/Install/TPAEInstallerRepository'/>
    <repository location='/apps/Launchpad/Install/ConfigToolRepository'/>
  </server>
<!-- A profile is an installation location. The 'installLocation' keyword determines                -->
<!--     the base installation path.                                                                -->
<!-- Specify a Maximo Asset Management V7.6.1 installation location.                                -->
<!--    Do not reuse the installation location of a currently installed Maximo product.             -->
<!--    If another Maximo product has been installed, both the profile id AND the installLocation   -->
<!--        need to be changed to unique values.  The profile id must also match the values         -->
<!--        supplied near the bottom of this file, in the install section, for : <offering profile= -->
  <profile id='IBM   Tivoli&apos;s process automation suite' installLocation='/apps/IBM/SMP'>
  </profile>

<!-- Purpose - IBM Installation Manager needs a temp space to extract the files from repository     -->
<!--    location, so it uses this location                                                          -->
<!-- Default Shared Location for Unix    : /opt/IBM/IBMIMShared                                     -->
<!-- Default Shared Location for Windows : C:\Program Files\IBM\IBMIMShared                         -->
<!-- Valid values - Any directory location which has write permission                               -->
        <variables>
        <variable name='sharedLocation' value='/apps/IBM/IMShared'/>
        </variables>
        <preference name='com.ibm.cic.common.core.preferences.eclipseCache' value='\${sharedLocation}'/>

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!-- Do not change anything below this line unless the profile provided above has      -->
<!-- been changed.  If it has, provide the same profile information for the following  -->
<!-- offering lines.                                                                   -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <install modify='false'>
    <offering profile='IBM   Tivoli&apos;s process automation suite' id='com.ibm.tivoli.tpae.base.tpae.main' features='TPAEWin32bitSupport.feature,main.feature,java.feature,configTool.feature' installFixes='none'/>
    <offering profile='IBM   Tivoli&apos;s process automation suite' id='com.ibm.tivoli.tpae.base.mam.main' features='TPAEWin32bitSupport.feature,main.feature' installFixes='none'/>
  </install>
</agent-input>
EOF

}

createMAMConfigFile () {
cat > /apps/Launchpad/MAM_Config.properties <<EOF
MW.Operation=Configure
# Maximo Configuration Parameters
mxe.adminuserloginid=maxadmin
mxe.adminPasswd=maxadmin
mxe.system.reguser=maxreg
mxe.system.regpassword=maxreg
mxe.int.dfltuser=mxintadm
maximo.int.dfltuserpassword=mxintadm
MADT.NewBaseLang=en
MADT.NewAddLangs=
mxe.adminEmail=root@localhost
mail.smtp.host=localhost
mxe.db.user=maximo
mxe.db.password=$1
mxe.db.schemaowner=maximo
mxe.useAppServerSecurity=0
mxe.rmi.enabled=0
# Database Configuration Parameters
Database.Vendor=Oracle
Database.Oracle.InstanceName=MAXDB761
#Database.Oracle.ServiceName=MAXDB761
Database.Oracle.DataTablespaceName=MAXDATA
Database.Oracle.IndexTablespaceName=MAXINDEX
Database.Oracle.ServerHostName=$2
Database.Oracle.ServerPort=1521
# WebSphere Configuration Parameters
ApplicationServer.Vendor=WebSphere
WAS.ND.AutomateConfig=false
IHS.AutomateConfig=false
WAS.ClusterAutomatedConfig=false
WAS.DeploymentManagerRemoteConfig=false
EOF
}

## Main

createMAMResponse
createMAMConfigFile $1 $2
