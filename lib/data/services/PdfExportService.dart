import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/alat_model.dart';
import '../models/company_model.dart';

class PdfExportService {
  static const String _appName = "HamaTech";

  /// Generate comprehensive PDF report
  static Future<void> generateCompanyReport({
    required CompanyModel company,
    required DateTime startDate,
    required DateTime endDate,
    required int totalAlat,
    required int totalPengecekan,
    required List<String> availablePestTypes,
    required Map<String, Map<String, List<FlSpot>>> pestTypeLayeredData,
    required Map<String, Map<String, Color>> pestTypeLabelColors,
    required List<AlatModel> tools,
    required Function(String) getLabelsByPestType,
  }) async {
    try {
      // Request permissions (simplified version)
      await _requestPermissions();

      // Create PDF document
      final pdf = pw.Document(
        title: 'Laporan HamaTech - ${company.name}',
        author: _appName,
        subject: 'Laporan Monitoring Pest Control',
      );

      // Load HamaTech logo
      final logoData = await _loadHamaTechLogo();
      final logo = logoData != null ? pw.MemoryImage(logoData) : null;

      // Load fonts
      final font = await PdfGoogleFonts.notoSansRegular();
      final fontBold = await PdfGoogleFonts.notoSansBold();

      // Format dates in Indonesian
      final startDateStr = _formatIndonesianDate(startDate);
      final endDateStr = _formatIndonesianDate(endDate);
      final reportDateStr = _formatIndonesianDate(DateTime.now());

      // Create PDF pages
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          theme: pw.ThemeData.withFont(
            base: font,
            bold: fontBold,
          ),
          header: (context) => _buildHeader(logo, company, startDateStr, endDateStr),
          footer: (context) => _buildFooter(context, reportDateStr),
          build: (context) => [
            // Summary Section
            _buildSummarySection(totalAlat, totalPengecekan, startDateStr, endDateStr),

            pw.SizedBox(height: 20),

            // Charts Section
            ..._buildChartsSection(
              availablePestTypes,
              pestTypeLayeredData,
              pestTypeLabelColors,
            ),

            pw.SizedBox(height: 20),

            // Tools Section
            _buildToolsSection(tools),
          ],
        ),
      );

