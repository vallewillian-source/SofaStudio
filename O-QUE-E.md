## **0) Visão e objetivo 🎯**

Criar um cliente desktop **open source** para bancos de dados, começando por **PostgreSQL**, com UI/UX minimalista, rápida e extensível, inspirado no impacto do Visual Studio Code: uma base enxuta, consistente, altamente plugável e com ótima experiência.

**MVP**: equivalente às funções básicas do Beekeeper Studio (só SQL, conectar, explorar schema, rodar SQL, ver resultados), porém com:

- UX superior (velocidade, padrões, legibilidade, atalhos, “beleza” nas tabelas)
- arquitetura interna desencapsulada (padrões + interfaces injetáveis)
- add-ons desde o dia 1 (o primeiro: Postgres)

---

## **1) Princípios de produto e engenharia ✅**

### **1.1 Diretrizes de UX**

- **Minimalismo funcional**: poucos elementos, bem resolvidos.
- **Rápido por padrão**: latência baixa em cada interação (scroll, filtros, abrir tabela).
- **Consistência total**: padrões de componentes, comportamento e atalhos.
- **“Beauty mode”**: transformar tabelas em views legíveis e analisáveis (sem virar BI corporativo).

### **1.2 Diretrizes de arquitetura**

- **Tudo que for crítico é interfaceado e injetável**: execução SQL, catálogo/schema, streaming de dados, persistência local, telemetry opt-in, feature flags, etc.
- **Core “magro”**: UI e motor universal de dados; conectores e variações via add-ons.
- **Contrato universal de dados**: DataGrid funciona igual para qualquer fonte.
- **Eficiência**: sempre paginar e/ou streamar; nunca tentar carregar “tudo” de uma tabela.

### **1.3 Open source-first**

- Código e decisões documentadas.
- Padrões comuns de projetos OSS: contribution guide, code of conduct, arquitetura, ADRs.
- Build reprodutível e CI desde cedo.

---

## **2) Stack e plataforma 🧱**

### **2.1 Stack**

- **Shell + layout + componentes**: Qt Quick (QML)
- **Engine do grid e dados**: **C++** (camada performática)
- **Design system**: tokens (cores, spacing, radius, typography) + biblioteca de componentes QML

### **2.2 Processo do app (conceitual)**

- **UI Layer**: QML (Shell, navegação, sidebar, tabs, dialogs)
- **Core Layer (C++)**: domínio + serviços + DI (Service Container) + Command System
- **Addon Host (C++)**: carregamento/execução de add-ons + compat
- **Data Engine (C++)**: DataGrid engine + UDM + cache/paginação
- **Local Store (C++)**: persistência local (preferências, views, conexões) + integração com secrets do SO

---

## **3) Escopo do MVP (apenas o essencial) ✅**

### **3.1 Funcionalidades do MVP**

1. **Conexão com Postgres (via add-on)**
- Criar/editar/remover conexões
- Testar conexão
- Conectar e manter sessão
1. **Navegação do banco**
- Lista de schemas/tabelas/views
- Colunas (tipo, null, default)
- Índices e constraints (no mínimo: PK/FK)
1. **SQL Console básico**
- Editor SQL com executar/cancelar
- Abas
- Histórico local de queries (por conexão)
- Resultados em DataGrid
1. **DataGrid universal**
- Tabela de resultados com:
    - paginação
    - ordenação por coluna (server-side quando possível)
    - copiar célula/linha
    - export simples (CSV) opcional no MVP (se der tempo)
1. **“Beauty mode” (MVP)**
- Criar “View” para uma tabela com:
    - aliases de colunas (nome amigável)
    - ocultar/ordenar colunas
    - formatação básica por tipo (data, moeda, boolean, null highlight)
    - filtros salvos (ex.: “status != archived”)
- Várias views para a mesma tabela

**Fora do MVP**: dashboards, charts, profiling avançado, colaboração, outros bancos.

---

## **4) Arquitetura interna: Core desencapsulado + Add-ons 🔌**

### **4.1 Componentes principais**

(A) **App Core (C++)**

