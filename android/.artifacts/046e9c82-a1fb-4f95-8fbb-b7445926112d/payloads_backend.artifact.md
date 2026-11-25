# Payloads Base para os Endpoints Pendentes (Backend)

Documento contendo os payloads JSON base (Requisições POST/PUT) para os módulos restantes da API CBTech.

---

## 1. Modelos de Aparelhos (`/api/v1/modelos-aparelho`)

### Criar Modelo (`POST /api/v1/modelos-aparelho`)
```json
{
  "marcaId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "nome": "iPhone 13",
  "categoria": "Smartphone",
  "ativo": true
}
```

---

## 2. Produtos / Peças (`/api/v1/produtos`)

### Criar Produto (`POST /api/v1/produtos`)
```json
{
  "nome": "Tela Frontal OLED iPhone 13",
  "sku": "TEL-IP13-OLED",
  "codigoBarras": "7891234567890",
  "categoriaId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "fornecedorId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "precoCusto": 350.00,
  "precoVenda": 650.00,
  "estoqueAtual": 12,
  "estoqueMinimo": 3,
  "unidadeMedida": "UN",
  "ativo": true
}
```

---

## 3. Movimentações de Estoque (`/api/v1/movimentacoes-estoque`)

### Registrar Movimentação (`POST /api/v1/movimentacoes-estoque`)
```json
{
  "produtoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "tipo": "ENTRADA",
  "quantidade": 10,
  "custoUnitario": 350.00,
  "motivo": "Compra de lote com fornecedor",
  "ordemServicoId": null
}
```

---

## 4. Pedidos de Compra (`/api/v1/pedidos-compra`)

### Criar Pedido de Compra (`POST /api/v1/pedidos-compra`)
```json
{
  "fornecedorId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "condicaoPagamento": "Boleto 28 dias",
  "observacoes": "Urgente para reparos pendentes",
  "itens": [
    {
      "produtoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "quantidade": 5,
      "precoUnitario": 350.00
    }
  ]
}
```

---

## 5. Serviços (`/api/v1/servicos`)

### Criar Serviço (`POST /api/v1/servicos`)
```json
{
  "nome": "Troca de Frontal e Display",
  "descricao": "Substituição completa do conjunto frontal (OLED + Touch)",
  "precoSugerido": 250.00,
  "tempoEstimadoMinutos": 45,
  "ativo": true
}
```

---

## 6. Orçamentos (`/api/v1/orcamentos`)

### Criar Orçamento (`POST /api/v1/orcamentos`)
```json
{
  "clienteId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "aparelhoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "descricaoProblema": "Tela trincada e sem toque",
  "laudoTecnico": "Queda acidental, cabo flex danificado",
  "valorPecas": 650.00,
  "valorServicos": 250.00,
  "desconto": 50.00,
  "valorTotal": 850.00,
  "validadeDias": 7,
  "observacoes": "Aprovado pelo cliente via WhatsApp"
}
```

---

## 7. Ordens de Serviço - OS (`/api/v1/ordens-servico`)

### Criar Ordem de Serviço (`POST /api/v1/ordens-servico`)
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
  "termoGarantia": "Garantia de 90 dias sobre a peça substituída",
  "pecas": [
    {
      "produtoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "quantidade": 1,
      "valorUnitario": 650.00
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

## 8. Pagamentos e Financeiro (`/api/v1/transacoes-financeiras`)

### Registrar Pagamento (`POST /api/v1/transacoes-financeiras`)
```json
{
  "tipo": "RECEITA",
  "descricao": "Pagamento OS #1024 - Maria Silva",
  "categoria": "Serviços e Peças",
  "valor": 850.00,
  "formaPagamento": "PIX",
  "clienteId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "ordemServicoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "dataVencimento": "2026-11-22T00:00:00Z",
  "dataPagamento": "2026-11-22T03:00:00Z",
  "status": "PAGO"
}
```
