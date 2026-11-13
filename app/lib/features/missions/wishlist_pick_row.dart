import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/wishlist.dart';
import '../../l10n/app_localizations.dart';
import 'wishlist_csv.dart';

/// One ranked wishlist pick: conditions and the reasons from its score terms.
class WishlistPickRow extends ConsumerWidget {
  const WishlistPickRow({super.key, required this.rank, required this.c});

  final int rank;
  final WishCandidate c;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    return Semantics(
      label: l.wishlistPin(f.integer(rank)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FsSpace.s3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Text(
                f.integer(rank),
                style: context.nums.md.copyWith(color: context.fs.textTertiary),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wishConditions(l, f, c), style: context.text.labelLarge),
                  for (final r in wishReasons(l, f, c))
                    Text(r, style: context.text.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
