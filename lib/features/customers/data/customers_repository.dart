import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'models/customer.dart';

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return CustomersRepository(dio);
});

class CustomersRepository {
  final Dio _dio;

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
      } else if (data is Map && data['itens'] != null) {
        items = data['itens'] as List<dynamic>;
      } else if (data is Map && data['items'] != null) {
        items = data['items'] as List<dynamic>;
      } else if (data is Map && data['data'] != null) {
        items = data['data'] as List<dynamic>;
      } else if (data is Map && data['id'] != null) {
        items = [data];
      }

      return items.map((item) => Customer.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? e.response?.data?['title'] ?? 'Erro ao carregar clientes da API.';
      throw ApiException(message: message.toString(), statusCode: e.response?.statusCode);
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
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? e.response?.data?['title'] ?? 'Erro ao salvar cliente na API. Verifique os dados.';
      throw ApiException(message: message.toString(), statusCode: e.response?.statusCode);
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _dio.delete('${ApiEndpoints.customers}/$id');
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? e.response?.data?['title'] ?? 'Erro ao excluir cliente na API.';
      throw ApiException(message: message.toString(), statusCode: e.response?.statusCode);
    }
  }
}
