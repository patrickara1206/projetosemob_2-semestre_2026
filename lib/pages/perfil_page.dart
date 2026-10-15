import 'package:flutter/material.dart';

import '../core/theme.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  // 0 = Visão Geral & Dados | 1 = Segurança & Acesso
  int aba = 0;

  final nome = TextEditingController(text: 'Carlos Eduardo Mendonça');
  final matricula = TextEditingController(text: '4829-SEMOB / SP');
  final email = TextEditingController(text: 'carlos.mendonca@saocaetano.sp.gov.br');
  final telefone = TextEditingController(text: '+55 (11) 4233-7000 Ramal 482');
  final departamento = TextEditingController(text: 'Engenharia de Tráfego e Mobilidade');

  void salvar() {
    // TODO: salvar no backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alterações salvas com sucesso!')),
    );
  }

  @override
  void dispose() {
    nome.dispose();
    matricula.dispose();
    email.dispose();
    telefone.dispose();
    departamento.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _cabecalho(),
          const SizedBox(height: 16),
          _abas(),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, box) {
              final direita = Column(
                children: [
                  if (aba == 0) ...[_cardDados(), const SizedBox(height: 16)],
                  _cardSeguranca(),
                  const SizedBox(height: 16),
                  _cardAtividade(),
                ],
              );

              // celular: tudo empilhado
              if (box.maxWidth < 900) {
                return Column(
                  children: [
                    if (aba == 0) ...[_cardPerfil(), const SizedBox(height: 16)],
                    direita,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (aba == 0) ...[
                    SizedBox(width: 340, child: _cardPerfil()),
                    const SizedBox(width: 16),
                  ],
                  Expanded(child: direita),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- topo ----------------

  Widget _cabecalho() {
    return _card(
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEMOB-SCS  •  Servidor Ativo',
                  style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Perfil do Usuário',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                SizedBox(height: 4),
                Text(
                  'Gerencie suas informações cadastrais e segurança da conta.',
                  style: TextStyle(fontSize: 14, color: AppColors.muted),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: salvar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Salvar Alterações'),
          ),
        ],
      ),
    );
  }

  Widget _abas() {
    return _card(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _botaoAba(0, Icons.person_outline, 'Visão Geral & Dados'),
          const SizedBox(width: 8),
          _botaoAba(1, Icons.verified_user_outlined, 'Segurança & Acesso'),
        ],
      ),
    );
  }

  Widget _botaoAba(int indice, IconData icone, String texto) {
    final selecionada = aba == indice;

    return TextButton.icon(
      onPressed: () => setState(() => aba = indice),
      style: TextButton.styleFrom(
        backgroundColor: selecionada ? AppColors.primary : Colors.transparent,
        foregroundColor: selecionada ? Colors.white : AppColors.text,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icone, size: 18),
      label: Text(texto, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  // ---------------- coluna da esquerda ----------------

  Widget _cardPerfil() {
    return _card(
      child: Column(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.navy,
                  child: Text('CE', style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.photo_camera_outlined, size: 16, color: AppColors.text),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Carlos Eduardo Mendonça',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy),
          ),
          const SizedBox(height: 6),
          const Text(
            'Coordenador de Planejamento Operacional',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Secretaria de Mobilidade Urbana (SEMOB)',
            style: TextStyle(fontSize: 12, color: AppColors.text),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chip('● Conta Ativa', AppColors.greenSoft, AppColors.green),
              const SizedBox(width: 8),
              _chip('#4829-SEMOB', const Color(0xFFF3F4F6), AppColors.text),
            ],
          ),
          const Divider(height: 32, color: AppColors.border),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Autenticação 2FA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Ativada via App', style: TextStyle(fontSize: 11, color: AppColors.green)),
                    ],
                  ),
                ),
                Icon(Icons.check_circle_outline, color: AppColors.green, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: AppColors.navy,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.lock_reset, size: 18),
              label: const Text('Alterar Senha de Acesso', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- coluna da direita ----------------

  Widget _cardDados() {
    return _secao(
      Icons.badge_outlined,
      'Dados Pessoais & Funcionais',
      'Informações institucionais de identificação',
      Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _campo('Nome Completo', nome)),
              const SizedBox(width: 16),
              Expanded(child: _campo('Matrícula Funcional', matricula, ativo: false)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _campo('E-mail Corporativo', email, ativo: false)),
              const SizedBox(width: 16),
              Expanded(child: _campo('Telefone / Ramal', telefone)),
            ],
          ),
          const SizedBox(height: 16),
          _campo('Departamento / Lotação', departamento),
        ],
      ),
    );
  }

  Widget _cardSeguranca() {
    return _secao(
      Icons.lock_outline,
      'Segurança da Conta',
      'Credenciais e certificados vinculados',
      Row(
        children: [
          Expanded(
            child: _caixaInfo(Icons.fingerprint, 'Certificado ICP-Brasil (A3)', 'Válido até Out/2024',
                'Conectado', AppColors.greenSoft, AppColors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _caixaInfo(Icons.devices, 'Sessão Atual', 'IP 177.136.210.42 (Intranet)',
                'Ativa', const Color(0xFFE8F1FB), AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _cardAtividade() {
    return _secao(
      Icons.history,
      'Atividade Recente',
      'Últimos acessos e operações registradas',
      Column(
        children: [
          _atividade(Icons.login, 'Último acesso autenticado ao sistema',
              'Login via Certificado Digital (ICP-Brasil)', 'Hoje, 13:42'),
          const Divider(height: 24, color: AppColors.border),
          _atividade(Icons.lock_reset, 'Última alteração de senha', 'Atualizada com sucesso', 'Há 45 dias'),
        ],
      ),
    );
  }

  // ---------------- widgets reutilizados ----------------

  Widget _card({required Widget child, EdgeInsets padding = const EdgeInsets.all(24)}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  // card com ícone + título + subtítulo e uma linha embaixo
  Widget _secao(IconData icone, String titulo, String subtitulo, Widget filho) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, color: AppColors.navy, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy)),
                  Text(subtitulo, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ],
          ),
          const Divider(height: 32, color: AppColors.border),
          filho,
        ],
      ),
    );
  }

  Widget _campo(String rotulo, TextEditingController controller, {bool ativo = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: ativo,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: ativo ? Colors.white : const Color(0xFFF3F4F6),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String texto, Color fundo, Color corTexto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(6)),
      child: Text(texto, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: corTexto)),
    );
  }

  Widget _caixaInfo(IconData icone, String titulo, String sub, String status, Color fundo, Color cor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icone, color: AppColors.primary, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
          _chip(status, fundo, cor),
        ],
      ),
    );
  }

  Widget _atividade(IconData icone, String titulo, String sub, String quando) {
    return Row(
      children: [
        Icon(icone, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
          ),
        ),
        Text(quando, style: const TextStyle(fontSize: 12, color: AppColors.muted, fontFamily: 'monospace')),
      ],
    );
  }
}
