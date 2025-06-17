# Kusto Query Language (KQL)

O **Kusto Query Language (KQL)** é a linguagem utilizada para consultas de dados dentro do **Azure Monitor**, especialmente no **Log Analytics** e no **Application Insights**. Ele permite realizar análises profundas de registros e métricas armazenadas, facilitando a detecção de padrões e anomalias em ambientes monitorados.

### Importância do KQL

- **Análise eficiente de logs**: Permite consultas rápidas sobre eventos do sistema, métricas de desempenho e dados de segurança.
- **Monitoramento proativo**: Com KQL, os administradores podem criar alertas baseados em padrões específicos nos logs.
- **Facilidade na criação de dashboards**: KQL é amplamente utilizado para alimentar visualizações gráficas dentro do **Azure Workbooks**, proporcionando insights claros e acessíveis.

### Como utilizar KQL

1. Acesse o **Azure Monitor** ou **Log Analytics**.
2. Utilize a interface de consulta para escrever comandos KQL e visualizar os resultados.
3. Exemplos de consultas:

```kql
// Exibir eventos de erro nos últimos 24h
Event 
| where TimeGenerated > ago(24h) 
| where EventLevelName == "Error"
```

```kql
//Listar VMs que reiniciaram nos últimos 7 dias
Heartbeat
| where TimeGenerated > ago(7d)
| summarize Restarts = count() by Computer
| order by Restarts desc
```

```kql
//Verificar falhas de login no Azure AD
SigninLogs
| where ResultType != "0"
| summarize Falhas=count() by UserPrincipalName, ResultDescription
| order by Falhas desc
```

```kql
//Monitorar uso de CPU acima de 90% em VMs nos últimos 2 dias
Perf
| where TimeGenerated > ago(2d)
| where CounterName == "% Processor Time"
| where InstanceName == "_Total"
| where CounterValue > 90
| summarize max(CounterValue) by Computer, bin(TimeGenerated, 1h)
| order by TimeGenerated desc
```

```kql
//Detectar falhas de disco (Event Viewer - ID 7 e 11)
Event
| where EventID in (7, 11)
| where Source == "Disk"
| summarize TotalFalhas = count() by Computer, EventID, RenderedDescription
| order by TotalFalhas desc
```

```kql
//Consultar logs de atividades administrativas no Azure
AzureActivity
| where Category == "Administrative"
| where ActivityStatus == "Succeeded"
| summarize Ações=count() by Caller, OperationNameValue
| order by Ações desc
```

```kql
//Exibir alertas críticos disparados nos últimos 3 dias
Alert
| where TimeGenerated > ago(3d)
| where Severity == "Sev3" or Severity == "Sev2"
| summarize Total=count() by AlertName, Severity, Resource
| order by Total desc
```

```kql
//Verificar tempo médio de resposta de um aplicativo (Application Insights)
requests
| where timestamp > ago(24h)
| summarize avg(duration) by bin(timestamp, 1h)
| render timechart
```

```kql
//Identificar falhas de dependência em um serviço
dependencies
| where success == false
| summarize TotalErros = count() by target, type
| order by TotalErros desc
```

4. Por fim, integre KQL a **Workbooks** para criar dashboards interativos.

---
([Voltar para o README](https://github.com/jardelsantos78/desafio-az-104-monitoramento/tree/main)
)
