param([string]$vmName, [string]$resourceGroupName)

$session = New-AzVMRunCommandSession -ResourceGroupName $resourceGroupName -VMName $vmName

$command = "Get-Process | Sort CPU -Descending | Select -First 1 | Stop-Process -Force"

Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -VMName $vmName -CommandId 'RunPowerShellScript' -ScriptString $command

Remove-AzVMRunCommandSession -Session $session