- Estado global, navegação, layout, tema, atalhos.
- Registro de serviços (Service Container / DI).
- Command System (todas ações do app viram comandos).
- Host de add-ons (carrega, valida, executa).
- Orquestração do DataGrid + pipeline universal de dados.

(B) **UI Shell (QML/Qt Quick)**

- Sidebar, tabs, modais, listas e layout geral.
- Componentes do design system (Button, Input, Tabs, List, Dialog, etc.).
- Camada de binding para comandos e serviços do Core.

(C) **Add-on Host (C++)**

- Manifest + versionamento + compat.
- Carregamento controlado (sandbox/isolamento quando viável).
- Permissões (rede, secrets, filesystem) — no MVP pode ser conceitual/documentado.

(D) **Universal Data Model (UDM) (C++)**

- Padrão universal para:
    - schema metadata
    - datasets tabulares
    - paginação/cursores
    - tipos e formatações
    - operações (sort/filter) expressas de forma abstrata

(E) **Local Store (C++)**

- Banco local para persistir “experiência” (não dados sensíveis do DB).
- Integração com secure storage do sistema para secrets.

---

## **5) Contratos: como o Postgres vira “universal” 📦**

### **5.1 Add-on de fonte (primeiro: Postgres)**

Um add-on de fonte implementa estes contratos (interfaces):

**I. ConnectionProvider**

- listConnections()
- createConnection(config)
- testConnection(config)
- openSession(connectionId)
- closeSession(sessionId)

**II. CatalogProvider (schema)**

- listSchemas(sessionId)
- listTables(sessionId, schema)
- describeTable(sessionId, schema, table)
- listRelations(sessionId, schema, table) (FKs básicas)

**III. QueryProvider (console)**

- execute(sessionId, query, params?, options) → ResultHandle
- cancel(resultHandle)
- fetchPage(resultHandle, cursor|pageToken)
- getResultSchema(resultHandle) → UDM schema

**IV. DataProvider (para DataGrid universal)**

- createDataset(queryOrTableRef, options) → DatasetHandle
- fetch(datasetHandle, request) → DatasetPage
    - request: {cursor, limit, sort, filter}
- release(datasetHandle)

Observação: Postgres pode mapear “table view” para query (SELECT …) e sempre operar via fetch paginado.

### **5.2 Universal Data Model (UDM) — definição base**

**UDM.TableSchema**

- columns[]: { id, name, type, nullable, displayType?, formatHints? }

**UDM.Page**

- rows: Row[] (row como vetor/array para performance)
- rowCount?: number (opcional, caro)
- cursor?: string (para paginação)
- warnings?: string[]

**UDM.TypeSystem**

- Tipos universais: string, number, integer, boolean, datetime, date, time, json, binary, uuid, money, unknown
- Cada add-on declara mapeamentos + hints (ex.: precision/scale)

**UDM.Filter/Sort**

- Sort[]: { columnId, direction }
- Filter: AST simples (AND/OR, ops = != > < contains in isnull)

### **5.3 Eficiência (obrigatória)**

- Sem “select * sem limite” automático.
- Paginação obrigatória:
    - Por LIMIT/OFFSET no MVP (simples)
    - Evolução futura: keyset pagination por PK/índice + cursores
- Streaming: retornar schema rápido, trazer dados por páginas.
- Cancelamento: sempre suportar abort do request.

---

## **6) DataGrid “super inteligente” 🧠 (AGORA COMO ENGINE C++)**

### **6.1 Responsabilidades do DataGrid Engine (C++)**

- Renderização performática via Qt Quick (surface única / item especializado), com:
    - virtualização de linhas e colunas
    - layout e hit-testing eficientes
    - input model (seleção, foco, teclado, scroll) controlado por engine
- Operações padronizadas: sort/filter/page.
- Pipeline de formatação:
    - tipo universal → renderer default
    - “beauty mode” pode sobrescrever renderers/hints

### **6.2 Data requests (contrato único)**

A UI nunca fala “Postgres”; ela fala:

- dataset.fetch({ cursor, limit, sort, filter })

