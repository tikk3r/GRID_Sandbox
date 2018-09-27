#!/bin/bash


function run_with_singularity(){
# first argument is the singularity Image file
# second argument is the script to run

echo "Running script $2 in image $1"

singularity exec $1 ./$2

}


function run_pipeline(){


echo ""
echo "Running test script"
python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'running pipeline'
python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${PARSET} &

ls ${PWD}
ls ${RUNDIR}/Input

echo ""
echo "Testing LOFAR Environment"
echo "Running script $SCRIPT"
echo ""
echo "--------------------------------"
echo ""
chmod a+x $SCRIPT

if [[ -n $SIMG  ]]; then
    echo "Running using the singularity image at ${SIMG}"
    run_with_singularity $SIMG $SCRIPT
else
    echo "Running using LOFAR version at $LOFAR_PATH"
    ./${SCRIPT}
fi


echo ""
echo "--------------------------------"
echo ""
python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'

}
