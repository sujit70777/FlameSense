import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import 'simple_table.dart';

/// TeX for the three equations, identical to docs/PHYSICS_SPEC.md §1.
const kEqSpread =
    r'V_f = \frac{\pi}{4} \cdot \frac{\lambda_g \cdot (T_f - T_v)}{\rho_s \cdot c_s \cdot \tau \cdot (T_v - T_\infty)}';
const kEqBuoyant =
    r'U_b = \left( \frac{g \cdot \alpha_g \cdot (T_f - T_\infty)}{T_\infty} \right)^{1/3}';
const kEqEffective = r'U_{eff} = \sqrt{U_{forced}^2 + U_b^2}';

/// "Physics check": equations, symbols, applicability, parameters, sign-off (DESIGN.md §11.7 #physics).
class MethodsPhysics extends ConsumerWidget {
  const MethodsPhysics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final p = ref.watch(loadedDataProvider).physics;
    final c = context.fs;
    Widget eq(
      String title,
      String tex,
      List<(String, String, String)> symbols,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: context.text.titleMedium),
        const SizedBox(height: FsSpace.s3),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            tex,
            mathStyle: MathStyle.display,
            textStyle: context.text.titleLarge!.copyWith(color: c.textPrimary),
          ),
        ),
        const SizedBox(height: FsSpace.s3),
        SimpleTable(
          headers: [l.colSymbol, l.colMeaning, l.colUnit],
          flex: const [1, 3, 1],
          rows: [
            for (final (sym, meaning, unit) in symbols)
              [
                Math.tex(
                  sym,
                  textStyle: context.text.bodyMedium!.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                SimpleTable.t(context, meaning),
                SimpleTable.t(context, unit),
              ],
          ],
        ),
        const SizedBox(height: FsSpace.s5),
      ],
    );
    String n(double? v) => v == null ? l.notAvailable : f.sig(v, digits: 4);
    final paramRows = <List<Widget>>[
      [
        SimpleTable.t(context, r'λ_g'),
        SimpleTable.t(context, n(p.lambda)),
        SimpleTable.t(
          context,
          p.gasSource.isEmpty ? l.methodsPending : p.gasSource,
        ),
      ],
      [
        SimpleTable.t(context, r'α_g'),
        SimpleTable.t(context, n(p.alpha)),
        SimpleTable.t(
          context,
          p.gasSource.isEmpty ? l.methodsPending : p.gasSource,
        ),
      ],
      [
        SimpleTable.t(context, r'T_∞'),
        SimpleTable.t(context, n(p.tInf)),
        SimpleTable.t(
          context,
          p.gasSource.isEmpty ? l.methodsPending : p.gasSource,
        ),
      ],
      for (final e in p.fuels.entries)
        [
          SimpleTable.t(context, e.key),
          SimpleTable.t(
            context,
            [
              n(e.value.rho),
              n(e.value.cs),
              n(e.value.tv),
              n(e.value.halfThicknessM),
            ].join(', '),
          ),
          SimpleTable.t(
            context,
            e.value.source.isEmpty ? l.methodsPending : e.value.source,
          ),
        ],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        eq(l.methodsEq1, kEqSpread, [
          (r'V_f', l.symVf, l.unitMS),
          (r'\lambda_g', l.symLambda, l.unitWmK),
          (r'T_f', l.symTf, l.unitK),
          (r'T_v', l.symTv, l.unitK),
          (r'T_\infty', l.symTinf, l.unitK),
          (r'\rho_s', l.symRho, l.unitKgM3),
          (r'c_s', l.symCs, l.unitJkgK),
          (r'\tau', l.symTau, l.unitM),
        ]),
        eq(l.methodsEq2, kEqBuoyant, [
          (r'U_b', l.symUb, l.unitMS),
          (r'g', l.symG, l.unitMs2),
          (r'\alpha_g', l.symAlpha, l.unitM2S),
        ]),
        eq(l.methodsEq3, kEqEffective, [(r'U_{eff}', l.symUeff, l.unitMmS)]),
        Text(l.methodsApplicability, style: context.text.bodyLarge),
        const SizedBox(height: FsSpace.s3),
        Text(l.methodsPhysLimit, style: context.text.bodyLarge),
        const SizedBox(height: FsSpace.s4),
        SimpleTable(
          headers: [l.colParameter, l.colValue, l.colSource],
          flex: const [1, 2, 3],
          rows: paramRows,
        ),
        if (p.problems.isNotEmpty) ...[
          const SizedBox(height: FsSpace.s2),
          Text(l.methodsParamsPending, style: context.text.bodyMedium),
        ],
        const SizedBox(height: FsSpace.s3),
        Text(
          p.signedOffByLead
              ? l.methodsSignedOff(p.signedOffOn ?? '')
              : l.methodsPending,
          style: context.text.labelLarge!.copyWith(
            color: p.signedOffByLead ? c.success : c.warn,
          ),
        ),
      ],
    );
  }
}
