#!/bin/bash


function run_with_singularity(){
# first argument is the singularity Image file
# second argument is the parset to run
echo $1 $2

singularity exec $1 which NDPPP
singularity exec $1 NDPPP -v
singularity exec $1 NDPPP $2


}

function run_pipeline(){

echo ""
echo "Running test script"
$OLD_PYTHON update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'running pipeline'
$OLD_PYTHON update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${PARSET} &

#echo ""
#echo "Testing LOFAR Environment"
#source /cvmfs/softdrive.nl/lofar_sw/factor_prereqs/dysco/init_env.sh

#SINGULARITY_IMAGE=/cvmfs/softdrive.nl/fsweijen/singularity/lofar_3_1_4.simg


if [[ -n $SIMG   ]]; then
    echo "Using singularity image at $SIMG"
    run_with_singularity $SIMG $SCRIPT
  else
    which NDPPP
    NDPPP -v
    NDPPP ${PARSET}
fi

$OLD_PYTHON update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'

}
