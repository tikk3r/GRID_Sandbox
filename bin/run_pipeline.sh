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

wsclean -name ${RUNDIR}/Output/Result.img -size $WSCLEAN_SIZE $WSCLEAN_SIZE -mgain $WSCLEAN_MGAIN -pol $WSCLEAN_POL -j 6 -mem 20.0 -weight $WSCLEAN_WEIGHT -scale $WSCLEAN_SCALE -niter $WSCLEAN_NITER ${RUNDIR}/Input/*

echo ""
echo "--------------------------------"
echo ""
python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'

}
