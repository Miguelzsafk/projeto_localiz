import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class BotaoTeste extends StatefulWidget {
  const BotaoTeste({super.key});

  @override
  State<BotaoTeste> createState() => _BotaoTesteState();
}

class _BotaoTesteState extends State<BotaoTeste> {
 
  final List<Map<String, String>> cafeterias = const [
    {
      "nome": "Una Bistrô & Café",
      "descricao":
          "O lugar ideal para os apaixonados por café artesanal e deliciosas opções de acompanhamentos.",
      "link": "https://maps.app.goo.gl/1PGojL5ZkRKJtqYQ6",
    },
    {
      "nome": "Antonietta Cafeteria",
      "descricao":
          "O ponto de encontro perfeito com cafés incríveis, doces irresistíveis e aquela vibe ideal para relaxar ou atualizar as redes sociais.",
      "link": "https://maps.app.goo.gl/NnB1WkM1hMNsEr4G8",
    },
    {
      "nome": "Café & Cia",
      "descricao":
          "Ambiente super tradicional e acolhedor, que oferece aquele cafezinho com sabor de feito na hora e um atendimento impecável para ir com toda a família.",
      "link": "https://maps.app.goo.gl/gyUF1LSShCwSx3yT7",
    },
    {
      "nome": "Deck café",
      "descricao":
          "Ideal para aquele brunch de fim de semana ou um lanche reforçado no fim da tarde com os amigos. Toque no botão para conferir a rota e o horário de funcionamento!",
      "link": "https://share.google/5gNbBRrTU8ucR8tw9",
    },
  ];

 
  List<Map<String, String>> cafeteriasFiltradas = [];

 
  final TextEditingController _controladorPesquisa = TextEditingController();

  @override
  void initState() {
    super.initState();
   
    cafeteriasFiltradas = cafeterias;
  }

  @override
  void dispose() {
   
    _controladorPesquisa.dispose();
    super.dispose();
  }

 
  void _filtrarCafeterias(String textoDigitado) {
    setState(() {
      if (textoDigitado.isEmpty) {

        cafeteriasFiltradas = cafeterias;
      } else {
   
        cafeteriasFiltradas = cafeterias
            .where(
              (cafeteria) => cafeteria["nome"]!.toLowerCase().contains(
                textoDigitado.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  
  Future<void> _abrirLink(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir o link: $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cafeterias')),
      body: Column(
        children: [
   
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller:
                  _controladorPesquisa, 
              onChanged:
                  _filtrarCafeterias, 
              decoration: const InputDecoration(
                labelText: 'Pesquisar Cafeteria...',
                prefixIcon: Icon(Icons.search), 
                border: OutlineInputBorder(), 
              ),
            ),
          ),

          
          Expanded(
            child: ListView.builder(
              itemCount: cafeteriasFiltradas.length,
              itemBuilder: (context, index) {
                final cafeteria = cafeteriasFiltradas[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.coffee),
                    title: Text(cafeteria["nome"]!),
                    subtitle: Text(cafeteria["descricao"]!),
                    // Apenas o botão azul de abrir o link 
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new, color: Colors.blue),
                      onPressed: () {
                        final link = cafeteria["link"];
                        if (link != null && link.isNotEmpty) {
                          _abrirLink(link);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
