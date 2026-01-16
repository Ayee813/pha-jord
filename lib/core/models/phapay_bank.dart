/// Supported Banks for PhaPay
enum PhaPayBank {
  bcel, // BCEL One
  jdb, // JDB Yes
  ldb, // LDB Trust
  other, // Inter-bank / Generic
}

extension PhaPayBankExtension on PhaPayBank {
  String get displayName {
    switch (this) {
      case PhaPayBank.bcel:
        return 'BCEL One';
      case PhaPayBank.jdb:
        return 'JDB Yes';
      case PhaPayBank.ldb:
        return 'LDB Trust';
      case PhaPayBank.other:
        return 'Scan Any Bank';
    }
  }

  String get logoAsset {
    switch (this) {
      case PhaPayBank.bcel:
        return 'assets/icons/bcel.png';
      case PhaPayBank.jdb:
        return 'assets/icons/jdb.png';
      case PhaPayBank.ldb:
        return 'assets/icons/ldb.png';
      case PhaPayBank.other:
        return 'assets/icons/PromptPay-logo.png';
    }
  }
}
