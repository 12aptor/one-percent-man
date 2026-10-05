import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum TransactionType { income, expense }

enum TransactionCategory {
  salary,
  food,
  transport,
  health,
  entertainment,
  shopping,
  home,
  savings,
  other,
}

extension TransactionCategoryExt on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.salary: return 'Salario';
      case TransactionCategory.food: return 'Comida';
      case TransactionCategory.transport: return 'Transporte';
      case TransactionCategory.health: return 'Salud';
      case TransactionCategory.entertainment: return 'Ocio';
      case TransactionCategory.shopping: return 'Compras';
      case TransactionCategory.home: return 'Hogar';
      case TransactionCategory.savings: return 'Ahorro';
      case TransactionCategory.other: return 'Otros';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.salary: return LucideIcons.briefcase;
      case TransactionCategory.food: return LucideIcons.pizza;
      case TransactionCategory.transport: return LucideIcons.car;
      case TransactionCategory.health: return LucideIcons.heartPulse;
      case TransactionCategory.entertainment: return LucideIcons.gamepad2;
      case TransactionCategory.shopping: return LucideIcons.shoppingBag;
      case TransactionCategory.home: return LucideIcons.home;
      case TransactionCategory.savings: return LucideIcons.piggyBank;
      case TransactionCategory.other: return LucideIcons.moreHorizontal;
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.salary: return const Color(0xFF10B981); // emerald
      case TransactionCategory.food: return const Color(0xFFF59E0B); // amber
      case TransactionCategory.transport: return const Color(0xFF3B82F6); // blue
      case TransactionCategory.health: return const Color(0xFFEF4444); // red
      case TransactionCategory.entertainment: return const Color(0xFF8B5CF6); // violet
      case TransactionCategory.shopping: return const Color(0xFFEC4899); // pink
      case TransactionCategory.home: return const Color(0xFF14B8A6); // teal
      case TransactionCategory.savings: return const Color(0xFF6366F1); // indigo
      case TransactionCategory.other: return const Color(0xFF64748B); // slate
    }
  }
}

enum AccountType { general, savings }

class FinancialAccount {
  final String id;
  final String name;
  final AccountType type;
  final IconData icon;
  final Color color;
  final String? goalId; // Link to a goal if it's a savings account

  FinancialAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.goalId,
  });

  static const Map<String, IconData> _icons = {
    'wallet': LucideIcons.wallet,
    'landmark': LucideIcons.landmark,
    'creditCard': LucideIcons.creditCard,
    'banknote': LucideIcons.banknote,
    'coins': LucideIcons.coins,
    'piggyBank': LucideIcons.piggyBank,
    'shoppingBag': LucideIcons.shoppingBag,
    'briefcase': LucideIcons.briefcase,
    'home': LucideIcons.home,
  };

  Map<String, dynamic> toJson() {
    final iconKey = _icons.entries
        .firstWhere((e) => e.value.codePoint == icon.codePoint, orElse: () => _icons.entries.first)
        .key;

    return {
      'id': id,
      'name': name,
      'type': type.index,
      'iconKey': iconKey,
      'color': color.value,
      'goalId': goalId,
    };
  }

  factory FinancialAccount.fromJson(Map<String, dynamic> json) {
    final iconKey = json['iconKey'] as String?;
    final iconData = iconKey != null ? _icons[iconKey] : LucideIcons.wallet;

    return FinancialAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AccountType.values[json['type'] as int],
      icon: iconData ?? LucideIcons.wallet,
      color: Color(json['color'] as int),
      goalId: json['goalId'] as String?,
    );
  }
}

class FinancialTransaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final TransactionCategory category;
  final String accountId; // New field to link transaction to an account

  FinancialTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    required this.accountId,
  });

  FinancialTransaction copyWith({
    String? title,
    double? amount,
    TransactionType? type,
    DateTime? date,
    TransactionCategory? category,
    String? accountId,
  }) {
    return FinancialTransaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.index,
      'date': date.toIso8601String(),
      'category': category.index,
      'accountId': accountId,
    };
  }

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    return FinancialTransaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values[json['type'] as int],
      date: DateTime.parse(json['date'] as String),
      category: TransactionCategory.values[json['category'] as int],
      accountId: json['accountId'] as String? ?? 'main', // Default to main for migration
    );
  }

  String toJsonString() => jsonEncode(toJson());
  factory FinancialTransaction.fromJsonString(String source) =>
      FinancialTransaction.fromJson(jsonDecode(source));
}

