import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:cbtech/features/customers/data/customers_repository.dart';
import 'package:cbtech/features/customers/data/models/customer.dart';
import 'package:cbtech/features/customers/presentation/customers_controller.dart';
import 'package:cbtech/features/devices/data/devices_repository.dart';
import 'package:cbtech/features/devices/data/models/customer_device.dart';
import 'package:cbtech/features/devices/presentation/devices_controller.dart';
import 'package:cbtech/features/suppliers/data/suppliers_repository.dart';
import 'package:cbtech/features/suppliers/presentation/suppliers_controller.dart';
import 'package:cbtech/features/inventory/data/products_repository.dart';
import 'package:cbtech/features/inventory/data/models/product.dart';
import 'package:cbtech/features/inventory/presentation/products_controller.dart';
import 'package:cbtech/features/services/data/services_repository.dart';
import 'package:cbtech/features/services/data/models/service_item.dart';
import 'package:cbtech/features/services/presentation/services_controller.dart';

void main() {
  final dio = Dio();

  group('Fase 2 - Cadastros Base Tests', () {
    test('CustomersController: lista clientes, busca por nome e salva novo cliente', () async {
      final repo = CustomersRepository(dio);
      final controller = CustomersController(repo);

      // Aguarda carregamento inicial
      await controller.loadCustomers();
      expect(controller.state.customers.length, greaterThanOrEqualTo(4));

      // Busca por 'Mariana'
      controller.setSearchQuery('Mariana');
      expect(controller.state.filteredCustomers.length, 1);
      expect(controller.state.filteredCustomers.first.name, 'Mariana Souza');

      // Limpa busca
      controller.setSearchQuery('');
      expect(controller.state.filteredCustomers.length, greaterThanOrEqualTo(4));

      // Cadastra novo cliente
      final newCustomer = Customer(
        id: '',
        tenantId: '11111111-1111-1111-1111-111111111111',
        name: 'Roberto Alencar',
        phone: '(11) 91234-5678',
        email: 'roberto@alencar.com',
        city: 'São Paulo',
        createdAt: DateTime.now(),
      );

      final success = await controller.saveCustomer(newCustomer);
      expect(success, isTrue);
      expect(controller.state.customers.any((c) => c.name == 'Roberto Alencar'), isTrue);
    });

    test('DevicesController: catalogo de marcas, modelos e vinculacao de aparelho ao cliente', () async {
      final repo = DevicesRepository(dio);
      final controller = DevicesController(repo);

      await controller.loadAll();
      expect(controller.state.brands.isNotEmpty, isTrue);

      // Modelos para a marca Apple (b1)
      final appleModels = await controller.getModelsForBrand('b1');
      expect(appleModels.any((m) => m.name == 'iPhone 13'), isTrue);

      // Salva novo aparelho vinculado a cliente
      final newDevice = CustomerDevice(
        id: '',
        tenantId: '11111111-1111-1111-1111-111111111111',
        customerId: 'c1111111-1111-1111-1111-111111111111',
        customerName: 'Mariana Souza',
        brandName: 'Apple',
        modelName: 'iPhone 14 Pro Max',
        color: 'Roxo Profundo',
        storage: '256 GB',
        createdAt: DateTime.now(),
      );

      final success = await controller.saveDevice(newDevice);
      expect(success, isTrue);
      expect(controller.state.devices.any((d) => d.modelName == 'iPhone 14 Pro Max'), isTrue);
    });

    test('SuppliersController: listagem e busca de fornecedores', () async {
      final repo = SuppliersRepository(dio);
      final controller = SuppliersController(repo);

      await controller.loadSuppliers();
      expect(controller.state.suppliers.length, greaterThanOrEqualTo(3));

      controller.setSearchQuery('TotalCell');
      expect(controller.state.filteredSuppliers.length, 1);
      expect(controller.state.filteredSuppliers.first.tradeName, 'TotalCell Distribuidora');
    });

    test('ProductsController: filtragem por categoria e alerta de estoque baixo', () async {
      final repo = ProductsRepository(dio);
      final controller = ProductsController(repo);

      await controller.loadProducts();
      expect(controller.state.products.isNotEmpty, isTrue);

      // Filtra por 'Baterias'
      controller.setCategory('Baterias');
      expect(controller.state.filteredProducts.every((p) => p.category == 'Baterias'), isTrue);

      // Filtra apenas estoque baixo
      controller.setCategory('Todas');
      controller.toggleLowStockOnly();
      expect(controller.state.filteredProducts.every((p) => p.isLowStock), isTrue);

      // Cadastra nova peca
      final newProduct = Product(
        id: '',
        tenantId: '11111111-1111-1111-1111-111111111111',
        sku: 'TEL-S23-DYNAMIC',
        name: 'Tela AMOLED Galaxy S23',
        category: 'Telas',
        compatibleModels: 'Samsung Galaxy S23',
        salePrice: 580.00,
        costPrice: 290.00,
        currentStock: 3,
        minStock: 2,
        createdAt: DateTime.now(),
      );

      final success = await controller.saveProduct(newProduct);
      expect(success, isTrue);
    });

    test('ServicesController: catalogo de servicos e precificacao de mao de obra', () async {
      final repo = ServicesRepository(dio);
      final controller = ServicesController(repo);

      await controller.loadServices();
      expect(controller.state.services.length, greaterThanOrEqualTo(5));

      final newService = ServiceItem(
        id: '',
        tenantId: '11111111-1111-1111-1111-111111111111',
        name: 'Troca de Lente de Câmera Traseira',
        category: 'Troca de Peça',
        defaultPrice: 80.00,
        estimatedTimeMinutes: 30,
        createdAt: DateTime.now(),
      );

      final success = await controller.saveService(newService);
      expect(success, isTrue);
      expect(controller.state.services.any((s) => s.name.contains('Lente de Câmera')), isTrue);
    });
  });
}
