#!/bin/bash

function runtaql(){

    ls ${RUNDIR}/Input/
    echo "running taql on "$( ls -d ${RUNDIR}/Input/*${OBSID}*SB*  )"/SPECTRAL_WINDOW"
    #FREQ=$( singularity -v exec -B /scratch,$PWD $SIMG echo "select distinct REF_FREQUENCY from $( ls -d ${RUNDIR}/Input/*${OBSID}*SB* )::SPECTRAL_WINDOW"| singularity -v exec -B /scratch,$PWD $SIMG taql | tail -n 2 | head -n 1)
    FREQ=$(singularity -v exec -B /scratch,$PWD $SIMG taql "select distinct REF_FREQUENCY from $(basename $(ls -d ${RUNDIR}/Input/*${OBSID}*SB*))::SPECTRAL_WINDOW" | tail -n 1)
    export ABN=$( python  update_token_freq.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} ${FREQ} )
    echo "Frequency is "${FREQ}" and Absolute Subband is "${ABN}
    mv prefactor/results/L*ms ${RUNDIR}  #moves untarred results from targ1 to ${RUNDIR} 


}

