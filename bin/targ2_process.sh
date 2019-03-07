#!/bin/bash

function runtaql(){

    echo "running taql on "$( ls -d ${RUNDIR}/Input/*${OBSID}*SB*  )"/SPECTRAL_WINDOW"
    FREQ=$( singularity exec $SIMG echo "select distinct REF_FREQUENCY from $( ls -d ${RUNDIR}/Input/*${OBSID}*SB* )/SPECTRAL_WINDOW"| $SIMG exec taql | tail -1 | head -1)
    A_SBN=$( python  update_token_freq.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} ${FREQ} )
    echo "Frequency is "${FREQ}" and Absolute Subband is "${A_SBN}
    mv prefactor/results/L*ms ${RUNDIR}  #moves untarred results from targ1 to ${RUNDIR} 



}

