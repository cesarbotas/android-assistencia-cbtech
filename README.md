# CBTech — Plataforma SaaS de Gestão de Assistências Técnicas

Aplicativo mobile oficial da plataforma SaaS **CBTech** para gestão operacional, técnica, de estoque e financeira de assistências técnicas especializadas em manutenção de smartphones.

---

## 🚀 Tecnologias Utilizadas
- **Flutter** & **Dart** (compatível com Android e arquitetura preparada para iOS)
- **Material Design 3** (Light & Dark Theme)
- **Riverpod** (Gerenciamento de Estado reativo e modular)
- **GoRouter** (Navegação declarativa com proteção por autenticação e seleção de assistência técnica)
- **Dio** (Cliente HTTP com interceptors para tokens JWT e injeção do `TenantId`)
- **Flutter Secure Storage** (Armazenamento seguro criptografado de credenciais)
- **Image Picker** (Captura de fotos via câmera e anexo de galeria na entrada e bancada)
- **Share Plus** (Compartilhamento nativo de status e comprovantes via WhatsApp)
- **Intl** (Formatação de moeda BRL R$ e datas brasileiras)

---

## 📱 Status do Desenvolvimento & Fases

### ✅ Fase 1 — Fundação (Concluída)
- **Autenticação & Multi-tenancy**:
  - Tela de Login com validação de credenciais.
  - Tela de Seleção de Assistência Técnica (Tenant Ativo).
  - Gerenciamento seguro de sessão com `FlutterSecureStorage` e `AuthController`.
- **Dashboard Operacional**:
  - Contadores de OS (Abertas, Em Reparo, Aguardando Orçamento, Aguardando Retirada).
  - Resumo financeiro (Faturamento, Custos de Peças, Lucro Bruto Estimado).
  - Alertas automáticos de estoque mínimo.
  - Lista rápida das últimas ordens de serviço.

---

### ✅ Fase 2 — Cadastros Base (Concluída)
- **Clientes ([`Customers`](lib/features/customers/))**:
  - Listagem com busca textual em tempo real (nome, telefone, CPF).
  - Formulário completo de cadastro e edição (PF/PJ, WhatsApp, e-mail, endereço e observações).
- **Aparelhos ([`Devices`](lib/features/devices/))**:
  - Catálogo de marcas (Apple, Samsung, Motorola, Xiaomi, etc.).
  - Cadastro de modelos e vinculação com clientes, incluindo IMEI 1/2, cor e serial.
- **Fornecedores ([`Suppliers`](lib/features/suppliers/))**:
  - Cadastro e listagem de fornecedores de componentes e peças de reposição.
- **Peças & Estoque ([`Inventory`](lib/features/inventory/))**:
  - Catálogo de produtos/peças com SKU, custo, preço de venda, estoque atual e estoque mínimo.
  - Filtro dedicado de peças com **alerta de estoque baixo**.
- **Serviços de Mão de Obra ([`Services`](lib/features/services/))**:
  - Tabela padrão de serviços técnicos (Troca de Tela, Troca de Bateria, Desoxidação, etc.) com tempo estimado e categoria.

---

### ✅ Fase 3 — Operação: Ordens de Serviço & Orçamentos (Concluída)
- **Abertura Guiada de OS em 7 Passos ([`NewWorkOrderScreen`](lib/features/work_orders/presentation/new_work_order_screen.dart))**:
  - 1. Seleção de cliente cadastrado ou inclusão de novo cliente.
  - 2. Identificação do aparelho (marca, modelo, cor, IMEI).
  - 3. Estado de conservação no recebimento, acessórios deixados e captura de fotos (Câmera/Galeria).
  - 4. Defeito relatado e nível de prioridade (Baixa, Normal, Alta, Urgente).
  - 5. Diagnóstico técnico inicial e estimativa de horas de bancada.
  - 6. Orçamento preliminar com peças e mão de obra.
  - 7. Resumo final e emissão atômica da numeração sequencial (ex: `OS-0105`).
- **Painel de Ordens de Serviço ([`WorkOrdersScreen`](lib/features/work_orders/presentation/work_orders_screen.dart))**:
  - Busca por número, cliente, aparelho ou defeito.
  - Filtros instantâneos por status oficial (`WorkOrderStatus`).
  - Botão de envio rápido de status pelo WhatsApp com mensagem personalizada.
- **Tela de Detalhes da OS em 5 Abas ([`WorkOrderDetailScreen`](lib/features/work_orders/presentation/work_order_detail_screen.dart))**:
  - **Aba 1 (Visão Geral)**: Status, prioridade, dados do cliente, aparelho e relato de entrada.
  - **Aba 2 (Diagnóstico Técnico)**: Editor de laudo técnico de bancada com persistência.
  - **Aba 3 (Orçamento & Revisões)**: Adição de peças do estoque e serviços, cálculo automático de total, custo e margem de lucro (`estimatedProfit`), além de fluxo formal de aprovação/rejeição.
  - **Aba 4 (Linha do Tempo / Histórico)**: Trilha de auditoria imutável com data/hora, autor da mudança e notas técnicas.
  - **Aba 5 (Fotos & Anexos)**: Visualização e anexo de fotografias de bancada.
- **Workflow de Status**:
  - `Aberta` ➔ `Diagnóstico` ➔ `Orçamento Pendente` ➔ `Aprovada` ➔ `Em Reparo` ➔ `Aguardando Peça` ➔ `Testes` ➔ `Concluída` ➔ `Entregue` (ou `Cancelada`).

---

### ⏳ Próximas Fases do Roadmap
- **Fase 4**: Estoque Avançado & Compras (Movimentações manuais de entrada/saída, histórico Kardex por peça e pedidos de compra).
- **Fase 5**: Financeiro & Caixa (Lançamentos de caixa, formas de pagamento na entrega da OS: PIX, Cartão, Dinheiro e recibos).
- **Fase 6**: Documentos PDF & Relatórios (Emissão de comprovante de entrada de OS e termo de garantia).
- **Fase 7**: Configurações & Gestão de Usuários (Técnicos, atendentes e permissões).

---

## 📚 Documentação Técnica de Referência
Os documentos de especificação para o futuro backend .NET 10 e modelo de dados estão organizados em `docs/`:
- [Arquitetura Geral da Solução](docs/architecture/ARCHITECTURE.md)
- [Design da API REST & Endpoints](docs/api/API_DESIGN.md)
- [Modelo Relacional e RLS do PostgreSQL](docs/database/DATABASE_MODEL.md)
- [Guia de Configuração e Infraestrutura](docs/setup/GETTING_STARTED.md)

---

## 🛠️ Como Executar e Testar o Aplicativo

### Pré-requisitos
- Flutter SDK (3.x+)
- Dart SDK (3.x+)

### Comandos
```bash
# 1. Instalar dependências
flutter pub get

# 2. Executar análise estática (0 erros/avisos)
flutter analyze

# 3. Executar toda a suíte de testes unitários (12 testes cobrindo Fases 1, 2 e 3)
flutter test

# 4. Iniciar o aplicativo no emulador ou dispositivo físico
flutter run
```
