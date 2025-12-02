import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/api_service.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final ApiService _apiService = ApiService();
  bool _uploading = false;
  bool _loading = true;
  bool _refreshing = false;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        if (!_refreshing) _loading = true;
      });

      final history = await _apiService.getUploadHistory();
      setState(() {
        _history = history;
        _loading = false;
        _refreshing = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _refreshing = false;
      });
    }
  }

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;
        await _uploadFile(file.bytes!, file.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar archivo: $e')),
        );
      }
    }
  }

  Future<void> _uploadFile(Uint8List bytes, String filename) async {
    try {
      setState(() {
        _uploading = true;
      });

      final response = await _apiService.uploadFile(bytes, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['success'] == true
                  ? 'Archivo cargado correctamente. ${response['recordsCount']} registros procesados.'
                  : response['message'] ?? 'Error al procesar el archivo',
            ),
            backgroundColor: response['success'] == true
                ? Colors.green
                : Colors.red,
          ),
        );
      }

      if (response['success'] == true) {
        _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar archivo: $e')),
        );
      }
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'processing':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'success':
        return 'Completado';
      case 'error':
        return 'Error';
      case 'processing':
        return 'Procesando';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargar Datos')),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cargar Archivo de Despachos',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selecciona un archivo CSV con los datos de despachos para cargarlos al sistema',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _uploading ? null : _pickAndUploadFile,
                        icon: _uploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload),
                        label: Text(_uploading ? 'Cargando...' : 'Seleccionar Archivo'),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historial de Cargas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (_loading && !_refreshing)
                      const Center(child: CircularProgressIndicator())
                    else if (_history.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No hay historial de cargas',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      ..._history.map((item) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(item['filename'] ?? ''),
                              subtitle: Text(
                                DateTime.parse(item['uploadDate'])
                                    .toString()
                                    .substring(0, 19),
                              ),
                              trailing: Chip(
                                label: Text(_getStatusLabel(item['status'] ?? '')),
                                backgroundColor: _getStatusColor(item['status'] ?? '')
                                    .withValues(alpha: 0.2),
                                labelStyle: TextStyle(
                                  color: _getStatusColor(item['status'] ?? ''),
                                ),
                              ),
                              leading: Icon(
                                Icons.description,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

