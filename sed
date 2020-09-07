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
