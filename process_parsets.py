import sys 


upstream_file_name = sys.argv[2]
LRT_file_name = sys.argv[1]

parset_keys={}
with open(LRT_file_name,'r') as orig_file:
    orig_keys = {} 
    for line in orig_file: 
        if line[0]=='!': 
            orig_keys[line.split("=")[0].replace("!","").strip()] = line.split("=")[1] 
        elif "@NO_OVERWRITE@" in line: 
            orig_keys[line.split("=")[0].replace("!","").strip()] = line.split("=")[1] 

keep_keys={}
for k,v in orig_keys.items(): 
    if "@NO_OVERWRITE@" in v: 
        keep_keys[k]=v.split("#")[0].strip() 



with open(upstream_file_name,'r') as upstream_file: 
    with open("merged.parset",'w') as merged_file: 
        for line in upstream_file: 
            if "=" not in line: 
                merged_file.write(line) 
            else: 
                tmp_key = line.split("=")[0].replace("!","").strip() 
                left_pad = " "*(26 - len(tmp_key)) 
                if tmp_key in keep_keys.keys(): 
                    right_pad = " "*(70 - len(left_pad) - len(tmp_key) - len(keep_keys[tmp_key]))  
                    if line[0]=="!": 
                        merged_file.write("! {0}{1}= {2}{3}##  From GRID_LRT version of the parset!\n".format(tmp_key,left_pad,keep_keys[tmp_key], right_pad)) 
                    else: 
                        merged_file.write("{0}  {1}= {2}{3}##  From GRID_LRT version of the parset!\n".format(tmp_key,left_pad,keep_keys[tmp_key], right_pad)) 
                else: 
                    merged_file.write(line) 

