# CBTech — Aplicativo Mobile (Flutter)

Aplicativo oficial da plataforma SaaS **CBTech** para gestão operacional, técnica e financeira de assistências técnicas especializadas em manutenção de smartphones.

---

## 🚀 Tecnologias Utilizadas
- **Flutter** & **Dart**
- **Material Design 3** (Light & Dark Theme)
- **Riverpod** (Gerenciamento de Estado)
- **GoRouter** (Navegação declarativa com proteção por autenticação e seleção de assistência)
- **Dio** (Cliente HTTP com interceptors de JWT e TenantId)
- **Flutter Secure Storage** (Armazenamento seguro de tokens e credenciais)
- **Image Picker** (Captura e anexo de fotografias de aparelhos)
- **Share Plus** (Compartilhamento nativo de status e comprovantes via WhatsApp)

---

## 📱 Módulos Implementados (Fase 1 — Fundação)
1. **Autenticação & Multi-tenancy**:
   - Tela de Login com validação de credenciais.
   - Tela de Seleção de Assistência Técnica (Tenant Ativo).
   - Gerenciamento seguro de sessão com `FlutterSecureStorage` e `AuthController`.
2. **Dashboard Operacional**:
   - Contadores de OS (Abertas, Em Reparo, Aguardando Orçamento, Aguardando Retirada).
   - Resumo financeiro (Faturamento, Custos de Peças, Lucro Bruto Estimado).
   - Alertas automáticos de estoque mínimo.
   - Lista rápida das últimas ordens de serviço.
3. **Fluxo Guiado de Abertura de Ordem de Serviço (Stepper)**:
   - 1. Cliente (dados cadastrais).
   - 2. Aparelho (marca, modelo, cor, IMEI).
   - 3. Recebimento e Fotos (conservação física, acessórios, fotos via Câmera/Galeria).
   - 4. Defeito relatado e prioridade de atendimento.
   - 5. Diagnóstico técnico inicial.
   - 6. Orçamento preliminar (peças e mão de obra).
   - 7. Confirmação e geração atômica da OS.
4. **Ordens de Serviço**:
   - Listagem com chips de filtro por status e barra de pesquisa em tempo real.
   - Visualização detalhada de OS em BottomSheet.
   - Compartilhamento de status diretamente no WhatsApp.
5. **Cadastros Base**:
   - Módulo de Clientes.
   - Módulo de Aparelhos (com catálogo de marcas: Apple, Samsung, Motorola, Xiaomi, etc.).
   - Módulo de Peças & Estoque com alerta de estoque baixo.
   - Módulo de Serviços com tabela padrão de preços e tempos estimados.
   - Módulo Financeiro com balanço de caixa e registro de transações.
   - Módulo de Configurações da Assistência.

---

## 📚 Documentação Técnica de Referência
Os documentos de especificação para o futuro backend .NET 10 estão organizados na pasta `docs/`:
- [Arquitetura Geral](docs/architecture/ARCHITECTURE.md)
- [Modelo Relacional e RLS do PostgreSQL](docs/database/DATABASE_MODEL.md)
- [Design da API REST](docs/api/API_DESIGN.md)
- [Guia de Configuração e Infraestrutura](docs/setup/GETTING_STARTED.md)

---

## 🛠️ Como Executar o Aplicativo

### Pré-requisitos
- Flutter SDK instalado (`flutter --version`)
- Emulador Android ou dispositivo físico conectado

### Passos
```bash
# 1. Instalar dependências
flutter pub get

# 2. Executar análise estática
flutter analyze

# 3. Executar os testes
flutter test

# 4. Iniciar o aplicativo
flutter run
```
