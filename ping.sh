#!/bin/bash
 for i in $(seq 100)
 do 
 ping -c 1 192.168.1.$i &>/dev/null 
 if [ $? -eq 0 ];
 then echo "Ip is up " 
 else echo "ip is down" 
 fi done
