import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class TicketDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketDetailScreen({super.key, required this.ticket, required ticketId});

  @override
  Widget build(BuildContext context) {
    String formatDate(String? date) {
      if (date == null) return 'Not yet';
      try {
        return DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(date));
      } catch (e) {
        return 'Invalid date';
      }
    }

    bool isApproved = ticket['status'] == 'APPROVED';
/*
    Future<void> downloadPdf() async {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                    'Ticket Number: ${ticket['reference'] ?? "Non rempli"}'),
                pw.SizedBox(height: 8),
                pw.Text('Status: ${ticket['status'] ?? "Non rempli"}'),
                pw.Text('Service Station: ${ticket['service_station'] ?? "Non rempli"}'),
                pw.Text('Client: ${ticket['client'] != null && ticket['client']['client'] != null ? ticket['client']['client'] : "Non rempli"}'),
                pw.Text('Equipement S/N: ${ticket['equipement'] != null && ticket['equipement']['equipement_sn'] != null ? ticket['equipement']['equipement_sn'] : "Non rempli"}'),
                pw.Text('Service Type: ${ticket['service_type'] ?? "Non rempli"}'),
                pw.Text('Type: ${ticket['type'] ?? "Non rempli"}'),
                pw.Text('Client: ${ticket['contact'] != null && ticket['contact']['name'] != null ? ticket['contact']['name'] : "Non rempli"}'),
                pw.Text('Call Time: ${formatDate(ticket['call_time'])}'),
                pw.Text('Receiving time: ${formatDate(ticket['created_at'])}'),
                pw.Text('Accepting time: ${formatDate(ticket['accepting_time'])}'),
                pw.Text('Starting time: ${formatDate(ticket['starting_time'])}'),
                pw.Text('Solving time: ${formatDate(ticket['solving_time'])}'),
                pw.Text('Completion time: ${formatDate(ticket['completion_time'])}'),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final fileName = 'ticket_${ticket['reference']}.pdf';
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/$fileName';

      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      // Open file in external application (platform-specific)
      if (Platform.isAndroid || Platform.isIOS) {
        await OpenFile.open(filePath);
      }
    }
*/
    Future<void> downloadPdf() async {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.red, width: 2),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Tunisys',
                              style: pw.TextStyle(
                                  fontSize: 25,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.red)),
                          pw.Text('124, Avenue de la liberté'),
                          pw.Text('1002 Tunis-Bélvedére'),
                          pw.Text('Tél : 71 791 699'),
                          pw.Text('Fax : 71 786 188'),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.red, width: 8),
                        ),
                        child: pw.Text('Fiche Intervention',
                            style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red)),
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Date :', style: const pw.TextStyle(fontSize: 12)),
                          pw.Text(formatDate(ticket['completion_time']),
                              style: const pw.TextStyle(fontSize: 15)),
                          pw.SizedBox(height: 10),
                          pw.Text('Numéro :',
                              style: const pw.TextStyle(fontSize: 12)),
                          pw.Text(ticket['reference'] ?? "",
                              style: const pw.TextStyle(fontSize: 20)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.red, width: 2),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Client', style: const pw.TextStyle(fontSize: 20)),
                      pw.Text(ticket['client']?['client'] ?? "",
                          style: const pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.red, width: 2),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Localisation',
                                style: const pw.TextStyle(fontSize: 20)),
                            pw.Text(
                                ticket['service_station'] != null
                                    ? '${ticket['service_station'] ?? ''}'
                                    : '',
                                style: const pw.TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.red, width: 2),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Num série',
                                style: const pw.TextStyle(fontSize: 20)),
                            pw.Text(
                                ticket['equipement']?['equipement_sn'] ?? "",
                                style: const pw.TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.red, width: 2),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Nature panne',
                          style: const pw.TextStyle(fontSize: 20)),
                      pw.Text(ticket['service_type'] ?? "",
                          style: const pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.red, width: 2),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Heure', style: const pw.TextStyle(fontSize: 20)),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('D\'arrivé',
                                  style: const pw.TextStyle(fontSize: 18)),
                              pw.Text(formatDate(ticket['accepting_date']),
                                  style: const pw.TextStyle(fontSize: 18)),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('De cloturage',
                                  style: const pw.TextStyle(fontSize: 18)),
                              pw.Text(formatDate(ticket['solving_time']),
                                  style: const pw.TextStyle(fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.red, width: 2),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Action envisagé',
                          style: const pw.TextStyle(fontSize: 20)),
                      pw.Text(ticket['solution'] ?? "",
                          style: const pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.red, width: 2),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Visa', style: const pw.TextStyle(fontSize: 20)),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Expanded(
                              child: pw.Container(
                                  height: 50,
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                          color: PdfColors.black, width: 2)))),
                          pw.SizedBox(width: 10),
                          pw.Expanded(
                              child: pw.Container(
                                  height: 50,
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                          color: PdfColors.black, width: 2)))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final fileName = 'ticket_${ticket['reference']}.pdf';
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/$fileName';

      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      // Open file in external application (platform-specific)
      if (Platform.isAndroid || Platform.isIOS) {
        await OpenFile.open(filePath);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ticket Details',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: const Color.fromRGBO(209, 77, 90, 1),
        toolbarHeight: 60,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket Number: ${ticket['reference'] ?? "Non rempli"}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Status: ${ticket['status'] ?? "Non rempli"}'),
            Text(
                'Service Station: ${ticket['service_station'] ?? "Non rempli"}'),
            Text(
                'Client: ${ticket['client'] != null && ticket['client']['client'] != null ? ticket['client']['client'] : "Non rempli"}'),
            Text(
                'Equipement S/N: ${ticket['equipement'] != null && ticket['equipement']['equipement_sn'] != null ? ticket['equipement']['equipement_sn'] : "Non rempli"}'),
            Text('Service Type: ${ticket['service_type'] ?? "Non rempli"}'),
            Text('Type: ${ticket['type'] ?? "Non rempli"}'),
            Text(
                'Client: ${ticket['contact'] != null && ticket['contact']['name'] != null ? ticket['contact']['name'] : "Non rempli"}'),
            Text('Call Time: ${formatDate(ticket['call_time'])}'),
            Text('Receiving time: ${formatDate(ticket['created_at'])}'),
            Text('Accepting time: ${formatDate(ticket['accepting_time'])}'),
            Text('Starting time: ${formatDate(ticket['starting_time'])}'),
            Text('Solving time: ${formatDate(ticket['solving_time'])}'),
            Text('Completion time: ${formatDate(ticket['completion_time'])}'),
            const SizedBox(height: 16), // Add some spacing below the last text
            if (isApproved) // Conditionally display the button if status is 'approved'
              ElevatedButton(
                onPressed: downloadPdf,
                child: const Text('Download Fiche Intervention'),
              ),
          ],
        ),
      ),
    );
  }
}
