#!/bin/bash


function replace_dirs(){

 sed -i "s?PREFACTOR_SCRATCH_DIR?$(pwd)?g" ${PARSET}
 if [ -d $(pwd)/Input/*MS ]; then
     sed -i "s?msin\ .*?msin=$(pwd)/Input/*MS?g" ${PARSET}
 fi
 if [ -d $(pwd)/Input/*ms  ]; then
    sed -i "s?msin\ .*?msin=$(pwd)/Input/*ms?g" ${PARSET}
 fi
 sed -i "s?msout\ .*?msout=$(pwd)/Output/results_${PIPELINE_STEP}_${OBSID}_SB${STARTSB}.MS?g" ${PARSET}

 echo "Pipeline Step is "$PIPELINE_STEP
 echo "Adding $OBSID and $PIPELINE_STEP into the tcollector tags"
 sed -i "s?\[\]?\[\ \"obsid=${OBSID}\",\ \"pipeline=${PIPELINE_STEP}_{$OBSID}\"\]?g" tcollector/collectors/etc/config.py

 echo "Modified Parset is:"
 cat ${PARSET}
}
