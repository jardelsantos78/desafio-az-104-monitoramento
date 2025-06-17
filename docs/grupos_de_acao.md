# Grupos de Ação no Azure

Os **Grupos de Ação** são recursos do **Azure Monitor** que facilitam o envio de notificações e a execução de ações automáticas quando um alerta é acionado.

### Qual a importância dos Grupos de Ação?

- **Automação de respostas**: Quando um alerta é disparado, um **Grupo de Ação** pode executar scripts, reiniciar serviços ou escalar incidentes para equipes responsáveis.
- **Comunicação eficaz**: Suporte a notificações via **e-mail, SMS, aplicativos móveis, webhooks** e integrações com **Microsoft Teams** e **ITSM**.
- **Flexibilidade na gestão de alertas**: Permite definir grupos de destinatários específicos para diferentes tipos de alertas.

### Como utilizar Grupos de Ação?

1. **Criar um Grupo de Ação** no **Azure Monitor**.
2. **Definir os destinatários** (e-mails, números de telefone ou serviços integrados).
3. **Associar o grupo a alertas** para automatizar respostas.
4. **Exemplos de uso**:
   - Enviar uma mensagem ao **Microsoft Teams** quando uma VM apresentar uso de CPU acima de 90%.
   - Enviar uma mensagem por e-mail quando uma VM monitorada for excluída.

---

# Aplicação prática dos exemplos citados anteriormente:

## Cenário

Configurar um **Grupo de Ação** no Azure Monitor para enviar notificações simultâneas quando:

- Uma **VM apresentar uso de CPU acima de 90% por mais de 20 minutos**, ou
- Uma **VM for excluída**.

As notificações serão enviadas:
- Por **e-mail** para `monitoria_ti@suporte.com.br`
- Para o **canal do Microsoft Teams "Suporte TI N3"`**

---

## Etapas de Configuração

### 1. Crie o Grupo de Ação

**Nome sugerido:** `GAC-SuporteTI-N3`

Adicione duas ações:

#### ➤ Ação 1: Envio de E-mail

- **Nome:** `EmailMonitoriaTI`
- **Tipo:** E-mail
- **Destinatário:** `monitoria_ti@suporte.com.br`

#### ➤ Ação 2: Envio para o Microsoft Teams

- **Nome:** `TeamsSuporteTI`
- **Tipo:** Webhook
- **URL:** (Webhook gerado no canal Teams)
- **Corpo personalizado:** (exemplo abaixo)

> *Nota: para criar o Webhook do Teams:*
> - No canal **Suporte TI N3**, vá em “Conectores” > “Webhook Personalizado” > Defina um nome > Copie a URL.
> - **Teste a URL do Webhook** antes de utilizá-la para garantir o correto funcionamento.

---

### 2. Crie os Alertas e Associe-os ao Grupo de Ação

#### Alerta 1: CPU Acima de 90% por mais de 20 minutos

- **Recurso:** Máquina Virtual
- **Métrica:** `% Processor Time`
- **Condição:** `Maior que 90` por `20 minutos`
- **Intervalo de amostragem:** **5 minutos**
- **Ação:** Grupo `GAC-SuporteTI-N3`
- **Gravidade:** 2 (Alta)

#### Alerta 2: VM Excluída

- **Recurso:** Subscription ou Resource Group (ajustado para escopo correto)
- **Fonte de Log:** AzureActivity
- **KQL:**
  
  ```kql
  AzureActivity
  | where OperationNameValue == "Microsoft.Compute/virtualMachines/delete"
  | where ActivityStatusValue == "Succeeded"
  | where ResourceGroup == "MeuGrupoDeRecursos" // Filtrar por Resource Group
  ```

- **Ação:** Grupo `GAC-SuporteTI-N3`
- **Gravidade:** 1 (Crítica)

---

### Exemplo básico de JSON para Webhook do Microsoft Teams

```json
{
  "title": "Alerta do Azure Monitor",
  "text": "**Alerta Ativado**: {{alertName}}\n\n**Recurso**: {{resourceName}}\n**Descrição**: {{description}}\n**Hora**: {{timestamp}}",
  "themeColor": "EA4300"
}
```

---

## Integração com Azure Automation

Para que as notificações sejam **mais eficazes**, considere adicionar um **Runbook** no **Azure Automation**, permitindo **respostas automáticas** a incidentes:

- **Exemplo:** Reiniciar uma VM ou um serviço crítico quando o uso de CPU ultrapassar 90% por 20 minutos.
- **Passos:**
  1. Crie um **Runbook** com um script de resposta automática.
  2. Vincule o Runbook ao **Grupo de Ação**.

---

## Resultado Esperado

Quando qualquer uma das condições acima for atendida:

- A equipe de monitoramento receberá um **alerta por e-mail**.
- O canal **Suporte TI N3** no **Microsoft Teams** receberá uma **mensagem automática** com os detalhes do alerta.
- **Possível resposta automática via Azure Automation** [(vide exemplo)](docs/resposta_automatica.md).

---

## Considerações Finais

**Padronize a severidade dos alertas** para melhor priorização.  
**Sempre teste webhooks antes de utilizar** para evitar falhas de comunicação.  
**Explore a integração com Azure Automation** para respostas automáticas eficazes.

---
([Voltar para o README](https://github.com/jardelsantos78/desafio-az-104-monitoramento/tree/main))
