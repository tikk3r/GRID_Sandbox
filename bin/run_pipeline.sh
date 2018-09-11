#!/bin/bash

function run_pipeline(){


echo ""
echo "Running test script"
$OLD_PYTHON update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'running pipeline'
$OLD_PYTHON update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${PARSET} &

#echo ""
#echo "Testing LOFAR Environment"
#source /cvmfs/softdrive.nl/lofar_sw/factor_prereqs/dysco/init_env.sh

SINGULARITY_IMAGE=/cvmfs/softdrive.nl/fsweijen/singularity/lofar_3_1_4.simg
echo "Using singularity image at $SINGULARITY_IMAGE"
singularity exec $SINGULARITY_IMAGE NDPPP -v
singularity exec $SINGULARITY_IMAGE NDPPP ${PARSET}

$OLD_PYTHON update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'

}
