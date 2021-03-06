Add-PSSnapin VMware.VimAutomation.Core

#FQDNs or IP addresses of ESXi Hosts to Configure
#Enclose each host in quotes and separate with a comma.
#Example: $ESXiHosts = "192.168.1.1","192.168.1.2"

#Prompt user for IP or host name to connect to
$ESXiHosts = Read-Host -Prompt 'Enter Host IP'

# Prompt for ESXi Root Credentials
$esxcred = Get-Credential 

#Connect to each host defined in $ESXiHosts
Connect-viserver -Server $ESXiHosts -Credential $esxcred

# Set $targets to the SendTargets you want to add. Enclose each target in quotes and separate with a comma.
# Example: $targets = "192.168.151.10", "192.168.151.11", "192.168.151.12", "192.168.151.13"
$targets = "10.51.184.26", "10.51.184.27", "10.51.184.28", "10.51.184.29", "10.51.186.26", "10.51.186.27", "10.51.186.28", "10.51.186.29", "10.51.184.50", "10.51.184.51", "10.51.186.50", "10.51.186.51"

foreach ($esx in $ESXiHosts) {

  # Enable Software iSCSI Adapter on each host
  Write-Host "Enabling Software iSCSI Adapter on $esx ..."
  #Get-VMHostStorage -VMHost $esx | Set-VMHostStorage -SoftwareIScsiEnabled $True -Confirm:$false
  
  $h = Get-VMHost -Name "$esx" | Get-View -Property "ConfigManager.StorageSystem"
	$hostStorageSystem = Get-view $h.ConfigManager.StorageSystem
	$hostStorageSystem.UpdateSoftwareInternetScsiEnabled($true)
   

  # Just a sleep to wait for the adapter to load
  Write-Host "Sleeping for 30 Seconds..." -ForegroundColor Green
  Start-Sleep -Seconds 30
  Write-Host "OK Here we go..." -ForegroundColor Green
  Write-Host "Adding iSCSI SendTargets..." -ForegroundColor Green

  $hba = get-vmhost $esx | Get-VMHostHba -Type iScsi | Where {$_.Model -eq "iSCSI Software Adapter"}

  foreach ($target in $targets) {

     # Check to see if the SendTarget exist, if not add it
     if (Get-IScsiHbaTarget -IScsiHba $hba -Type Send | Where {$_.Address -cmatch $target}) {
        Write-Host "The target $target does exist on $esx" -ForegroundColor Green
     }
     else {
        Write-Host "The target $target doesn't exist on $esx" -ForegroundColor Red
        Write-Host "Creating $target on $esx ..." -ForegroundColor Yellow
        New-IScsiHbaTarget -IScsiHba $hba -Address $target        
     }

  }

}
Write "`n Done - Disconnecting from $ESXiHosts"
Disconnect-VIServer -Server * -Force -Confirm:$false

Write-Host "Done! Now go manually add the iSCSI vmk bindings to the Software iSCSI Adapter and Resan." -ForegroundColor Green