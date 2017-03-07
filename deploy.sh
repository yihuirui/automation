#!/bin/bash
################################################################################################
#自动拉取war包，自动解压，自动删除日志，自动重启tomcat，dubbo程序,备份项目,自动替换配置文件
#用法: deploy | deploy start | deploy stop | deploy restart| deploy clear| deploy status 
#*需要自己修改相关路径   文件名 deploy :
################################################################################################
env="dev"  
module=""  
project="esb"  
tomcat="tomcat-esb-6060"  
  
dubbo="dubbo"  
  
base="http://192.168.1.1:9090/jenkins/job"  
clear()  
{  
rm -rf rm -rf $dubbo/*/logs/*  
rm -rf $tomcat/logs/*  
rm -rf *.log  
rm -rf *.war  
rm -rf *assembly.tar.gz  
}  
stop()  
{  
module="esb-consumer"  
#ps -ef | grep $env/esb/dubbo/$module | grep -v grep  
pid=`ps -ef | grep $env/$project/dubbo/$module | grep -v grep |awk 'NR==1{print $2}'`  
if [ -n "$pid" ];then  
     echo "停止$env $module..."  
     kill -9 $pid  
     sleep 1s  
fi  
  
module="esb-facade"  
#ps -ef | grep $env/$project/dubbo/$module | grep -v grep  
pid=`ps -ef | grep $env/$project/dubbo/$module | grep -v grep |awk 'NR==1{print $2}'`  
if [ -n "$pid" ];then  
     echo "停止$env $module..."  
     kill -9 $pid  
     sleep 1s  
fi  
  
#ps -ef | grep $env/$project/$tomcat | grep -v grep  
pid=`ps -ef | grep $env/$project/$tomcat | grep -v grep |awk 'NR==1{print $2}'`  
if [ -n "$pid" ];then  
echo "停止$env $tomcat"  
kill -9 $pid  
sleep 1s  
fi  
}  
  
  
start()  
{  
  module="esb-facade"  
  echo "启动$env $module..."  
  sh $dubbo/$module/bin/start.sh  
  sleep 2s  
  module="esb-consumer"  
  echo "启动$env $module..."  
  sh $dubbo/$module/bin/start.sh  
  
  echo "启动$env $tomcat"  
  sh $tomcat/bin/startup.sh  
  
}  
deploy_dubbo()  
{  
rm -rf bak/$module  
cp -r $dubbo/$module bak  
rm -rf $dubbo/$module  
rm -rf $module-assembly.tar.gz  
wget -qc "$base/$project/ws/$module/target/$module-assembly.tar.gz"  
echo "正在解压$env $module-assembly.tar.gz"  
tar -zxvf $module-assembly.tar.gz -C $dubbo  >/dev/null 2>&1  
echo "替换配置$env $module"  
cp -r configbak/$module/* $dubbo/$module/conf  
}  
deploy_tomcat()  
{  
rm -rf bak/$module  
cp -r $tomcat/webapps/$module bak  
rm -rf $tomcat/webapps/$module  
rm -rf $module.war  
wget -qc "$base/$project/ws/$module/target/$module.war"  
echo "正在解压$env $module"  
unzip $module.war -d $tomcat/webapps/$module  >/dev/null 2>&1  
echo "替换配置$env $module"  
cp -r configbak/$module/* $tomcat/webapps/$module/WEB-INF/classes  
}  
  
deploy()  
{  
stop  
clear  
  
  
module="esb-consumer"  
deploy_dubbo  
module="esb-facade"  
deploy_dubbo  
module="esb-scheduler"  
deploy_tomcat  
module="esb-api"  
deploy_tomcat  
module="esb-web"  
deploy_tomcat  
  
start  
}  
  
  
if [ "$1" = "start" ];then  
    start  
elif [ "$1" = "stop" ];then  
    stop  
elif [ "$1" = "clear" ];then  
    clear  
elif [ "$1" = "restart" ];then  
    stop  
    start  
elif [ "$1" = "status" ];then  
    ps -ef | grep $env/$project/$dubbo | grep -v grep  
    ps -ef | grep $env/$project/$tomcat | grep -v grep  
elif [ -z "$1" ];then  
    deploy  
else  
    echo "用法: deploy | deploy start | deploy stop | deploy restart| deploy clear";  
    exit 1;  
fi  
