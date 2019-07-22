
function download_cygx_files(){

 case "${PIPELINE_STEP}" in
    cygx_cal1) echo "downloading file for cygx_cal1 step"; download_files $1 ;;
    *) echo "Unsupported pipeline, nothing downloaded"; exit 20;;
 esac
}


function run_cygx_pipeline(){
    echo ""
    echo "Running script"
    #python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'running pipeline'
    #singularity exec /cvmfs/softdrive.nl/fsweijen/singularity/lofar.simg python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'running pipeline'
    /bin/python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'launching_pipeline'
    #python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${SCRIPT} &
    singularity exec /cvmfs/softdrive.nl/fsweijen/singularity/lofar.simg python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${SCRIPT} &

    ls ${PWD}
    ls ${RUNDIR}/Input

    echo "Running script $SCRIPT"
    echo ""
    echo "--------------------------------"
    echo ""

    #python ${SCRIPT}
    #singularity exec /cvmfs/softdrive.nl/fsweijen/singularity/lofar.simg python ${SCRIPT}
    #singularity exec /cvmfs/softdrive.nl/kimberly/tikk3r-lofar-grid-hpccloud-master-lofar.simg python ${SCRIPT}

    export INSTALLDIR=/opt
    source $INSTALLDIR/lofar/lofarinit.sh
    export PYTHONPATH=$INSTALLDIR/RMextract/lib64/python2.7/site-packages/:$INSTALLDIR/lofar/lib64/python2.7/site-packages/:$INSTALLDIR/losoto/lib/python2.7/site-packages/:$INSTALLDIR/lsmtool/lib/python2.7/site-packages/:$INSTALLDIR/pybdsf/lib:$INSTALLDIR/pybdsf/lib64:$INSTALLDIR/python-casacore/lib/python2.7/site-packages/:$INSTALLDIR/python-casacore/lib64/python2.7/site-packages/:$INSTALLDIR/python-casacore/lib/python2.7/site-packages/:$INSTALLDIR/DPPP/lib64/python2.7/site-packages/:$PYTHONPATH
    export PATH=$INSTALLDIR/aoflagger/bin:$PATH
    export PATH=$INSTALLDIR/casacore/bin:$PATH
    export PATH=$INSTALLDIR/DPPP/bin:$PATH
    export PATH=$INSTALLDIR/dysco/bin:$PATH
    export PATH=$INSTALLDIR/losoto/bin:$PATH
    export PATH=$INSTALLDIR/pybdsf/bin:$PATH
    export PATH=/net/lofar1/data1/sweijen/software/LOFAR/pyrmsynth_lite:$PATH
    export PATH=$INSTALLDIR/wsclean/bin:$PATH
    export LD_LIBRARY_PATH=$INSTALLDIR/aoflagger/lib:$INSTALLDIR/armadillo/lib64:$INSTALLDIR/boost/lib:$INSTALLDIR/casacore/lib:$INSTALLDIR/cfitsio/lib:$INSTALLDIR/DPPP/lib:$INSTALLDIR/dysco/lib:$INSTALLDIR/lofar/lib64:$INSTALLDIR/LOFARBeam/lib:$INSTALLDIR/superlu/lib64:$INSTALLDIR/wcslib/:/net/lofar1/data1/sweijen/software/HDF5_1.8/lib:$LD_LIBRARY_PATH
    python ${SCRIPT}


    echo ""
    echo "--------------------------------"
    echo ""
    #python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'
    singularity exec /cvmfs/softdrive.nl/fsweijen/singularity/lofar.simg python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'
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

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'archiving results'
    find . -name instrument |xargs tar -cvf results.tar
    find *MS.fac/ANTENNA |xargs tar -rvf results.tar
    find *MS.fac/FIELD |xargs tar -rvf results.tar
    find *MS.fac/sky |xargs tar -rvf results.tar 

    python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'uploading results'
    globus-url-copy results.tar ${RESULTS_DIR}/${OBSID}/cal1_SB${STARTSB}.tar || { echo "Upload Failed"; exit 31;} # exit 31 => Upload to storage failed
    cd ${RUNDIR}
}

