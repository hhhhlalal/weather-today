String getLunarDateStr(DateTime date) {
  final lunarCycle = 29.53;
  final diff = date.difference(DateTime(1900, 1, 31));
  final days = diff.inDays % lunarCycle;
  final lunarDay = (days + 1).round();
  final lunarMonth = ((date.month + 1) % 12) + 1;
  return 'Âm: $lunarDay/$lunarMonth';
}
