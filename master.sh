#!/bin/bash

# ===================================================================== #
# authors: Alexandar Mechev <apmechev@strw.leidenuniv.nl> --Leiden	#
#	   Natalie Danezi <anatoli.danezi@surfsara.nl>  --  SURFsara    #
#          J.B.R. Oonk <oonk@strw.leidenuniv.nl>    -- Leiden/ASTRON    #
#                                                                       #
# helpdesk: Grid Services <grid.support@surfsara.nl>    --  SURFsara    #
#                                                                       #
# usage: master.sh is called by Launch.py in the GRID_PiCaS_Launcher    #
#                                                                       #
# description:                                                          #
#       Sets Lofar environment, fetches input from Grid Storage,        #
#       Start profiling and run some small scripts to test environment  #
#       finally copy the output to a (temporary) Grid Storage           #
# ===================================================================== #

#--- NEW SD ---
JOBDIR=${PWD}
export OLD_PYTHON=$( which python)
echo $OLD_PYTHON


rm -rm /scratch/* 2>/dev/null

if [ -z "$TOKEN" ] || [  -z "$PICAS_USR" ] || [  -z "$PICAS_USR_PWD" ] || [  -z "$PICAS_DB" ]
 then
  echo "One of Token=${TOKEN}, Picas_usr=${PICAS_USR}, Picas_db=${PICAS_DB} not set"; exit 1 
fi


########################
### Importing functions
########################

for setupfile in `ls bin/* `; do source ${setupfile} ; done
trap cleanup EXIT

############################
#Initialize the environment
############################

setup_LOFAR_env $LOFAR_PATH      ##Imported from setup_LOFAR_env.sh
source /cvmfs/softdrive.nl/lofar_sw/env/losoto_2.0.sh
export PATH=/cvmfs/softdrive.nl/lofar_sw/losoto/2.0/bin/losoto:$PATH
source /cvmfs/softdrive.nl/lofar_sw/wsclean/wsclean-2.6/init_env.sh

if [[ -z "$SCRIPT" ]]; then
    ls "$SCRIPT"
    echo "Script not found"
    exit 3  #exit 3=> Parset doesn't exist                                                               
fi

print_worker_info                      ##Imported from bin/print_info

setup_disc_run_dir                     #imported from bin/setup_run_dir.sh

print_disc_job_info                  #imported from bin/print_job_info.sh

echo ""
echo "---------------------------------------------------------------------------"
echo "START PROCESSING" $OBSID "SUBBAND:" $STARTSB
echo "---------------------------------------------------------------------------"
echo ""
echo "---------------------------"
echo "Starting Data Retrieval"
echo "---------------------------"


download_disc_files srm.txt $PIPELINE_STEP

echo "Download finished, list contents"
ls -l $PWD
du -hs $PWD


#########
#Starting processing
#########

start_profile

python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'running'
run_disc_pipeline
stop_profile

#####################
# Make plots
#
######################

# - step3 finished check contents

#more openTSDB_tcollector/logs/*
#OBSID=$( echo $(head -1 srm.txt) |grep -Po "L[0-9]*" | head -1 )
#echo "Saving profiling data to profile_"$OBSID_$( date  +%s )".tar.gz"
#globus-url-copy file:`pwd`/profile.tar.gz gsiftp://gridftp.grid.sara.nl:2811/pnfs/grid.sara.nl/data/lofar/user/disk/profiling/profile_${OBSID}_$( date  +%s ).tar.gz &
#wait

save_plots
upload_disc_results

cleanup 

echo ""
echo `date`
echo "---------------------------------------------------------------------------"
echo "FINISHED PROCESSING TOKEN " ${TOKEN}
echo "---------------------------------------------------------------------------"
