import 'package:equatable/equatable.dart';

class Watchlist extends Equatable {
  final String id;
  final String name;
  final List<String> symbols;
  final DateTime createdAt;

  const Watchlist({
    required this.id,
    required this.name,
    required this.symbols,
    required this.createdAt,
  });

  Watchlist copyWith({String? name, List<String>? symbols}) => Watchlist(
        id: id,
        name: name ?? this.name,
        symbols: symbols ?? this.symbols,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbols': symbols,
        'createdAt': createdAt.toIso8601String(),
      };

  static Watchlist fromJson(Map<String, dynamic> j) => Watchlist(
        id: j['id'] as String,
        name: j['name'] as String,
        symbols: (j['symbols'] as List).cast<String>(),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );

  @override
  List<Object?> get props => [id, name, symbols, createdAt];
}
