# CBTech — Modelo de Dados e Políticas de Banco

## 1. Convenções de Banco de Dados
- **SGBD**: PostgreSQL 16+
- **Nomenclatura**: `snake_case` para tabelas e colunas.
- **Tipos de Chave Primária**: `uuid` (v4/v7) gerado pelo sistema para desacoplamento e segurança contra enumeração.
- **Auditoria Padrão**: Todas as tabelas transacionais incluem:
  - `criado_em` (`timestamptz` default `now()`)
  - `atualizado_em` (`timestamptz` nulo ou default `now()`)
  - `tenant_id` (`uuid` com Foreign Key para `tenants(id)`)

---

## 2. Tabelas por Grupo de Domínio

### 2.1. Tenant e Usuários
```sql
CREATE TABLE tenants (
    id UUID PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cnpj VARCHAR(18) NULL,
    slug VARCHAR(60) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'Ativo', -- Ativo, Suspenso, Inativo
    data_cadastro TIMESTAMPTZ NOT NULL DEFAULT now(),
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em TIMESTAMPTZ NULL
);

CREATE TABLE usuarios (
    id UUID PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(180) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    telefone VARCHAR(20) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Ativo',
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em TIMESTAMPTZ NULL
);

CREATE TABLE tenant_usuarios (
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    perfil VARCHAR(30) NOT NULL, -- Administrador, Atendente, Tecnico, Financeiro
    status VARCHAR(20) NOT NULL DEFAULT 'Ativo',
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (tenant_id, usuario_id)
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expira_em TIMESTAMPTZ NOT NULL,
    revogado_em TIMESTAMPTZ NULL,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 2.2. Numeração Sequencial Atômica por Tenant
Para evitar `MAX(Numero) + 1` e race conditions:
```sql
CREATE TABLE tenant_sequences (
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    tipo VARCHAR(30) NOT NULL, -- 'ORDEM_SERVICO', 'ORCAMENTO'
    ultimo_numero BIGINT NOT NULL DEFAULT 0,
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (tenant_id, tipo)
);
```

---

## 3. Row-Level Security (RLS) no PostgreSQL

Para todas as tabelas com `tenant_id`:
```sql
-- Habilita RLS na tabela
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- Política de isolamento por TenantId configurado na sessão
CREATE POLICY ordens_servico_tenant_isolation ON ordens_servico
    AS RESTRICTIVE
    USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID)
    WITH CHECK (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID);
```

O comando de ativação da sessão na conexão:
```sql
SET LOCAL app.current_tenant_id = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
```
Ao usar `SET LOCAL`, o parâmetro de sessão expira automaticamente ao término da transação, protegendo contra vazamento no pool de conexões.
