import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'models.dart';
import 'dart:typed_data';

// Importar dart:html solo para web usando importación condicional
import 'pdf_web_helper.dart' if (dart.library.io) 'pdf_mobile_helper.dart';

/// Servicio para generar y guardar PDFs de preavisos
class PdfService {
  /// Genera un PDF con los datos del preaviso y lo guarda
  /// Retorna la ruta del archivo generado (móvil) o descarga automáticamente (web)
  Future<String> generatePreaviso(Preaviso preaviso, String numeroMedidor) async {
    final pdf = pw.Document();

    // Agregar página con el contenido del preaviso
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado centrado
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 2),
                        ),
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          'EMPRESA ELÉCTRICA',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'PREAVISO DE CONSUMO',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 30),
                
                // Información del cliente
                pw.Text(
                  'DATOS DEL CLIENTE',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 10),
                
                _buildInfoRow('Preaviso:', preaviso.codCliente),
                _buildInfoRow('Nombre de cliente:', preaviso.nombreCliente),
                _buildInfoRow('Categoría:', preaviso.categoria),
                _buildInfoRow('Número de medidor:', numeroMedidor),
                
                pw.SizedBox(height: 20),
                
                // Detalle de consumo
                pw.Text(
                  'DETALLE DE CONSUMO',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 10),
                
                _buildInfoRow('Lectura Anterior:', preaviso.lecturaAnterior + ' kWh'),
                _buildInfoRow('Lectura Actual:', preaviso.lecturaActual + ' kWh'),
                _buildInfoRow('Consumo:', preaviso.consumo + ' kWh'),
                
                pw.SizedBox(height: 20),
                
                // Monto a pagar destacado
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 2),
                    color: PdfColors.grey300,
                  ),
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'MONTO A PAGAR:',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'S/. ${preaviso.montoAPagar}',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Información adicional
                _buildInfoRow('Periodo:', preaviso.periodo),
                _buildInfoRow('Fecha de Vencimiento:', preaviso.fechaVencimiento),
                
                pw.SizedBox(height: 20),
                
                // Mensaje
                if (preaviso.mensaje.isNotEmpty)
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child: pw.Text(
                      preaviso.mensaje,
                      style: const pw.TextStyle(fontSize: 11),
                      textAlign: pw.TextAlign.justify,
                    ),
                  ),
                
                pw.Spacer(),
                
                // Pie de página
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Divider(),
                      pw.Text(
                        'Gracias por su pago puntual',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Generado el: ${DateTime.now().toString().substring(0, 16)}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final String fileName = 'preaviso_${preaviso.codCliente}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final Uint8List bytes = await pdf.save();

    if (kIsWeb) {
      // En web: descargar automáticamente usando el helper
      downloadPdfWeb(bytes, fileName);
      return 'Descargado: $fileName';
    } else {
      // En móvil: guardar en almacenamiento
      return _savePdfMobile(bytes, fileName);
    }
  }

  /// Guarda el PDF en dispositivos móviles
  Future<String> _savePdfMobile(Uint8List bytes, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final File file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  /// Construye una fila de información
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 180,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Abre el archivo PDF generado (solo móvil)
  Future<void> openPdf(String filePath) async {
    if (!kIsWeb) {
      await OpenFilex.open(filePath);
    }
  }
}
