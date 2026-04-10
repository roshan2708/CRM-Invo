import 'package:get/get.dart';
import 'base_provider.dart';
import '../api_constants.dart';

class PaymentProvider extends BaseProvider {
  Future<Response> fetchHistory(String role, Map<String, dynamic> filters) {
    String url = '';
    if (role == 'ADMIN') {
      url = ApiConstants.paymentHistoryAdmin;
    } else if (role == 'MANAGER') {
      url = ApiConstants.paymentHistoryManager;
    } else {
      url = ApiConstants.paymentHistoryTl;
    }

    final queryParams = <String, String>{};
    if (filters['startDate'] != null) queryParams['startDate'] = '${filters['startDate']}T00:00:00';
    if (filters['endDate'] != null) queryParams['endDate'] = '${filters['endDate']}T23:59:59';
    if (filters['tlId'] != null) queryParams['tlId'] = filters['tlId'].toString();
    if (filters['associateId'] != null) queryParams['associateId'] = filters['associateId'].toString();
    if (filters['status'] != null) queryParams['status'] = filters['status'].toString();

    return get(url, query: queryParams);
  }

  Future<Response> updatePaymentStatus(String id, Map<String, dynamic> payload) =>
      put(ApiConstants.updatePaymentStatus(id), {}, query: payload.map((k, v) => MapEntry(k, v.toString())));

  Future<Response> splitPayment(String id, Map<String, dynamic> splitRequest) =>
      post(ApiConstants.splitPayment(id), splitRequest);

  Future<Response> recordManualPayment(Map<String, dynamic> data) =>
      post(ApiConstants.manualPaymentRecord, data);

  Future<Response> generateInvoice(String orderId) =>
      get('/public/payments/invoice', query: {'order_id': orderId});

  Future<Response> fetchInvoiceByLead(String leadId) =>
      get(ApiConstants.invoiceByLead(leadId));
}
