class ApiEndpoints {
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Clientes & Aparelhos & Marcas
  static const String customers = '/clientes';
  static const String devices = '/aparelhos';
  static const String brands = '/marcas';

  // Fornecedores, Categorias & Produtos
  static const String suppliers = '/fornecedores';
  static const String categories = '/categorias';
  static const String products = '/produtos';

  // Serviços & Categorias de Serviços
  static const String serviceCategories = '/categorias-servicos';
  static const String services = '/servicos';

  // Orçamentos & Ordens de Serviço
  static const String budgets = '/orcamentos';
  static const String workOrders = '/ordens-servico';

  // Estoque, Movimentações & Compras
  static const String stockMovements = '/movimentacoes-estoque';
  static const String purchaseOrders = '/pedidos-compra';

  // Financeiro
  static const String payments = '/financeiro';
  static const String dashboard = '/dashboard';
}
