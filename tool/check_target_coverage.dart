import 'dart:io';

const targets = <String>{
  'lib/features/watchlist/data/watchlist_repository.dart',
  'lib/features/holdings/data/portfolio_repository.dart',
  'lib/features/watchlist/presentation/bloc/watchlist_bloc.dart',
  'lib/features/holdings/presentation/bloc/portfolio_bloc.dart',
  'lib/features/market_data/presentation/bloc/market_bloc.dart',
  'lib/features/home/presentation/bloc/settings_bloc.dart',
  'lib/features/order/presentation/bloc/order_bloc.dart',
};

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    stderr.writeln(
      'coverage/lcov.info not found. Run "flutter test --coverage" first.',
    );
    exitCode = 2;
    return;
  }

  final records = _parse(file.readAsLinesSync());
  final missingRecords = targets.difference(records.keys.toSet());
  if (missingRecords.isNotEmpty) {
    stderr.writeln('Missing coverage records:');
    for (final path in missingRecords) {
      stderr.writeln('  $path');
    }
    exitCode = 1;
    return;
  }

  var total = 0;
  var hit = 0;
  var failed = false;

  for (final path in targets.toList()..sort()) {
    final lines = records[path]!;
    final uncovered = lines.entries
        .where((entry) => entry.value == 0)
        .map((entry) => entry.key)
        .toList()
      ..sort();
    final fileHit = lines.values.where((count) => count > 0).length;
    total += lines.length;
    hit += fileHit;
    final percent = lines.isEmpty ? 100 : fileHit * 100 / lines.length;
    stdout.writeln(
      '$path: ${percent.toStringAsFixed(2)}% '
      '($fileHit/${lines.length} lines)',
    );
    if (uncovered.isNotEmpty) {
      stdout.writeln('  uncovered lines: ${uncovered.join(', ')}');
      failed = true;
    }
  }

  final totalPercent = total == 0 ? 100 : hit * 100 / total;
  stdout.writeln(
    'Target total: ${totalPercent.toStringAsFixed(2)}% ($hit/$total lines)',
  );
  if (failed || hit != total) {
    stderr.writeln('Targeted BLoC/repository coverage must be 100%.');
    exitCode = 1;
  }
}

Map<String, Map<int, int>> _parse(List<String> lines) {
  final result = <String, Map<int, int>>{};
  String? current;
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      current = line.substring(3);
      if (targets.contains(current)) result[current] = <int, int>{};
    } else if (line.startsWith('DA:') &&
        current != null &&
        result.containsKey(current)) {
      final parts = line.substring(3).split(',');
      if (parts.length >= 2) {
        final lineNumber = int.tryParse(parts[0]);
        final count = int.tryParse(parts[1]);
        if (lineNumber != null && count != null) {
          result[current]![lineNumber] = count;
        }
      }
    } else if (line == 'end_of_record') {
      current = null;
    }
  }
  return result;
}
