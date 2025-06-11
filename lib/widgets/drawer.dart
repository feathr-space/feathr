import 'package:flutter/material.dart';

import 'package:feathr/data/account.dart';

/// The [FeathrDrawerHeader] widget stores and displays information about
/// the currently logged-in user account in a drawer that will be displayed
/// on the tab view.
class FeathrDrawerHeader extends StatelessWidget {
  final Account account;

  const FeathrDrawerHeader({required this.account, super.key});

  @override
  Widget build(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(account.displayName, style: TextStyle(color: Colors.white)),
      ),
      accountEmail: Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(account.acct, style: TextStyle(color: Colors.white)),
      ),
      currentAccountPicture: CircleAvatar(
        foregroundImage: account.avatarUrl != null
            ? NetworkImage(account.avatarUrl!)
            : null,
      ),
      decoration: BoxDecoration(
        image: account.headerUrl != null
            ? DecorationImage(
                image: NetworkImage(account.headerUrl!),
                fit: BoxFit.cover,
              )
            : null,
        color: account.headerUrl == null ? Colors.teal : null,
      ),
    );
  }
}
