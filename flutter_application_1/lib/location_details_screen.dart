import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationDetailsScreen extends StatefulWidget {
  final String localId;
  final String localNome;

  const LocationDetailsScreen({
    super.key,
    required this.localId,
    required this.localNome,
  });

  @override
  State<LocationDetailsScreen> createState() => _LocationDetailsScreenState();
}

class _LocationDetailsScreenState extends State<LocationDetailsScreen> {
  final _commentController = TextEditingController();
  final _replyController = TextEditingController();
  String _tipoFeedback = 'Bom';
  String? _filtroFeedback; // Filtro de Consulta no Firestore

  void _adicionarComentario() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final subcolecao = FirebaseFirestore.instance
        .collection('locais')
        .doc(widget.localId)
        .collection('comentarios');

    await subcolecao.add({
      'autor': user?.email ?? 'Anônimo',
      'texto': _commentController.text.trim(),
      'tipo': _tipoFeedback,
      'data': FieldValue.serverTimestamp(),
      'respostas': [],
    });

    _commentController.clear();
  }

  void _adicionarResposta(String comentarioId, List respostasAtuais) async {
    if (_replyController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final docRef = FirebaseFirestore.instance
        .collection('locais')
        .doc(widget.localId)
        .collection('comentarios')
        .doc(comentarioId);

    List novasRespostas = List.from(respostasAtuais);
    novasRespostas.add({
      'autor': user?.email ?? 'Anônimo',
      'texto': _replyController.text.trim(),
    });

    await docRef.update({'respostas': novasRespostas});
    _replyController.clear();
    if (mounted) Navigator.pop(context);
  }

  void _abrirModalResposta(String comentarioId, List respostasAtuais) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Responder Comentário'),
        content: TextField(
          controller: _replyController,
          decoration: const InputDecoration(labelText: 'Sua resposta'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _adicionarResposta(comentarioId, respostasAtuais),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consulta com filtro (Requisito c)
    Query query = FirebaseFirestore.instance
        .collection('locais')
        .doc(widget.localId)
        .collection('comentarios');

    if (_filtroFeedback != null) {
      query = query.where('tipo', isEqualTo: _filtroFeedback);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.localNome),
      ),
      body: Column(
        children: [
          // Filtros de Consulta (Consulta 1 e Consulta 2 na mesma tela)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Filtrar: '),
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _filtroFeedback == null,
                  onSelected: (_) => setState(() => _filtroFeedback = null),
                ),
                const SizedBox(width: 5),
                ChoiceChip(
                  label: const Text('Bons'),
                  selected: _filtroFeedback == 'Bom',
                  onSelected: (_) => setState(() => _filtroFeedback = 'Bom'),
                ),
                const SizedBox(width: 5),
                ChoiceChip(
                  label: const Text('Ruins'),
                  selected: _filtroFeedback == 'Ruim',
                  onSelected: (_) => setState(() => _filtroFeedback = 'Ruim'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Erro.'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String comId = docs[index].id;
                    List respostas = data['respostas'] ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['autor']} (${data['tipo']})',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(data['texto'] ?? ''),
                            const SizedBox(height: 5),
                            TextButton.icon(
                              icon: const Icon(Icons.reply, size: 16),
                              label: const Text('Responder'),
                              onPressed: () => _abrirModalResposta(comId, respostas),
                            ),
                            if (respostas.isNotEmpty) ...[
                              const Divider(),
                              const Text(
                                'Respostas:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              ...respostas.map((r) => Padding(
                                    padding: const EdgeInsets.only(left: 15, top: 4),
                                    child: Text(
                                      '${r['autor']}: ${r['texto']}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  )),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Formulário para enviar novos comentários
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Deixe seu comentário...',
                        ),
                      ),
                    ),
                    DropdownButton<String>(
                      value: _tipoFeedback,
                      items: ['Bom', 'Ruim'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _tipoFeedback = val);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _adicionarComentario,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}