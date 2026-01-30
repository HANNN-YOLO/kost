String formatCurrency(int value) {
  final str = value.toString();
  final rev = str.split('').reversed.toList();
  final parts = <String>[];
  for (int i = 0; i < rev.length; i += 3) {
    parts.add(rev.sublist(i, (i + 3).clamp(0, rev.length)).join());
  }
  final grouped = parts.join('.').split('').reversed.join();
  return 'Rp $grouped';
}
