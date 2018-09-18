#!/bin/bash

function print_disc_job_info(){
    echo "j_info: Run Directory is "${RUNDIR}
    echo "PWD is $(pwd)"

    echo "j_info: Pipeline Step is ${PIPELINE_STEP}"
    echo "j_info:" "INITIALIZATION OF JOB ARGUMENTS"
    echo "j_info: jobdir = " ${JOBDIR}
    echo "j_info: startSB = " ${STARTSB}
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
    echo "Running script"
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
      disc_cal1) upload_cal1 ;;
      disc_cal2) upload_cal2 ;;
      disc_trg1) upload_trg1 ;;
      disc_trg2) upload_trg2 ;;
      disc_trg3) upload_trg3 ;;
      *) echo ""; echo "Can't find PIPELINE type, will tar and upload everything in the Uploads folder "; echo ""; generic_upload ;;
    esac
}


function upload_cal1_ext(){
    uberftp -mkdir ${RESULTS_DIR}/${OBSID}
    #cd ${RUNDIR}/Output
    
    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'      
    #ls -lh ${RUNDIR}/L*.MS*
    tar -cvf results.tar L*.MS*

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'      
    globus-url-copy results.tar ${RESULTS_DIR}/${OBSID}/cal1_SB${STARTSB}.tar || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed
    cd ${RUNDIR}
}


function upload_cal1(){
    uberftp -mkdir ${RESULTS_DIR}/${OBSID}
    #cd ${RUNDIR}/Output

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'

    find . -name instrument |xargs tar -cvf results.tar
    find *MS.cfa/ANTENNA |xargs tar -rvf results.tar
    find *MS.cfa/FIELD |xargs tar -rvf results.tar
    find *MS.cfa/sky |xargs tar -rvf results.tar

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'
    globus-url-copy results.tar ${RESULTS_DIR}/${OBSID}/cal1_SB${STARTSB}.tar || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed
    cd ${RUNDIR}
}


function upload_cal2(){
    uberftp -mkdir ${RESULTS_DIR}/${OBSID}
    #cd ${RUNDIR}/Output

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'
    ls -lh global/smooth*
    tar -cvf results.tar global/smooth* 
    find . -name "global*.h5" |xargs tar -rvf results.tar

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'
    globus-url-copy results.tar ${RESULTS_DIR}/${OBSID}/cal2_allSB.tar || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed
    #cd ${RUNDIR}
}


function upload_trg1(){
    uberftp -mkdir ${RESULTS_DIR}/${OBSID}

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'
    find . -name "*.MS.tfa.phase.amp" |xargs tar -cvf results.tar
    #find . -name "*image.fits" |xargs tar -rvf results.tar

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'
    globus-url-copy results.tar ${RESULTS_DIR}/${OBSID}/trg1_SB${STARTSB}.tar
}

function upload_trg2(){
    uberftp -mkdir ${RESULTS_DIR}/${OBSID}
    #cd ${RUNDIR}/Output

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'
    ls -lh global/smooth*
    tar -cvf results.tar global/smooth*

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'
    globus-url-copy results.tar ${RESULTS_DIR}/${OBSID}/trg2_allSB.tar || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed
    #cd ${RUNDIR}
}


function upload_trg3(){
    uberftp -mkdir ${RESULTS_DIR}/${OBSID}
    #cd ${RUNDIR}/Output

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'
    find . -name "*.MS.tfa.phase.amp.flg" |xargs tar -cvf results.tar
    find . -name "*image.fits" |xargs tar -rvf results.tar

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'
    globus-url-copy results.tar ${RESULTS_DIR}/${OBSID}/trg3_SB${STARTSB}.tar || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed
    #cd ${RUNDIR}
}


function save_plots(){
    echo "Saving plots"
    find . -name "*.png" -exec cp {} ${JOBDIR} \;
}


function download_disc_files(){

 case "${PIPELINE_STEP}" in
    disc_cal1) echo "downloading file for disc_cal1 step"; download_files $1 ;;
    disc_cal2) echo "downloading files for disc_cal2 step"; dl_cal2 ;;
    disc_trg1) echo "downloading files for disc_trg1 step"; dl_trg1 $1 ;;
    disc_trg2) echo "downloading files for disc_trg2 step"; dl_trg2 $1 ;;
    disc_trg3) echo "downloading files for disc_trg3 step"; dl_trg3 $1 ;;
    *) echo "Unsupported pipeline, nothing downloaded"; exit 20;;
 esac
}


function dl_cal2(){
    echo "Downloading instrument tables from cal1 step"
    cd ${RUNDIR}/Input
    trg=${RESULTS_DIR}/${OBSID}/cal1_SB*.tar
    uberftp -ls ${trg} > trgfiles
    while read p; do tt=$( echo $p |awk '{print "gsiftp://gridftp.grid.sara.nl:2811"$NF'}| tr -d '\r'| tr -d '\n' ); globus-url-copy ${tt} ./; done < trgfiles
    wait
    for i in `ls *tar`; do tar -xf $i &&rm $i; done
    wait
    ls ${RUNDIR}/Input
    cd ${RUNDIR}
}


function dl_trg1(){
    echo "Downloading srm and cal2 instrument tables"
    download_files $1
    
    cd ${RUNDIR}/Input
    cal=${RESULTS_DIR}/${CAL_OBSID}/cal2_allSB.tar
    globus-url-copy ${cal} instruments_amp.tar
    wait
    if [[ -e instruments_amp.tar ]]
      then
        tar -xvf instruments_amp.tar
    else
        exit 31 #exit 31=> numpy solutions do not get downloaded
    fi
    wait
    ls ${RUNDIR}/Input
    cd ${RUNDIR}
}


function dl_trg2(){
    echo "Downloading instrument tables from trg1 step"
    cd ${RUNDIR}/Input
    trg=${RESULTS_DIR}/${OBSID}/trg1_SB*.tar
    uberftp -ls ${trg} > trgfiles
    while read p; do tt=$( echo $p |awk '{print "gsiftp://gridftp.grid.sara.nl:2811"$NF'}| tr -d '\r'| tr -d '\n' ); globus-url-copy ${tt} ./; done < trgfiles
    wait
    for i in `ls *tar`; do tar -xf $i &&rm $i; done
    wait
    ls ${RUNDIR}/Input
    cd ${RUNDIR}
}


function dl_trg3(){
    echo "Downloading MS from trg1 and instrument tables from trg2 step"
    cd ${RUNDIR}/Input

    trg1=${RESULTS_DIR}/${OBSID}/trg1_SB${STARTSB}.tar
    globus-url-copy ${trg1} MS_amp.tar
    wait
    if [[ -e MS_amp.tar ]]
      then
        tar -xvf MS_amp.tar
    else
        exit 31 #exit 31=> numpy solutions do not get downloaded
    fi
    wait

    trg2=${RESULTS_DIR}/${OBSID}/trg2_allSB.tar
    globus-url-copy ${trg2} instruments_amp.tar
    wait
    if [[ -e instruments_amp.tar ]]
      then
        tar -xvf instruments_amp.tar
    else
        exit 31 #exit 31=> numpy solutions do not get downloaded
    fi
    wait

    ls ${RUNDIR}/Input
    cd ${RUNDIR}
}


