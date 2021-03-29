import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:strape_app/bloc/pagar/pagar_bloc.dart';
import 'package:strape_app/data/tarjetas.dart';
import 'package:strape_app/helpers/helpers.dart';
import 'package:strape_app/pages/tarjeta_page.dart';
import 'package:strape_app/widgets/total_pay_button.dart';

import 'package:strape_app/services/stripe_service.dart';


class HomePage extends StatelessWidget {

  final stripeService = new StripeService();

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    // ignore: close_sinks
    final pagarBloc = BlocProvider.of<PagarBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pagar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add), 
            onPressed: () async {
              // mostrarLoading(context);
              // await Future.delayed(Duration(seconds: 1));
              // Navigator.pop(context);

              // mostrarAlerta(context, 'Hola', 'Mundo');

              mostrarLoading(context);

              final amount = pagarBloc.state.montoPagarString;
              final currency = pagarBloc.state.moneda;

              final resp = await this.stripeService.pagarConNuevaTarjeta(
                amount: amount, 
                currency: currency
              );

              Navigator.pop(context);

              if ( resp.ok ) {
                mostrarAlerta(context, 'Tarjeta Ok', 'Todo correcto');
              } else {
                mostrarAlerta(context, 'Algo salió mal', resp.msg);
              }

            }
          )
        ],
      ),
      body: Stack(
        children: [

          Positioned(
            width: size.width,
            height: size.height,
            top: 200.0,
            child: PageView.builder(
              controller: PageController(
                viewportFraction: 0.9
              ),
              physics: BouncingScrollPhysics(),
              itemCount: tarjetas.length,
              itemBuilder: (_, i) {
                final tarjeta = tarjetas[i];
                return GestureDetector(
                  onTap: () {
                    pagarBloc.add( OnSeleccionarTarjeta(tarjeta) );
                    Navigator.push(context, navegarFadeIn(context, TarjetaPage()));
                  },
                  child: Hero(
                    tag: tarjeta.cardNumber,
                    child: CreditCardWidget(
                      cardNumber: tarjeta.cardNumberHidden, 
                      expiryDate: tarjeta.expiracyDate,
                      cardHolderName: tarjeta.cardHolderName,
                      cvvCode: tarjeta.cvv, 
                      showBackView: false // Tajerta gire
                    ),
                  ),
                );
              }
            ),
          ),

          Positioned(
            bottom: 0,
            child: TotalPayButton()
          )

        ],
      )
   );
  }
}