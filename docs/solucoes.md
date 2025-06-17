# Soluções de Monitoramento - Performance, Segurança e Automação

Neste documento, apresento algumas abordagens para melhorar o monitoramento das máquinas virtuais garantindo mais eficiência e segurança. Aqui, você encontrará soluções como *alertas de desempenho e segurança, visualização detalhada de métricas e respostas automatizadas* utilizando Azure Automation e Logic Apps.

## Objetivo

Monitorar VMs em tempo real, detectar anomalias, aplicar respostas automáticas e notificar equipes técnicas de forma eficiente.

---

## Detalhando as soluções

### Alerta de CPU

Detecta quando a VM ultrapassa 90% de uso de CPU por mais de 10 minutos.

**Arquivo:** `alerts/alerta_cpu_alta.json`

```jsonjson
{
  "name": "Alto Uso de CPU",
  "description": "Uso de CPU acima de 90% por 10 minutos",
  "resourceType": "Microsoft.Compute/virtualMachines",
  "metricName": "Percentage CPU",
  "operator": "GreaterThan",
  "threshold": 90,
  "timeAggregation": "Average",
  "windowSize": "PT10M",
  "evaluationFrequency": "PT5M",
  "actionGroup": [
    "/subscriptions/{subscription-id}/resourceGroups/rg-monitoramento/providers/microsoft.insights/actionGroups/ag-cpu-alert"
  ]
}
```

### Alerta Espaço em Disco

Detecta quando o espaço disponível no disco da VM está abaixo de 10%.

**Arquivo:** `alerts/alerta_espaco_disco.json`

```jsonjson
{
  "name": "Alerta Espaço em Disco",
  "properties": {
    "description": "Alerta disparado quando o espaço livre no disco é menor que 10%",
    "enabled": true,
    "condition": {
      "metricName": "Disk Used Percentage",
      "operator": "GreaterThan",
      "threshold": 90
    },
    "actionGroup": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.Insights/actionGroups/{actionGroupName}"
  }
}
```

### Alerta de Exclusão de VM

Monitora eventos administrativos no Activity Log e alerta se uma Máquina Virtual for excluída.

**Arquivo:** `alerts/alerta_vm_excluida.json`

```jsonjson
{
  "name": "Alerta VM Excluída",
  "description": "Alerta gerado quando uma VM for excluída no Azure",
  "resourceType": "Microsoft.Resources/subscriptions/resourceGroups",
  "signalType": "ActivityLog",
  "condition": {
    "operationName": "Microsoft.Compute/virtualMachines/delete",
    "category": "Administrative",
    "status": "Accepted"
  },
  "scope": "/subscriptions/{subscription-id}/resourceGroups/rg-monitoramento",
  "severity": 0,
  "actionGroup": [
    "/subscriptions/{subscription-id}/resourceGroups/rg-monitoramento/providers/microsoft.insights/actionGroups/ag-vm-delete"
  ]
}
```

### Alerta de Falha na Conectividade

Monitora a conectividade da VM e dispara uma ação caso a máquina fique inacessível.

**Arquivo:** `alerts/alerta_conectividade_perdida.json`

```jsonjson
{
  "name": "Alerta Conectividade",
  "properties": {
    "description": "Alerta disparado quando a VM perde conectividade",
    "enabled": true,
    "condition": {
      "metricName": "Network Outage",
      "operator": "Equals",
      "threshold": 1
    },
    "actionGroup": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.Insights/actionGroups/{actionGroupName}"
  }
}
```


### Alerta de Uso Elevado de Memória

Monitora o uso de memória na VM e dispara uma ação quando o uso ultrapassa 85%.

**Arquivo:** `alerts/alerta_memoria_utilizacao.json`

```jsonjson
{
  "name": "Alerta Memória Alta",
  "properties": {
    "description": "Alerta disparado quando o uso de memória RAM ultrapassa 85%",
    "enabled": true,
    "condition": {
      "metricName": "Available Memory Bytes",
      "operator": "LessThan",
      "threshold": 15
    },
    "actionGroup": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.Insights/actionGroups/{actionGroupName}"
  }
}
```

### Alerta de Tentativa de Acesso Não Autorizado

Monitora tentativas de login mal-sucedidas na VM e dispara uma ação quando há mais de 5 tentativas falhas.

**Arquivo:** `alerts/alerta_acesso_nao_autorizado.json`

```jsonjson
{
  "name": "Alerta Acesso Não Autorizado",
  "properties": {
    "description": "Alerta disparado quando há múltiplas tentativas de login falhas",
    "enabled": true,
    "condition": {
      "logName": "SecurityEvent",
      "operationName": "FailedLogin",
      "operator": "GreaterThan",
      "threshold": 5
    },
    "actionGroup": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.Insights/actionGroups/{actionGroupName}"
  }
}
```

