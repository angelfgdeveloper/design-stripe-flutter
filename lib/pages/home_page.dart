import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';

import 'package:strape_app/data/tarjetas.dart';
import 'package:strape_app/helpers/helpers.dart';
import 'package:strape_app/pages/tarjeta_page.dart';
import 'package:strape_app/widgets/total_pay_button.dart';


class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pagar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add), 
            onPressed: () async {
              mostrarLoading(context);
              await Future.delayed(Duration(seconds: 1));
              Navigator.pop(context);

              mostrarAlerta(context, 'Hola', 'Mundo');
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