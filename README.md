# Monitoramento Eficaz de Máquinas Virtuais no Azure

Neste repositório, compartilho minha experiência prática na implementação e administração do monitoramento de recursos no Microsoft Azure, com ênfase nas Máquinas Virtuais (VMs). O objetivo deste projeto é demonstrar como obter uma visão completa do ambiente, mantendo o controle e a capacidade de responder de forma ágil a eventos críticos – como a exclusão inesperada de uma VM – que podem impactar a operação na nuvem.

Além disso, este material reúne anotações e dicas práticas sobre as ferramentas e os serviços de monitoramento do Azure, com o intuito de auxiliar outros profissionais que, assim como eu, buscam um aprendizado contínuo e aprimoramento de suas habilidades na administração de ambientes em nuvem.

A seguir, apresento um guia prático e detalhado para configurar e gerenciar o monitoramento de máquinas virtuais, garantindo total visibilidade sobre os recursos e possibilitando a identificação e resposta proativa a eventos críticos, como o alto uso de CPU, por exemplo.

---

## Introdução

No universo da computação em nuvem, a forma como monitoramos nossos recursos pode definir o sucesso na resposta a incidentes e na manutenção da continuidade dos negócios. Ao iniciar este projeto, meu objetivo era consolidar uma solução que integrasse monitoramento de performance, detecção de ameaças, visualização inteligente e automação de respostas para as Máquinas Virtuais no Azure.

A ideia é sair do modo reativo e adotar uma postura preventiva e inteligente, garantindo que nossa infraestrutura permaneça ágil, segura e resiliente. Este projeto abrange a configuração de alertas de desempenho e segurança, a visualização detalhada de métricas e a implementação de respostas automatizadas utilizando o Azure Automation e Logic Apps.

Embora eu reconheça que ainda há muito para aprender e aperfeiçoar, compartilho minha experiência com a intenção de ajudar outros profissionais a evoluírem. Juntos, podemos transformar o monitoramento tradicional em um mecanismo dinâmico de prevenção de incidentes e de melhoria contínua da infraestrutura em nuvem.


---

## Pré-requisitos

Antes de seguir com a implementação, verifique se você possui os seguintes itens essenciais:

- **Assinatura Ativa**: Uma assinatura ativa (inclusive trial) do Microsoft Azure.
- **Acesso ao Portal do Azure**: Credenciais com permissões administrativas para criação e gerenciamento de recursos.
- **Máquina Virtual para Teste**: Uma VM, preferencialmente Linux (por questões de custo e performance), provisionada para os testes.
- **Agente de Monitoramento ou Diagnósticos Habilitados**: Certifique-se de que o agente de monitoramento está instalado na VM ou que a configuração de diagnósticos está devidamente ativa.
- **Acesso ao Log Analytics Workspace**: Para armazenar, consultar e analisar os logs, é necessário ter um workspace configurado.

---

### Criação do Log Analytics Workspace: Passo a Passo Detalhado

Para facilitar a compreensão e garantir uma implantação sem dúvidas, siga os passos abaixo e consulte as referências visuais fornecidas nos recursos oficiais.

