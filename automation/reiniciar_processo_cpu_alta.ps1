param (
    [string]$vmName,
    [string]$resourceGroupName
)

# Validar parâmetros
if (-not $vmName -or -not $resourceGroupName) {
    Write-Error "Os parâmetros vmName e resourceGroupName são obrigatórios."
    exit 1
}

try {
    Write-Output "Iniciando sessão na VM $vmName..."
    $session = New-AzVMRunCommandSession -ResourceGroupName $resourceGroupName -VMName $vmName

    $command = @"
    try {
        \$highCPUProcess = Get-Process | Sort-Object CPU -Descending | Select-Object -First 1
        if (\$highCPUProcess) {
            Write-Output "Processo de maior uso de CPU: \$(\$highCPUProcess.Name) (PID: \$(\$highCPUProcess.Id))"
            Stop-Process -Id \$highCPUProcess.Id -Force
            Write-Output "Processo \$(\$highCPUProcess.Name) encerrado com sucesso."
        } else {
            Write-Output "Nenhum processo de alto consumo de CPU encontrado."
        }
    } catch {
        Write-Error "Erro ao identificar e encerrar processo: \$_"
    }
"@

    Write-Output "Executando comando na VM..."
    Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -VMName $vmName -CommandId 'RunPowerShellScript' -ScriptString $command

    Write-Output "Removendo sessão..."
    Remove-AzVMRunCommandSession -Session $session

    Write-Output "Execução concluída com sucesso."

} catch {
    Write-Error "Erro ao executar o script: $_"
}
