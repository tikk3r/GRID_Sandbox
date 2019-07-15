
function download_cygx_files(){

 case "${PIPELINE_STEP}" in
    #cygx_cal1) echo "downloading file for cygx_cal1 step"; download_files $1 ;;
    cygx_cal1) echo "downloading file for cygx_cal1 step";  echo "skip";;
    *) echo "Unsupported pipeline, nothing downloaded"; exit 20;;
 esac
}


function run_cygx_pipeline(){
    echo ""
    echo "Running script"
    #python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'running pipeline'
    singularity exec /cvmfs/softdrive.nl/fsweijen/singularity/lofar.simg python  ${JOBDIR}/GRID_PiCaS_Launcher/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'running pipeline'
    #python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${SCRIPT} &
    singularity exec /cvmfs/softdrive.nl/fsweijen/singularity/lofar.simg python ${JOBDIR}/GRID_PiCaS_Launcher/GRID_PiCaS_Launcher/update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${SCRIPT} &

    ls ${PWD}
    ls ${RUNDIR}/Input

    echo "Running script $SCRIPT"
    echo ""
    echo "--------------------------------"
    echo ""

    python ${SCRIPT}
    #singularity exec /cvmfs/softdrive.nl/fsweijen/singularity/lofar.simg python ${SCRIPT}

    echo ""
    echo "--------------------------------"
    echo ""
    #python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'
    singularity exec /cvmfs/softdrive.nl/fsweijen/singularity/lofar.simg python ${JOBDIR}/GRID_PiCaS_Launcher/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'
}



function upload_cygx_results(){
    echo "---------------------------------------------------------------------------"
    echo "Copy the output from the Worker Node to the Grid Storage Element"
    echo "---------------------------------------------------------------------------"

    case "${PIPELINE_STEP}" in
      cygx_cal1) upload_cygx_cal1 ;;
      *) echo ""; echo "Can't find PIPELINE type, will tar and upload everything in the Uploads folder "; echo ""; generic_upload ;;
    esac
}


function upload_cygx_cal1(){
    uberftp -mkdir ${RESULTS_DIR}/${OBSID}
    #cd ${RUNDIR}/Output

    python  ${JOBDIR}/GRID_PiCaS_Launcher/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'
    find . -name instrument |xargs tar -cvf results.tar
    find *MS.cfa/ANTENNA |xargs tar -rvf results.tar
    find *MS.cfa/FIELD |xargs tar -rvf results.tar
    find *MS.cfa/sky |xargs tar -rvf results.tar 

    python  ${JOBDIR}/GRID_PiCaS_Launcher/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'
    globus-url-copy results.tar ${RESULTS_DIR}/${OBSID}/cal1_SB${STARTSB}.tar || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed
    cd ${RUNDIR}
}