1. **Acesse o Portal do Azure**  
   Faça login no [Portal do Azure](https://portal.azure.com) com suas credenciais.  
   _Observação:_ Na tela de entrada, você verá seu dashboard inicial com diversos serviços.

2. **Localize o Log Analytics Workspaces**  
   - Utilize a barra de pesquisa no topo do portal e digite **"Log Analytics Workspaces"**.  
   - Selecione a opção exibida nos resultados.  
   - Isso o levará a uma tela onde os workspaces já existentes são listados.  
   > **Imagem de Referência:** Veja a Figura 1 no guia do [Microsoft Learn](https://learn.microsoft.com/pt-br/azure/azure-monitor/logs/quick-create-workspace).

3. **Inicie a Criação do Workspace**  
   - Clique no botão **"Criar"**.  
   - Você será redirecionado para a página de criação do Log Analytics Workspace.  
   > **Imagem de Referência:** A Figura 2 do mesmo guia mostra a tela inicial do formulário de criação.

4. **Preencha os Detalhes Básicos**  
   Na página de criação, preencha os seguintes campos:
   - **Assinatura:** Selecione a assinatura que deseja usar.
   - **Grupo de Recursos:** Escolha um grupo existente ou crie um novo. É recomendável agrupar os recursos relacionados para facilitar a gestão.
   - **Nome do Workspace:** Insira um nome exclusivo, por exemplo, `teste-monitoramento-projeto`.
   - **Região:** Selecione a mesma região dos recursos que serão monitorados (por exemplo, **Brazil South**). Isso otimiza a latência e os custos de transferência de dados.
  
5. **Examinar e Criar o Workspace**  
   - Clique no botão **"Examinar + Criar"** para que o Azure valide os dados inseridos.
   - Revise cuidadosamente os detalhes. Se tudo estiver correto, clique em **"Criar"**.
   - A implantação do workspace pode levar alguns minutos. Durante esse tempo, você pode acompanhar o progresso na notificação do portal.
  
6. **Finalização e Verificação**  
   - Após a criação, você pode acessar o workspace para configurar as fontes de dados e iniciar a coleta de logs.  
   - Confira se o workspace aparece na lista e se os agentes (ou as configurações de diagnóstico) da sua VM estão conectando corretamente.

---

### Conexão da VM ao Log Analytics Workspace

Para garantir que sua máquina virtual envie os dados necessários para o monitoramento, siga estes passos:

1. **Selecione a Máquina Virtual**  
   No [Portal do Azure](https://portal.azure.com), navegue até a lista de máquinas virtuais e selecione aquela que deseja monitorar. Essa ação garante que você estará focando nos recursos corretos para sua estratégia de monitoramento.

2. **Acesse as Configurações de Diagnóstico e Monitoramento**  
   No menu da máquina virtual, clique em **Configurações** e, em seguida, selecione **Diagnóstico e Monitoramento**. Nesta tela, você encontrará as opções para configurar a coleta de dados, incluindo logs, métricas e outros diagnósticos.

3. **Selecione o Log Analytics Workspace**  
   Dentro das configurações de diagnóstico, escolha o Log Analytics Workspace previamente criado para centralizar a coleta dos logs. Essa escolha conecta a VM ao ambiente de análise, possibilitando consultas e análises com a Linguagem Kusto (KQL).

4. **Habilite a Coleta de Métricas e Logs**  
   Configure a coleta para incluir:
   - **Métricas:** Dados quantitativos (ex.: uso de CPU, memória).
   - **Logs:** Para VMs Linux, ative a coleta do **Syslog**; para VMs Windows, habilite a captura do **Windows Event Logs**.  
   Essa etapa é fundamental para garantir que tanto eventos operacionais quanto indicadores de performance sejam registrados.

5. **Salvar e Verificar o Funcionamento**  
   Clique em **Salvar** para confirmar as alterações. Em seguida, verifique se a sua VM está enviando dados periodicamente, como os batimentos cardíacos (heartbeat), que indicam a conexão ativa com o Log Analytics Workspace. Caso haja problemas, certifique-se de que o agente de monitoramento está instalado e operando corretamente na VM.

---

## Configuração de Alertas no Azure Monitor

Uma das funcionalidades mais robustas do Azure Monitor é a criação de regras de alerta que permitem uma resposta imediata a situações críticas. A seguir, veja como configurar um alerta passo a passo:

### Criando um Alerta

1. **Abra o Azure Monitor**  
   No [Portal do Azure](https://portal.azure.com), navegue até **Azure Monitor**. Selecione **Alertas** no menu principal e, em seguida, clique em **Regras de Alerta**.

2. **Inicie a Criação de uma Nova Regra de Alerta**  
   Clique em **+ Nova regra de alerta** para começar a configurar um novo alerta. Essa ação abrirá o assistente de criação, que guiará você pelas etapas de definição do escopo, condições e ações.

3. **Defina o Escopo do Alerta**  
   Selecione o recurso ou grupo de recursos que contém a máquina virtual a ser monitorada. Escolher o escopo correto garante que o alerta só será avaliado para os recursos em questão.

4. **Configure a Condição do Alerta**  
   Selecione entre monitorar dados de **Activity Log** (ideal para operações administrativas, como a exclusão de uma VM) ou utilizar **Métricas** (para monitorar desempenho, como alto uso de CPU). Por exemplo, para notificar a exclusão de uma VM, selecione “Activity Log” e especifique a operação `Microsoft.Compute/virtualMachines/delete`. Se o objetivo for monitorar desempenho, configure um alerta baseado em métricas (como uso excessivo de CPU).

5. **Configurar o Grupo de Ação**  
   Crie ou selecione um grupo de ação que especifica os destinatários – e-mail, SMS, webhook, entre outros – para receber as notificações. Este grupo de ação é uma coleção centralizada de configurações de notificação que pode ser aplicada a vários alertas, facilitando atualizações futuras.

6. **Defina os Detalhes do Alerta**  
   Insira um nome descritivo para o alerta, por exemplo, `Alerta - Alto Uso de CPU` ou `Alerta - Exclusão de VM`. Adicione uma descrição detalhada e defina a **severidade** (por exemplo, Crítico) para ajudar sua equipe a priorizar a resposta ao incidente.

7. **Finalize a Criação do Alerta**  
   Após revisar todas as configurações, clique em **Criar Alerta** para concluir o processo. O sistema validará as informações e, se estiver tudo correto, o alerta será publicado e avaliará automaticamente os dados do recurso.

---

### Testando o Alerta

Para validar se o alerta configurado dispararia corretamente, executei os passos abaixo:

1. **Simulação do Evento**  
   - Exclusão da máquina virtual monitorada. Essa ação simulou uma ocorrência crítica e ativou o alerta configurado.
   
2. **Captura e Avaliação do Evento**  
   - Ao excluir a VM, o Azure Monitor registrou o evento e executou a condição especificada na regra de alerta.
   
---

### Validação e Resultado Esperado

Após realizar o teste, realizei as seguintes verificações:

- **Notificação pelo Grupo de Ação**:  
  - Confirmei que o **Grupo de Ação** configurado recebeu a notificação via e-mail. A mensagem continha informações detalhadas sobre o incidente como o tipo de evento e os recursos afetados.

- **Resultado Esperado**:  
  - Acessei o **Activity Log** no Portal do Azure para confirmar que o evento (exclusão da VM) foi devidamente registrado.
  - Nos detalhes do log, constavam informações como a identidade de quem realizou a ação, a hora exata e o status informado pelo sistema.

---

## Dicas Importantes para Monitoramento

- **Consistência das Regiões**: Utilize uma mesma região para a VM e o Log Analytics Workspace sempre que possível para reduzir latência e custos de transferência de dados.
- **Severidade dos Alertas**: Configure níveis de severidade de acordo com o impacto potencial do evento. Isso ajuda a priorizar a resposta da equipe.
- **Consultas KQL**: Aproveite a linguagem Kusto Query Language para criar consultas personalizadas que possibilitam análises detalhadas e identificação de padrões nos logs.
- **Documentação de Alterações**: Sempre registre as configurações e alterações realizadas. O Activity Log pode ser essencial para auditoria e investigação de incidentes.
- **Automatização de Respostas**: Considere utilizar ações automatizadas (como webhooks ou Azure Functions) para integrar os alertas a sistemas internos de gerenciamento de incidentes ou comunicação (Microsoft Teams, Slack, etc.).
- **Testes Regulares**: Periodicamente, realize testes de alerta para garantir que toda a cadeia de monitoramento e notificação esteja funcionando de forma ideal.
- **Revisão dos Grupos de Ação**: Mantenha atualizados os contatos dos responsáveis e ajuste os grupos de ação conforme a equipe evolui.
- **Monitoramento Inteligente de Máquinas Virtuais no Azure**: Para garantir um ambiente estável e seguro para suas máquinas virtuais no Microsoft Azure disponibilizei alguns arquivos JSON para servirem de **soluções completas** para acompanhar desempenho, segurança e o comportamento das VMs. O intuito é proporcionar uma **visibilidade detalhada das métricas essenciais** e **respostas automatizadas** para eventos críticos. Com o uso de **Azure Automation** e **Logic Apps**, é possível transformar o monitoramento reativo em uma abordagem proativa, permitindo que alertas sejam acionados dinamicamente e respostas automatizadas garantam a continuidade dos serviços. Para conhecer e explorar algumas soluções de monitoramento, acesse o arquivo [Soluções de monitoramento](docs/solucoes.md).

---

## Conclusão

Este guia demonstrou um processo para configurar o monitoramento de máquinas virtuais no Azure. A implementação desses recursos permite que a equipe de TI mantenha um controle rigoroso sobre os ativos críticos, garantindo respostas rápidas a qualquer evento inesperado e fortalecendo a postura geral de segurança e confiabilidade da infraestrutura.

Caso necessite de ajuda adicional, consulte os guias oficiais no [Microsoft Learn](https://learn.microsoft.com/pt-br/azure/azure-monitor/) e vídeos tutoriais, que demonstram cada etapa com detalhes visuais para confirmar as configurações em tempo real.


