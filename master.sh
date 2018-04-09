#!/bin/bash

# ===================================================================== #
# authors: Alexandar Mechev <apmechev@strw.leidenuniv.nl> --Leiden	#
#	   Natalie Danezi <anatoli.danezi@surfsara.nl>  --  SURFsara    #
#          J.B.R. Oonk <oonk@strw.leidenuniv.nl>    -- Leiden/ASTRON    #
#                                                                       #
# helpdesk: Grid Services <grid.support@surfsara.nl>    --  SURFsara    #
#                                                                       #
# usage: ./master.sh [OPTIONS]                                          #
#                                                                       #
# description:                                                          #
#       Set Lofar environment, fetch input from Grid Storage,           #
#       do averaging or demixing, then flag output with std. strategy,  #
#       finally copy the output to a (temporary) Grid Storage           #
# ===================================================================== #

# -----------------------------------------------------------------------
# PSNC VERSION
LOGFILE=/tmp/$USER.creamce.lofar.psnc.pl.log

echo "start master" >> $LOGFILE
ls -l >> $LOGFILE
date >> $LOGFILE

# SETTING PATH TO SINGULARITY IMAGE
#sing_img_path=/cvmfs/softdrive.nl/oonk/SINGULARITY_IMAGES/C7_2_20_2_sml_env/lofar-2_20_2_c7_sml_env.simg
sing_img_path=/mnt/lustre/inula/shared/lofar/oonk/lofar-2_20_2_c7_sml_env.simg
#
#
echo "SINGULARITY IMAGE: ", ${sing_img_path}
echo "CHECKING PATH OF SINGULARITY IMAGE (ls -l): "
ls -l ${sing_img_path}
echo ""
#
bpath=/var,/mnt #multiple paths are comma separated
echo "ADD BIND PATH: ", $bpath
echo ""
echo "singularity ndppp test in: master"
sing_img_path=/mnt/lustre/inula/shared/lofar/oonk/lofar-2_20_2_c7_sml_env.simg
singularity exec --bind $bpath --pwd $PWD ${sing_img_path} NDPPP -h
echo ""
# -----------------------------------------------------------------------


#--- NEW SD ---
JOBDIR=${PWD}
OLD_PYTHON=$( which python)
echo $OLD_PYTHON

echo ""
echo ""
echo "Current rundir has:"
ls
echo ""
if [ -z "$TOKEN" ] || [  -z "$PICAS_USR" ] || [  -z "$PICAS_USR_PWD" ] || [  -z "$PICAS_DB" ]
 then
  echo "One of Token=${TOKEN}, Picas_usr=${PICAS_USR}, Picas_db=${PICAS_DB} not set"; exit 1 
fi


########################
### Importing functions
########################

for setupfile in `ls bin/* `; do source ${setupfile} ; done


############################
#Initialize the environment
############################

#setup_LOFAR_env $LOFAR_PATH      ##Imported from setup_LOFAR_env.sh
#
# ADD SINGULARITY PATH HERRE
#

#trap cleanup EXIT #This ensures the script cleans_up regardless of how and where it exits

print_worker_info                      ##Imported from bin/print_worker_info

if [[ -z "$PARSET" ]]; then
    ls "$PARSET"
    echo "not found"
    exit 3  #exit 3=> Parset doesn't exist
fi


#!!! CHECK IF THIS NEEDS TO CHANGE !!!



# -----------------------------------------------------------------------
# PSNC VERSION
#
# LOCAL NODE DIRECTORY (IS TOO SMALL FOR JOB DATA HENCE GO TO SHARED FS DIR)
DLOCAL=${JOBDIR}

# USE shared lofar directory at PSNC (oonk is user lofar038 for GRID jobs, whereas locally oonk is lofar001)
SHRDIR=/mnt/lustre/inula/shared/lofar/oonk
ls -l ${SHRDIR}
echo ""
echo "contents shared/lofar/oonk: " ${SHRDIR}
ls -l ${SHRDIR}

# create a temporary scratch directory in shared !!! UPDATE SCRATCH WITH UNIQ IDENTIFIER 'OBSID_SBN' !!!
DSCRATCH=${SHRDIR}/ln38s_${PIPELINE_STEP}_${OBSID}_${STARTSB}
echo "create scratch on shared/lofar/oonk: " ${DSCRATCH}
mkdir -p ${DSCRATCH}
rm -rf ${DSCRATCH}/*
echo ""
echo "cp all local node WMS tranferred scripts to scratch and check with ls -l"
cp -r ${DLOCAL}/* ${DSCRATCH}/
ls -l ${DSCRATCH}
echo ""
#echo "clean up local node WMS and check with ls -l"
#rm -rf ${DLOCAL}
#ls -l ${DLOCAL}

# go to shared dir and ste it as jobdir
echo ""
echo "cd to SHRDIR: " ${SHRDIR}
cd ${SHRDIR}
echo "set JOBDIR to SHRDIR"
JOBDIR=${SHRDIR}
echo "new JOBDIR set as: " ${JOBDIR}

# set RUNDIR to scratch dir created below rundir
echo ""
echo "set RUNDIR to scratch dir on shared/lofar"
RUNDIR=${DSCRATCH}
# -----------------------------------------------------------------------

# cp prefactor files from the jobdir to rundir
setup_sara_dir ${RUNDIR}

# cd into rundir
cd ${RUNDIR}

print_job_info                  #imported from bin/print_job_info.sh

echo ""
echo "---------------------------------------------------------------------------"
echo "START PROCESSING" $OBSID "SUBBAND:" $STARTSB
echo "---------------------------------------------------------------------------"
echo ""
echo "---------------------------"
echo "Starting Data Retrieval"
echo "---------------------------"

download_files srm.txt $PIPELINE_STEP

echo "Download finished, list contents"
ls -l $PWD
du -hs $PWD

replace_dirs            #imported from bin/modify_files.sh

if [[ ! -z ${CAL_OBSID}  ]]
then
 download_cals $CAL_OBSID
fi

if [[ ! -z $( echo $PIPELINE_STEP |grep targ1 ) ]]
  then
    # change to singularity directly here
    # runtaql
    #
    # singularity version with bind paths
    bpath=/var,/mnt
    echo "ADD BIND PATH: ", $bpath
    echo ""
    #
    singularity exec --bind $bpath --pwd $PWD ${sing_img_path} runtaql
    #
    # note: RMextract exists within the singularity image
    #source /cvmfs/softdrive.nl/lofar_sw/env/current_RMextract.sh 

fi


#########
#Starting processing
#########

#/bin -> *.sh script
#start_profile

#-> run_pipeline.sh (change to sing inside run_pipeline.sh in /bin)
run_pipeline

#stop_profile

process_output output


#####################
# Make plots
#
######################

make_plots
#make_pie
# - step3 finished check contents

upload_results

cleanup 

echo ""
echo `date`
echo "---------------------------------------------------------------------------"
echo "FINISHED PROCESSING TOKEN " ${TOKEN}
echo "---------------------------------------------------------------------------"
