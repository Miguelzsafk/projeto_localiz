import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'segunda_tela.dart';
import 'botao_teste.dart';
import 'location_details_screen.dart';

class PrimeiraTela extends StatelessWidget {
  const PrimeiraTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Localization Itaperuna"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SegundaTela(),
                  ),
                );
              },
              child: const Text("Hotéis"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BotaoTeste(),
                  ),
                );
              },
              child: const Text("Ver Cafeterias"),
            ),

            const SizedBox(height: 20),

            // Botão para acessar os comentários/detalhes de um local no Firestore
            ElevatedButton.icon(
              icon: const Icon(Icons.comment),
              label: const Text("Avaliações e Comentários"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationDetailsScreen(
                      localId: 'cafeteria_principal', // ID do documento no Firestore
                      localNome: 'Cafeteria & Feedback',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}