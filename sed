sed -i '/local7.*/a auditConfig:\n  auditFilePath: /etc/origin/master/audit/audit-ocp.log\n  enabled: true\n  maximumFileRetentionDays: 10\n  maximumFileSizeMegabytes: 10\n  maximumRetainedFiles: 10\n  logFormat: json\n  policyFile: /etc/origin/master/audit-policy.yaml' /tmp/rsyslog.conf
[root@test-centos ~]# more /tmp/abcd.sh
#!/bin/sh
if [ `grep auditConfig /tmp/rsyslog.conf` ]
then
   echo "no change needed"
else
   sed -i '73 a auditConfig:\n  auditFilePath: /etc/origin/master/audit/audit-ocp.log\n  enab
led: true\n  maximumFileRetentionDays: 10\n  maximumFileSizeMegabytes: 10\n  maximumRetainedF
iles: 10\n  logFormat: json\n  policyFile: /etc/origin/master/audit-policy.yaml' /tmp/rsyslog
.conf
fi
=============================================================
scripts:
==============================================================
# cat script-copy.sh
#!/bin/sh
cd /etc/origin/master/
for i in `cat servers`
do
scp syslogforwarder.sh $i:/etc/origin/master/
echo "Scripts are copied to server $i"
done
==============================================================

# cat syslogforwarder.sh
#!/bin/sh
cp /etc/rsyslog.conf /var/opt/rsyslog.conf_`date "+%Y.%m.%d-%H.%M.%S"`
grep "1.2.3.4" /etc/rsyslog.conf > /dev/null 2>&1
if [ $? -eq 0 ]
then
   echo "no change needed" > /dev/null 2>&1
else
   sed -i '$ a ## Rajeev \n*.* @1.2.3.4:514' /etc/rsyslog.conf
   systemctl restart rsyslog
   systemctl status rsyslog |grep -i running
   if [ $? -eq 0 ]
   then
      echo "systemctl is running fine on server `uname -n`
   else
      echo " manually check rsyslog daemon on server `uname -n`
   fi
fi
==============================================================
# cat auditupdate.sh
#!/bin/sh
cp /etc/origin/master/master-config.yaml /var/opt/master-config.yaml_`date "+%Y.%m.%d-%H.%M.%S"`
grep auditConfig /etc/origin/master/master-config.yaml > /dev/null 2>&1
if [ $? -eq 0 ]
then
   echo "no change needed" > /dev/null 2>&1
else
   sed -i '$ a auditConfig:\n  auditFilePath: /etc/origin/master/audit/audit-ocp.log\n  enabled: true\n  maximumFileRetentionDays: 3\n  maximumFileSizeMegabytes: 100\n  maximumRetainedFiles: 3\n  logFormat: json\n  policyFile: /etc/origin/master/audit-policy.yaml' /etc/origin/master/master-config.yaml
   oc get po -n kube-system > /var/opt/kubesystempolist_`date "+%Y.%m.%d-%H.%M.%S"`
   master-restart api
   master-restart controllers
   sleep 120
   oc get po -n kube-system |grep -v NAME |grep -v Running |grep -v "1/1"
   if [ $? -eq 1 ]
   then
      echo "Master API server and controllers are restarted successfully on server `uname -n`"
   else
      echo " check it manually on server `uname -n`"
   fi
fi
#
##########################################################################################################################
Script1 (configuring rsyslog config on remote servers)
vi config_rsyslog_remote.sh

#!/bin/sh
cd /etc/origin/master/
echo "enter oc server name with FQDN"
read A
oc login $A
oc get nodes |grep -v NAME |cut -f 1 -d " " > servers
for i in `cat servers`
do
echo "#### Please wait. Copying necessary scripts to remote servers ####"
scp syslogforwarder.sh $i:/etc/origin/master/
echo "                                                                   "
echo "#### Scripts are copied to remote servers successfully ####"
echo "                                                                   "
echo "#### Please wait. Updating the rsyslog.conf on remote servers ####"
ssh $i "sudo sh /etc/origin/master/syslogforwarder.sh
echo "                                                                   "
echo "rsyslog configuration has been completed on remote server $i"
done
###########################################################################################################################
# cat syslogforwarder.sh
#!/bin/sh
cp /etc/rsyslog.conf /var/opt/rsyslog.conf_`date "+%Y.%m.%d-%H.%M.%S"`
grep "<IP address of syslog server>" /etc/rsyslog.conf > /dev/null 2>&1
if [ $? -eq 0 ]
then
   echo "no change needed" > /dev/null 2>&1
else
   sed -i '$ a ## Rajeev \n*.* @<IP address of syslog server>:514' /etc/rsyslog.conf
   systemctl restart rsyslog
   systemctl status rsyslog |grep -i running
   if [ $? -eq 0 ]
   then
      echo "systemctl is running fine on server `uname -n`
   else
      echo " manually check rsyslog daemon on server `uname -n`
   fi
fi
##########################################################################################################################
Script1 (configuring cluster auditing on oc master servers)
vi oc-cluster-audit-master-servers.sh

#!/bin/sh
cd /etc/origin/master/
echo "enter oc server name with FQDN"
read A
oc login $A
oc get nodes |grep -v NAME |cut -f 1 -d " " > servers
for i in `cat servers`
do
echo "#### Please wait. Copying necessary scripts to remote servers ####"
scp oc-cluster-auditupdate.sh $i:/etc/origin/master/
echo "                                                                   "
echo "#### Scripts are copied to remote servers successfully ####"
echo "                                                                   "
echo "#### Please wait. Updating the audit config file on remote servers ####"
ssh $i "sudo sh /etc/origin/master/oc-cluster-auditupdate.sh
echo "                                                                   "
echo "cluster audit enablement has been completed on remote server $i"
done
#############################################################################################################################3
# cat oc-cluster-auditupdate.sh
#!/bin/sh
cp /etc/origin/master/master-config.yaml /var/opt/master-config.yaml_`date "+%Y.%m.%d-%H.%M.%S"`
grep auditConfig /etc/origin/master/master-config.yaml > /dev/null 2>&1
if [ $? -eq 0 ]
then
   echo "no change needed" > /dev/null 2>&1
else
   sed -i '$ a auditConfig:\n  auditFilePath: /etc/origin/master/audit/audit-ocp.log\n  enabled: true\n  maximumFileRetentionDays: 3\n  maximumFileSizeMegabytes: 100\n  maximumRetainedFiles: 3\n  logFormat: json\n  policyFile: /etc/origin/master/audit-policy.yaml' /etc/origin/master/master-config.yaml
   oc get po -n kube-system > /var/opt/kubesystempolist_`date "+%Y.%m.%d-%H.%M.%S"`
   master-restart api
   master-restart controllers
   sleep 120
   oc get po -n kube-system |grep -v NAME |grep -v Running |grep -v "1/1"
   if [ $? -eq 1 ]
   then
      echo "Master API server and controllers are restarted successfully on server `uname -n`"
   else
      echo " check it manually on server `uname -n`"
   fi
fi
###########################################################################################################################



