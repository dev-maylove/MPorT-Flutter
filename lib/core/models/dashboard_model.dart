import 'invoice_model.dart';

class DashboardSummary {
  final int unpaidCount;
  final int overdueCount;
  final int paidCount;
  final double totalUnpaidAmount;
  final int packagesCount;
  final List<InvoiceModel> recentInvoices;

  const DashboardSummary({
    this.unpaidCount = 0,
    this.overdueCount = 0,
    this.paidCount = 0,
    this.totalUnpaidAmount = 0,
    this.packagesCount = 0,
    this.recentInvoices = const [],
  });

  String get totalUnpaidFormatted {
    final s = totalUnpaidAmount.toStringAsFixed(0);
    final buf = StringBuffer('Rp ');
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] is Map
        ? Map<String, dynamic>.from(json['summary'] as Map)
        : json;
    final recent = <InvoiceModel>[];
    final raw = json['recent_invoices'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          recent.add(InvoiceModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return DashboardSummary(
      unpaidCount: _asInt(summary['unpaid_count']),
      overdueCount: _asInt(summary['overdue_count']),
      paidCount: _asInt(summary['paid_count']),
      totalUnpaidAmount: _asDouble(summary['total_unpaid_amount']),
      packagesCount: _asInt(summary['packages_count']),
      recentInvoices: recent,
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
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}
