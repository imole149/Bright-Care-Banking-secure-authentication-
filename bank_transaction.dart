class BankTransaction {
  final int? id;
  final int userId;
  final String date;
  final String description;
  final double amount;
  final String type;
  final String category;

  BankTransaction({
    this.id,
    required this.userId,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
  });

  bool get isCredit => type.toLowerCase() == 'credit';

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'description': description,
      'amount': amount,
      'type': type,
      'category': category,
    };
  }

  factory BankTransaction.fromMap(Map<String, dynamic> map) {
    return BankTransaction(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      date: map['date'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double,
      type: map['type'] as String,
      category: map['category'] as String,
    );
  }
}
