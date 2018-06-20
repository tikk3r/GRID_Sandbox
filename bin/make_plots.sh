function make_pie(){
   
   xmlfile=$( find . -name "*statistics.xml" 2>/dev/null)
   #cp piechart/autopie.py .
   ./autopie.py ${xmlfile} PIE_${OBSID}_${PIPELINE}.png
   [[ -e PIE_${OBSID}_${PIPELINE}.png  ]] && cp PIE_${OBSID}_${PIPELINE}.png ${WORKDIR}
   
}

function make_plots(){
   python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'making_plots'

   if [[ ! -z $( echo $pipelinetype |grep targ2 ) ]]
     then
       cd ${RUNDIR}
       ./prefactor/scripts/plot_solutions_all_stations.py -p $( ls -d ${RUNDIR}/prefactor/results/*ms )/instrument_directionindependent/ ${JOBDIR}/GSM_CAL_${OBSID}_ABN${STARTSB}_plot.png
   fi
   
#   xmlfile=$( find . -name "*statistics.xml" 2>/dev/null)
#   cp piechart/autopie.py .
#   ./autopie.py ${xmlfile} PIE_${OBSID}.png
#   
#   find ${RUNDIR} -name "PIE*png"|xargs tar -zcf pngs.tar.gz
   find ${RUNDIR} -name "*.png" -exec cp {} ${JOBDIR} \;
#  cp PIE_${OBSID}.png ${JOBDIR}
   cp ${RUNDIR}/prefactor/cal_results/*png ${JOBDIR}
   
}

