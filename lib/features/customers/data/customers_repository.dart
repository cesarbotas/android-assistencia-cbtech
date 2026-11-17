import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/customer.dart';

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return CustomersRepository(dio);
});

class CustomersRepository {
  final Dio _dio;
  final _uuid = const Uuid();

  // Cache local em memória para desenvolvimento e fallback imediato
  final List<Customer> _localCustomers = [
    Customer(
      id: 'c1111111-1111-1111-1111-111111111111',
      tenantId: '11111111-1111-1111-1111-111111111111',
      name: 'Mariana Souza',
      cpfCnpj: '123.456.789-01',
      phone: '(11) 99876-5432',
      whatsapp: '(11) 99876-5432',
      email: 'mariana.souza@gmail.com',
      street: 'Av. Paulista',
      number: '1000',
      neighborhood: 'Bela Vista',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '01310-100',
      notes: 'Cliente preferencial. Sempre solicita peças originais.',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      devicesCount: 2,
    ),
    Customer(
      id: 'c2222222-2222-2222-2222-222222222222',
      tenantId: '11111111-1111-1111-1111-111111111111',
      name: 'Carlos Eduardo Silva',
      cpfCnpj: '234.567.890-12',
      phone: '(11) 98888-7777',
      whatsapp: '(11) 98888-7777',
      email: 'carlos.edu@outlook.com',
      street: 'Rua Augusta',
      number: '450',
      neighborhood: 'Consolação',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '01304-000',
      notes: 'Solicitou urgência no atendimento da linha Samsung.',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      devicesCount: 1,
    ),
    Customer(
      id: 'c3333333-3333-3333-3333-333333333333',
      tenantId: '11111111-1111-1111-1111-111111111111',
      name: 'Fernanda Lima',
      cpfCnpj: '345.678.901-23',
      phone: '(11) 97777-6666',
      whatsapp: '(11) 97777-6666',
      email: 'fernanda.lima@hotmail.com',
      street: 'Rua Vergueiro',
      number: '2020',
      neighborhood: 'Vila Mariana',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '04101-000',
      notes: 'Possui múltiplos aparelhos corporativos na família.',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      devicesCount: 3,
    ),
    Customer(
      id: 'c4444444-4444-4444-4444-444444444444',
      tenantId: '11111111-1111-1111-1111-111111111111',
      name: 'Rodrigo Menezes',
      cpfCnpj: '456.789.012-34',
      phone: '(11) 96666-5555',
      whatsapp: '(11) 96666-5555',
      email: 'rodrigo.m@gmail.com',
      street: 'Rua Domingos de Morais',
      number: '880',
      neighborhood: 'Vila Mariana',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '04010-000',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      devicesCount: 1,
    ),
  ];

  CustomersRepository(this._dio);

  Future<List<Customer>> getCustomers({String? search, bool? activeOnly}) async {
    try {
      final Map<String, dynamic> params = {};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (activeOnly != null) params['activeOnly'] = activeOnly;

      final response = await _dio.get(
        ApiEndpoints.customers,
        queryParameters: params,
      );
      final list = (response.data as List<dynamic>)
          .map((item) => Customer.fromJson(item as Map<String, dynamic>))
          .toList();
      return list;
    } catch (_) {
      // Fallback local
      return _localCustomers.where((c) {
        if (activeOnly == true && !c.isActive) return false;
        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          final matchesName = c.name.toLowerCase().contains(q);
          final matchesPhone = c.phone.contains(q);
          final matchesCpf = c.cpfCnpj?.contains(q) ?? false;
          return matchesName || matchesPhone || matchesCpf;
        }
        return true;
      }).toList();
    }
  }

  Future<Customer> saveCustomer(Customer customer) async {
    try {
      if (customer.id.isEmpty) {
        final response = await _dio.post(
          ApiEndpoints.customers,
          data: customer.toJson(),
        );
        return Customer.fromJson(response.data as Map<String, dynamic>);
      } else {
        final response = await _dio.put(
          '${ApiEndpoints.customers}/${customer.id}',
          data: customer.toJson(),
        );
        return Customer.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Salva no cache local
      if (customer.id.isEmpty) {
        final newCustomer = customer.copyWith(
          id: _uuid.v4(),
          createdAt: DateTime.now(),
        );
        _localCustomers.insert(0, newCustomer);
        return newCustomer;
      } else {
        final index = _localCustomers.indexWhere((c) => c.id == customer.id);
        if (index != -1) {
          _localCustomers[index] = customer;
        }
        return customer;
      }
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _dio.delete('${ApiEndpoints.customers}/$id');
    } catch (_) {
      _localCustomers.removeWhere((c) => c.id == id);
    }
  }
}
