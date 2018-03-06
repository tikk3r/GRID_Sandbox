#!/bin/bash


function replace_dirs(){

 sed -i "s?PREFACTOR_SCRATCH_DIR?$(pwd)?g" ${PARSET}
 sed -i "s?msin\ .*?msin=$(pwd)/Input/*MS?g" ${PARSET}
 sed -i "s?msout\ .*?msout=$(pwd)/Output/results_${OBSID}.MS?g" ${PARSET}

 echo "Pipeline Step is "$PIPELINE_STEP
 echo "Adding $OBSID and $PIPELINE_STEP into the tcollector tags"
 sed -i "s?\[\]?\[\ \"obsid=${OBSID}\",\ \"pipeline=${PIPELINE_STEP}_{$OBSID}\"\]?g" tcollector/collectors/etc/config.py

}
