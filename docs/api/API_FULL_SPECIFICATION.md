# Especificação Completa da API REST — CBTech SaaS

Este documento especifica os endpoints, contratos de payload (JSON), códigos de status HTTP e regras de negócio da API REST do **CBTech SaaS** (.NET 10 / Modular Monolith / Clean Architecture / PostgreSQL RLS).

---

## 1. Visão Geral e Convenções
- **Base URL**: `/api/v1`
- **Formato**: JSON (`camelCase` no payload).
- **Autenticação**: `Bearer <JWT_TOKEN>` contendo a claim `tenant_id`.
- **Tratamento de Erros**: RFC 7807 (Problem Details) (`application/problem+json`).

---

## 2. Módulo de Autenticação & Multi-Tenancy (`/api/v1/auth`)

### 2.1. Login
- **POST `/api/v1/auth/login`**
- **Request Body**:
  ```json
  {
    "email": "admin@cbtech.com",
    "password": "SecretPassword123"
  }
  ```
- **Response 200 OK (Single Tenant)**:
  ```json
  {
    "accessToken": "eyJhbGci...",
    "refreshToken": "dG9rZW4...",
    "userId": "usr-001",
    "userName": "César Botas",
    "userEmail": "admin@cbtech.com",
    "activeTenantId": "11111111-1111-1111-1111-111111111111",
    "activeTenantName": "CB Tech Matriz",
    "userRole": "Administrador",
    "isSubscriptionActive": true
  }
  ```
- **Response 200 OK (Multi-Tenant / Requires Selection)**:
  ```json
  {
    "requiresTenantSelection": true,
    "userId": "usr-001",
    "userName": "César Botas",
    "userEmail": "admin@cbtech.com",
    "availableTenants": [
      {
        "id": "11111111-1111-1111-1111-111111111111",
        "nome": "CB Tech Matriz",
        "cnpj": "45.890.123/0001-99",
        "perfil": "Administrador",
        "isSubscriptionActive": true
      }
    ]
  }
  ```

### 2.2. Seleção de Tenant
- **POST `/api/v1/auth/select-tenant`**
- **Request Body**:
  ```json
  {
    "tenantId": "11111111-1111-1111-1111-111111111111"
  }
  ```
- **Response 200 OK**: Retorna o token definitivo com a claim `tenant_id` injetada.

---

## 3. Módulo de Clientes (`/api/v1/customers`)

- **GET `/api/v1/customers?search=query&page=1&pageSize=20`**
- **POST `/api/v1/customers`**
  ```json
  {
    "name": "Rodrigo Mendes",
    "phone": "(11) 99999-1234",
    "whatsapp": "(11) 99999-1234",
    "email": "rodrigo@email.com",
    "cpfCnpj": "123.456.789-00",
    "address": "Rua das Flores, 100 - São Paulo/SP",
    "notes": "Cliente preferencial"
  }
  ```
- **PUT `/api/v1/customers/{id}`**
- **DELETE `/api/v1/customers/{id}`**

---

## 4. Módulo de Aparelhos (`/api/v1/devices` & `/api/v1/brands`)

- **GET `/api/v1/brands`**
- **GET `/api/v1/devices?customerId={id}`**
- **POST `/api/v1/devices`**
  ```json
  {
    "customerId": "cust-001",
    "brand": "Apple",
    "model": "iPhone 11",
    "color": "Preto",
    "imei1": "354123098765432",
    "imei2": "354123098765433",
    "serialNumber": "F2LVC123HD",
    "screenPassword": "1234"
  }
  ```

---

## 5. Módulo de Estoque & Peças (`/api/v1/products`)

- **GET `/api/v1/products?search={query}&lowStockOnly=false`**
- **POST `/api/v1/products`**
  ```json
  {
    "sku": "TELA-IP11-INC",
    "name": "Tela Incell iPhone 11",
    "category": "Telas",
    "currentStock": 5,
    "minimumStock": 2,
    "costPrice": 120.00,
    "salePrice": 250.00,
    "supplierId": "supp-001"
  }
  ```
- **POST `/api/v1/stock/movements`** (Entrada/Saída/Kardex)
- **POST `/api/v1/purchase-orders`** (Pedidos de Compra)

---

## 6. Módulo de Ordens de Serviço (`/api/v1/work-orders`)

- **GET `/api/v1/work-orders?status={status}&search={query}`**
- **POST `/api/v1/work-orders`** (Abertura em 7 passos)
- **PATCH `/api/v1/work-orders/{id}/status`**
- **POST `/api/v1/work-orders/{id}/budgets`**
- **POST `/api/v1/work-orders/{id}/approve`**
- **POST `/api/v1/work-orders/{id}/diagnose`**

---

## 7. Módulo Financeiro & Caixa (`/api/v1/finances`)

- **GET `/api/v1/finances/transactions?startDate={date}&endDate={date}`**
- **POST `/api/v1/finances/transactions`** (Lançamento manual de receita/despesa)
- **POST `/api/v1/work-orders/{id}/pay`** (Quitação de OS, baixa no caixa e emissão de recibo)