      // Save and share PDF
      await _savePdf(pdf, company.name, startDate, endDate);

    } catch (e) {
      throw Exception('Gagal membuat laporan PDF: $e');
    }
  }

  /// Request necessary permissions (simplified version)
  static Future<void> _requestPermissions() async {
    // For now, we'll rely on the printing and share_plus packages
    // to handle permissions internally. If you need explicit permission
    // handling, add permission_handler package to pubspec.yaml

    /*
    // Uncomment this section if you add permission_handler package
    if (Platform.isAndroid) {
      try {
        final status = await Permission.storage.request();
        if (status != PermissionStatus.granted) {
          // For Android 11+, try manage external storage
          await Permission.manageExternalStorage.request();
        }
      } catch (e) {
        print('Permission request failed: $e');
      }
    }
    */

    // For now, just return successfully
    return;
  }

  /// Load HamaTech logo from assets
  static Future<Uint8List?> _loadHamaTechLogo() async {
    try {
      final ByteData data = await rootBundle.load('assets/icons/logo.png');
      return data.buffer.asUint8List();
    } catch (e) {
      print('Warning: Could not load HamaTech logo: $e');
      // Create a simple colored rectangle as fallback
      return await _createFallbackLogo();
    }
  }

  /// Create fallback logo
  static Future<Uint8List> _createFallbackLogo() async {
    final font = await PdfGoogleFonts.notoSansBold();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(100, 60),
        build: (pw.Context context) {
          return pw.Container(
            width: 100,
            height: 60,
            decoration: const pw.BoxDecoration(
              color: PdfColors.green700,
            ),
            child: pw.Center(
              child: pw.Text(
                'HamaTech',
                style: pw.TextStyle(
                  font: font,
                  color: PdfColors.white,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );

    return await pdf.save();
  }

  /// Build PDF header
  static pw.Widget _buildHeader(
      pw.ImageProvider? logo,
      CompanyModel company,
      String startDate,
      String endDate
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // HamaTech Logo
          if (logo != null)
            pw.Container(
              width: 80,
              height: 60,
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            )
          else
            pw.Container(
              width: 80,
              height: 60,
              decoration: const pw.BoxDecoration(
                color: PdfColors.green700,
              ),
              child: pw.Center(
                child: pw.Text(
                  'HT',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),

          pw.SizedBox(width: 20),

          // Title and Company Info
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LAPORAN MONITORING PEST CONTROL',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  company.name.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.orange700,
                  ),
                ),
                pw.Text(
                  company.address,
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Periode: $startDate - $endDate',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build PDF footer
  static pw.Widget _buildFooter(pw.Context context, String reportDate) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey400, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Dibuat oleh: $_appName - Sistem Monitoring Pest Control',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            'Halaman ${context.pageNumber} dari ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            'Dibuat pada: $reportDate',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  /// Build summary section
  static pw.Widget _buildSummarySection(
      int totalAlat,
      int totalPengecekan,
      String startDate,
      String endDate
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RINGKASAN LAPORAN',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green700,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildSummaryCard('Total Alat Terpasang', totalAlat.toString(), PdfColors.orange),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _buildSummaryCard('Total Pengecekan', totalPengecekan.toString(), PdfColors.green),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _buildSummaryCard('Periode Laporan', '$startDate\ns/d $endDate', PdfColors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build summary card
  static pw.Widget _buildSummaryCard(String title, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: color),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build charts section
  static List<pw.Widget> _buildChartsSection(
      List<String> availablePestTypes,
      Map<String, Map<String, List<FlSpot>>> pestTypeLayeredData,
      Map<String, Map<String, Color>> pestTypeLabelColors,
      ) {
    if (availablePestTypes.isEmpty) {
      return [
        pw.Container(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Center(
            child: pw.Text(
              'Tidak ada data chart untuk periode ini',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
            ),
          ),
        ),
      ];
    }

    List<pw.Widget> chartWidgets = [
      pw.Text(
        'DATA TANGKAPAN BERDASARKAN JENIS HAMA',
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.green700,
        ),
      ),
      pw.SizedBox(height: 15),
    ];

    for (String pestType in availablePestTypes) {
      chartWidgets.addAll([
        _buildChartSection(pestType, pestTypeLayeredData, pestTypeLabelColors),
        pw.SizedBox(height: 20),
      ]);
    }

    return chartWidgets;
  }

  /// Build individual chart section
  static pw.Widget _buildChartSection(
      String pestType,
      Map<String, Map<String, List<FlSpot>>> pestTypeLayeredData,
      Map<String, Map<String, Color>> pestTypeLabelColors,
      ) {
    final labelData = pestTypeLayeredData[pestType] ?? {};
    final labelColors = pestTypeLabelColors[pestType] ?? {};

    // Calculate totals for each label
    Map<String, int> labelTotals = {};
    int grandTotal = 0;

    labelData.forEach((label, spots) {
      if (spots.isNotEmpty && !(spots.length == 1 && spots.first.y == 0)) {
        int total = spots.map((e) => e.y.toInt()).reduce((a, b) => a + b);
        labelTotals[label] = total;
        grandTotal += total;
      } else {
        labelTotals[label] = 0;
      }
    });

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Chart Title
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                pestType.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange700,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange100,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(
                  'Total: $grandTotal',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.orange700,
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          // Data Table
          if (labelTotals.isNotEmpty) ...[
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: const {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Jenis/Label',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Total Tangkapan',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Persentase',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                // Data rows
                ...labelTotals.entries.map((entry) {
                  final percentage = grandTotal > 0 ? (entry.value / grandTotal * 100).toStringAsFixed(1) : '0.0';
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 12,
                              height: 12,
                              decoration: pw.BoxDecoration(
                                color: _convertColorToPdfColor(labelColors[entry.key]),
                                shape: pw.BoxShape.circle,
                              ),
                            ),
                            pw.SizedBox(width: 8),
                            pw.Text(
                              entry.key,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          entry.value.toString(),
                          style: const pw.TextStyle(fontSize: 10),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '$percentage%',
                          style: const pw.TextStyle(fontSize: 10),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ] else ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Center(
                child: pw.Text(
                  'Tidak ada data untuk $pestType',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build tools section
  static pw.Widget _buildToolsSection(List<AlatModel> tools) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DAFTAR ALAT MONITORING',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green700,
          ),
        ),
        pw.SizedBox(height: 15),

        if (tools.isEmpty) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Center(
              child: pw.Text(
                'Tidak ada alat yang terdaftar',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
              ),
            ),
          ),
        ] else ...[
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: const {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(1.5),
              4: pw.FlexColumnWidth(1),
              5: pw.FlexColumnWidth(1),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  'No',
                  'Nama Alat',
                  'Lokasi',
                  'Detail Lokasi',
                  'Jenis Hama',
                  'Status',
                ].map((header) => pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    header,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                )).toList(),
              ),
              // Data rows
              ...tools.asMap().entries.map((entry) {
                final index = entry.key;
                final tool = entry.value;

                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        '${index + 1}',
                        style: const pw.TextStyle(fontSize: 9),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        tool.namaAlat,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        tool.lokasi,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        tool.detailLokasi,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        tool.pestType,
                        style: const pw.TextStyle(fontSize: 9),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: pw.BoxDecoration(
                          color: _getStatusColor(tool.kondisi),
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Text(
                          _getStatusText(tool.kondisi),
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.white),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ],
    );
  }

  /// Helper methods
  static String _formatIndonesianDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  static PdfColor _convertColorToPdfColor(Color? color) {
    if (color == null) return PdfColors.grey;

    return PdfColor(
      color.red / 255.0,
      color.green / 255.0,
      color.blue / 255.0,
    );
  }

  static PdfColor _getStatusColor(String kondisi) {
    String normalized = kondisi.trim().toLowerCase();
    if (normalized == 'good' || normalized == 'baik') {
      return PdfColors.green;
    } else if (normalized == 'broken' || normalized == 'rusak') {
      return PdfColors.red;
    } else if (normalized == 'maintenance') {
      return PdfColors.orange;
    }
    return PdfColors.grey;
  }

  static String _getStatusText(String kondisi) {
    String normalized = kondisi.trim().toLowerCase();
    if (normalized == 'good' || normalized == 'baik') {
      return 'Aktif';
    } else if (normalized == 'broken' || normalized == 'rusak') {
      return 'Rusak';
    } else if (normalized == 'maintenance') {
      return 'Maintenance';
    }
    return 'Unknown';
  }

  /// Save and share PDF
  static Future<void> _savePdf(pw.Document pdf, String companyName, DateTime startDate, DateTime endDate) async {
    try {
      // Generate filename
      final monthYear = DateFormat('MMMyyyy').format(startDate);
      final filename = 'HamaTech_Report_${companyName.replaceAll(' ', '_')}_$monthYear.pdf';

      final bytes = await pdf.save();

      if (Platform.isAndroid || Platform.isIOS) {
        // For mobile platforms, use share
        await Printing.sharePdf(
          bytes: bytes,
          filename: filename,
        );
      } else {
        // For desktop/web, save to downloads
        try {
          final directory = await getDownloadsDirectory();
          if (directory != null) {
            final file = File('${directory.path}/$filename');
            await file.writeAsBytes(bytes);

          } else {
            // Fallback to share if no downloads directory
            await Printing.sharePdf(bytes: bytes, filename: filename);
          }
        } catch (e) {
          // If file operations fail, just use printing share
          await Printing.sharePdf(bytes: bytes, filename: filename);
        }
      }
    } catch (e) {
      throw Exception('Gagal menyimpan PDF: $e');
    }
  }

  /// Alternative method for custom save location
  static Future<void> saveToCustomLocation(pw.Document pdf, String filename) async {
    try {
      final bytes = await pdf.save();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
      );
    } catch (e) {
      throw Exception('Gagal membuka PDF: $e');
    }
  }

  /// Preview PDF before sharing
  static Future<void> previewPdf({
    required CompanyModel company,
    required DateTime startDate,
    required DateTime endDate,
    required int totalAlat,
    required int totalPengecekan,
    required List<String> availablePestTypes,
    required Map<String, Map<String, List<FlSpot>>> pestTypeLayeredData,
    required Map<String, Map<String, Color>> pestTypeLabelColors,
    required List<AlatModel> tools,
    required Function(String) getLabelsByPestType,
  }) async {
    try {
      // Create PDF document
      final pdf = pw.Document(
        title: 'Laporan HamaTech - ${company.name}',
        author: _appName,
        subject: 'Laporan Monitoring Pest Control',
      );

      // Load HamaTech logo
      final logoData = await _loadHamaTechLogo();
      final logo = logoData != null ? pw.MemoryImage(logoData) : null;

      // Load fonts
      final font = await PdfGoogleFonts.notoSansRegular();
      final fontBold = await PdfGoogleFonts.notoSansBold();

      // Format dates in Indonesian
      final startDateStr = _formatIndonesianDate(startDate);
      final endDateStr = _formatIndonesianDate(endDate);
      final reportDateStr = _formatIndonesianDate(DateTime.now());

      // Create PDF pages
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          theme: pw.ThemeData.withFont(
            base: font,
            bold: fontBold,
          ),
          header: (context) => _buildHeader(logo, company, startDateStr, endDateStr),
          footer: (context) => _buildFooter(context, reportDateStr),
          build: (context) => [
            // Summary Section
            _buildSummarySection(totalAlat, totalPengecekan, startDateStr, endDateStr),

            pw.SizedBox(height: 20),

            // Charts Section
            ..._buildChartsSection(
              availablePestTypes,
              pestTypeLayeredData,
              pestTypeLabelColors,
            ),

            pw.SizedBox(height: 20),

            // Tools Section
            _buildToolsSection(tools),
          ],
        ),
      );

      // Preview PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Preview - Laporan HamaTech ${company.name}',
      );

    } catch (e) {
      throw Exception('Gagal membuat preview PDF: $e');
    }
  }
}