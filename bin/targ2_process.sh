#!/bin/bash

function runtaql(){

    echo "running taql on "$( ls -d ${RUNDIR}/Input/*${OBSID}*SB*  )"/SPECTRAL_WINDOW"
    FREQ=$( singularity exec -B $PWD $SIMG echo "select distinct REF_FREQUENCY from $( ls -d ${RUNDIR}/Input/*${OBSID}*SB* )::SPECTRAL_WINDOW"| singularity exec -B $PWD $SIMG taql | tail -n 2 | head -n 1)
    export ABN=$( python  update_token_freq.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} ${FREQ} )
    echo "Frequency is "${FREQ}" and Absolute Subband is "${ABN}
    mv prefactor/results/L*ms ${RUNDIR}  #moves untarred results from targ1 to ${RUNDIR} 


}

