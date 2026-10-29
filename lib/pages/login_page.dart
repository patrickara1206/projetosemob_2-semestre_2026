import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/auth_state.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool carregando = false;
  bool ocultarSenha = true;

  String? erro;

  Future<void> entrar() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      await AuthService().login(
        email: emailController.text.trim(),
        senha: senhaController.text,
      );

      authNotifier.value = true;

      if (!mounted) {
        return;
      }

      context.go('/');
    } catch (e) {
      var mensagem = e.toString();

      mensagem = mensagem.replaceFirst(
        'Exception: ',
        '',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        erro = mensagem;
      });
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final isMobile = box.maxWidth < 600;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 20 : 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: isMobile ? 100 : 130,
                            child: Image.asset(
                              'assets/images/brasao_sao_caetano.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          Text(
                            'SEMOB-SCS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 22 : 26,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF173E8C),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Inteligência em Transportes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 14,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: isMobile ? 24 : 32),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            validator: (valor) {
                              if (valor == null || valor.trim().isEmpty) {
                                return 'Informe o e-mail.';
                              }

                              return null;
                            },
                            onFieldSubmitted: (_) {
                              entrar();
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: senhaController,
                            obscureText: ocultarSenha,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                              ),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    ocultarSenha = !ocultarSenha;
                                  });
                                },
                                icon: Icon(
                                  ocultarSenha
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (valor) {
                              if (valor == null || valor.isEmpty) {
                                return 'Informe a senha.';
                              }

                              return null;
                            },
                            onFieldSubmitted: (_) {
                              entrar();
                            },
                          ),
                          if (erro != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 20,
                                    color: Colors.red.shade700,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      erro!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: isMobile ? 20 : 24),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: carregando ? null : entrar,
                              child: carregando
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Entrar'),
                            ),
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          const Text(
                            'Acesso restrito aos usuários autorizados pela SEMOB.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}