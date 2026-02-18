import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';

class InvoiceService {
  static Future<void> printInvoice(CustomerOrder order) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header ──
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Coastal Farmer',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#2E7D32'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Farm Fresh Products',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColor.fromHex('#666666'),
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#333333'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '#${order.id}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromHex('#666666'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColor.fromHex('#2E7D32'), thickness: 2),
              pw.SizedBox(height: 20),

              // ── Customer Info & Date ──
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Bill To:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#888888'),
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          order.customerName,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          order.customerPhone,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          order.customerAddress,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _infoRow('Date:', dateFormat.format(order.orderDate)),
                      pw.SizedBox(height: 4),
                      _infoRow(
                        'Status:',
                        order.status.name[0].toUpperCase() +
                            order.status.name.substring(1),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // ── Items Table ──
              pw.TableHelper.fromTextArray(
                headerAlignment: pw.Alignment.centerLeft,
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#2E7D32'),
                  borderRadius: const pw.BorderRadius.vertical(
                    top: pw.Radius.circular(4),
                  ),
                ),
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
                cellStyle: const pw.TextStyle(fontSize: 11),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
                headerAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
                headerPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                oddRowDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F5F5F5'),
                ),
                headers: ['Product', 'Qty', 'Unit Price', 'Total'],
                data: order.items.map((item) {
                  return [
                    item.productName,
                    item.quantity.toStringAsFixed(0),
                    '৳${item.unitPrice.toStringAsFixed(0)}',
                    '৳${item.totalPrice.toStringAsFixed(0)}',
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 16),

              // ── Totals ──
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 200,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E8F5E9'),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(
                      color: PdfColor.fromHex('#2E7D32'),
                      width: 1.5,
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total:',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '৳${order.totalAmount.toStringAsFixed(0)}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#2E7D32'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Notes ──
              if (order.notes.isNotEmpty) ...[
                pw.SizedBox(height: 24),
                pw.Text(
                  'Notes:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#888888'),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FFF9C4'),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    order.notes,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              ],

              pw.Spacer(),

              // ── Footer ──
              pw.Divider(color: PdfColor.fromHex('#CCCCCC')),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Thank you for your order!',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#2E7D32'),
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Coastal Farmer Admin • Generated on ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColor.fromHex('#999999'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${order.id}_${order.customerName}',
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#888888'),
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
      ],
    );
  }
}
