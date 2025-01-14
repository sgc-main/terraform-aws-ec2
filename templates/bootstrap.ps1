
$dnsServers = "${dns_servers}"
$bootstrap_log = 'C:\Temp\bootstrap-log.txt'

New-Item C:\Temp -type directory
Write-Output "Temp folder created ..." | Out-File $bootstrap_log -Append

# Set DNS
if ($dnsServers.Length -gt 0) {
  $dnsServersArray = $dnsServers -split ","
  $dnsServersString = $dnsServersArray -join '", "'
  $interfaceIndex = (Get-NetAdapter | Where-Object { $_.Name -like '*Ethernet*' } | Select-Object -ExpandProperty InterfaceIndex)
  Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses "`"$dnsServersString`""
  Write-Output "DNS set ..." | Out-File $bootstrap_log -Append
}

# Rename instance
try
{
	Rename-Computer -NewName ${hostname} -Force
	Write-Output 'Server rename successfull' | Out-File $bootstrap_log -Append
}
catch
{
	Write-Output 'Errors :' | Out-File $bootstrap_log -Append
	Write-Output $_.Exception | Out-File $bootstrap_log -Append
}

# Capability to inject custom bootstrapping step
try
{
    Write-Output "Execute Extended User Data ..." | Out-File $bootstrap_log -Append
    ${indent(4, extended_userdata)}
}
catch
{
    Write-Output "Extended User Data Execution Failed ..." | Out-File $bootstrap_log -Append
    Write-Error $_.Exception | Out-File $bootstrap_log -Append
}
finally
{
    Write-Host "Extended User Data Execution Finished ..." | Out-File $bootstrap_log -Append
}

# Restart Instance to finish Initial Setup  
Restart-Computer -ComputerName . -Force