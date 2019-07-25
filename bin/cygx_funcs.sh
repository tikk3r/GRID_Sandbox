
function download_cygx_files(){
 case "${PIPELINE_STEP}" in
    cygx_cal1) echo "downloading file for cygx_cal1 step"; download_files $1 ;;
    cygx_cal2) echo "downloading file for cygx_cal2 step"; dl_cygx_cal2 ;;
    cygx_trg1) echo "downloading file for cygx_trg1 step"; download_files $1 ;;
    cygx_trg2) echo "downloading file for cygx_trg2 step"; dl_cygx_trg2 $1 ;;
    *) echo "Unsupported pipeline, nothing downloaded"; exit 20;;
 esac
}


function dl_cygx_cal2(){
    echo "Downloading cal1 ms"

    cd ${RUNDIR}/Input
    cal=${RESULTS_DIR}/${OBSID}/cal1_SB${STARTSB}.tar
    globus-url-copy ${cal} cal.tar
    wait
    if [[ -e cal.tar ]]
      then
        tar -xvf cal.tar
    else
        exit 31 #exit 31=> numpy solutions do not get downloaded
    fi
    wait
    ls ${RUNDIR}/Input
    cd ${RUNDIR}
}

function dl_cygx_trg2(){
    echo "Downloading trg1 ms and cal2 instrument tables"

    cd ${RUNDIR}/Input
    trg=${RESULTS_DIR}/${OBSID}/trg1_SB${STARTSB}.tar
    globus-url-copy ${trg} trg.tar
    wait
    if [[ -e trg.tar ]]
      then
        tar -xvf trg.tar
    else
        exit 31 #exit 31=> numpy solutions do not get downloaded
    fi
    wait

    let NUM=240
    CALSB=`expr $STARTSB + $NUM`
    cal=${RESULTS_DIR}/${OBSID}/cal2_SB${CALSB}.tar
    globus-url-copy ${cal} cal.tar
    wait
    if [[ -e cal.tar ]]
      then
        tar -xvf cal.tar
    else
        exit 31 #exit 31=> numpy solutions do not get downloaded
    fi
    wait

    
    ls ${RUNDIR}/Input
    cd ${RUNDIR}
}

function run_cygx_pipeline(){
 case "${PIPELINE_STEP}" in
    cygx_cal1) echo "running script for cygx_cal1 step"; run_cygx_step1 ;;
    cygx_cal2) echo "running script for cygx_cal1 step"; run_cygx_step ;;
    cygx_trg1) echo "running script for cygx_cal1 step"; run_cygx_step1 ;;
    cygx_trg2) echo "running script for cygx_cal1 step"; run_cygx_step ;;
    *) echo "Unsupported pipeline, nothing downloaded"; exit 20;;
 esac
}


function run_cygx_step(){
    python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'launching_pipeline'
    python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${SCRIPT} &    

    ls ${PWD}
    ls ${RUNDIR}/Input

    echo "Running script $SCRIPT"
    echo ""
    echo "--------------------------------"
    echo ""
    
    singularity exec /cvmfs/softdrive.nl/kimberly/tikk3r-lofar-grid-hpccloud-master-lofar.simg python ${SCRIPT}

    echo ""
    echo "--------------------------------"
    echo ""

    python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'
}


function run_cygx_step1(){
    python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'launching_pipeline'
    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${SCRIPT} &

    ls ${PWD}
    ls ${RUNDIR}/Input

    echo "Running script $SCRIPT"
    echo ""
    echo "--------------------------------"
    echo ""

    source /cvmfs/softdrive.nl/kimberly/init_dlofar_3_2_17.sh 
    #echo ${SPATH}
    #echo ${SINGULARITYENV_PYTHONPATH}
    #echo ${SINGULARITYENV_PREPEND_PATH}
    #echo ${SINGULARITYENV_PREPEND_LD_LIBRARY_PATH}
    #echo "path"
    #singularity exec /cvmfs/softdrive.nl/kimberly/dlofar_3_2_17.simg echo ${SPATH}
    #echo "python path"
    #singularity exec /cvmfs/softdrive.nl/kimberly/dlofar_3_2_17.simg echo ${SINGULARITY_PYTHONPATH}
    #echo "prepend_path"
    #singularity exec /cvmfs/softdrive.nl/kimberly/dlofar_3_2_17.simg echo ${SINGULARITYENV_PREPEND_PATH}
    #echo "library path"
    #singularity exec /cvmfs/softdrive.nl/kimberly/dlofar_3_2_17.simg echo ${SINGULARITYENV_PREPEND_LD_LIBRARY_PATH}
    #echo "start script"
    
    singularity exec -B $PWD /cvmfs/softdrive.nl/kimberly/dlofar_3_2_17.simg env LD_LIBRARY_PATH=$SINSTALLDIR/aoflagger/lib:$SINSTALLDIR/armadillo/lib64:$SINSTALLDIR/boost/lib:$SINSTALLDIR/casacore/lib:$SINSTALLDIR/cfitsio/lib:$SINSTALLDIR/DPPP/lib:$SINSTALLDIR/dysco/lib:$SINSTALLDIR/lofar/lib:$SINSTALLDIR/LOFARBeam/lib:$SINSTALLDIR/superlu/lib64:$SINSTALLDIR/wcslib/lib/ python ${SCRIPT}

    echo ""
    echo "--------------------------------"
    echo ""
    
    python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'
}


function upload_cygx_results(){
    echo "---------------------------------------------------------------------------"
    echo "Copy the output from the Worker Node to the Grid Storage Element"
    echo "---------------------------------------------------------------------------"

    case "${PIPELINE_STEP}" in
      cygx_cal1) upload_cygx_cal1 ;;
      cygx_cal2) upload_cygx_cal2 ;;
      cygx_trg1) upload_cygx_trg1 ;;
      cygx_trg2) upload_cygx_trg2 ;;
      *) echo ""; echo "Can't find PIPELINE type, will tar and upload everything in the Uploads folder "; echo ""; generic_upload ;;
    esac
}


function upload_cygx_cal1(){
    uberftp -mkdir ${RESULTS_DIR}/${OBSID}

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'
    find . -name *.MS.fac |xargs tar -cvf results.tar

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'
    globus-url-copy results.tar ${RESULTS_DIR}/${OBSID}/cal1_SB${STARTSB}.tar || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed
    cd ${RUNDIR}
}


function upload_cygx_cal2(){
    uberftp -mkdir ${RESULTS_DIR}/${OBSID}

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'
    find . -name instrument*h5 |xargs tar -cvf results.tar
    find . -name "*fits" |xargs tar -rvf results.tar

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'
    globus-url-copy results.tar ${RESULTS_DIR}/${OBSID}/cal2_SB${STARTSB}.tar || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed
    cd ${RUNDIR}
}


function upload_cygx_trg1(){
    uberftp -mkdir ${RESULTS_DIR}/${OBSID}

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'
    find . -name *.MS.f |xargs tar -cvf results.tar

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'
    globus-url-copy results.tar ${RESULTS_DIR}/${OBSID}/trg1_SB${STARTSB}.tar || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed
    cd ${RUNDIR}
}

function upload_cygx_trg2(){
    uberftp -mkdir ${RESULTS_DIR}/${OBSID}

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'
    find . -name *.MS.f.sub |xargs tar -cvf results.tar

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'
    globus-url-copy results.tar ${RESULTS_DIR}/${OBSID}/trg2_SB${STARTSB}.tar || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed
    cd ${RUNDIR}
}


