############################
# Sampath Kunapareddy      #
# sampath.a926@gmail.com   #
############################
#!/bin/bash
#set -x
clear
export IFSBKP=$IFS
export IFS=$'\n'
export CS="IGNORECASE=1"
export USER=$(whoami)
if [[ -z $USER ]]; then export USER=$LOGNAME ;fi
export BOLD="\e[1m"
export ESC="\e[0m"
export check=1

#opt#chmod 755 ~/appinfo.sh
#opt#if [[ ! -f ~/.bash_profile ]]; then touch ~/.bash_profile; fi
#opt#if [[ -z $(echo $SHELL | grep -i bash) ]]; then
#opt#	if [[ -z $(cat ~/.bash_profile | grep 'alias appinfo="/bin/bash/ ~/appinfo.sh"') ]]; then echo "alias appinfo=\"/bin/bash ~/appinfo.sh\"" >> ~/.bash_profile; echo "\nDONE\n"; else echo -e "\nAlias, already exists\n"; fi
#opt#else
#opt#	if [[ -z $(cat ~/.bash_profile | grep 'alias appinfo=". ~/appinfo.sh"') ]]; then echo "alias appinfo=\". ~/appinfo.sh\"" >> ~/.bash_profile; echo -e "\nDONE\n";else echo -e "\nAlias, already exists\n"; fi
#opt#fi
#opt#.  ~/.bash_profile

cd ~
echo -e "${BOLD}$(pwd)${ESC}"
export ALL_PROC=$(ps ux | grep -i "java\|httpd" | grep -v -i "grep\|bash\|TTY\|startWebLogic.sh\|startNodeManager.sh\|nohup")
export TOT_PROC=$(ps ux | grep -i "java\|httpd" | grep -v -i "grep\|bash\|TTY\|startWebLogic.sh\|startNodeManager.sh\|nohup" | wc -l)
APPNM() {
  APPD=""
  export APPD=$(echo $1 | awk -F 'appdynamics.agent.nodeName=' '{print $2}' | awk '{print $1}' | grep -v ^$)
}
TIMEE() {
  TIME=""
  PID=$(echo $1 | awk '{print $2}' | grep -v ^$)
  export TIME=$( ps -eo pid,lstart | awk '{print $1" "$2"."$3$4"."$5" "$6}' | grep -w ${PID} | awk '{print $2" "$3}' | grep -v ^$)
}

echo -e "\n"
echo -e "-----------------------------------------------------------------------------"
echo -e "${BOLD}Number of running/active processes for user: \"$USER\" are -- **** \" $TOT_PROC \" **** ${ESC}"
echo -e "-----------------------------------------------------------------------------"
echo ""
echo -e "########################################"
echo -e "#   ${BOLD}Appdynamics TIERs Name and NODEs ${ESC}  #"
echo -e "########################################"
ATIER=$(for i in $ALL_PROC; do echo $i | awk -F 'appdynamics.agent.tierName=' '{print $2}' | awk '{print $1}' | grep -v ^$; done | sort | uniq)
echo -e "\n${BOLD}TIERs:${ESC}"
if [[ -z $ATIER ]]; then echo -e "  --NO AppD TIERs found" ;else echo -e "${ATIER}";fi

for i in $ALL_PROC; do
  AJ=`echo $i | awk -F "-javaagent:" '{print $2}' | awk -F "javaagent.jar" '{print $1}'`
  if [[ ! -z $AJ ]]; then ANODE=$(echo "$(ls -d ${AJ}/logs/* 2>/dev/null | awk -F '/' '{print $NF}')" | sort | uniq | tr ' ' '\n' ); fi
done

if [[ $(echo $ANODE | tr ' ' '\n' | wc -l) -lt 10 ]]; then
  echo -e "\n${BOLD}NODEs:${ESC}"
  if [[ -z $ANODE ]]; then echo -e "  --NO AppD NODESs found"; else echo -e "${ANODE}";fi
fi

