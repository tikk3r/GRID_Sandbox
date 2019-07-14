
function download_disc_files(){

 case "${PIPELINE_STEP}" in
    cygx_cal1) echo "downloading file for cygx_cal1 step"; download_files $1 ;;
    *) echo "Unsupported pipeline, nothing downloaded"; exit 20;;
 esac
}


function upload_disc_results(){
    echo "---------------------------------------------------------------------------"
    echo "Copy the output from the Worker Node to the Grid Storage Element"
    echo "---------------------------------------------------------------------------"

    case "${PIPELINE_STEP}" in
      cygx_cal1) upload_cal1 ;;
      *) echo ""; echo "Can't find PIPELINE type, will tar and upload everything in the Uploads folder "; echo ""; generic_upload ;;
    esac
}

function upload_cal1(){
    uberftp -mkdir ${RESULTS_DIR}/${OBSID}
    #cd ${RUNDIR}/Output

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'
    tar -cvf results.tar L*.MS*

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'
    globus-url-copy results.tar ${RESULTS_DIR}/${OBSID}/cal1_SB${STARTSB}.tar || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed
    cd ${RUNDIR}
}

