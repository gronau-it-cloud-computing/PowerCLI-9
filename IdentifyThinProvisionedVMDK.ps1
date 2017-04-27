Add-PSSnapin VMware.VimAutomation.Core

# Prompt for vCenter Server 
$vcenterserver = Read-Host -Prompt 'Please enter the vCenter serve you wish to connect to'

Connect-VIServer $vcenterserver

$report = @()
foreach ($vm in Get-VM){
 $view = Get-View $vm
   if ($view.config.hardware.Device.Backing.ThinProvisioned -eq $true){
   $row = '' | select Name, Provisioned, Total, Used, VMDKs, Thin
      $row.Name = $vm.Name
      $row.Provisioned = [math]::round($vm.ProvisionedSpaceGB , 2)
      $row.Total = [math]::round(($view.config.hardware.Device | Measure-Object CapacityInKB -Sum).sum/1048576 , 2)
      $row.Used = [math]::round($vm.UsedSpaceGB , 2)
      $row.VMDKs = $view.config.hardware.Device.Backing.Filename | Out-String
      $row.Thin = $view.config.hardware.Device.Backing.ThinProvisioned | Out-String
   $report += $row
}}
$report | Sort Name | Export-Csv -Path "C:Thin_Disks.csv"