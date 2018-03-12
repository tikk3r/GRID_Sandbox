#!/bin/bash

function run_pipeline(){


echo ""
echo "Running test script"
$OLD_PYTHON update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'running pipeline'
$OLD_PYTHON update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${PARSET} &

echo ""
echo "Testing LOFAR Environment"
source /cvmfs/softdrive.nl/lofar_sw/factor_prereqs/dysco/init_env.sh

NDPPP --version
NDPPP ${PARSET}

$OLD_PYTHON update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'

}
