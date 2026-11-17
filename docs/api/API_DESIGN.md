# CBTech — Design da API REST

## 1. Convenções e Padrões
- **Base URL**: `/api/v1`
- **Formato**: JSON (camelCase nos campos de payload, snake_case ou kebab-case em query params)
- **Content-Type**: `application/json`
- **Autenticação**: `Bearer <JWT_TOKEN>` no header `Authorization`

---

## 2. Padrão de Respostas

### 2.1. Sucesso
- `200 OK`: Consulta ou operação bem-sucedida com retorno de dados.
- `201 Created`: Criação bem-sucedida de recurso com header `Location`.
- `204 No Content`: Operação executada sem corpo de retorno (ex: delete, alteração de status simples).

### 2.2. Erros e Validações (RFC 7807 Problem Details)
Todas as falhas retornam JSON no padrão `application/problem+json`:
```json
{
  "type": "https://cbtech.com/errors/validation-error",
  "title": "Erro de Validação",
  "status": 400,
  "detail": "Um ou mais campos não atenderam às regras de validação.",
  "errors": {
    "Email": ["O e-mail informado não possui formato válido."],
    "Cnpj": ["CNPJ inválido."]
  }
}
```

---

## 3. Endpoints Essenciais da Fase 1 (Fundação)

### 3.1. Tenants
- `POST /api/v1/tenants`
  - Cria um novo Tenant (empresa) e o usuário Administrador inicial.
  - Retorna `201 Created` com o ID do Tenant e os dados do usuário.

### 3.2. Autenticação e Sessão
- `POST /api/v1/auth/login`
  - Autentica credenciais (e-mail + senha).
  - Se o usuário pertencer a apenas 1 tenant ativo, retorna imediatamente o Access Token (JWT) e o Refresh Token.
  - Se pertencer a múltiplos tenants, retorna a lista de tenants para seleção.
- `POST /api/v1/auth/select-tenant`
  - Recebe credenciais de sessão temporária e o `tenantId` escolhido.
  - Emite o Access Token com a claim `tenant_id` e o Refresh Token associado.
- `POST /api/v1/auth/refresh-token`
  - Renova o Access Token expirado utilizando o Refresh Token válido.
  - Aplica rotação de Refresh Token para prevenção de reutilização indevida.
- `POST /api/v1/auth/logout`
  - Revoga o Refresh Token ativo.