### Alerta de Modificação de Firewall

Monitora alterações inesperadas nas regras de firewall e dispara uma ação quando há uma modificação detectada.

**Arquivo:** `alerts/alerta_modificacao_firewall.json`

```jsonjson
{
  "name": "Alerta Modificação Firewall",
  "properties": {
    "description": "Alerta disparado quando há mudanças nas regras de firewall",
    "enabled": true,
    "condition": {
      "logName": "Activity Log",
      "operationName": "Microsoft.Network/networkSecurityGroups/write",
      "operator": "Equals",
      "threshold": 1
    },
    "actionGroup": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.Insights/actionGroups/{actionGroupName}"
  }
}
```

### Alerta de Execução de Comandos Suspeitos

Monitora a execução de comandos potencialmente maliciosos e dispara uma ação caso um comando suspeito seja identificado.

**Arquivo:** `alerts/alerta_comandos_suspeitos.json`

```jsonjson
{
  "name": "Alerta Comandos Suspeitos",
  "properties": {
    "description": "Alerta disparado quando comandos suspeitos são executados",
    "enabled": true,
    "condition": {
      "logName": "Syslog",
      "operationName": "CommandExecution",
      "operator": "Contains",
      "threshold": "wget, curl, nc"
    },
    "actionGroup": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.Insights/actionGroups/{actionGroupName}"
  }
}
```

### Workbook de Monitoramento

Dashboard com gráficos de uso de CPU e memória das VMs conectadas ao Log Analytics.

**Arquivo:** `dashboards/workbook_monitoramento_vm.json`

Contém dois gráficos principais:
- CPU (%) por hora
- Memória disponível (bytes)

### Azure Automation: Reinício de Processo

Script que identifica e encerra o processo que consome mais CPU na VM.

**Arquivo:** `automation/reiniciar_processo_cpu_alta.ps1`

```powershell
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
```

>Os parâmetros **$VMName e $ResourceGroup** devem ser fornecidos pelo Azure Monitor, que dispara o Runbook automaticamente ao ocorrer um alerta. No momento da configuração da ação no Grupo de Ação do Azure, você deve passar esses parâmetros garantindo que o Runbook os receba e execute comandos dentro da VM para identificar e encerrar o processo de maior uso de CPU.

### Logic App: Notificação via Teams

Recebe alertas e envia mensagens automáticas para um canal do Microsoft Teams.

**Arquivo:** `logicapps/alerta_notificacao_teams.json`

Fluxo:
- Disparo via Azure Monitor Alert
- Ação: Envio de mensagem "Alerta de CPU Alto! A VM {vmName} está com uso acima de 90%." para canal de TI

---

## Como Usar

### 1. Importe os recursos no portal do Azure

- [ ] **Baixe os arquivos deste Github**
- [ ] **Importe os alertas aplicáveis ao seu ambiente**
- [ ] **Importe o workbook:** `dashboards/workbook_monitoramento_vm.json`
- [ ] **Crie um Runbook:** copie o conteúdo de `automation/reiniciar_processo_cpu_alta.ps1`
- [ ] **Crie uma Logic App:** usando `logicapps/alerta_notificacao_teams.json`

### 2. Configure permissões e conexões

- Adicione as VMs ao Log Analytics.
- Dê permissão de contributor para Automation.
- Crie um Action Group com e-mail + webhook se quiser notificação adicional.

---

## Conclusão
Esses alertas ajudam a manter a segurança da sua máquina virtual, monitorando eventos críticos e permitindo uma resposta rápida.

## Para saber mais, não deixe de consultar os links abaixo:

- [Azure Monitor - Documentação](https://learn.microsoft.com/pt-br/azure/azure-monitor/)
- [Azure Automation](https://learn.microsoft.com/pt-br/azure/automation/)
- [VM Insights](https://learn.microsoft.com/pt-br/azure/azure-monitor/vm/vminsights-overview)
- [Logic Apps](https://learn.microsoft.com/pt-br/azure/logic-apps/)
- [Azure Monitor - Notificação via Teams](https://techcommunity.microsoft.com/blog/coreinfrastructureandsecurityblog/azure-monitor---alert-notification-via-teams/2507676)
- [Notificações para um canal do Teams](https://learn.microsoft.com/pt-br/azure/data-factory/how-to-send-notifications-to-teams?tabs=data-factory)


---
([Voltar para o README](https://github.com/jardelsantos78/desafio-az-104-monitoramento/tree/main))
