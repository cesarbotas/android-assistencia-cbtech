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
      name: 'Mariana Souza',
      phone: '(11) 99876-5432',
      email: 'mariana.souza@gmail.com',
      endereco: Address(logradouro: 'Av. Paulista', numero: '1000', bairro: 'Bela Vista', cidade: 'São Paulo', estado: 'SP', cep: '01310-100'),
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    Customer(
      id: 'c2222222-2222-2222-2222-222222222222',
      name: 'Carlos Eduardo Silva',
      phone: '(11) 98888-7777',
      email: 'carlos.edu@outlook.com',
      endereco: Address(logradouro: 'Rua Augusta', numero: '450', bairro: 'Consolação', cidade: 'São Paulo', estado: 'SP', cep: '01304-000'),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Customer(
      id: 'c3333333-3333-3333-3333-333333333333',
      name: 'Fernanda Lima',
      phone: '(11) 97777-6666',
      email: 'fernanda.lima@hotmail.com',
      endereco: Address(logradouro: 'Rua Vergueiro', numero: '2020', bairro: 'Vila Mariana', cidade: 'São Paulo', estado: 'SP', cep: '04101-000'),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Customer(
      id: 'c4444444-4444-4444-4444-444444444444',
      name: 'Rodrigo Menezes',
      phone: '(11) 96666-5555',
      email: 'rodrigo.m@gmail.com',
      endereco: Address(logradouro: 'Rua Domingos de Morais', numero: '880', bairro: 'Vila Mariana', cidade: 'São Paulo', estado: 'SP', cep: '04010-000'),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  CustomersRepository(this._dio);

  Future<List<Customer>> getCustomers({String? search, int pagina = 1, int tamanho = 10, bool? activeOnly}) async {
    try {
      final Map<String, dynamic> params = {
        'Pagina': pagina,
        'Tamanho': tamanho,
      };
      if (search != null && search.isNotEmpty) params['Search'] = search;

      final response = await _dio.get(
        ApiEndpoints.customers,
        queryParameters: params,
      );

      final data = response.data;
      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['items'] != null) {
        items = data['items'] as List<dynamic>;
      } else if (data is Map && data['data'] != null) {
        items = data['data'] as List<dynamic>;
      }

      return items.map((item) => Customer.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      // Fallback local com paginação em memória
      final filtered = _localCustomers.where((c) {
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

      final startIndex = (pagina - 1) * tamanho;
      if (startIndex >= filtered.length) return [];
      final endIndex = (startIndex + tamanho < filtered.length) ? startIndex + tamanho : filtered.length;
      return filtered.sublist(startIndex, endIndex);
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
