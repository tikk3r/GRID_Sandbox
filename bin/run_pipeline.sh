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

wsclean -name ${RUNDIR}/Output/Result.img -size 1024 1024 -mgain 0.65 -pol I -j 2 -mem 8.0 -weight briggs 0.0 -scale 0.00694 -niter 2000 ${RUNDIR}/Input/*

echo ""
echo "--------------------------------"
echo ""
python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'

}
