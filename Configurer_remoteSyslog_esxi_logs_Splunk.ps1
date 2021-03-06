Add-PSSnapin VMware.VimAutomation.Core

#Prompt for host name
$ESXiHosts = Read-Host -Prompt 'Enter Host IP'

# Prompt for ESXi Root Credentials
$esxcred = Get-Credential

#Connect to ESXi host
Connect-viserver -Server $ESXiHosts -Credential $esxcred

#Create NFS datastore
#New-Datastore -Nfs -VMHost $ESXiHosts -Name "vnx2_esxi_logs" -Path "/vnx2_esxi_logs" -NfsHost "10.51.194.25"


Get-AdvancedSetting -Entity $ESXiHosts -Name Syslog.global.logHost | Set-AdvancedSetting -Value "udp://10.51.10.141:9514" -Confirm:$false

touch /etc/vmware/firewall/splunksyslog.xml
cd /etc/vmware/firewall

echo "<ConfigRoot>
	<service>
    	 <id>splunkSyslog</id>
     	     <rule id='0000'>
             <direction>outbound</direction>
             <protocol>udp</protocol>
             <porttype>dst</porttype>
             <port>9514</port>
             </rule>
         </service>
</ConfigRoot>" > splunksyslog.xml

