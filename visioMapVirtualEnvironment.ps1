Import-Module VMware.VimAutomation.Core
Import-Module VMware.VimAutomation.Cis.Core

$vcenterserver = Read-Host -Prompt 'Please enter the vCenter serve you wish to connect to'

Connect-VIServer $vcenterserver -Credential (Get-Credential)


# Get all Clusters
$allclusters = Get-Cluster
 
# Iterate for each cluster and generate and save the vCenter Network map visio diagram.
foreach ($cluster in $allclusters)
 
{
 
 
$shpFile1 = "VMware EUC Visio Stencils 2015.vss"
 
#VISIO Function for the Connection-of-objects  
function connect-visioobject ($firstObj, $secondObj)  
{  
    $shpConn = $pagObj.Drop($pagObj.Application.ConnectorToolDataObject, 0, 0)  
    #// Connect its Begin to the 'From' shape:  
    $connectBegin = $shpConn.CellsU("BeginX").GlueTo($firstObj.CellsU("PinX"))  
    #// Connect its End to the 'To' shape:  
    $connectEnd = $shpConn.CellsU("EndX").GlueTo($secondObj.CellsU("PinX"))  
}  
 
#VISIO Function for adding the object into the drawing  
function add-visioobject ($mastObj, $item)  
{  
         Write-Host "Adding $item"  
        # Drop the selected stencil on the active page, with the coordinates x, y  
          $shpObj = $pagObj.Drop($mastObj, $x, $y)  
        # Enter text for the object  
          $shpObj.Text = $item
        #Return the visioobject to be used  
        return $shpObj  
 }  
 
# Create VI Properties to extract vmtype
 
New-VIProperty -Name GuestFamily -ObjectType VirtualMachine -ValueFromExtensionProperty 'guest.guestfamily' -Force | Out-Null
New-VIProperty -Name GuestOSType -ObjectType VirtualMachine -ValueFromExtensionProperty 'guest.guestfullname' -Force | Out-Null
 
 
# Create an instance of Visio and create a document based on the Basic Diagram template.  
$AppVisio = New-Object -ComObject Visio.Application  
$docsObj = $AppVisio.Documents  
$DocObj = $docsObj.Add("Basic Network Diagram.vst")  
 
# Set the active page of the document to page 1  
$pagsObj = $AppVisio.ActiveDocument.Pages  
$pagObj = $pagsObj.Item(1)  
 
# Load a set of stencils and select one to drop  
$stnPath = [system.Environment]::GetFolderPath('MyDocuments') + "\My Shapes\"  
$stnObj1 = $AppVisio.Documents.Add($stnPath + $shpFile1)  
$VirtualMachine = $stnobj1.Masters.item("Virtual Machine (3D)")  
$VirtualAppliance = $stnobj1.Masters.item("3D Virtual Appliance")  
$vSphere = $stnobj1.Masters.item("vSphere")
$Clusters = $stnobj1.Masters.item("Clusters 2")
$VMware_Host=$stnobj1.Masters.item("VMware Host")
$datastores=$stnobj1.Masters.item("Disks 1")
  
#Connect-VIServer "Your vCenter Name" -Credential (Get-Credential)
 
$allNODES = Get-Cluster $cluster | get-vmhost
$allclusters = Get-Cluster $cluster
$allVMs = Get-Cluster $cluster | Get-VM  
$allDs = Get-Cluster $cluster | Get-Datastore
 
 
#Set Start Locations of Objects  
$x = 1  
$y = .5  
 
#DRAW ALL Cluster-NODES  
Foreach ($cluster in $allclusters) {  
    $y += 0.25  
    $clusterInfo = "CLUSTER: " + $cluster.Name  
    $clusterObj = add-visioobject $Clusters $clusterInfo
  
#DRAW ALL Datastore's and connect them to the cluster object
    Foreach ($d in $allDs) {  
          
            $x = -3  
            $y += 1.5  
            $dsInfo = "Datastore: " + $d.Name  + "`nDSCapacity(GB): " + [math]::Round([decimal]$d.CapacityGB,2)
            $datastores = add-visioobject $datastores $dsInfo  
            connect-visioobject $clusterObj $datastores
    
    }
 
#DRAW ALL Physical VMHOST NODES with Node Name, Total Memory and vCenter version and connect them to the cluster object
    Foreach ($node in $allNODES) {  
          
            $x = 2  
            $y += 1.5  
            $nodeInfo = "NODE: " + $node.Name  + "`eSXIVersion: " + $node.Version + "`nTotalMemory(GB): " + [math]::Round([decimal]$node.MemoryTotalGB,2)
            $nodeObj = add-visioobject $VMware_Host $nodeInfo  
            connect-visioobject $clusterObj $nodeObj      
        
# GET All Virtual Machines and drwa them based on the OS type and connect them to the Node object.
$allVMNodes = Get-VMHost $node | Get-VM | select guestfamily,guestostype | Group-Object guestostype |?{$_.name -ne ''} | select name,count
                
        foreach ($vm in $allVMNodes) {   
        
            $x += 2          
            $y += 1.5
            $vmInfo = "VM_OSType: " + $vm.Name  + "`nNo_of_VM's: " + $vm.count
            $VirtualMachine = add-visioobject $VirtualMachine $vmInfo
            connect-visioobject $nodeObj $VirtualMachine  
        
        }  
 
        }
 
        }
 
# Resize the Visio so that all fits in one page, nice and clean.
$pagObj.ResizeToFitContents()  
 
# Save the Visio file generated in desktop for each of the cluster.
$DocObj.SaveAs("C:\Users\aa-gcorea\Desktop\vmwarelabvisio\$cluster.vsd")
        
}