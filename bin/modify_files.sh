#!/bin/bash


function replace_dirs(){

 if [ -d $(pwd)/Input/*MS ]; then
     sed -i "s?msin\ .*?msin=$(pwd)/Input/*MS?g" ${PARSET}
 fi
 if [ -d $(pwd)/Input/*ms  ]; then
    sed -i "s?msin\ .*?msin=$(pwd)/Input/*ms?g" ${PARSET}
 fi
 sed -i "s?msout\ .*?msout=$(pwd)/Output/results_${PIPELINE_STEP}_${OBSID}_SB${STARTSB}.MS?g" ${PARSET}


 echo "Modified Parset is:"
 cat ${PARSET}
 echo ""
}