O add-on decide como traduzir isso:

- SQL com ORDER BY / WHERE / LIMIT
- ou outra tecnologia no futuro (NoSQL, APIs, arquivos)

### **6.3 Estratégia de performance (MVP)**

- Cache LRU de páginas do dataset (apenas memória).
- “Prefetch” de páginas adjacentes (ex.: página atual + próxima).
- Evitar materializar estruturas por célula; preferir arrays/colunas compactas.

---

## **7) “Beauty mode” — modelo de Views ✨**

### **7.1 Conceito**

Uma View é um “preset de apresentação” aplicável a:

- uma tabela (schema.table)
- (opcional futuro) um dataset de query

### **7.2 O que uma View contém (MVP)**

- Identidade: viewId, name, sourceRef (tabela)
- Colunas:
    - alias (display name)
    - visibilidade
    - ordem
    - formato (ex.: date format, moeda, boolean labels)
- Filtros salvos (UDM Filter AST)
- Ordenação salva

### **7.3 Relações/“FK lookup” (análise mais agradável)**

No MVP, manter simples:

- Configurar “coluna X referencia tabela Y” e mostrar um “display field” ao invés do ID (lookup paginado).
- Implementação sugerida:
    - resolver lazy: ao renderizar a célula, coletar IDs visíveis e buscar batch (com cache)
    - sem joins automáticos no MVP; apenas lookup cacheado

---

## **8) Persistência local segura 🗄️🔒**

### **8.1 Regras de segurança**

- Nunca persistir dados retornados do DB em disco.
    - Resultados ficam apenas em memória (com eviction).
- Persistir apenas:
    - configurações, conexões (sem senha em plain text), histórico de queries (opcional: com redaction), views, preferências de UI.

### **8.2 Banco local (estrutura)**

Escolher um banco embutido simples e robusto (ex.: SQLite). Estrutura proposta:

**Tabelas locais**

- connections
    - id, name, host, port, database, user, sslMode, createdAt, updatedAt
    - secretRef (ponteiro para credencial no secure storage)
- workspaces
    - id, name, createdAt, updatedAt
- recent_connections
    - workspaceId, connectionId, lastUsedAt
- query_history
    - id, workspaceId, connectionId, queryText, createdAt
    - tags, starred
    - (opcional) redactedQueryText
- views
    - id, workspaceId, connectionId, sourceRef, name, definitionJson, createdAt, updatedAt
- ui_preferences
    - tema, atalhos custom, etc.

### **8.3 Secrets (credenciais)**

- Guardar senha/token no secure storage do SO:
    - Keychain (macOS), Credential Manager (Windows), Secret Service/libsecret (Linux)
- O banco local guarda apenas secretRef.

### **8.4 Como acessar esses dados no código (padrão)**

Definir um LocalStoreService com interface única:

- getConnections() / saveConnection() / deleteConnection()
- getViews(sourceRef) / saveView()
- appendQueryHistory() / listQueryHistory()

E injetar via DI para toda a app.

- QML consome por bindings/handlers que chamam esse serviço.
- Testes usam InMemoryLocalStore (mesma interface).

---

## **9) Organização do repositório e padrões OSS 📚 (ATUALIZADO)**

### **9.1 Estrutura sugerida do repo**

- /apps/desktop — app Qt (C++ + QML)
- /src/core — domínio + contratos UDM + DI + command system + addon host
- /src/ui — design system QML (tokens + componentes)
- /src/datagrid — engine do grid (C++ + item QML)
- /src/local_store — persistência local + secrets
- /addons/postgres — primeiro add-on (Postgres)
- /docs — documentação
- /.github — workflows, templates, CODEOWNERS

### **9.2 Documentação que deve existir (onde e o quê)**

**Raiz**

- README.md — visão, screenshots, quick start, roadmap do MVP
- LICENSE
- CODE_OF_CONDUCT.md
- CONTRIBUTING.md
- SECURITY.md
- GOVERNANCE.md
- ARCHITECTURE.md — visão geral do core + add-ons + UDM + DataGrid engine
- ROADMAP.md — apenas MVP + próximas 2-3 etapas

