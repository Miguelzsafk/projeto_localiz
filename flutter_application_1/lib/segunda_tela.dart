import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 

class SegundaTela extends StatefulWidget {
  const SegundaTela({super.key});

  @override
  State<SegundaTela> createState() => _SegundaTelaState();
}

class _SegundaTelaState extends State<SegundaTela> {
  
  final List<Map<String, String>> hoteis = const [
    {
      "nome": "Hotel Albinos",
      "descricao":
          "Excelente opção de hospedagem no centro de Itaperuna, oferecendo muito conforto, Wi-Fi gratuito e um ótimo atendimento.",
      "link": "https://maps.app.goo.gl/nTynKJhSEx2pi1ss7",
    },
    {
      "nome": "ibis budget",
              
              
      "descricao":
          "Conforto, sofisticação e localização privilegiada para uma estadia inesquecível.",
      "link": "https://maps.app.goo.gl/BEJFrJMVqtz7vV5N7",
    },
    {
      "nome": "Hotel Caiçara",
      "descricao":
          "Quartos aconchegantes, café da manhã completo e uma localização privilegiada para facilitar a sua estadia na cidade.",
      "link": "https://maps.app.goo.gl/LnvPLxbRtSsE8Ro56",
    },
    {
              
      "nome": " Star Hotel ",
      "descricao":
          "Conforto, praticidade e hospitalidade no coração de Itaperuna. Uma estadia acolhedora com tudo o que você precisa.",
      "link": "https://maps.app.goo.gl/9At63XSSv7LhLw9z6",
    },
  ];

  
  List<Map<String, String>> hoteisFiltrados = [];
 
 
  final TextEditingController _controladorPesquisa = TextEditingController();

  @override
  void initState() {
    super.initState();
   
    hoteisFiltrados = hoteis;
  }

  @override
  void dispose() {
   
    _controladorPesquisa.dispose();
    super.dispose();
  }


 
  void _filtrarHoteis(String textoDigitado) {
              
    setState(() {
      if (textoDigitado.isEmpty) {
        hoteisFiltrados = hoteis;
      } else {
        hoteisFiltrados = hoteis
            .where(
              (hotel) => hotel["nome"]!.toLowerCase().contains(
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
      appBar: AppBar(title: const Text('Hotéis')),
      body: Column(
        children: [
        
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controladorPesquisa, 
              onChanged: _filtrarHoteis, 
              decoration: const InputDecoration(
                labelText: 'Pesquisar Hotéis...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

         
          Expanded(
            child: ListView.builder(
              itemCount: hoteisFiltrados.length,
              itemBuilder: (context, index) {
                final hotel = hoteisFiltrados[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.hotel, color: Colors.brown),
                    title: Text(hotel["nome"]!),
                    subtitle: Text(hotel["descricao"]!),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new, color: Colors.blue),
                      onPressed: () {
                        final link = hotel["link"];
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
