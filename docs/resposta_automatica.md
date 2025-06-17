# Respostas Automáticas no Azure

Neste documento, você verá como configurar um **Runbook no Azure Automation**, integrar com alertas do Azure Monitor e criar respostas automatizadas para eventos críticos. Para exemplo, vamos detalhar como executar a ação **reiniciar uma máquina virtual** quando o uso de CPU ultrapassar **90% por 20 minutos**.

---

## Etapas de Configuração

### **Crie uma Conta de Automação**
1. Acesse o **Portal do Azure**.
2. Pesquise por **Automação do Azure** e clique em **Contas de Automação**.
3. Clique em **Criar** e preencha os detalhes:
   - **Nome:** `Automacao-Monitoramento`
   - **Grupo de Recursos:** Escolha um existente ou crie um novo.
   - **Região:** Selecione a mesma região dos recursos monitorados.
4. Clique em **Criar** e aguarde a implantação.

> *Lembrando que, a Microsoft oferece um nível gratuito por assinatura:*
> - 500 minutos de execução de job por mês gratuitamente, ou seja:
>> - Se você executar scripts pequenos e esporádicos, não haverá cobrança.
>> - Se ultrapassar os 500 minutos/mês ou usar recursos adicionais como Hybrid Worker ou Atualização de patches em larga escala, poderá haver cobrança adicional.
>> - Se houver múltiplas contas de automação na mesma assinatura, os minutos gratuitos são compartilhados entre elas.

### **Crie um Runbook para Resposta Automática**
1. Dentro da **Conta de Automação**, vá até **Runbooks** e clique em **Criar um Runbook**.
2. Preencha os detalhes:
   - **Nome:** `ReiniciarVMAltaCPU`
   - **Tipo:** PowerShell
   - **Versão do Runtime:** Escolha a versão mais recente.
3. Clique em **Criar**.

### **Escreva o Script do Runbook**
Edite o Runbook e insira o seguinte código PowerShell:

```powershell
param (
    [string]$VMName,
    [string]$ResourceGroup
)

# Validar parâmetros
if (-not $VMName -or -not $ResourceGroup) {
    Write-Error "Os parâmetros VMName e ResourceGroup são obrigatórios."
    exit 1
}

try {
    # Autenticação no Azure
    Write-Output "Autenticando no Azure..."
    Connect-AzAccount -Identity

    # Verificar se a VM existe antes de tentar reiniciá-la
    $vm = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName -ErrorAction SilentlyContinue
    if ($vm) {
        Write-Output "Reiniciando a VM $VMName..."
        Restart-AzVM -ResourceGroupName $ResourceGroup -Name $VMName
        Write-Output "A VM $VMName foi reiniciada com sucesso devido ao alto uso de CPU."
    } else {
        Write-Error "A VM $VMName não foi encontrada no grupo de recursos $ResourceGroup."
    }
} catch {
    Write-Error "Ocorreu um erro: $_"
}
```
> Os parâmetros **$VMName e $ResourceGroup** devem ser fornecidos pelo Azure Monitor, que dispara o Runbook automaticamente ao ocorrer um alerta. No momento da configuração da ação no Grupo de Ação do Azure, você deve passar esses parâmetros para o Runbook, garantindo que a VM correta seja identificada e reiniciada.

### **Publique e teste o Runbook**
1. Clique em **Publicar** para ativar o Runbook.
2. Vá até **Testar** e execute com parâmetros de teste (`VMName` e `ResourceGroup`).

### **Associe o Runbook ao Grupo de Ação**
1. No **Azure Monitor**, vá até **Alertas** e selecione o alerta de **CPU acima de 90%**.
2. Clique em **Ações** e selecione **Grupo de Ação**.
3. Adicione uma **ação do tipo "Automação do Azure"** e vincule ao Runbook `ReiniciarVMAltaCPU`.
4. Configure os parâmetros (`VMName` e `ResourceGroup`) para que sejam passados automaticamente pelo alerta.

Com isso, quando a CPU da VM ultrapassar **90% de uso por 20 minutos**, o **Azure Monitor** acionará o **Grupo de Ação**, que executará o **Runbook** para reiniciar a VM automaticamente.

## Importante
**Monitore logs do Azure Automation** para verificar o sucesso das execuções.  
**Considere ações adicionais**, como notificações ao Microsoft Teams ou envio de logs para análise futura.
**Para evitar ultrapassar o limite gratuito de 500 minutos/mês**, recomendo criar um alerta para monitorar o uso da conta de automação.

---
([Voltar para o README](https://github.com/jardelsantos78/desafio-az-104-monitoramento/tree/main))