if [[ $TOT_PROC -ge 1 ]]; then
  cat /dev/null > ~/activeproc.txt
  echo ""
  SPACE='               '
  echo -e "###############################################################################################################################################################################"
  echo -e "#${SPACE}${BOLD}Node/Process INFO${ESC}${SPACE}----${SPACE}${BOLD}UPTIME${ESC}${SPACE}----${SPACE}${BOLD}PID${ESC}${SPACE}----${SPACE}${BOLD}APPD-NODE${ESC}${SPACE}      #"
  echo -e "###############################################################################################################################################################################"
  for i in $ALL_PROC; do
    PROC="";APPD="";SERVERNAME="";CONTROLLER="";CONF="";JAR="";LAST="";ATGHME="";SNAME="";OBIEE="";OEM="";WLS="";DHME="";MSorSL="";SPRING="";APROC=""
    if [[ ! -z $(echo $i | grep -i "catalina.home") ]]; then
      APPNM $i; TIMEE $i
      CHME=$(echo $i | awk -F "catalina.home=" '{print $2}' $CS | awk '{print $1}' | grep -v ^$)
      CBASE=$(echo $i | awk -F "catalina.base=" '{print $2}' $CS | awk '{print $1}' | grep -v ^$)
      if [[ "$CHME" == "$CBASE" ]]; then PROC=$(echo "${CBASE}" | awk '{$1=$1;print}'); else PROC=$(echo "${CBASE}  ${CHME}" | awk '{$1=$1;print}');fi
          
    elif [[ ! -z $(echo $i | grep -i "weblogic.Server\|weblogic.NodeManager\|derby\|emagent\|obi") ]]; then
      APPNM $i; TIMEE $i
      WLS=$(echo $i | awk -F "weblogic.Name=" '{print $2}' $CS |  awk '{print $1}' |  grep -v ^$)
      DHME=$(echo $i | awk -F "domain.home=" '{print $2}' $CS |  awk '{print $1}' |  grep -v ^$)
      OEM=$(echo $i | grep -i emagent | awk -F "-cp" '{print $2}' $CS | awk -F ":" '{print $1}' $CS |  awk '{print $1}' |  grep -v ^$)
      if [[ -z $DHME ]]; then DHME=$(echo $i | awk -F "wls.home=" '{print $2}' $CS |  awk '{print $1}' |  grep -v ^$);fi
      if [[ -z $WLS ]] && [[ ! -z $(echo $i |grep -i "derby") ]]; then WLS=Derby; DHME=$(echo $i | awk -F "Dderby.system.home=" '{print $2}' $CS |  awk '{print $1}' |  grep -v ^$);fi
      if [[ -z $WLS ]] && [[ ! -z $(echo $i |grep "weblogic.NodeManager") ]]; then WLS="weblogic.NodeManager"; DHME=$(echo $i |awk -F "Dweblogic.RootDirectory=" '{print $2}' $CS|awk '{print $1}'|grep -v ^$);fi
      if [[ ! -z $(echo $i | grep -i "obips[1-9]") ]]; then  OBIEE="OBIEE: $(echo $i | awk -F "Dinstance.name=" '{print $2}' | awk '{print $1}' | grep -v '^$') :managed BI presentation server"; fi
      if [[ ! -z $(echo $i | grep -i "obijh[1-9]") ]]; then  OBIEE="OBIEE: $(echo $i | awk -F "Dinstance.name=" '{print $2}' | awk '{print $1}' | grep -v '^$') :managed BI Java host server"; fi
      if [[ ! -z $(echo $i | grep -i "obiccs[1-9]") ]]; then OBIEE="OBIEE: $(echo $i | awk -F "Dinstance.name=" '{print $2}' | awk '{print $1}' | grep -v '^$') :managed BI clustering server"; fi
      if [[ ! -z $(echo $i | grep -i "obisch[1-9]") ]]; then OBIEE="OBIEE: $(echo $i | awk -F "Dinstance.name=" '{print $2}' | awk '{print $1}' | grep -v '^$') :managed BI scheduler server"; fi
      if [[ ! -z $(echo $i | grep -i "obis[1-9]") ]];   then OBIEE="OBIEE: $(echo $i | awk -F "Dinstance.name=" '{print $2}' | awk '{print $1}' | grep -v '^$') :managed BI NQ server"; fi
      PROC=$(echo "${OEM} ${OBIEE} ${WLS} ${DHME}" | awk '{$1=$1;print}')
          
    elif [[ ! -z $(echo $i | grep -i "jboss.server\|jboss-eap") ]]; then
      APPNM $i; TIMEE $i
      SERVERNAME=$(echo $i | awk -F "jboss.server.name=" '{print $2}' $CS | awk '{print $1}' |  grep -v ^$)
      CONTROLLER=$(echo $i | awk -F "-D\\\[" '{print $2}' |  awk -F "\\\]" '{print $1}' |  grep -v ^$)
      MSorSL=$(echo $i | awk -F '--host-config=' '{print $2}' | awk '{print $1}' |  grep -v ^$)
      if [[ -z $SERVERNAME ]]; then SERVERNAME=$(echo $i | awk -F "-Djboss.server.log.dir=" '{print $2}' $CS | awk '{print $1}' | awk -F "/" '{print $NF}');fi
      if [[ -z $SERVERNAME ]]; then SERVERNAME=$APPD; fi
      PROC=$(echo -e "${SERVERNAME} ${CONTROLLER} ${MSorSL}" | awk '{$1=$1;print}')
          
    elif [[ ! -z $(echo $i | grep -i "ATG") ]]; then
      APPNM $i; TIMEE $i
      SERVERNAME=$(echo $i | awk -F "java.rmi.server.hostname=" '{print $2}' $CS |  awk '{print $1}' |  grep -v ^$)
      ATGHME=$(echo $i | awk -F "atg.dynamo.server.home=" '{print $2}' $CS |  awk '{print $1}' |  grep -v ^$)
      CONTROLLER=$(echo $i | awk -F "-D\\\[" '{print $2}' |  awk -F "\\\]" '{print $1}' |  grep -v ^$)
      SNAME=$(echo $i | awk -F "server.name=" '{print $2}' $CS |  awk '{print $1}' |  grep -v ^$)
      SPRING=$(echo $i | awk -F "spring.config.file=" '{print $2}' $CS |  awk '{print $1}' |  grep -v ^$)
      PROC=$(echo -e "${SERVERNAME} ${ATGHME} ${SNAME} ${CONTROLLER} ${SPRING}" | awk '{$1=$1;print}')
          
    elif [[ ! -z $(echo $i | grep -i "spring") ]]; then
      APPNM $i; TIMEE $i
      CONF=$(echo $i | awk -F "spring.config.location=" '{print $2}' $CS | awk '{print $1}' | grep -v ^$)
      JAR=$(echo $i | tr ' ' '\n' | grep "\.jar" | grep -v "javaagent" | grep -v ^$ | awk '{$1=$1;print}' | uniq | tr '\n' ' ')
      PROC=$(echo -e "${CONF} ${JAR}" | awk '{$1=$1;print}')
      if [[ $(echo $i | grep -i "stub.serviceinvocations.enabled=true") ]]; then
      	 PROC=$(echo -e "stub.service: ${JAR}" | awk '{$1=$1;print}')
      fi	
          
    elif [[ ! -z $(echo $i | grep -i "httpd.conf") ]]; then
      APPNM $i; TIMEE $i
      CONF=$(echo $i | awk -F "httpd.conf" '{print $1}' | awk '{print $NF"httpd.conf"}' | grep -v ^$)
      PROC=$(echo -e "Apache: ${CONF}" | awk '{$1=$1;print}')
      
    elif [[ ! -z $(echo $i | grep -i "httpd") ]]; then
      APPNM $i; TIMEE $i
      CONF=$(echo $i | awk -F / '{for(i=2;i<=NF;i++){printf("/%s", $i);}}' | grep -v ^$)
      PROC=$(echo -e "Apache: ${CONF}" | awk '{$1=$1;print}')
          
    elif [[ ! -z $(echo $i | grep -i "soapui") ]]; then
      APPNM $i; TIMEE $i
      CONF=$(echo $i | grep -v grep | awk -F  "soapui.tools."  '{print $2}' $CS | awk '{print $1 "-" $4}' | grep -v ^$)
      APROC=$(echo -e "${CONF}" | awk '{$1=$1;print}')
          
    elif [[ ! -z $(echo $i | grep -i "machineagent.jar") ]]; then
      APPNM $i; TIMEE $i
      CONF=$(echo $i | awk -F machineagent.jar '{print $1}' $CS | awk '{print $NF}' | grep -v ^$)
      PROC=$(echo -e "${CONF}" | awk '{$1=$1;print}')
      
    elif [[ $(echo $PROC | wc -c) -lt 3 ]]; then
      APPNM $i; TIMEE $i
      JAR=$(echo $i |  tr ' ' '\n' | grep "\.jar" | grep -v "javaagent" | grep -v ^$)
      if [[ -z $JAR ]]; then LAST=$(echo $i | awk -F "/" '{print $NF}' | grep -v ^$);fi
      PROC=$(echo -e "${LAST} \n ${JAR}" | awk '{$1=$1;print}' | uniq | tr '\n' ' ' | awk '{$1=$1;print}')
      if [[ $(echo $PROC | wc -w) -ge 4 ]]; then
         JAR=$(echo $i |  tr ' ' '\n' | grep "\.jar" | grep -v "javaagent" | grep -v ^$)
         if [[ -z $JAR ]]; then LAST=$(echo $i | awk '{print $NF}' | grep -v ^$);fi
         PROC=$(echo -e "${LAST} \n ${JAR}" | awk '{$1=$1;print}' | uniq | tr '\n' ' ' | awk '{$1=$1;print}')
      fi
    else
        echo -e "Not a valid Process..."
    fi
    PD=$(echo $i | awk '{print $2}')
    if [[ -z $APPD ]]; then APPD=NA; fi
    if [[ -z $TIME ]]; then TIME=NA; fi
    printf '%-80s %-10s %-10s %-10s %-20s %-10s %s\n' \
    "$(tput bold)$PROC$(tput sgr0)" "----" "$(tput bold)$TIME$(tput sgr0)"  "----" "$(tput bold)$PD$(tput sgr0)" "----" "$(tput bold)$APPD$(tput sgr0)"
    #sleep 2
    if [[ ! -z $APROC ]]; then 
      printf '%-80s %-10s %-10s %-10s %-20s %-10s %s\n' \
      "$(tput bold)$PROC$(tput sgr0)" "----" "$(tput bold)$TIME$(tput sgr0)"  "----" "$(tput bold)$PD$(tput sgr0)" "----" "$(tput bold)$APPD$(tput sgr0)"
    fi
  done | sort | tee -a activeproc.txt
  echo ""
  export IFS=$IFSBKP
  cat activeproc.txt | sed 's/\x1b*(B//g' | sed 's/\x1b\[[0-9;]*m//g' | grep -v ^$ | awk '{$1=$1;print}' > ~/activeprocs.txt
  rm ~/activeproc.txt &>/dev/null
