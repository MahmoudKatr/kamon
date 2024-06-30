class ApiContest {
  static const String baseUrl = 'https://accept.paymob.com/api';
  static const String getAuthToken = '/auth/tokens';
  static const String paymentApiKey =
      'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2T1RneU56WXpMQ0p1WVcxbElqb2lhVzVwZEdsaGJDSjkuTUhUQ29JUFowQkFjWm5qWlh1VXZLNVZJNXNoM2tHdXk4aXhRMTJYOEtRbmwyeGFjLXVXU20tNWhEUnhYVnlScUtPUW9Ta1FSSzRHRlhyU2FDN0g2c3c=';
  static const String getOrderId = '/ecommerce/orders';
  static String paymentFirstToken = '';
  static String paymentOrderId = '';
  static String cardPaymentMethodIntegrationId = '4600739';
}
