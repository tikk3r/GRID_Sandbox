function download_files(){
 
 globus-url-copy >/dev/null 2>&1
 if [[ $? ==  127 ]]
 then
    echo "setup_dl: globus-url-copy doesn't exist. ";exit 13
 fi  
 
 if [[ ! -f ${1}  ]]
 then
     echo "No srm.txt found "
     exit 20 #exit 20=> No download file present
 fi
    
 
 echo "Downloading $(wc -l $1 | awk '{print $1}' ) files"
 python  ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'downloading'
    
 mkdir ${RUNDIR}/Input
 mkdir ${RUNDIR}/Output
    
 case "$2" in
    *SSD1*) echo "Downloading cal1 files"; dl_ssd1 $1 ;; 
*DYSCO*) echo "Downloading cal1 files"; dl_ssd1 $1 ;; 
    *) echo "Unknown Pipeline, Will try to download anyways"; dl_generic $1 ;;
 esac
} 


function dl_ssd1(){
    echo "Downloading files from distrib"
    dl_generic $1

}

