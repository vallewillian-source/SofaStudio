# **Objetivo deste documento 🎯**

Definir um **roteiro incremental**, em etapas pequenas e verificáveis, para construir o MVP a partir de uma **pasta vazia já versionada em git**.

Cada etapa deve ser suficientemente explícita para uma IA executar via vibe coding, sem depender de contexto externo.

**Premissas**

- Stack: **Qt 6 + Qt Quick (QML)** para UI; **C++** para core/engine.
- MVP: somente **Postgres** como add-on.
- **DataGrid custom**: inicialmente básico, mas com arquitetura preparada para evoluir.
- UI “bonita” não é prioridade nas primeiras etapas, porém **decisões estruturais devem permitir UI/UX premium** depois.
- Dados retornados do DB: **somente em memória**, sempre que possível paginados.
- As opções do DataGrid devem ficar em um **painel/toolbar escondível** (toggle).

---

## **Convenções globais (valem para todas as etapas)**

### **Toolchain e padrão de build**

- **CMake** como build system.
- Qt 6 (mínimo necessário: Qt6::Quick, Qt6::Qml, Qt6::Gui, Qt6::Core, Qt6::Sql (se usar), Qt6::Network (se necessário)).
- Estrutura modular: core, ui, datagrid, addons.

### **Padrões de código**

- C++17 ou C++20 (decidir e manter).
- Uma camada de **interfaces** (pure virtual) para serviços essenciais: LocalStoreService, AddonHost, CommandService, Logger, DatasetService.
- QML deve consumir o core via **QObjects expostos** (properties + invokables).

### **Critérios de “pronto” por etapa**

Cada etapa precisa incluir:

- **Build rodando** (CI local e/ou comando de build documentado)
- **App abre** e mostra algo verificável
- **Teste manual** simples (checklist)
- Pequeno update em docs/ (quando aplicável)

---

## **Etapa 0 — Bootstrap do repositório (pasta vazia → projeto compilável)**

**Objetivo**: criar um “Hello App” Qt Quick rodando com CMake.

### **Tarefas**

1. Criar estrutura inicial:

```
/CMakeLists.txt
/apps/desktop/CMakeLists.txt
/apps/desktop/main.cpp
/apps/desktop/qml/Main.qml
/docs/01-getting-started.md
```

1. main.cpp:
- iniciar QGuiApplication
- criar QQmlApplicationEngine
- carregar Main.qml
1. Main.qml:
- uma janela simples com título “Sofa Studio”
- texto “Boot OK”
1. Documentar build/run em docs/01-getting-started.md:
- comandos CMake (configure/build/run)
- dependências Qt 6

### **Critério de pronto ✅**

- cmake -S . -B build + cmake --build build gera binário
- Executar abre janela com “Boot OK”

---

## **Etapa 1 — Organização modular + convenções OSS mínimas**

**Objetivo**: preparar o terreno para crescimento organizado.

### **Tarefas**

1. Criar diretórios:

```
/src/core
/src/datagrid
/src/ui
/addons/postgres
/docs/adr
```

1. Criar arquivos OSS mínimos (conteúdo inicial simples):
- README.md (visão curta + como rodar)
- LICENSE (definir depois; usar placeholder “TBD” por enquanto, ou já escolher uma licença)
- CONTRIBUTING.md (placeholder com regras básicas)
- CODE_OF_CONDUCT.md (placeholder)
- ARCHITECTURE.md (1 página: módulos e responsabilidades)
1. Ajustar CMake para compilar apps/desktop e linkar módulos como libs internas (core, datagrid, etc.), mesmo que ainda vazias.

### **Critério de pronto ✅**

- App continua abrindo
- Repo com estrutura modular e docs mínimas

---

## **Etapa 2 — Command System + Logger (base de UX e consistência)**

**Objetivo**: toda ação importante virar comando (futuro command palette e atalhos).

### **Tarefas**

1. Implementar em src/core:
- ILogger + ConsoleLogger
- ICommandService:
    - registrar comando (id, title, callback)
    - executar comando por id
- Implementar CommandService simples.
1. Expor CommandService ao QML:
- Criar AppContext (QObject) que contém ponteiros/refs aos serviços.
- Registrar no QML via engine.rootContext()->setContextProperty("App", appContext).
1. Na UI (Main.qml):
- botão “Test Command” → executa comando que loga no console.

### **Critério de pronto ✅**

- Clicar no botão imprime log no terminal
- Estrutura pronta para “command-first UI” (mesmo sem beleza)

---

## **Etapa 3 — Layout inicial do app (shell do MVP)**

