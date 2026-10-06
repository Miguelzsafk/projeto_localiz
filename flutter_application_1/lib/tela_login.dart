import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'tela_cadastro.dart';
import 'primeira_tela.dart';
import 'prefs_service.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _carregando = false;
  bool _mostrarSenha = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      // GUARDA A SESSÃO LOCALMENTE (Atende ao requisito do SharedPreferences)
      await PrefsService.guardarEmail(_emailController.text.trim());

      if (!mounted) return;

      // Login realizado.
      // Vai para a PrimeiraTela.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PrimeiraTela(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Erro ao fazer login.';

      if (e.code == 'invalid-credential') {
        mensagem = 'E-mail ou senha incorretos.';
      } else if (e.code == 'user-not-found') {
        mensagem = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        mensagem = 'Senha incorreta.';
      } else if (e.code == 'invalid-email') {
        mensagem = 'Digite um e-mail válido.';
      } else if (e.code == 'user-disabled') {
        mensagem = 'Esta conta foi desativada.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TelaCadastro(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 450,
            ),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  const Icon(
                    Icons.account_circle,
                    size: 90,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Entrar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // E-MAIL
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,

                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),

                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Digite seu e-mail.';
                      }

                      if (!valor.contains('@')) {
                        return 'Digite um e-mail válido.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // SENHA
                  TextFormField(
                    controller: _senhaController,
                    obscureText: !_mostrarSenha,

                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),

                      suffixIcon: IconButton(
                        icon: Icon(
                          _mostrarSenha
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),

                        onPressed: () {
                          setState(() {
                            _mostrarSenha = !_mostrarSenha;
                          });
                        },
                      ),
                    ),

                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Digite sua senha.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  // BOTÃO ENTRAR
                  SizedBox(
                    height: 50,

                    child: ElevatedButton(
                      onPressed: _carregando ? null : _entrar,

                      child: _carregando
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(),
                            )
                          : const Text(
                              'ENTRAR',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Ainda não possui uma conta?',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 5),

                  // BOTÃO CADASTRO
                  OutlinedButton(
                    onPressed: _carregando ? null : _abrirCadastro,

                    child: const Text(
                      'CRIAR UMA CONTA',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}