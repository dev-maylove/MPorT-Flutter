class InvoiceModel {
  final int id;
  final String invoiceNumber;
  final double amount;
  final String? amountFormatted;
  final String status; // unpaid | paid | overdue | cancelled
  final String? period;
  final String? dueDate;
  final String? packageName;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    this.amountFormatted,
    required this.status,
    this.period,
    this.dueDate,
    this.packageName,
  });

  String get displayAmount {
    if (amountFormatted != null && amountFormatted!.isNotEmpty) {
      return amountFormatted!;
    }
    return 'Rp ${_format(amount)}';
  }

  bool get isUnpaid => status == 'unpaid' || status == 'overdue';
  bool get isPaid => status == 'paid';
  bool get isOverdue => status == 'overdue';

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: _asInt(json['id']),
      invoiceNumber: (json['invoice_number'] ?? json['number'] ?? '#${json['id']}').toString(),
      amount: _asDouble(json['amount']),
      amountFormatted: json['amount_formatted']?.toString(),
      status: (json['status'] ?? 'unpaid').toString().toLowerCase(),
      period: json['period']?.toString(),
      dueDate: json['due_date']?.toString(),
      packageName: (json['package_name'] ?? json['package']?['name'])?.toString(),
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    return 0;
  }

  static String _format(double n) {
    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
