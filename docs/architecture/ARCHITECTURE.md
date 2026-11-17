# CBTech — Arquitetura de Software

## 1. Visão Geral
O **CBTech** é uma plataforma SaaS multi-tenant voltada para gestão operacional, técnica e financeira de assistências técnicas de manutenção de smartphones.

A plataforma adota o padrão **Modular Monolith** com **Clean Architecture** no backend em .NET 10 e cliente mobile desenvolvido em **Flutter** (Android prioritário, arquitetura pronta para iOS).

---

## 2. Padrões Arquiteturais e Diretrizes

### 2.1. Clean Architecture (Separação em Camadas)
1. **CBTech.Domain**:
   - Camada pura, sem dependência de frameworks externos ou bibliotecas de persistência.
   - Contém Entidades, Agregados, Enums, Value Objects, Domain Events e interfaces de domínio.
   - Aplica os princípios de isolamento de regras de negócio.
2. **CBTech.Application**:
   - Coordena os casos de uso do sistema.
   - Organização vertical por módulos (`Modules/Tenants`, `Modules/Identity`, `Modules/Customers`, `Modules/WorkOrders`, etc.).
   - Padrão **CQRS** próprio e leve (Commands, Queries, Handlers, Validators, DTOs e Results) sem dependência obrigatória de bibliotecas de terceiros como MediatR.
   - Validações de entrada com **FluentValidation**.
3. **CBTech.Infrastructure**:
   - Implementa detalhes de tecnologia e acesso externo.
   - Persistência com **Entity Framework Core 10** e **Npgsql**.
   - Integração com PostgreSQL Row-Level Security (RLS) via interceptors de conexão.
   - Armazenamento de arquivos e fotos compatível com **Amazon S3 / MinIO**.
   - Geração de documentos PDF profissionais com QuestPDF.
   - Implementações de hash de senhas (BCrypt / PBKDF2), geração de tokens JWT e serviços externos.
4. **CBTech.Contracts**:
   - DTOs públicos de requisição e resposta para os contratos da API HTTP.
5. **CBTech.Api**:
   - Camada de entrada HTTP / REST.
   - Configuração de DI (Dependency Injection), Middlewares globais (Tratamento de exceções, Resolução de Tenant, Logging estruturado).
   - Documentação com OpenAPI / Swagger.

---

## 3. Estratégia de Multi-tenancy

### 3.1. Modelo Adotado
- **Banco de Dados Compartilhado, Schema Compartilhado (`public`) com Isolamento por `TenantId`**.
- Cada assistência técnica cadastrada é um `Tenant`.
- O isolamento de dados é protegido em três camadas redundantes (**Defense in Depth**):

```
+-------------------------------------------------------------------+
| 1. Camada de Aplicação / Middleware                               |
|    - Extração segura do TenantId a partir do token JWT assinado   |
|    - Nunca confia em headers ou parâmetros informados pelo client |
+---------------------------------+---------------------------------+
                                  |
+---------------------------------v---------------------------------+
| 2. Camada ORM (EF Core)                                           |
|    - Global Query Filters: e => e.TenantId == _tenantContext.Id   |
|    - SaveChangesInterceptor: validação obrigatória antes de gravar|
+---------------------------------+---------------------------------+
                                  |
+---------------------------------v---------------------------------+
| 3. Camada de Banco de Dados (PostgreSQL RLS)                      |
|    - ALTER TABLE ... ENABLE ROW LEVEL SECURITY;                   |
|    - CREATE POLICY tenant_isolation_policy ON ...                 |
|    - Interceptor: SET LOCAL app.current_tenant_id = '...'         |
+-------------------------------------------------------------------+
```

### 3.2. Prevenção de Vazamento no Pool de Conexões
- A diretiva `SET LOCAL app.current_tenant_id` possui escopo estritamente transacional no PostgreSQL.
- Ao término do escopo da transação/requisição, o valor é descartado automaticamente antes que a conexão retorne ao pool do ADO.NET/Npgsql.

---

## 4. CQRS e Padrão Result
Para manter máxima performance e clareza sem MediatR:
- **`ICommand<TResponse>`** e **`ICommandHandler<TCommand, TResponse>`**
- **`IQuery<TResponse>`** e **`IQueryHandler<TQuery, TResponse>`**
- **`Result<T>`**: Objeto padronizado de retorno que expressa sucesso ou falha sem lançar exceções desnecessárias para fluxos de validação esperados.
- Respostas da API seguem o padrão **RFC 7807 (Problem Details)** para erros HTTP.
