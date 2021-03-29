import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import 'package:strape_app/bloc/pagar/pagar_bloc.dart';
import 'package:strape_app/widgets/total_pay_button.dart';


class TarjetaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // final tarjeta = TarjetaCredito(
    //   cardNumberHidden: '4242',
    //   cardNumber: '4242424242424242',
    //   brand: 'visa',
    //   cvv: '213',
    //   expiracyDate: '01/25',
    //   cardHolderName: 'Luis Flores'
    // );

    final tarjeta = BlocProvider.of<PagarBloc>(context).state.tarjeta;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pagar'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), 
          onPressed: () {
            BlocProvider.of<PagarBloc>(context).add( OnDesactivarTarjeta() );
            Navigator.pop(context);
          }
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [

          Container(),

          Hero(
            tag: tarjeta.cardNumber,
            child: CreditCardWidget(
              cardNumber: tarjeta.cardNumberHidden, 
              expiryDate: tarjeta.expiracyDate,
              cardHolderName: tarjeta.cardHolderName,
              cvvCode: tarjeta.cvv, 
              showBackView: false // Tajerta gire
            ),
          ),

          Positioned(
            bottom: 0,
            child: TotalPayButton()
          )
          
        ],
      ),
   );
  }
}