**Objetivo**: criar a estrutura visual do app: sidebar + área principal + abas.

### **Tarefas**

1. Em QML, criar layout básico:
- **Sidebar** (à esquerda):
    - seção “Connections”
    - placeholder lista vazia
    - botão “New Connection”
- Área principal:
    - **Tab bar** (top)
    - área central de conteúdo (placeholder)
1. Criar componentes QML simples em /src/ui:
- AppButton.qml, AppSidebar.qml, AppTabs.qml (sem design final, mas com estrutura).
1. Definir tokens básicos (mesmo se simples) em /src/ui/tokens/:
- cores e spacing mínimos (para facilitar banho de loja depois).

### **Critério de pronto ✅**

- App abre com sidebar e tab bar visíveis
- Componentes estão isolados (fácil de refatorar visual depois)

---

## **Etapa 4 — Local Store (persistência local) + “Connections” (sem DB ainda)**

**Objetivo**: persistir conexões localmente, sem salvar dados sensíveis de DB.

### **Tarefas**

1. Implementar LocalStoreService:
- usar **SQLite local** (ex.: arquivo em diretório do app)
- tabelas mínimas: connections(id, name, host, port, database, user, createdAt, updatedAt, secretRef)
1. Secrets:
- nesta etapa, **não armazenar senha ainda** (deixar secretRef vazio).
- Apenas preparar interface ISecretsService e um stub.
1. UI:
- “New Connection” abre modal com campos:
    - name, host, port, database, user
- salvar e listar na sidebar
- editar e excluir

### **Critério de pronto ✅**

- Criar conexão e ela persiste ao reiniciar o app
- Sidebar lista conexões do banco local

---

## **Etapa 5 — Add-on Host (esqueleto) + contrato do Postgres**

**Objetivo**: criar o sistema de add-ons e os contratos (interfaces), mesmo que o Postgres ainda esteja “mock”.

### **Tarefas**

1. Definir interfaces do add-on (em src/core/addons/):
- IConnectionProvider
- ICatalogProvider
- IQueryProvider
- IDataProvider
1. Definir UDM mínimo (em src/core/udm/):
- Column, TableSchema
- DatasetRequest { cursor, limit, sort, filter }
- DatasetPage { rows, cursor, warnings }
1. Implementar AddonHost inicialmente “in-tree”:
- registrar add-ons em código (sem dynamic loading no MVP)
- AddonHost.registerAddon("postgres", addonInstance)
1. Criar addons/postgres com implementações **mock**:
- testConnection retorna OK
- listSchemas/listTables retornam arrays fake
- execute retorna dataset fake paginado

### **Critério de pronto ✅**

- App consegue “selecionar” o add-on postgres e receber dados fake
- UI mostra schemas/tables fake (sem DB real)

---

## **Etapa 6 — UI de Navegação de Schema (usando mock do Postgres)**

**Objetivo**: construir o fluxo de navegação que depois vai plugar no Postgres real.

### **Tarefas**

1. Quando usuário seleciona uma conexão na sidebar:
- abrir “Database Explorer” na área principal
- chamar CatalogProvider.listSchemas e listTables
1. UI:
- árvore simples: Schema → Tables
- clicar numa tabela abre uma aba “Table: X”
1. “Table View” ainda mostra “placeholder de grid”.

### **Critério de pronto ✅**

- Selecionar conexão → ver schemas e tabelas fake
- Abrir tabela → abre aba

---

## **Etapa 7 — DataGrid custom v1 (base, leitura e UX)**

**Objetivo**: criar um DataGrid próprio com arquitetura encapsulada e UX básica sólida.

### **Requisitos do DataGrid v1 (somente o básico)**

- Renderizar cabeçalho + linhas (virtualização simples por linhas pode ser “mínimo”)
- Scroll vertical
- Seleção de célula e highlight
- Copiar valor da célula (Ctrl/Cmd+C)
- Paginação: botão “Next/Prev” (no começo)
- **Painel/toolbar escondível**:
    - um componente “GridControlsPanel” (toggle show/hide)
    - no MVP v1, conter:
        - botão refresh
        - toggle “wrap text” (mesmo que placebo no começo)
        - seletor de page size (ex.: 50/100/200)

### **Tarefas**

1. Criar módulo src/datagrid:
- DataGridEngine (C++): mantém estado do grid, seleção, paginação, formatação básica
- DataGridView (QQuickItem custom): desenha grid (pode começar simples)
- API de binding: setSchema, setPage(rows), requestPage(cursor, limit)
1. Criar QML wrapper DataGrid.qml em /src/ui/components/:
- contém DataGridView + GridControlsPanel escondível
1. Criar “modo simples” sem otimização extrema ainda, mas com estrutura que permita:
- virtualização 2D no futuro
- render surface única
- caching e prefetch

