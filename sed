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
scp auditupdate.sh syslogforwarder.sh $i:/etc/origin/master/
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
fi
#

