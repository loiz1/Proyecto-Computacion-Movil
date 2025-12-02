import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class FiltersPanel extends StatefulWidget {
  final List<String> clients;
  final List<String> cities;
  final Function({
    String? cliente,
    String? ciudad,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) onFiltersChanged;
  final String? selectedCliente;
  final String? selectedCiudad;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const FiltersPanel({
    super.key,
    required this.clients,
    required this.cities,
    required this.onFiltersChanged,
    this.selectedCliente,
    this.selectedCiudad,
    this.fechaInicio,
    this.fechaFin,
  });

  @override
  State<FiltersPanel> createState() => _FiltersPanelState();
}

class _FiltersPanelState extends State<FiltersPanel> {
  String? _selectedCliente;
  String? _selectedCiudad;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _selectedCliente = widget.selectedCliente;
    _selectedCiudad = widget.selectedCiudad;
    _fechaInicio = widget.fechaInicio;
    _fechaFin = widget.fechaFin;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_fechaInicio ?? DateTime.now()) : (_fechaFin ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  void _applyFilters() {
    widget.onFiltersChanged(
      cliente: _selectedCliente,
      ciudad: _selectedCiudad,
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCliente = null;
      _selectedCiudad = null;
      _fechaInicio = null;
      _fechaFin = null;
    });
    widget.onFiltersChanged(
      cliente: null,
      ciudad: null,
      fechaInicio: null,
      fechaFin: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ExpansionTile(
        title: const Text('Filtros'),
        initiallyExpanded: _expanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _expanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedCliente,
                  decoration: const InputDecoration(
                    labelText: 'Cliente',
                    prefixIcon: Icon(Icons.business),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    ...AppConstants.clientesOficiales.map((client) => DropdownMenuItem(
                          value: client,
                          child: Text(client),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCliente = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCiudad,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todas'),
                    ),
                    ...widget.cities.map((city) => DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCiudad = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha Inicio',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _fechaInicio != null
                                ? DateFormat('yyyy-MM-dd').format(_fechaInicio!)
                                : 'Seleccionar',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha Fin',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _fechaFin != null
                                ? DateFormat('yyyy-MM-dd').format(_fechaFin!)
                                : 'Seleccionar',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearFilters,
                        child: const Text('Limpiar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

