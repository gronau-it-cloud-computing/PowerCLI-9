Add-PSSnapin VMware.VimAutomation.Core

#Prompt for host name
$ESXiHosts = Read-Host -Prompt 'Enter Host IP'

# Prompt for ESXi Root Credentials
$esxcred = Get-Credential

#Connect to ESXi host
Connect-viserver -Server $ESXiHosts -Credential $esxcred

#Create NFS datastore
#New-Datastore -Nfs -VMHost $ESXiHosts -Name "vnx2_esxi_logs" -Path "/vnx2_esxi_logs" -NfsHost "10.51.194.25"


Get-AdvancedSetting -Entity $ESXiHosts -Name Syslog.global.logDir | Set-AdvancedSetting -Value "[vnx2_esxi_logs]/ESXi-Syslog/$ESXihosts" -Confirm:$false