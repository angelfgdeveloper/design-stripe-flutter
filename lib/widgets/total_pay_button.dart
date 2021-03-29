import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stripe_payment/stripe_payment.dart';

import 'package:strape_app/bloc/pagar/pagar_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:strape_app/helpers/helpers.dart';
import 'package:strape_app/services/stripe_service.dart';


class TotalPayButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final pagarBloc = BlocProvider.of<PagarBloc>(context).state;

    return Container(
      width: width,
      height: 100.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0)
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Total', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              Text('${ pagarBloc.montoPagar } ${ pagarBloc.moneda }', style: TextStyle(fontSize: 20.0)),
            ],
          ),

          BlocBuilder<PagarBloc, PagarState>(
            builder: (context, state) {
              return _BtnPay(state);
            },
          ),

        ],
      ),
    );
  }
}


class _BtnPay extends StatelessWidget {

  final PagarState state;
  const _BtnPay(this.state);

  @override
  Widget build(BuildContext context) {
    return state.tarjetaActiva 
    ? buildButtonTarjeta(context)
    : buildAppleAndGooglePay(context);
  }

  Widget buildButtonTarjeta(BuildContext context) {
    return MaterialButton(
      height: 45.0,
      minWidth: 170.0,
      shape: StadiumBorder(),
      elevation: 0,
      color: Colors.black,
      child: Row(
        children: [
          Icon(FontAwesomeIcons.solidCreditCard, color: Colors.white),
          SizedBox(width: 10.0),
          Text('Pagar', style: TextStyle(color: Colors.white, fontSize: 22.0)),
        ],
      ),
      onPressed: () async {

        mostrarLoading(context);
        final stripeService = new StripeService();
        final state = BlocProvider.of<PagarBloc>(context).state;
        // print(tarjeta.cardNumber);
        final tarjeta = state.tarjeta;
        final mesAnio = tarjeta.expiracyDate.split('/');

        final resp = await stripeService.pagarConTarjetaExistente(
          amount: state.montoPagarString, 
          currency: state.moneda,
          card: CreditCard(
            number: tarjeta.cardNumber,
            expMonth: int.parse(mesAnio[0]),
            expYear: int.parse(mesAnio[1]) 
          )
        );

        Navigator.pop(context);

        if ( resp.ok ) {
          mostrarAlerta(context, 'Tarjeta Ok', 'Todo correcto');
        } else {
          mostrarAlerta(context, 'Algo salió mal', resp.msg);
        }

      }
    );
  }

  Widget buildAppleAndGooglePay(BuildContext context) {
    return MaterialButton(
      height: 45.0,
      minWidth: 150.0,
      shape: StadiumBorder(),
      elevation: 0,
      color: Colors.black,
      child: Row(
        children: [
          Icon(
            Platform.isAndroid
             ? FontAwesomeIcons.google
             : FontAwesomeIcons.apple,
             color: Colors.white
          ),
          Text(' Pay', style: TextStyle(color: Colors.white, fontSize: 22.0)),
        ],
      ),
      onPressed: () async {

        final stripeService = new StripeService();
        final state = BlocProvider.of<PagarBloc>(context).state;

        await stripeService.pagarApplePayGooglePay(
          amount: state.montoPagarString, 
          currency: state.moneda
        );

      }
    );
  }
}