# Guia Completo de Payloads Base & Migrations (Backend API CBTech)

Este documento consolidado contém todos os payloads JSON de requisição (POST/PUT) e scripts SQL de inserção inicial (*Migrations / Seed Data*) para todos os módulos do sistema CBTech.

---

## Sumário
1. [Categorias de Produtos](#1-categorias-de-produtos)
2. [Categorias de Serviços](#2-categorias-de-serviços)
3. [Marcas de Aparelhos](#3-marcas-de-aparelhos)
4. [Perfis de Acesso (Roles) & Permissões](#4-perfis-de-acesso-roles--permissões)
5. [Clientes & Endereços](#5-clientes--endereços)
6. [Fornecedores & Endereços](#6-fornecedores--endereços)
7. [Aparelhos](#7-aparelhos)
8. [Produtos / Peças](#8-produtos--peças)
9. [Serviços](#9-serviços)
10. [Orçamentos](#10-orçamentos)
11. [Ordens de Serviço (OS)](#11-ordens-serviço-os)
12. [Movimentações de Estoque](#12-movimentações-de-estoque)
13. [Pedidos de Compra](#13-pedidos-compra)
14. [Transações Financeiras / Pagamentos](#14-transações-financeiras--pagamentos)

---

## 1. Categorias de Produtos (`/api/v1/categorias`)

### Payload JSON (`POST /api/v1/categorias`)
```json
{
  "nome": "Telas",
  "descricao": "Displays e vidros frontais"
}
```

### Script SQL Migration / Seed
```sql
INSERT INTO Categorias (Id, Nome, Descricao, CriadoEm) VALUES
(gen_random_uuid(), 'Telas', 'Displays e vidros frontais', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Baterias', 'Baterias e células de íon de lítio', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Conectores', 'Sub-placas e flex de carga USB', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Câmeras', 'Câmeras frontal e traseira', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Placas', 'Placas principais e componentes de circuito', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Tampas Traseiras', 'Carcaças e tampas de vidro/metal', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Alto-falantes', 'Campainhas e auriculares', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Acessórios', 'Cabos, carregadores e capas protetoras', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Outros', 'Diversos e insumos de bancada', CURRENT_TIMESTAMP);
```

---

## 2. Categorias de Serviços (`/api/v1/categorias-servicos`)

### Payload JSON (`POST /api/v1/categorias-servicos`)
```json
{
  "nome": "Reparo de Placa",
  "descricao": "Solda microeletrônica e recuperação de curto"
}
```

### Script SQL Migration / Seed
```sql
INSERT INTO CategoriasServicos (Id, Nome, Descricao, CriadoEm) VALUES
(gen_random_uuid(), 'Manutenção Preventiva', 'Limpeza química, troca de pasta térmica e revisão geral', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Reparo de Placa', 'Solda microeletrônica, troca de CI e recuperação de curto', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Troca de Tela', 'Substituição completa do conjunto frontal (Display + Touch)', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Troca de Bateria', 'Substituição e calibração de bateria', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Software / Formatação', 'Remoção de conta Google/Apple, flash de ROM e recuperação de sistema', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Outros', 'Serviços gerais de assistência técnica', CURRENT_TIMESTAMP);
```

---

## 3. Marcas de Aparelhos (`/api/v1/marcas`)

### Payload JSON (`POST /api/v1/marcas`)
```json
{
  "nome": "Apple"
}
```

### Script SQL Migration / Seed
```sql
INSERT INTO Marcas (Id, Nome, CriadoEm) VALUES
(gen_random_uuid(), 'Apple', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Samsung', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Motorola', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Xiaomi', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Redmi', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Poco', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Asus', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Realme', CURRENT_TIMESTAMP),
(gen_random_uuid(), 'Outros Fabricantes', CURRENT_TIMESTAMP);
```

---

## 4. Perfis de Acesso (Roles) & Permissões

### Payload JSON (`POST /api/v1/roles`)
```json
{
  "nome": "Técnico",
  "descricao": "Acesso operacional à bancada e ordens de serviço"
}
```

### Script SQL Migration / Seed
```sql
INSERT INTO Roles (Id, Nome, Descricao) VALUES
(1, 'Administrador', 'Acesso total ao sistema, financeiro e configurações'),
(2, 'Gerente', 'Acesso a relatórios, estoque, compras e gestão'),
(3, 'Técnico', 'Acesso à bancada, ordens de serviço e laudos'),
(4, 'Atendente', 'Acesso a clientes, aparelhos, orçamentos e recepção');
```

---

## 5. Clientes & Endereços (`/api/v1/clientes`)

### Payload JSON (`POST /api/v1/clientes`)
```json
{
  "nome": "Roberto de Oliveira",
  "email": "roberto@email.com",
  "telefone": "11987654321",
  "endereco": {
    "logradouro": "Rua Amaral Gurgel",
    "numero": "123",
    "complemento": "Apto 42",
    "bairro": "Vila Buarque",
    "cidade": "São Paulo",
    "estado": "SP",
    "cep": "01221000"
  }
}
```

---

## 6. Fornecedores & Endereços (`/api/v1/fornecedores`)

### Payload JSON (`POST /api/v1/fornecedores`)
```json
{
  "nomeFantasia": "TotalCell Distribuidora",
  "razaoSocial": "TotalCell Comercio e Distribuicao Ltda",
  "cnpj": "11222333000144",
  "contato": "Marcos Vinicius",
  "telefone": "1132221000",
  "whatsapp": "11981112222",
  "email": "comercial@totalcell.com.br",
  "endereco": {
    "logradouro": "Rua Santa Ifigênia",
    "numero": "400",
    "complemento": "Loja 12",
    "bairro": "Centro",
    "cidade": "São Paulo",
    "estado": "SP",
    "cep": "01207000"
  },
  "prazoEntregaDias": 2,
  "condicaoPagamento": "Boleto 28 dias ou 5% no PIX",
  "ativo": true
}
```

---

## 7. Aparelhos (`/api/v1/aparelhos`)

### Payload JSON (`POST /api/v1/aparelhos`)
```json
{
  "clienteId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "marcaId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "modelo": "iPhone 13 Pro Max",
  "cor": "Azul Alpino",
  "imei1": "356891092384712",
  "imei2": "356891092384713",
  "numeroSerie": "F2LVC0XYZ000",
  "senhaTela": "1234"
}
```

---

## 8. Produtos / Peças (`/api/v1/produtos`)

### Payload JSON (`POST /api/v1/produtos`)
```json
{
  "nome": "Tela Display OLED iPhone 13",
  "sku": "TEL-IP13-OLED",
  "codigoBarras": "7891234567890",
  "categoriaId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "fornecedorId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "precoCusto": 220.00,
  "precoVenda": 450.00,
  "estoqueAtual": 5,
  "estoqueMinimo": 2,
  "unidadeMedida": "UN",
  "ativo": true
}
```

---

## 9. Serviços (`/api/v1/servicos`)

### Payload JSON (`POST /api/v1/servicos`)
```json
{
  "nome": "Troca de Frontal e Display",
  "categoriaServicoId": "GUID",
  "descricao": "Substituição completa do conjunto frontal",
  "precoSugerido": 250.00,
  "tempoEstimadoMinutos": 45,
  "ativo": true
}
```

---

## 10. Orçamentos (`/api/v1/orcamentos`)

### Payload JSON (`POST /api/v1/orcamentos`)
```json
{
  "clienteId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "aparelhoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "descricaoProblema": "Tela trincada e sem toque",
  "laudoTecnico": "Queda acidental, cabo flex danificado",
  "valorPecas": 450.00,
  "valorServicos": 250.00,
  "desconto": 20.00,
  "valorTotal": 680.00,
  "validadeDias": 7,
  "observacoes": "Aprovado via WhatsApp"
}
```

---

## 11. Ordens de Serviço - OS (`/api/v1/ordens-servico`)

### Payload JSON (`POST /api/v1/ordens-servico`)
```json
{
  "clienteId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "aparelhoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "orcamentoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "tecnicoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "problemaRelatado": "Não liga / Tela preta",
  "status": "EM_ANDAMENTO",
  "prioridade": "ALTA",
  "senhaTela": "1234",
  "termoGarantia": "Garantia de 90 dias",
  "pecas": [
    {
      "produtoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "quantidade": 1,
      "valorUnitario": 450.00
    }
  ],
  "servicos": [
    {
      "servicoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "valorUnitario": 250.00
    }
  ]
}
```

---

## 12. Movimentações de Estoque (`/api/v1/movimentacoes-estoque`)

### Payload JSON (`POST /api/v1/movimentacoes-estoque`)
```json
{
  "produtoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "tipo": "ENTRADA",
  "quantidade": 10,
  "custoUnitario": 220.00,
  "motivo": "Reposição de estoque"
}
```

---

## 13. Pedidos de Compra (`/api/v1/pedidos-compra`)

### Payload JSON (`POST /api/v1/pedidos-compra`)
```json
{
  "fornecedorId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "condicaoPagamento": "Boleto 28 dias",
  "observacoes": "Urgente",
  "itens": [
    {
      "produtoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "quantidade": 5,
      "precoUnitario": 220.00
    }
  ]
}
```

---

## 14. Transações Financeiras / Pagamentos (`/api/v1/financeiro`)

### Payload JSON (`POST /api/v1/financeiro`)
```json
{
  "tipo": "RECEITA",
  "descricao": "Pagamento OS #1024 - Roberto de Oliveira",
  "categoria": "Serviços e Peças",
  "valor": 680.00,
  "formaPagamento": "PIX",
  "clienteId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "status": "PAGO"
}
```
