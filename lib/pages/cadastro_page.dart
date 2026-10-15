import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final matriculaController = TextEditingController();
  final emailController = TextEditingController();
  final cargoController = TextEditingController();
  final justificativaController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  String? lotacao;
  bool aceitouTermo = false;

  bool carregando = false;
  String? erro;
  String? sucesso;

  static const unidades = [
    'Diretoria de Transportes',
    'Departamento de Tráfego',
    'Fiscalização Operacional',
    'Planejamento e Mobilidade',
    'DTI / Tecnologia da Informação',
  ];

  Future<void> solicitarCadastro() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!aceitouTermo) {
      setState(() {
        erro = 'É necessário aceitar o Termo de Sigilo Funcional.';
        sucesso = null;
      });
      return;
    }

    setState(() {
      carregando = true;
      erro = null;
      sucesso = null;
    });

    // TODO: ligar ao endpoint do backend (POST /auth/solicitar-cadastro)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    nomeController.clear();
    matriculaController.clear();
    emailController.clear();
    cargoController.clear();
    justificativaController.clear();
    senhaController.clear();
    confirmarSenhaController.clear();

    setState(() {
      carregando = false;
      lotacao = null;
      aceitouTermo = false;
      sucesso = 'Solicitação enviada! A triagem técnica responde '
          'em até 24h úteis no e-mail informado.';
    });
  }

  @override
  void dispose() {
    nomeController.dispose();
    matriculaController.dispose();
    emailController.dispose();
    cargoController.dispose();
    justificativaController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, box) {
          final largo = box.maxWidth >= 900;

          // em tela estreita mostra só o formulário
          if (!largo) {
            return _painelDireito();
          }

          return Row(
            children: [
              Expanded(flex: 7, child: _painelEsquerdo()),
              Expanded(flex: 5, child: _painelDireito()),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // PAINEL ESQUERDO (apresentação)
  // ------------------------------------------------------------

  Widget _painelEsquerdo() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sidebar, AppColors.navy],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 64,
                    vertical: 56,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cabecalhoEsquerdo(),
                      const Spacer(),
                      _statusOnline(),
                      const SizedBox(height: 20),
                      const Text(
                        'Plataforma de Inteligência e Gestão\n'
                        'do Transporte Público',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ambiente integrado de tomada de decisão com '
                        'telemetria contínua, governança de dados e '
                        'modelos preditivos em tempo real para a malha '
                        'viária municipal.',
                        style: TextStyle(
                          color: Color(0xFFB8C4E0),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _cardRecurso(
                            Icons.sensors,
                            AppColors.cyan,
                            'Telemetria Real-Time',
                            'GPS, pontualidade de linha e lotação '
                                'instantânea da frota.',
                          ),
                          const SizedBox(width: 16),
                          _cardRecurso(
                            Icons.psychology_outlined,
                            const Color(0xFF90CAF9),
                            'IA & Anomalias',
                            'Modelos supervisionados para detecção '
                                'precoce de gargalos.',
                          ),
                          const SizedBox(width: 16),
                          _cardRecurso(
                            Icons.verified_user_outlined,
                            const Color(0xFF66BB6A),
                            'ICP-Brasil / LGPD',
                            'Criptografia ponta a ponta e trilhas de '
                                'auditoria periciais.',
                          ),
                        ],
                      ),
                      const Spacer(),
                      _rodapeEsquerdo(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _cabecalhoEsquerdo() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.sidebarLogo,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(
            Icons.directions_bus,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'SEMOB-SCS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'INTEL-OPS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'PREFEITURA MUNICIPAL DE SÃO CAETANO DO SUL',
              style: TextStyle(
                color: Color(0xFFB8C4E0),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusOnline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: Color(0xFF66BB6A)),
          SizedBox(width: 8),
          Text(
            'Barramento Operacional Online • Nuvem Governamental',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardRecurso(
    IconData icone,
    Color corIcone,
    String titulo,
    String descricao,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: corIcone.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icone, color: corIcone, size: 20),
            ),
            const SizedBox(height: 14),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              descricao,
              style: const TextStyle(
                color: Color(0xFFB8C4E0),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rodapeEsquerdo() {
    return const Column(
      children: [
        Divider(color: Colors.white24),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.shield_outlined, size: 14, color: Color(0xFF66BB6A)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Gateway de Autenticação Seguro v4.8 (SSL/TLS 1.3)',
                style: TextStyle(color: Color(0xFFB8C4E0), fontSize: 11),
              ),
            ),
            Text(
              'IP Gov: 177.136.210.42',
              style: TextStyle(
                color: Color(0xFFB8C4E0),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // PAINEL DIREITO (formulário de cadastro)
  // ------------------------------------------------------------

  Widget _painelDireito() {
    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _abas(),
                const SizedBox(height: 28),
                _formCadastro(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _abas() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _aba(
            Icons.lock_outline,
            'Acesso Restrito',
            false,
            () => context.go('/login'),
          ),
          _aba(
            Icons.person_add_alt_outlined,
            'Solicitar Cadastro',
            true,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _aba(
    IconData icone,
    String texto,
    bool selecionada,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: selecionada ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selecionada
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icone,
                size: 18,
                color: selecionada ? AppColors.navy : AppColors.muted,
              ),
              const SizedBox(width: 8),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selecionada ? AppColors.navy : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formCadastro() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _selo(
            Icons.badge_outlined,
            'Credenciamento de Servidores & Operadores',
          ),
          const SizedBox(height: 16),
          const Text(
            'Solicitação de Acesso\nInstitucional',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Preencha seus dados funcionais para validação pela '
            'Secretaria de Mobilidade Urbana (SEMOB).',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          _duasColunas(
            _campo(
              rotulo: 'Nome Completo',
              controller: nomeController,
              dica: 'Ex: Carlos Eduardo de Mendonça',
              icone: Icons.person_outline,
              validador: (v) {
                if (v == null || v.trim().length < 5) {
                  return 'Informe o nome completo.';
                }
                return null;
              },
            ),
            _campo(
              rotulo: 'Matrícula / Registro Profissional',
              controller: matriculaController,
              dica: 'Ex: 4829-SEMOB',
              icone: Icons.badge_outlined,
              validador: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Informe a matrícula.';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          _duasColunas(
            _campo(
              rotulo: 'E-mail Institucional',
              rotuloDireita: '@saocaetano.sp.gov.br',
              controller: emailController,
              dica: 'carlos.mendonca@saocaetano.sp.gov.br',
              icone: Icons.mail_outline,
              teclado: TextInputType.emailAddress,
              validador: (v) {
                final email = (v ?? '').trim().toLowerCase();
                if (email.isEmpty) {
                  return 'Informe o e-mail.';
                }
                if (!email.endsWith('@saocaetano.sp.gov.br')) {
                  return 'Use o e-mail institucional.';
                }
                return null;
              },
            ),
            _campo(
              rotulo: 'Cargo / Função',
              controller: cargoController,
              dica: 'Ex: Analista de Tráfego',
              icone: Icons.work_outline,
              validador: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Informe o cargo.';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          _rotulo('Lotação / Departamento'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: lotacao,
            isExpanded: true,
            decoration: _decoracao(
              'Selecione a unidade institucional...',
              Icons.apartment_outlined,
            ),
            items: [
              for (final u in unidades)
                DropdownMenuItem(value: u, child: Text(u)),
            ],
            onChanged: (valor) {
              setState(() {
                lotacao = valor;
              });
            },
            validator: (v) {
              if (v == null) {
                return 'Selecione a unidade.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _campo(
            rotulo: 'Justificativa do Pedido de Acesso',
            controller: justificativaController,
            dica: 'Descreva resumidamente suas atribuições que '
                'justificam o acesso aos sistemas de telemetria e '
                'gestão viária',
            icone: Icons.description_outlined,
            linhas: 3,
            validador: (v) {
              if (v == null || v.trim().length < 20) {
                return 'Descreva a justificativa (mín. 20 caracteres).';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _duasColunas(
            _campo(
              rotulo: 'Senha de Acesso',
              controller: senhaController,
              dica: 'Mínimo 8 caracteres',
              icone: Icons.lock_outline,
              senha: true,
              validador: (v) {
                if (v == null || v.length < 8) {
                  return 'Mínimo 8 caracteres.';
                }
                return null;
              },
            ),
            _campo(
              rotulo: 'Confirmar Senha',
              controller: confirmarSenhaController,
              dica: 'Repita a senha',
              icone: Icons.lock_reset,
              senha: true,
              validador: (v) {
                if (v != senhaController.text) {
                  return 'As senhas não conferem.';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: aceitouTermo,
                activeColor: AppColors.primary,
                onChanged: (valor) {
                  setState(() {
                    aceitouTermo = valor ?? false;
                  });
                },
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Declaro ciência e concordância integral com o '
                    'Termo de Sigilo Funcional e a Política de Proteção '
                    'de Dados (Lei Geral de Proteção de Dados - LGPD '
                    'nº 13.709/2018).',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.text,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          _mensagens(),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: carregando ? null : solicitarCadastro,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: carregando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.how_to_reg_outlined, size: 18),
              label: const Text(
                'Solicitar Homologação de Acesso',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _caixaTriagem(),
        ],
      ),
    );
  }

  Widget _caixaTriagem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Triagem Técnica DTI / SEMOB',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'As solicitações passam por triagem funcional e são '
                  'respondidas em até 24h úteis no e-mail funcional '
                  'informado.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.text,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // WIDGETS REUTILIZADOS
  // ------------------------------------------------------------

  Widget _selo(IconData icone, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rotulo(String texto, {String? direita}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ),
        if (direita != null)
          Text(
            direita,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
      ],
    );
  }

  InputDecoration _decoracao(String dica, IconData icone) {
    final borda = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return InputDecoration(
      hintText: dica,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
      prefixIcon: Icon(icone, size: 20, color: AppColors.muted),
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      border: borda,
      enabledBorder: borda,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _campo({
    required String rotulo,
    required TextEditingController controller,
    required String dica,
    required IconData icone,
    String? Function(String?)? validador,
    String? rotuloDireita,
    bool senha = false,
    int linhas = 1,
    TextInputType? teclado,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rotulo(rotulo, direita: rotuloDireita),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: senha,
          keyboardType: teclado,
          minLines: linhas,
          maxLines: linhas,
          style: const TextStyle(fontSize: 13),
          decoration: _decoracao(dica, icone),
          validator: validador,
        ),
      ],
    );
  }

  // duas colunas no desktop, empilha no celular
  Widget _duasColunas(Widget a, Widget b) {
    final estreito = MediaQuery.of(context).size.width < 520;

    if (estreito) {
      return Column(
        children: [
          a,
          const SizedBox(height: 16),
          b,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
    );
  }

  // mostra erro (vermelho) ou sucesso (verde), se existir
  Widget _mensagens() {
    final texto = erro ?? sucesso;

    if (texto == null) {
      return const SizedBox.shrink();
    }

    final ehErro = erro != null;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ehErro ? AppColors.redSoft : AppColors.greenSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ehErro ? Colors.red.shade200 : Colors.green.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              ehErro ? Icons.error_outline : Icons.check_circle_outline,
              color: ehErro ? AppColors.red : AppColors.green,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 12,
                  color: ehErro ? Colors.red.shade800 : Colors.green.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
