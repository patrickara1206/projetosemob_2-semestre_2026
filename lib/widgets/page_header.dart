import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? eyebrow;
  final VoidCallback? onExport;
  final VoidCallback? onRefresh;
  final bool refreshing;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.onExport,
    this.onRefresh,
    this.refreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto = constraints.maxWidth < 850;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null) ...[
                    Text(
                      eyebrow!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: cores.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: compacto ? 22 : 26,
                      fontWeight: FontWeight.w800,
                      color: cores.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: cores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 16),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (compacto)
                  Tooltip(
                    message: 'Exportar relatório',
                    child: OutlinedButton(
                      onPressed: onExport,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(
                        Icons.download_outlined,
                        size: 19,
                      ),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: onExport,
                    icon: const Icon(
                      Icons.download_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'Exportar Relatório',
                    ),
                  ),

                const SizedBox(width: 10),

                if (compacto)
                  Tooltip(
                    message: 'Atualizar dados',
                    child: OutlinedButton(
                      onPressed:
                          refreshing ? null : onRefresh,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: EdgeInsets.zero,
                      ),
                      child: refreshing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.refresh,
                              size: 19,
                            ),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed:
                        refreshing ? null : onRefresh,
                    icon: refreshing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.refresh,
                            size: 18,
                          ),
                    label: const Text(
                      'Atualizar dados',
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}