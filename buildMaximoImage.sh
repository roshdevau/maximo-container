#!/bin/bash
######################################################################################
#       Script : buildMaximoImage.sh                                                 #
#       Author : roshdevau                                                           #
#       Description : Script to create Maximo image                                  #
#       Usage : ./buildMaximoImage.sh                                                #
#       Change History :                                                             #
#       Date            Author              Version     Description                  #
#       20 Aug 2020    roshdevau            0.1         Original Version             #
#                                                                                    #
######################################################################################

echo "Copy Maximo-UI to maxliberty folder"
cp -R /apps/IBM/SMP/maximo/deployment/was-liberty-default/deployment/maximo-ui/maximo-ui-server/* maxliberty/maximo/

## Build Maximo UI Image
docker build -t maximoui:7610 -t roshdevau/maximoui:7610 maxliberty

echo "Copy Maximo-CRON to maxliberty folder"
cp -R /apps/IBM/SMP/maximo/deployment/was-liberty-default/deployment/maximo-ui/maximo-cron-server/* maxliberty/maximo/

## Build Maximo CRON Image 
docker build -t maximocron:7610 -t roshdevau/maximocron:7610 maxliberty



