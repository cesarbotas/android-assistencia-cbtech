# CBTech — Design da API REST

## 1. Convenções e Padrões
- **Base URL**: `/api/v1`
- **Formato**: JSON (camelCase nos campos de payload, snake_case ou kebab-case em query params)
- **Content-Type**: `application/json`
- **Autenticação**: `Bearer <JWT_TOKEN>` no header `Authorization`
- **Isolamento**: Multi-tenant via claim `tenant_id` no JWT validado no middleware

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
    "CpfCnpj": ["Documento inválido."]
  }
}
```

---

## 3. Autenticação e Multi-Tenancy

### 3.1. Tenants
- `POST /api/v1/tenants`
  - Cria um novo Tenant (assistência técnica) e usuário Admin inicial.
  - Retorna `201 Created` com o ID do Tenant e tokens.

### 3.2. Autenticação e Sessão
- `POST /api/v1/auth/login`
  - Autentica credenciais (e-mail + senha).
  - Se pertencer a apenas 1 tenant: retorna JWT e Refresh Token.
  - Se pertencer a múltiplos tenants: retorna lista de tenants para escolha.
- `POST /api/v1/auth/select-tenant`
  - Recebe token de pré-autenticação e `tenantId` selecionado.
  - Emite Access Token contendo a claim `tenant_id`.
- `POST /api/v1/auth/refresh-token`
  - Renova Access Token utilizando Refresh Token válido (com rotação de tokens).
- `POST /api/v1/auth/logout`
  - Revoga o Refresh Token ativo.

---

## 4. Cadastros Base

### 4.1. Clientes (`/api/v1/customers`)
- `GET /api/v1/customers?search={query}&page={page}&pageSize={size}`
  - Retorna lista paginada e filtrada de clientes do tenant.
- `GET /api/v1/customers/{id}`
  - Retorna dados detalhados do cliente e histórico de ordens associadas.
- `POST /api/v1/customers`
  - Cadastra novo cliente (Nome, Telefone, WhatsApp, E-mail, CPF/CNPJ, Endereço, Observações).
- `PUT /api/v1/customers/{id}`
  - Atualiza cadastro do cliente.
- `DELETE /api/v1/customers/{id}`
  - Exclusão lógica ou bloqueio de cliente (se possuir histórico de OS).

### 4.2. Aparelhos e Catálogo (`/api/v1/devices` & `/api/v1/brands`)
- `GET /api/v1/brands`
  - Lista marcas cadastradas (Apple, Samsung, Motorola, Xiaomi, etc.).
- `GET /api/v1/devices?customerId={id}&search={query}`
  - Lista aparelhos vinculados a clientes (Marca, Modelo, Cor, IMEI 1/2, Serial, Senha de Tela).
- `POST /api/v1/devices`
  - Cadastra aparelho vinculado a um cliente.
- `PUT /api/v1/devices/{id}`
  - Atualiza dados do aparelho.

### 4.3. Fornecedores (`/api/v1/suppliers`)
- `GET /api/v1/suppliers?search={query}`
  - Lista fornecedores de peças e insumos.
- `POST /api/v1/suppliers`
  - Cadastra novo fornecedor (Nome Fantasia, Razão Social, CNPJ, Telefone, Contato, E-mail, Endereço).
- `PUT /api/v1/suppliers/{id}`
  - Atualiza dados do fornecedor.

### 4.4. Produtos e Estoque de Peças (`/api/v1/products`)
- `GET /api/v1/products?search={query}&lowStockOnly={bool}`
  - Lista produtos/peças com filtro para alerta de estoque mínimo.
- `GET /api/v1/products/{id}`
  - Detalhes do produto com histórico recente de movimentação.
- `POST /api/v1/products`
  - Cadastra nova peça/produto (SKU, Nome, Categoria, Estoque Atual, Mínimo, Preço Custo, Preço Venda, Fornecedor).
- `PUT /api/v1/products/{id}`
  - Atualiza cadastro do produto.

### 4.5. Serviços de Mão de Obra (`/api/v1/services`)
- `GET /api/v1/services?category={cat}`
  - Lista tabela de serviços técnicos (Troca de Tela, Troca de Bateria, Desoxidação, etc.).
- `POST /api/v1/services`
  - Cadastra novo serviço (Nome, Categoria, Preço Padrão, Tempo Estimado em minutos).
- `PUT /api/v1/services/{id}`
  - Atualiza dados do serviço.

---

## 5. Ordens de Serviço & Operação Técnica

### 5.1. Gestão de Ordens de Serviço (`/api/v1/work-orders`)
- `GET /api/v1/work-orders?status={status}&search={query}&dateFrom={d}&dateTo={d}`
  - Lista ordens de serviço com filtros por status, pesquisa por texto (número, cliente, aparelho, defeito).
- `GET /api/v1/work-orders/{id}`
  - Retorna visão completa da OS: cliente, aparelho, laudo técnico, orçamento vigente, revisões, linha do tempo e fotos.
- `POST /api/v1/work-orders`
  - Abertura de nova OS (atribui número sequencial atômico ex: `OS-0105`, grava estado de entrada, defeito e anexa fotos).
- `PUT /api/v1/work-orders/{id}/diagnosis`
  - Atualiza laudo de bancada e diagnóstico técnico.

### 5.2. Workflow e Transição de Status
- `PUT /api/v1/work-orders/{id}/status`
  - Payload:
    ```json
    {
      "newStatus": "emReparo",
      "note": "Iniciada a substituição da tela frontal na bancada 2"
    }
    ```
  - Valida se a transição de status é permitida pelo fluxo oficial:
    `aberta` ➔ `diagnostico` ➔ `orcamentoPendente` ➔ `aprovada` ➔ `emReparo` ➔ `testes` ➔ `concluida` ➔ `entregue` (ou `cancelada`).
  - Cria automaticamente registro imutável no histórico da OS.

### 5.3. Orçamentos & Revisões
- `POST /api/v1/work-orders/{id}/budgets`
  - Cria uma nova revisão de orçamento com snapshot de peças (custo e venda) e serviços.
- `POST /api/v1/work-orders/{id}/budgets/approve`
  - Payload: `{"approvedBy": "Cliente via WhatsApp", "notes": "Aprovado sem desconto"}`
  - Atualiza status do orçamento para `aprovado` e avança o status da OS para `aprovada`.
- `POST /api/v1/work-orders/{id}/budgets/reject`
  - Payload: `{"reason": "Cliente achou o valor acima do esperado"}`
  - Atualiza status do orçamento para `recusado` e status da OS para `cancelada`.

### 5.4. Linha do Tempo e Histórico
- `GET /api/v1/work-orders/{id}/history`
  - Retorna trilha de auditoria cronológica com data/hora, usuário executor, status de/para e anotações técnicas.

### 5.5. Fotos e Anexos
- `POST /api/v1/work-orders/{id}/attachments` (Multipart/form-data)
  - Upload de foto do aparelho (recebimento, placa em bancada, finalização).
  - Retorna URL assinada S3/MinIO e vincula à OS.

---

## 6. Estoque Avançado & Movimentações (Fase 4)

### 6.1. Movimentações de Estoque (`/api/v1/stock/movements`)
- `GET /api/v1/stock/movements?productId={id}&type={entrada|saida}&dateFrom={d}`
  - Histórico de movimentações de estoque (Kardex).
- `POST /api/v1/stock/movements`
  - Registro de movimentação avulsa:
    - Entrada (compra avulsa, ajuste de inventário)
    - Saída (perda técnica, quebra em bancada, garantia interna)
    - Saída vinculada à OS (baixa automática na aprovação/execução)

### 6.2. Pedidos de Compra & Fornecedores (`/api/v1/purchase-orders`)
- `GET /api/v1/purchase-orders?status={status}`
  - Lista pedidos de compras junto a fornecedores.
- `POST /api/v1/purchase-orders`
  - Emissão de pedido de compra de peças em falta.
- `PUT /api/v1/purchase-orders/{id}/receive`
  - Recebimento de mercadoria com entrada automática no estoque e atualização do custo médio ponderado.

---

## 7. Módulo Financeiro & Caixa (Fase 5)

### 7.1. Lançamentos Financeiros (`/api/v1/finances/transactions`)
- `GET /api/v1/finances/transactions?type={receita|despesa}&dateFrom={d}&dateTo={d}`
  - Extrato financeiro detalhado por período.
- `POST /api/v1/finances/transactions`
  - Lançamento financeiro avulso (despesas operacionais, aluguel, insumos).
- `POST /api/v1/work-orders/{id}/payment`
  - Baixa de pagamento no encerramento da OS (Dinheiro, PIX, Cartão Débito/Crédito) com emissão de recibo.
