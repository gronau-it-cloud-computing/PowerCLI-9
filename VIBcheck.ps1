#Add-PSSnapin VMware.VimAutomation.Core
#
##Vcenter Server
#$VcenterServer = "fl1vcenter"
#
##Read-Host -Prompt "Enter FQDN of the Vcenter Server your wish to connect to"
#
## Prompt for ESXi Root Credentials
#$esxcred = Get-Credential 
#
##Connect to each host defined in $ESXiHosts
#connect-viserver -Server $VcenterServer -Credential $esxcred
#
##********************************#
##******* Check for VIB **********#
##********************************#
#
#$VIBinstalled =@{}
#
#Get-VMHost | Sort Name | %{
#$VIBinstalled.Add($_,((Get-EsxCli -VMHost $_).software.vib.list() |
#Where-Object {$_.Name -like "openmanage"}) -ne $null)}

$VIBinstalled