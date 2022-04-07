#!/bin/bash
[ ! -d "/usr/td-agent/" ] && mkdir /usr/td-agent/
echo "/var/log/dmesg
/var/log/messages
/var/log/secure
/etc/hosts
/var/log/httpd/access_log
/var/log/httpd/error_log
/opt/webgateway/bin/CSP.log
/var/log/dmesg
/var/log/messages
/var/log/secure
/etc/hosts
/usr/local/HC/HCNDR/mgr/messages.log
/usr/local/HC/HCNDR/mgr/messages.old\*
/usr/local/HC/HCNDR/mgr/alerts.log
/usr/local/HC/HCNDR/mgr/journal.log
/usr/local/HC/HCNDR/csp/bin/CSP.log
/usr/local/HC/HCNDR/mgr/ensinstall.\*
/usr/local/HC/HCNDR/mgr/HS.Util.Installe" > /usr/td-agent/directories.list
file="/usr/td-agent/directories.list"
fileReadDir=$(cat "$file")
fileReadPath=$(cat "$file")
lines=$(echo "$fileReadDir" | wc -l)
dirs=($(echo $fileReadDir | tr "\n" "\n"))
allpaths=$(echo $fileReadPath | sed -r 's/[\/]+/-/g')
paths=($(echo $allpaths | tr "\n" "\n" | sed 's/.\(.*\)/\1/'))
for((i=0; i<lines; i++))
do
echo "<source>
 @type tail
  path ${dirs[i]}
  tag ${paths[i]:1}
  pos_file /var/log/td-agent/${paths[i]:1}.log
  
  <parse>
  @type none
  </parse>
</source>

<filter ${paths[i]:1}>
  @type stdout
</filter>

<filter ${paths[i]:1}>
  @type ec2_metadata

  metadata_refresh_seconds 3000
  imdsv2 true

  <record>
    hostname      \${tagset_name}
    instance_id   \${instance_id}
    instance_type \${instance_type}
    private_ip    \${private_ip}
    az            \${availability_zone}
    vpc_id        \${vpc_id}
    ami_id        \${image_id}
    account_id    \${account_id}
	  referente     \${tagset_referente}
  </record>
</filter>

<match ${paths[i]:1}>
  @type cloudwatch_logs
  log_group_name staging-fluentd-apps-logs
  log_stream_name ${paths[i]:1}
  auto_create_stream true 
  region eu-central-1
</match>" > /etc/td-agent/conf.d/${paths[i]:1}.conf
done