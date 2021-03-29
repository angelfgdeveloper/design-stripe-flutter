import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import 'package:stripe_payment/stripe_payment.dart';

import 'package:strape_app/models/payment_intent_response.dart';
import 'package:strape_app/models/stripe_custom_response.dart';


class StripeService {

  // Singleton
  StripeService._privateContructor();
  static final StripeService _instace = StripeService._privateContructor();
  factory StripeService() => _instace;

  String _paymentApiUrl = 'https://api.stripe.com/v1/payment_intents';
  static String _secretKey = 'sk_test_51IVks4Kl05qZ5yGAtjhs9zOulTKAInGzT2AZAMeR2Hr4LsbebN4XIyMWlD8nIWW469PziYEZKlAVfJQYP137LC79006ZtLwi9q';
  String _apiKey = 'pk_test_51IVks4Kl05qZ5yGAqdLMRHYo99YKg4Eiw3kQflte1puJA2cGLjPzxYmf7vzrpZNr7A6hvybzoLj2f4NsEERin9CY008KRRcwRq';

  final headerOptions = new Options(
    contentType: Headers.formUrlEncodedContentType,
    headers: {
      'Authorization': 'Bearer ${StripeService._secretKey}'
    }
  );

  void init() {

    StripePayment.setOptions(
      StripeOptions(
        publishableKey: this._apiKey,
        androidPayMode: 'test',
        merchantId: 'test'
      )
    );

  }

  Future<StripeCustomResponse> pagarConTarjetaExistente({
    @required String amount,
    @required String currency,
    @required CreditCard card,
  }) async {

    try {

      final paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(
          card: card
        )
      );

      final resp = await this._realizarPago(
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod
      );

      // return StripeCustomResponse(ok: true);
      return resp;
      
    } catch (err) {
      return StripeCustomResponse(
        ok: false,
        msg: err.toString()
      );
    }

  }

  Future<StripeCustomResponse> pagarConNuevaTarjeta({
    @required String amount,
    @required String currency,
  }) async {

    try {

      final paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest()
      );

      final resp = await this._realizarPago(
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod
      );

      // return StripeCustomResponse(ok: true);
      return resp;
      
    } catch (err) {
      return StripeCustomResponse(
        ok: false,
        msg: err.toString()
      );
    }
    
  }

  Future<StripeCustomResponse> pagarApplePayGooglePay({
    @required String amount,
    @required String currency,
  }) async {

    try {

      final newAmount = double.parse(amount) / 100;

      final token = await StripePayment.paymentRequestWithNativePay(
        androidPayOptions: AndroidPayPaymentRequest(
          totalPrice: amount,
          currencyCode: currency
        ), 
        applePayOptions: ApplePayPaymentOptions(
          countryCode: 'US',
          currencyCode: currency,
          items: [
            ApplePayItem(
              label: 'Super producto 1',
              amount: '$newAmount'
            )
          ]
        )
      );
      
      final paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(
          card: CreditCard(
            token: token.tokenId
          )
        )
      );

      final resp = await this._realizarPago(
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod
      );

      await StripePayment.completeNativePayRequest();

      return resp;

    } catch (err) {
      print(err.toString());
      return StripeCustomResponse(
        ok: false,
        msg: err.toString()
      );
    }

  }

  Future<PaymentIntentResponse> _crearPaymentIntent({
    @required String amount,
    @required String currency,
  }) async {

    try {

      final dio = new Dio();
      final data = {
        'amount': amount,
        'currency': currency
      };

      final resp = await dio.post(
        _paymentApiUrl,
        data: data,
        options: headerOptions
      );

      return PaymentIntentResponse.fromJson(resp.data);
      
    } catch (err) {
      print('Error en intento ${ err.toString() }');
      return PaymentIntentResponse(
        status: '400'
      );
    }

  }

  Future<StripeCustomResponse> _realizarPago({
    @required String amount,
    @required String currency,
    @required PaymentMethod paymentMethod
  }) async {

    try {
      // Crear el intent
      final paymentIntent = await this._crearPaymentIntent(
        amount: amount, 
        currency: currency
      );

      final paymentResult = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: paymentIntent.clientSecret,
          paymentMethodId: paymentMethod.id
        )
      );

      if ( paymentResult.status == 'succeeded' ) {
        return StripeCustomResponse(
          ok: true
        );
      } else {
        return StripeCustomResponse(
          ok: false,
          msg: 'Fallo: ${ paymentResult.status }'
        );
      }

    } catch (err) {
      print(err.toString());
      return StripeCustomResponse(
        ok: false,
        msg: err.toString()
      );
    }

  }

}