else
   echo -e "\n\n${BOLD}No process running, please check....${ESC}\n\n"
   sleep 2
   export check=0
fi
export IFS=$IFSBKP

#TOT_PROC_A=$(cat ~/activeprocs.txt | wc -l)
#if [[ $TOT_PROC -eq $TOT_PROC_A ]]; then echo -e "All good";fi

##############################
#   Duplicate Process check  #
##############################
if [[ $check -ne 0 ]]; then
  j=1; flag=0
  cat /dev/null > ~/dupproc
  while [[ $j -le $(cat ~/activeprocs.txt | wc -l) ]]; do
    PR=$(cat ~/activeprocs.txt | awk -F "----" '{print $1}' | head -$j | tail -1 | grep -v ^$ | awk '{$1=$1;print}')
    if [[ $(cat ~/activeprocs.txt | grep -w "$PR" | wc -l) -gt 1 ]]; then
      echo -e "${BOLD}===>\"${PR}\" processes is running  --  $(cat ~/activeprocs.txt | grep -w "$PR" | wc -l) times${ESC}" >> ~/dupproc
      echo -e "$(cat ~/activeprocs.txt | grep -w "$PR" | awk -F "----" '{print $1" UPTIME: "$2" PID: "$3}')" >> ~/dupproc
      flag=1
    fi
    ((++j))
    #sleep 2
  done
  if [[ $flag -eq 1 ]]; then
    echo -e "\n##############################################"
    echo -e "${BOLD}Duplicate Processes Found... Please Verify !!!${ESC}"
    echo -e "##############################################\n"
    cat ~/dupproc | sort | uniq; echo -e "\n"
  else
    echo -e "\n###############################"
    echo -e "${BOLD}No Duplicate processes found...${ESC}"
    echo -e "###############################\n"
  fi
fi
rm ~/activeproc.txt &>/dev/null
rm ~/activeprocs.txt &>/dev/null
rm ~/dupproc &>/dev/null
echo -e "\nYou are in $(pwd) dir..\n"
