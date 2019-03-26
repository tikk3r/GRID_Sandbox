#!/bin/bash

function download_cals(){

 echo "Getting solutions from obsid " $1
 globus-url-copy gsiftp://gridftp.grid.sara.nl:2811/pnfs/grid.sara.nl/data/lofar/user/sksp/diskonly/pipelines/SKSP/prefactor_v1.0/pref_cal2/${1}/${1}.tar file:${RUNDIR}/Input/cal_solutions.tar
 wait
 cd ${RUNDIR}/Input
 if [[ -e cal_solutions.tar ]]
  then
    tar -xvf cal_solutions.tar
 else
    exit 23 #exit 23=> numpy solutions do not get downloaded
 fi
 mkdir -p ${RUNDIR}/prefactor/cal_results
 find ${RUNDIR}/Input/ -name "*.npy" -exec mv {} ${RUNDIR}/prefactor/cal_results/ \; 
 cd ${RUNDIR}
}
