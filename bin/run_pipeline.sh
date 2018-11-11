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
which wsclean
wsclean --version

echo "WSClean on the data in Input"
ls ${RUNDIR}/Input/
echo ""
echo "--------------------------------"
echo ""
export WSCLEAN_PARAMS=""
while read -r param;  do export WSCLEAN_PARAMS="$WSCLEAN_PARAMS $param"; done < ${PARSET}

echo "RUNNING WSCLEAN WITH PARAMETERS: "
echo ${WSCLEAN_PARAMS}
echo ""
wsclean -name ${RUNDIR}/Output/Result.img ${WSCLEAN_PARAMS}  ${RUNDIR}/Input/*

echo ""
echo "--------------------------------"
echo ""
python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'

}
