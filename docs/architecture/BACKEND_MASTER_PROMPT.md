# Master Prompt: Desenvolvimento do Backend .NET 10 (CBTech SaaS API)

Use o prompt abaixo para iniciar e guiar a construção completa do backend em .NET 10 da plataforma **CBTech SaaS**, seguindo rigorosamente os padrões arquiteturais do projeto de referência (`gatums-gourmet-api`) e a especificação técnica multi-tenant com PostgreSQL RLS.

---

## 📋 Copie e Cole o Prompt Abaixo para o Desenvolvimento:

```markdown
Atue como um Arquiteto de Software Sênior e Especialista em .NET 10, C#, Clean Architecture e Sistemas SaaS Multi-Tenant.

Sua tarefa é criar a estrutura completa do backend para a plataforma **CBTech SaaS** (Gestão de Assistências Técnicas de Manutenção de Smartphones), seguindo exatamente o padrão arquitetural **Modular Monolith** e as diretrizes do repositório de referência `gatums-gourmet-api`.

### 1. Stack Tecnológica Obrigatória
- **Linguagem & Framework**: .NET 10, C# 13, ASP.NET Core Minimal APIs / Controllers.
- **Banco de Dados**: PostgreSQL 16+ com **Row-Level Security (RLS)** habilitado por `tenant_id`.
- **ORM & Acesso a Dados**: Entity Framework Core 10 com `Npgsql`, Global Query Filters e `SaveChangesInterceptor` para injeção de Tenant ID.
- **Validação**: FluentValidation.
- **Autenticação**: ASP.NET Core Identity / JWT Bearer Tokens com claims de `tenant_id` e `role`.
- **Padrão CQRS (Sem MediatR)**: Handlers dedicados implementando interfaces customizadas `ICommand<TResponse>`, `ICommandHandler<TCommand, TResponse>`, `IQuery<TResponse>`, `IQueryHandler<TQuery, TResponse>` e o objeto `Result<T>` para tratamento de erros sem exceções desnecessárias.
- **Padronização de Erros**: RFC 7807 (Problem Details) (`application/problem+json`).

### 2. Estrutura de Solução e Módulos
Crie uma Solution em .NET 10 dividida nos seguintes projetos (Clean Architecture):
1. **CBTech.Domain**: Entidades puras, Agregados, Value Objects, Enums e Interfaces de Repositório.
2. **CBTech.Application**: Casos de uso divididos por módulos verticais:
   - `Modules/Auth` (Login, Seleção de Tenant, Refresh Token)
   - `Modules/Tenants` (Gestão de Assistências e Assinaturas/Kill-Switch)
   - `Modules/Customers` (Clientes PF/PJ)
   - `Modules/Devices` (Aparelhos, Marcas, IMEI, Senhas)
   - `Modules/Suppliers` (Fornecedores de Peças)
   - `Modules/Inventory` (Produtos, SKU, Estoque Mínimo, Kardex, Pedidos de Compra)
   - `Modules/Services` (Serviços de Mão de Obra)
   - `Modules/WorkOrders` (Ordens de Serviço em 7 passos, Diagnósticos, Orçamentos e Revisões)
   - `Modules/Finances` (Lançamentos de Caixa, Receitas, Despesas e Pagamentos de OS)
   - `Modules/Settings` (Gestão de Usuários da Equipe e Permissões)
3. **CBTech.Infrastructure**: Configuração do EF Core 10, Migrations, Interceptors de RLS (`SET LOCAL app.current_tenant_id`), Repositórios e Serviços externos (PDF, Storage).
4. **CBTech.Contracts**: DTOs públicos de requisição e resposta para a API HTTP.
5. **CBTech.Api**: Endpoints REST, Middlewares globais (Tratamento de Erros, Resolução de Tenant via JWT), Injeção de Dependências e Swagger/OpenAPI.

### 3. Requisitos Críticos de Negócio
- **Isolamento Multi-Tenant por RLS**: Toda conexão com o PostgreSQL deve estar blindada com `SET LOCAL app.current_tenant_id` e EF Core Global Query Filters.
- **Travamento de Inadimplência (Kill-Switch)**: O endpoint de autenticação e o middleware de tenant devem verificar se a propriedade `IsSubscriptionActive` do tenant está ativa. Caso esteja inativa (`false`), retornar HTTP 402 Payment Required.
- **Numeração Sequencial Atômica**: A emissão de números de Ordens de Serviço (ex: `OS-0105`) deve ser sequencial por tenant sem condições de corrida.

Por favor, comece estruturando a Solution .NET 10, os projetos base e o esqueleto completo do primeiro módulo (`Modules/Auth` e `Modules/Tenants`).
```
