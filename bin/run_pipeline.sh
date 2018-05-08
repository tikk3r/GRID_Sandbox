#!/bin/bash

function run_pipeline(){

# -----------------------------------------------------------------------
# PSNC VERSION
LOGFILE=/tmp/$USER.creamce.lofar.psnc.pl.log

echo "start run pipeline" >> $LOGFILE
date >> $LOGFILE
ls -l >> $LOGFILE

# SETTING PATH TO SINGULARITY IMAGE
#sing_img_path=/cvmfs/softdrive.nl/oonk/SINGULARITY_IMAGES/C7_2_20_2_sml_env/lofar-2_20_2_c7_sml_env.simg
sing_img_path=/mnt/lustre/inula/shared/lofar/oonk/lofar-2_20_2_c7_sml_env.simg
#
#
echo "SINGULARITY IMAGE: ", ${sing_img_path}
echo "CHECKING PATH OF SINGULARITY IMAGE (ls -l): "
ls -l ${sing_img_path}
echo ""
#
# set bind paths
bpath=/var,/mnt #multiple paths are comma separated
echo "ADD BIND PATH: ", $bpath
echo ""
echo "singularity ndppp test in: run pipeline"
sing_img_path=/mnt/lustre/inula/shared/lofar/oonk/lofar-2_20_2_c7_sml_env.simg
singularity exec --bind $bpath --pwd $PWD ${sing_img_path} NDPPP -h
echo ""
# -----------------------------------------------------------------------


echo ""
echo "Running Prefactor Parset"
python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'running pipeline'
python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${PARSET} &

singularity exec --bind $bpath --pwd ${PWD} ${sing_img_path} which genericpipeline.py
echo ${PARSET}
ls pipeline.cfg

#
### UPDATE TO SINGULARITY ###
#genericpipeline.py ${PWD}/${PARSET} -d -c pipeline.cfg > output
singularity exec --bind $bpath --pwd ${PWD} ${sing_img_path} echo $PYTHONPATH

singularity exec --bind $bpath --pwd ${PWD} ${sing_img_path} genericpipeline.py ${PWD}/${PARSET} -d -c pipeline.cfg > output
#

echo "Output file:"
wc output
python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'

}
