#Add-PSSnapin VMware.VimAutomation.Core
#
##Vcenter Server
$VcenterServer = "fl1vcenter"

## Prompt for ESXi Root Credentials
$esxcred = Get-Credential 

##Connect to each host defined in $ESXiHosts
connect-viserver -Server $VcenterServer -Credential $esxcred

get-vm | get-snapshot | Select-Object -Property vm,created,sizeGB,name,description | Export-Csv -Path C:\Users\$env:username\Desktop\snapshots.csv