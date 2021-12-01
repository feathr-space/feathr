import 'package:flutter/material.dart';

import 'package:feathr/data/account.dart';

/// The [FeathrDrawerHeader] widget stores and displays information about
/// the currently logged-in user account in a drawer that will be displayed
/// on the tab view.
class FeathrDrawerHeader extends StatelessWidget {
  final Account account;

  const FeathrDrawerHeader({required this.account, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: Text(account.username),
      accountEmail: Text(account.displayName),
      currentAccountPicture: CircleAvatar(
        foregroundImage:
            account.avatarUrl != null ? NetworkImage(account.avatarUrl!) : null,
      ),
      decoration: BoxDecoration(
        image: account.headerUrl != null
            ? DecorationImage(image: NetworkImage(account.headerUrl!))
            : null,
        color: account.headerUrl == null ? Colors.teal : null,
      ),
    );
  }
}
