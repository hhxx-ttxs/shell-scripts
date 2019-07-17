#!/bin/bash
  
calculation() {
   if [[ $1 -lt 1024 ]];then
        value="$1B/s"
   elif [[ $1 -gt 1048576 ]];then
        value=$(echo $1 | awk '{print $1/1048576 "MB/s"}')
   else
        value=$(echo $1 | awk '{print $1/1024 "KB/s"}')
   fi
   echo $value
}


Number_of_parameters() {

if [ $# -ne 1 ];then
        ethn=eth0

fi

}



get_data() {
  while true
  do
   
   RX_pre=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $2}')
  
   if [  -z "${RX_pre}" ];then
       echo "$ethn not exist"
       exit
   fi 
  
   TX_pre=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $10}')
   sleep 1
   RX_next=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $2}')
   TX_next=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $10}')
  
   clear
   echo -e "\t RX `date +%k:%M:%S` TX"
  
   RX=$((${RX_next}-${RX_pre}))
   TX=$((${TX_next}-${TX_pre}))
  
   
   RX=$(calculation $RX) 
   TX=$(calculation $TX)
   echo -e "$ethn \t $RX $TX "
  
  done
}

main() {
  ethn=$1
  Number_of_parameters
  get_data
}

main

