#Remote Computer Inventory Powershell Script
#Version 1.0
#Created By Dan Flynn
#Update Date 10/19/2010
#Changes:Gathers basic computer info from list of computer names given in a list and puts it into an excel doc
$xl = New-Object -comobject Excel.Application
$xl.visible = $True

$wb = $xl.Workbooks.Add()
$s3 = $wb.Sheets | where {$_.name -eq "Sheet3"}
#$s3.delete()
$ws = $wb.Worksheets.Item(1)

$ws.name = "General Info"

$ws.Cells.Item(1,1) = "Server Name"
$ws.Cells.Item(1,2) = "Service Tag"
$ws.Cells.Item(1,3) = "Manufacturer"
$ws.Cells.Item(1,4) = "Model"
$ws.Cells.Item(1,5) = "System Type"
$ws.Cells.Item(1,6) = "IP Address"
$ws.Cells.Item(1,7) = "Default Gateway"
$ws.Cells.Item(1,8) = "MAC Address"
$ws.Cells.Item(1,9) = "Install Date"
$ws.Cells.Item(1,10) = "Operating System"
$ws.Cells.Item(1,11) = "Service Packs"
$ws.Cells.Item(1,12) = "Memory (GB)"
$ws.Cells.Item(1,13) = "Processors"
$ws.Cells.Item(1,14) = "Processor Type/Speed"
$ws.Cells.Item(1,15) = "Last Reboot Time"
$ws.Cells.Item(1,16) = "Report Time Stamp"

$d = $ws.UsedRange
$d.Interior.ColorIndex = 19
$d.Font.ColorIndex = 11
$d.Font.Bold = $True
$d.EntireColumn.AutoFit()

$intRow = 2

$colComputers = get-content C:\ServerList.txt
foreach ($strComputer in $colComputers)
{
$OS = get-wmiobject Win32_OperatingSystem -computername $strComputer
$Computer = get-wmiobject Win32_computerSystem -computername $strComputer
$Bios = get-wmiobject Win32_bios -computername $strComputer
$ProcType = get-wmiobject Win32_Processor -computername $strcomputer | select name
# [reflection.assembly]::loadwithpartialname('system.windows.forms');
# [system.Windows.Forms.MessageBox]::show($ProcType.name)
$NICCard= Get-WmiObject win32_networkadapterconfiguration -computername $strComputer
foreach($NIC in $NICCard){
if($NIC.ipenabled -eq $true)
{

$ws.Cells.Item($intRow,1) = $strComputer.Toupper()
$ws.Cells.Item($intRow,2) = $Bios.serialnumber
$ws.Cells.Item($intRow,3) = $Computer.Manufacturer
$ws.Cells.Item($intRow,4) = $Computer.Model
$ws.Cells.Item($intRow,5) = $Computer.SystemType
$ws.Cells.Item($intRow,6) = $NIC.IPaddress[0]
$ws.Cells.Item($intRow,7) = $NIC.DefaultIPGateway
$ws.Cells.Item($intRow,8) = $NIC.MACAddress
$ws.Cells.Item($intRow,9) = [System.Management.ManagementDateTimeconverter]::ToDateTime($OS.InstallDate)
$ws.Cells.Item($intRow,10) = $OS.Caption
$ws.Cells.Item($intRow,11) = $OS.CSDVersion
$ws.Cells.Item($intRow,12) = "{0:N0}" -f ($computer.TotalPhysicalMemory/1GB)
$ws.Cells.Item($intRow,13) = $Computer.NumberOfProcessors
$ws.Cells.Item($introw,14) = $ProcType.name
$ws.Cells.Item($intRow,15) = [System.Management.ManagementDateTimeconverter]::ToDateTime($OS.LastBootUpTime)
$ws.Cells.Item($intRow,16) = Get-date

$intRow = $intRow + 1
$d.EntireColumn.AutoFit()
}
}
}

#---------Create New WorkSheet------------------------------

$ws = $wb.Worksheets.Item(2)

$ws.Name = "Drive Info"
$ws.Cells.Item(1,1) = "Machine Name"
$ws.Cells.Item(1,2) = "Drive"
$ws.Cells.Item(1,3) = "Total size (MB)"
$ws.Cells.Item(1,4) = "Free Space (MB)"
$ws.Cells.Item(1,5) = "Free Space (%)"

$d = $ws.UsedRange
$d.Interior.ColorIndex = 19
$d.Font.ColorIndex = 11
$d.Font.Bold = $True
$d.EntireColumn.AutoFit()

$intRow = 2

$servers = get-content c:\serverlist.txt
foreach ($strcomputer in $servers)
{
$objDisks = get-wmiobject Win32_LogicalDisk -computername $strComputer -Filter "DriveType = 3"
foreach ($objdisk in $objDisks)
{
 $ws.Cells.Item($intRow, 1) = $strComputer.ToUpper()
 $ws.Cells.Item($intRow, 2) = $objDisk.DeviceID
 $ws.Cells.Item($intRow, 3) = "{0:N0}" -f ($objDisk.Size/1GB)
 $ws.Cells.Item($intRow, 4) = "{0:N0}" -f ($objDisk.FreeSpace/1GB)
 $ws.Cells.Item($intRow, 5) = "{0:P0}" -f ([double]$objDisk.FreeSpace/[double]$objDisk.Size)
$intRow = $intRow + 1
}
}
