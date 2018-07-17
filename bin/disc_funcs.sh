#!/bin/bash

function print_disc_job_info(){
    echo "j_info: Run Directory is "${RUNDIR}
    echo "PWD is $(pwd)"

    echo "j_info: Pipeline Step is ${PIPELINE_STEP}"
    echo "j_info:" "INITIALIZATION OF JOB ARGUMENTS"
    echo "j_info: jobdir = " ${JOBDIR}
    echo "j_info: startSB = " ${STARTSB}
    echo "j_info: numSB = " ${NUMSB}
    echo "j_info: script = " ${SCRIPT}
    echo "j_info: OBSID =" ${OBSID}
}


function setup_disc_run_dir(){
    case "$( hostname -f )" in
      *sara*) export RUNDIR=`mktemp -d -p ${JOBDIR}`; setup_disc_sara_dir ${RUNDIR} ;;
      *leiden*) setup_leiden_dir ;;
      node[0-9]*) export RUNDIR=`mktemp --directory --tmpdir=/data/lofar/grid_jobs`; setup_disc_sara_dir ${RUNDIR} ;;
      *) echo "Can't find host in list of supported clusters"; exit 11;;
    esac
}


function setup_disc_sara_dir(){
    export PYTHONPATH=${PWD}:$PYTHONPATH

    cp srm.txt $1 #this is a fallthrough by taking the srm from the token not from the sandbox!
    cp ${SCRIPT} $1
    cp -r $PWD/tcollector $1
    cp -r $PWD/skymodels $1
    cp -r $PWD/tools $1
    cp pipeline.cfg $1
    cd ${RUNDIR}
    touch pipeline_status

    mkdir -p Input
    mkdir -p Output
}

function run_disc_pipeline(){
    echo ""
    echo "Running test script"
    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'running pipeline'
    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${SCRIPT} &

    ls ${PWD}
    ls ${RUNDIR}/Input

    echo "Running script $SCRIPT"
    echo ""
    echo "--------------------------------"
    echo ""

    python ${SCRIPT}

    echo ""
    echo "--------------------------------"
    echo ""
    python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'
}


function upload_disc_results(){
    echo "---------------------------------------------------------------------------"
    echo "Copy the output from the Worker Node to the Grid Storage Element"
    echo "---------------------------------------------------------------------------"

    case "${PIPELINE_STEP}" in
      *cal1*) upload_cal1_ext ;;
      *) echo ""; echo "Can't find PIPELINE type, will tar and upload everything in the Uploads folder "; echo ""; generic_upload ;;
    esac
}


function upload_disc_cal1(){
   find ${RUNDIR} -name "instrument" |xargs tar -cvf ${RUNDIR}/Output/instruments_${OBSID}_${STARTSB}.tar  
   find ${RUNDIR} -iname "FIELD" |grep work |xargs tar -rvf ${RUNDIR}/Output/instruments_${OBSID}_${STARTSB}.tar 
   find ${RUNDIR} -iname "ANTENNA" |grep work |xargs tar -rvf ${RUNDIR}/Output/instruments_${OBSID}_${STARTSB}.tar
  
   uberftp -mkdir ${RESULTS_DIR}/${OBSID}
  
   globus-url-copy ${RUNDIR}/Output/instruments_${OBSID}_${STARTSB}.tar ${RESULTS_DIR}/${OBSID}/instruments_${OBSID}_SB${STARTSB}.tar  || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed   
}


function upload_cal1_ext(){
    uberftp -mkdir ${RESULTS_DIR}/${OBSID}
    mv ${RUNDIR}/L*.MS* ${RUNDIR}/Output/
    cd ${RUNDIR}/Output

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'      
    tar -cvf results.tar $PWD/* --remove-files

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'      
    globus-url-copy file:${RUNDIR}/Output/results.tar ${RESULTS_DIR}/${OBSID}/MS_${OBSID}_SB${STARTSB}.tar || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed
    cd ${RUNDIR}
}


function save_plots(){
    echo "Saving plots"
    find . -name "*.png" -exec cp {} ${JOBDIR} \;
}