### **Critério de pronto ✅**

- Abrir tabela (fake) mostra grid com dados
- Selecionar célula funciona
- Copiar célula funciona
- Painel do grid pode ser ocultado/mostrado

---

## **Etapa 8 — Console SQL v1 (mock)**

**Objetivo**: criar editor + executar query + mostrar resultado no DataGrid (ainda fake).

### **Tarefas**

1. Aba “SQL Console”:
- editor multiline básico
- botão Run / Cancel
- executa via QueryProvider.execute
1. Resultado:
- renderizar schema + dataset no DataGrid
- paginação do dataset via DataProvider/QueryProvider (mock)
1. Histórico local:
- salvar query no LocalStoreService (sem salvar resultados)

### **Critério de pronto ✅**

- Rodar query fake retorna grid preenchido
- Cancel funciona (mesmo que apenas “cancele UI” no mock)
- Histórico persiste localmente

---

## **Etapa 9 — Postgres real v1 (conectar e executar SELECT paginado)**

**Objetivo**: substituir mock por Postgres real, mantendo o mesmo contrato UDM.

### **Tarefas**

1. Implementar Postgres add-on real:
- testConnection
- openSession/closeSession
- execute para SELECT
- fetchPage com LIMIT/OFFSET no MVP
1. Catalog:
- listar schemas e tabelas reais
- describe table (colunas, tipos, null)
1. UI:
- habilitar “Connect” com status
- erros amigáveis (mensagem curta + detalhes expandíveis)

### **Critério de pronto ✅**

- Conectar em um Postgres local
- Explorar schemas/tabelas reais
- Rodar SELECT e ver resultado paginado no DataGrid

---

## **Etapa 10 — “Beauty Mode” v1 (Views locais para tabelas)**

**Objetivo**: permitir criar “views” de apresentação para uma tabela (aliases, ocultar colunas, formatação).

### **Tarefas**

1. Modelo local:
- tabela views no SQLite local:
    - id, connectionId, sourceRef, name, definitionJson
1. UI:
- na aba de uma tabela, botão “Create View”
- editor simples:
    - renomear colunas (alias)
    - esconder colunas
    - ordenar colunas
    - formatação básica por tipo (date/money/bool)
1. Aplicação:
- DataGrid recebe schema “decorado” (aliases e formatos) sem alterar UDM base.
- A view deve ser selecionável na UI (dropdown).

### **Critério de pronto ✅**

- Criar view e persistir
- Alternar entre views muda apresentação do grid

---

## **Etapa 11 — Polimento funcional do MVP (sem “banho de loja”)**

**Objetivo**: fechar MVP com robustez mínima e preparar o terreno para UI premium.

### **Tarefas**

1. Cancelamento real de query (se o driver suportar):
- cancelar request e atualizar UI
1. Tratamento de erro sólido:
- erros de conexão, credenciais, SQL inválido
1. UX básica:
- loading states
- empty states
- atalhos mínimos:
    - Run: Ctrl/Cmd+Enter
    - Cancel: Esc
    - Toggle grid controls: Ctrl/Cmd+.
1. Docs:
- atualizar README.md com:
    - features MVP
    - como conectar no Postgres
    - screenshots simples
- criar docs/07-datagrid-engine.md com:
    - arquitetura do grid (estado, render, bindings, cache/paging)
- criar docs/05-postgres-addon.md com:
    - como funciona, como testar

### **Critério de pronto ✅**

- MVP usável end-to-end no Postgres
- Sem crashes em fluxos básicos
- Documentação mínima pronta para contribuições

---

## **Observações importantes para a IA que implementará (instruções gerais)**

- Sempre manter contratos estáveis entre:
    - UI (QML) ↔ Core (C++)
    - Core ↔ Add-on Postgres
    - Core ↔ DataGridEngine
- Evitar “atalhos” que travem o futuro:
    - não acoplar UI a Postgres
    - não espalhar SQL no QML
    - não armazenar resultados em disco
- Preferir pequenas classes coesas e testáveis.
- Priorizar legibilidade e estrutura sobre “beleza visual” nesta fase.

---

Se você quiser, eu transformo esse roteiro em um formato ainda mais “executável por IA”:

- cada etapa com **lista de arquivos a criar/editar**,
- **assinaturas exatas de classes/interfaces**,
- e um **checklist de testes manuais** por etapa.