**/docs**

- docs/01-getting-started.md — build, toolchain, debug (Qt/CMake)
- docs/02-design-system.md — tokens QML, componentes, padrões de UI/UX
- docs/03-udm-spec.md — Universal Data Model (formal)
- docs/04-addon-system.md — manifest, lifecycle, permissões, ABI/API
- docs/05-postgres-addon.md — como funciona e como contribuir
- docs/06-local-storage.md — modelo local + secrets
- docs/07-datagrid-engine.md — arquitetura do grid (render, input model, paging/cache)
- docs/adr/ — ADRs

### **9.3 ADRs iniciais (mínimo) — atualizado**

- ADR-0001: Por que Qt Quick + C++ (substitui “React Native desktop”)
- ADR-0002: Por que UDM e DataGrid universal
- ADR-0003: Estratégia de paginação e não persistência de dados do DB
- ADR-0004: Sistema de add-ons (e limites no MVP)
- ADR-0005: Design do DataGrid engine (surface única, virtualização, cache)

---

## **10) Padrões de implementação (para “desencapsular” de verdade) 🧩**

### **10.1 Service Container / DI (C++)**

Um container simples onde tudo é interface:

- LocalStoreService
- AddonRegistry
- TelemetryService (no-op por padrão)
- CommandService (atalhos/palette)
- LoggerService
- DataGridService (datasets, cache, resolvers)

Implementações default no core; substituíveis por testes/plugins.

### **10.2 “Command-first UI”**

Mesmo no MVP:

- Todas ações do app registradas como comandos:
    - “Open Connection”
    - “Run Query”
    - “Cancel Query”
    - “Create View”
- QML chama comandos; comandos chamam serviços.

### **10.3 Estado e dados em runtime**

- Datasets/resultados ficam em memória em um DatasetCache com:
    - TTL / LRU
    - tamanho máximo
    - release ao fechar abas
- View definitions e configs vêm do LocalStore.

---

## **11) Itens adicionais que você provavelmente não quer esquecer ✅**

### **11.1 UX que faz diferença (MVP)**

- Atalhos consistentes (rodar/cancelar alternando)
- Loading states refinados (skeleton)
- Mensagens de erro “humanas” com detalhes técnicos expansíveis
- Confirmações para ações destrutivas (mesmo que MVP não tenha escrita)

### **11.2 Observabilidade do app (sem invadir privacidade)**

- Logs locais
- Telemetry opt-in (desativado por padrão), documentado em SECURITY.md e PRIVACY.md (criar se necessário)

### **11.3 Qualidade OSS**

- CI: build (mac/win/linux), lint/format, testes
- Convenções: clang-format / clang-tidy (ou equivalente), guidelines de C++ e QML
- Releases assinadas (futuro)

---

## **12) Checklist de entrega do MVP 🧾**

1. Repo estruturado + docs mínimas OSS
2. UI shell (sidebar + tabs + console + grid) em Qt Quick
3. LocalStore + secrets
4. Add-on host + addon “postgres”
5. DataGrid engine (virtualização 2D + paginação + copiar célula/linha)
6. Beauty mode:
    - criar/editar views
    - aplicar view na tabela
7. Polimento UX (atalhos, loading, erro/cancel)

---

### **Mudanças-chave desta versão (resumo)**

- Troca de **React Native desktop** → **Qt Quick (QML)** para UI + **C++** para core/engine.
- DataGrid passa a ser explicitamente uma **engine C++** integrada ao Qt Quick.
- Repo e docs ajustados para toolchain Qt/CMake e guidelines C++/QML.

Se você quiser o próximo passo já “executável”, eu sugiro fechar 2 decisões e registrar em ADR:

1. **CMake + estrutura de targets** (core/ui/datagrid/addons)
2. **Forma de carregar add-ons** no MVP (dinâmico via shared libs vs “in-tree” com interface estabilizada)

[Roteiro](https://www.notion.so/Roteiro-2fda0dda92aa80619043dafd59e5e1e7?pvs=21)