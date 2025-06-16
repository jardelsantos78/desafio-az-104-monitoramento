# Azure VM Monitoring - Performance, Security & Automation

Este repositório fornece uma solução completa de monitoramento para Máquinas Virtuais no Microsoft Azure. Ele abrange alertas de desempenho, segurança, visualização de métricas e respostas automatizadas via Azure Automation e Logic Apps.

## Objetivo

Monitorar VMs em tempo real, detectar anomalias, aplicar respostas automáticas e notificar equipes técnicas de forma eficiente.

---

## Estrutura do Repositório

```
/
├── alerts/                    # Regras de alerta baseadas em métricas e eventos
│   ├── cpu-alert.json
│   └── vm-delete-alert.json
├── dashboards/               # Workbooks customizados para visualização
│   └── vm-monitoring-workbook.json
├── automation/               # Runbook do Azure Automation
│   └── RestartHighCPUProcess.ps1
├── logicapps/                # Logic App para notificação via Microsoft Teams
│   └── AlertTeamsNotification.json
└── README.md                 # Documentação principal
```

---

## Componentes da Solução

### Alerta de CPU Alta

Detecta quando a VM ultrapassa 90% de uso de CPU por mais de 10 minutos.

**Arquivo:** `alerts/cpu-alert.json`

```jsonjson
{
  "name": "CPUHighUsage",
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

### Alerta de Exclusão de VM

Monitora eventos administrativos no Activity Log e alerta se uma Máquina Virtual for excluída.

**Arquivo:** `alerts/vm-delete-alert.json`

```json
{
  "name": "VMDeletionAlert",
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

### Workbook de Monitoramento

Dashboard com gráficos de uso de CPU e memória das VMs conectadas ao Log Analytics.

**Arquivo:** `dashboards/vm-monitoring-workbook.json`

Contém dois gráficos principais:
- CPU (%) por hora
- Memória disponível (bytes)

### Azure Automation: Reinício de Processo

Script que identifica e encerra o processo que consome mais CPU na VM.

**Arquivo:** `automation/RestartHighCPUProcess.ps1`

```powershell
param([string]$vmName, [string]$resourceGroupName)

$session = New-AzVMRunCommandSession -ResourceGroupName $resourceGroupName -VMName $vmName

$command = "Get-Process | Sort CPU -Descending | Select -First 1 | Stop-Process -Force"

Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -VMName $vmName -CommandId 'RunPowerShellScript' -ScriptString $command

Remove-AzVMRunCommandSession -Session $session
```

### Logic App: Notificação via Teams

Recebe alertas e envia mensagens automáticas para um canal do Microsoft Teams.

**Arquivo:** `logicapps/AlertTeamsNotification.json`

Fluxo:
- Disparo via Azure Monitor Alert
- Ação: Envio de mensagem "Alerta de CPU Alto! A VM {vmName} está com uso acima de 90%." para canal de TI

---

## Como Usar

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/azure-vm-monitoring.git
cd azure-vm-monitoring
```

### 2. Importe os recursos no portal do Azure

- [ ] **Importe o alerta:** `alerts/cpu-alert.json`
- [ ] **Importe o workbook:** `dashboards/vm-monitoring-workbook.json`
- [ ] **Crie um Runbook:** copie o conteúdo de `automation/RestartHighCPUProcess.ps1`
- [ ] **Crie uma Logic App:** usando `logicapps/AlertTeamsNotification.json`

### 3. Configure permissões e conexões

- Adicione as VMs ao Log Analytics.
- Dê permissão de contributor para Automation.
- Crie um Action Group com e-mail + webhook se quiser notificação adicional.

---

## Referências

- [Azure Monitor - Documentação](https://learn.microsoft.com/pt-br/azure/azure-monitor/)
- [Azure Automation](https://learn.microsoft.com/pt-br/azure/automation/)
- [VM Insights](https://learn.microsoft.com/pt-br/azure/azure-monitor/vm/vminsights-overview)
- [Logic Apps](https://learn.microsoft.com/pt-br/azure/logic-apps/)

---
