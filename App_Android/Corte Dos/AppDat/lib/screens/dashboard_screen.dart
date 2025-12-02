import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/despacho.dart';
import '../models/dashboard_metrics.dart';
import '../widgets/charts/bar_chart_widget.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/charts/pie_chart_widget.dart';
import '../widgets/filters_panel.dart';
import '../widgets/csv_upload_widget.dart';
import 'simulation_screen.dart';
import '../providers/auth_provider.dart';
import '../constants/app_constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Despacho> _despachos = [];
  DashboardMetrics? _metrics;
  bool _loading = true;
  bool _refreshing = false;
  String? _selectedCliente;
  String? _selectedCiudad;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        if (!_refreshing) _loading = true;
      });

      final [despachos, metrics] = await Future.wait([
        _apiService.getDespachos(
          cliente: _selectedCliente,
          ciudad: _selectedCiudad,
          fechaInicio: _fechaInicio,
          fechaFin: _fechaFin,
        ),
        _apiService.getDashboardMetrics(
          cliente: _selectedCliente,
          ciudad: _selectedCiudad,
          fechaInicio: _fechaInicio,
          fechaFin: _fechaFin,
        ),
      ]);

      setState(() {
        _despachos = despachos as List<Despacho>;
        _metrics = metrics as DashboardMetrics?;
        _loading = false;
        _refreshing = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _refreshing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _refreshing = true;
    });
    await _loadData();
  }

  void _onFiltersChanged({
    String? cliente,
    String? ciudad,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) {
    setState(() {
      _selectedCliente = cliente;
      _selectedCiudad = ciudad;
      _fechaInicio = fechaInicio;
      _fechaFin = fechaFin;
    });
    _loadData();
  }



  List<Map<String, dynamic>> _prepareBarChartData() {
    final clientData = <String, int>{};
    for (var d in _despachos) {
      clientData[d.cliente] = (clientData[d.cliente] ?? 0) + d.cajas;
    }
    return clientData.entries
        .map((e) => {'label': e.key, 'value': e.value})
        .toList()
      ..sort((a, b) => (b['value'] as int).compareTo(a['value'] as int))
      ..take(10);
  }

  List<Map<String, dynamic>> _prepareCostBarChartData() {
    final clientData = <String, double>{};
    for (var d in _despachos) {
      clientData[d.cliente] = (clientData[d.cliente] ?? 0) + d.costo;
    }
    return clientData.entries
        .map((e) => {'label': e.key, 'value': e.value})
        .toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double))
      ..take(10);
  }

  List<Map<String, dynamic>> _prepareVolumeBarChartData() {
    final clientData = <String, double>{};
    for (var d in _despachos) {
      clientData[d.cliente] = (clientData[d.cliente] ?? 0) + d.volumen;
    }
    return clientData.entries
        .map((e) => {'label': e.key, 'value': e.value})
        .toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double))
      ..take(10);
  }

  List<Map<String, dynamic>> _prepareWeightBarChartData() {
    final clientData = <String, double>{};
    for (var d in _despachos) {
      clientData[d.cliente] = (clientData[d.cliente] ?? 0) + d.peso;
    }
    return clientData.entries
        .map((e) => {'label': e.key, 'value': e.value})
        .toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double))
      ..take(10);
  }

  List<Map<String, dynamic>> _preparePieChartData() {
    final cityData = <String, double>{};
    for (var d in _despachos) {
      cityData[d.ciudad] = (cityData[d.ciudad] ?? 0) + d.volumen;
    }
    return cityData.entries
        .map((e) => {'name': e.key, 'value': e.value})
        .toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double))
      ..take(8);
  }

  List<Map<String, dynamic>> _prepareCostPieChartData() {
    final clientData = <String, double>{};
    for (var d in _despachos) {
      clientData[d.cliente] = (clientData[d.cliente] ?? 0) + d.costo;
    }
    
    final total = clientData.values.fold<double>(0, (sum, value) => sum + value);
    
    return clientData.entries
        .map((e) => {
              'name': e.key,
              'value': e.value,
              'percentage': total > 0 ? (e.value / total) * 100 : 0.0
            })
        .toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double))
      ..take(10);
  }

  List<Map<String, dynamic>> _prepareVolumePieChartData() {
    final clientData = <String, double>{};
    for (var d in _despachos) {
      clientData[d.cliente] = (clientData[d.cliente] ?? 0) + d.volumen;
    }
    
    final total = clientData.values.fold<double>(0, (sum, value) => sum + value);
    
    return clientData.entries
        .map((e) => {
              'name': e.key,
              'value': e.value,
              'percentage': total > 0 ? (e.value / total) * 100 : 0.0
            })
        .toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double))
      ..take(10);
  }

  List<Map<String, dynamic>> _prepareWeightPieChartData() {
    final clientData = <String, double>{};
    for (var d in _despachos) {
      clientData[d.cliente] = (clientData[d.cliente] ?? 0) + d.peso;
    }
    
    final total = clientData.values.fold<double>(0, (sum, value) => sum + value);
    
    return clientData.entries
        .map((e) => {
              'name': e.key,
              'value': e.value,
              'percentage': total > 0 ? (e.value / total) * 100 : 0.0
            })
        .toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double))
      ..take(10);
  }

  List<Map<String, dynamic>> _prepareBoxesPieChartData() {
    final clientData = <String, int>{};
    for (var d in _despachos) {
      clientData[d.cliente] = (clientData[d.cliente] ?? 0) + d.cajas;
    }
    
    final total = clientData.values.fold<int>(0, (sum, value) => sum + value);
    
    return clientData.entries
        .map((e) => {
              'name': e.key,
              'value': e.value,
              'percentage': total > 0 ? (e.value / total) * 100 : 0.0
            })
        .toList()
      ..sort((a, b) => (b['value'] as int).compareTo(a['value'] as int))
      ..take(10);
  }

  Widget _buildClientSummary() {
    final clientData = <String, Map<String, dynamic>>{};
    
    for (var d in _despachos) {
      if (!clientData.containsKey(d.cliente)) {
        clientData[d.cliente] = {
          'cajas': 0,
          'peso': 0.0,
          'costo': 0.0,
          'volumen': 0.0,
          'count': 0,
        };
      }
      
      clientData[d.cliente]!['cajas'] += d.cajas;
      clientData[d.cliente]!['peso'] += d.peso;
      clientData[d.cliente]!['costo'] += d.costo;
      clientData[d.cliente]!['volumen'] += d.volumen;
      clientData[d.cliente]!['count'] += 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: clientData.entries.map((entry) {
            final cliente = entry.key;
            final data = entry.value;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${data['count']} despachos',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Cajas: ${data['cajas']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        "Costo: \$${NumberFormat('#,###').format(data['costo'])}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Peso: ${data['peso'].toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final greeting = user != null ? 'Hola ${user.username}' : 'Dashboard';

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(greeting)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final clients = AppConstants.clientesOficiales;
    final cities = AppConstants.ciudadesColombia;

    return Scaffold(
      appBar: AppBar(
        title: Text(greeting),
        actions: [
          if (user != null && AppConstants.esAdmin(user.role))
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Borrar todos los datos',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('¿Borrar todos los datos?'),
                    content: const Text(
                      'Esta acción eliminará todos los despachos y reiniciará los gráficos. '
                      'No se puede deshacer.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Borrar Todo'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    await _apiService.clearAllData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Datos eliminados correctamente')),
                      );
                      _onRefresh();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FiltersPanel(
                clients: clients,
                cities: cities,
                onFiltersChanged: _onFiltersChanged,
                selectedCliente: _selectedCliente,
                selectedCiudad: _selectedCiudad,
                fechaInicio: _fechaInicio,
                fechaFin: _fechaFin,
              ),
              

              
              if (_metrics != null) _buildMetricsSection(),
              if (_despachos.isNotEmpty) ...[
                // Gráficos de barras
                BarChartWidget(
                  data: _prepareBarChartData(),
                  title: 'Cajas por Cliente',
                ),
                BarChartWidget(
                  data: _prepareCostBarChartData(),
                  title: 'Costo Total por Cliente (\$)',
                ),
                BarChartWidget(
                  data: _prepareVolumeBarChartData(),
                  title: 'Volumen Total por Cliente (m³)',
                ),
                BarChartWidget(
                  data: _prepareWeightBarChartData(),
                  title: 'Peso Total por Cliente (kg)',
                ),
                // Gráficos circulares con porcentajes
                PieChartWidget(
                  data: _preparePieChartData(),
                  title: 'Volumen por Ciudad',
                ),
                PieChartWidget(
                  data: _prepareCostPieChartData(),
                  title: 'Distribución de Costo por Cliente (%)',
                ),
                PieChartWidget(
                  data: _prepareVolumePieChartData(),
                  title: 'Distribución de Volumen por Cliente (%)',
                ),
                PieChartWidget(
                  data: _prepareWeightPieChartData(),
                  title: 'Distribución de Peso por Cliente (%)',
                ),
                PieChartWidget(
                  data: _prepareBoxesPieChartData(),
                  title: 'Distribución de Cajas por Cliente (%)',
                ),
              ],
              if (_despachos.isEmpty && !_loading)
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No hay datos disponibles para los filtros seleccionados',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              // Widget de carga de archivos CSV
              CsvUploadWidget(
                apiService: _apiService,
                onUploadComplete: _loadData,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: (user != null && AppConstants.puedeCrearEnvios(user.role))
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SimulationScreen(
                      onShipmentCreated: _onRefresh,
                    ),
                  ),
                );
                _onRefresh();
              },
              child: const Icon(Icons.add_shopping_cart),
              tooltip: 'Simular Envío',
            )
          : null,
    );
  }

  Widget _buildMetricsSection() {
    if (_metrics == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas Generales',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetricCard(
                'Total Cajas',
                _metrics!.totalCajas.toString(),
                Icons.inventory_2,
              ),
              _buildMetricCard(
                'Total Peso (kg)',
                _metrics!.totalPeso.toStringAsFixed(0),
                Icons.scale,
              ),
              _buildMetricCard(
                'Total Costo',
                '\$${_metrics!.totalCosto.toStringAsFixed(0)}',
                Icons.attach_money,
              ),
              _buildMetricCard(
                'Total Volumen',
                _metrics!.totalVolumen.toStringAsFixed(0),
                Icons.crop_free,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 40) / 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
