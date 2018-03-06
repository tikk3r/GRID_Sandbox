#!/bin/bash

function run_pipeline(){


echo ""
echo "Running test script"
python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'running pipeline'
python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${PARSET} &

ls ${PWD}
ls ${RUNDIR}/Input

echo ""
echo "Testing LOFAR Environment"
which NDPPP
NDPPP --version

echo "Running script $SCRIPT"
echo ""
echo "--------------------------------"
echo ""
chmod a+x $SCRIPT

./${SCRIPT}

echo ""
echo "--------------------------------"
echo ""
python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'

}
