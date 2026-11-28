import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/customer.dart';

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return CustomersRepository(dio);
});

class CustomersRepository {
  final Dio _dio;

  final List<Customer> _localCustomers = [
    Customer(
      id: 'c1',
      name: 'Mariana Souza',
      phone: '(11) 99876-5432',
      email: 'mariana.souza@email.com',
      city: 'São Paulo',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Customer(
      id: 'c2',
      name: 'Carlos Eduardo Silva',
      phone: '(11) 98888-7777',
      email: 'carlos.silva@email.com',
      city: 'São Paulo',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Customer(
      id: 'c3',
      name: 'Fernanda Lima',
      phone: '(11) 97777-6666',
      email: 'fernanda.lima@email.com',
      city: 'São Paulo',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Customer(
      id: 'c4',
      name: 'Rodrigo Menezes',
      phone: '(11) 96666-5555',
      email: 'rodrigo.menezes@email.com',
      city: 'São Paulo',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  CustomersRepository(this._dio);

  Future<List<Customer>> getCustomers({String? search, int pagina = 1, int tamanho = 100, bool? activeOnly}) async {
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
      } else if (data is Map && data['itens'] != null) {
        items = data['itens'] as List<dynamic>;
      } else if (data is Map && data['items'] != null) {
        items = data['items'] as List<dynamic>;
      } else if (data is Map && data['data'] != null) {
        items = data['data'] as List<dynamic>;
      } else if (data is Map && data['id'] != null) {
        items = [data];
      }

      final list = items.map((item) => Customer.fromJson(item as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
      return _localCustomers;
    } catch (_) {
      return _localCustomers.where((c) {
        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          return c.name.toLowerCase().contains(q) || c.phone.contains(q);
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
        if (response.data is Map<String, dynamic> && response.data['id'] != null) {
          return Customer.fromJson(response.data as Map<String, dynamic>);
        }
        return customer;
      } else {
        final response = await _dio.put(
          '${ApiEndpoints.customers}/${customer.id}',
          data: customer.toJson(),
        );
        if (response.data is Map<String, dynamic> && response.data['id'] != null) {
          return Customer.fromJson(response.data as Map<String, dynamic>);
        }
        return customer;
      }
    } catch (_) {
      if (customer.id.isEmpty) {
        final newCust = customer.copyWith(id: 'c-${DateTime.now().millisecondsSinceEpoch}');
        _localCustomers.insert(0, newCust);
        return newCust;
      } else {
        final idx = _localCustomers.indexWhere((c) => c.id == customer.id);
        if (idx != -1) _localCustomers[idx] = customer;
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
