class ApiEndpoints {
  static const String baseUrl = 'http://localhost:5176/api/v1'; // Emulador Android -> localhost

  // Autenticação & Tenants
  static const String login = '/auth/login';
  static const String selectTenant = '/auth/select-tenant';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String registerTenant = '/tenants';

  // Clientes & Aparelhos
  static const String customers = '/clientes';
  static const String devices = '/devices';
  static const String brands = '/brands';
  static const String models = '/models';

  // Fornecedores, Produtos & Estoque
  static const String suppliers = '/suppliers';
  static const String products = '/products';
  static const String purchases = '/purchases';
  static const String inventory = '/inventory';
  static const String stockMovements = '/stock/movements';
  static const String purchaseOrders = '/purchase-orders';

  // Serviços & Ordens de Serviço
  static const String services = '/services';
  static const String workOrders = '/work-orders';
  static const String budgets = '/budgets';
  static const String payments = '/payments';

  // Dashboard & Relatórios
  static const String dashboard = '/dashboard';
}
