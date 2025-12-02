import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/despacho.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../constants/app_constants.dart';

class SimulationScreen extends StatefulWidget {
  final VoidCallback? onShipmentCreated;

  const SimulationScreen({
    super.key,
    this.onShipmentCreated,
  });

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  
  String? _selectedCliente;
  String? _selectedCiudad;
  int _cajas = 1;
  double _peso = 0.0;
  double _volumen = 0.0;
  double _costo = 0.0;
  DateTime _fechaEnvio = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    
    // Verificar permisos
    if (user == null || !AppConstants.puedeCrearEnvios(user.role)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Simulación de Envíos')),
        body: const Center(child: Text('No tienes permisos para acceder a esta función')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulación de Envíos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nuevo Envío Simulado',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.esAdmin(user.role) 
                            ? Colors.green.shade100 
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppConstants.esAdmin(user.role) ? 'Admin' : 'Analista',
                        style: TextStyle(
                          color: AppConstants.esAdmin(user.role) 
                              ? Colors.green.shade800 
                              : Colors.blue.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Selección de Cliente
                      DropdownButtonFormField<String>(
                        value: _selectedCliente,
                        decoration: const InputDecoration(
                          labelText: 'Cliente',
                          prefixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(),
                        ),
                        items: AppConstants.clientesOficiales.map((cliente) {
                          return DropdownMenuItem<String>(
                            value: cliente,
                            child: Text(cliente),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Seleccione un cliente';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedCliente = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Selección de Ciudad
                      DropdownButtonFormField<String>(
                        value: _selectedCiudad,
                        decoration: const InputDecoration(
                          labelText: 'Ciudad de Destino',
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(),
                        ),
                        items: AppConstants.ciudadesColombia.map((ciudad) {
                          return DropdownMenuItem<String>(
                            value: ciudad,
                            child: Text(ciudad),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Seleccione una ciudad';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedCiudad = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Número de Cajas
                      TextFormField(
                        initialValue: _cajas.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Número de Cajas',
                          prefixIcon: Icon(Icons.inventory_2),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el número de cajas';
                          }
                          if (int.tryParse(value) == null || int.parse(value) <= 0) {
                            return 'Ingrese un número válido';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _cajas = int.tryParse(value) ?? 1;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Peso
                      TextFormField(
                        initialValue: _peso.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Peso (kg)',
                          prefixIcon: Icon(Icons.scale),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el peso';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Ingrese un peso válido';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _peso = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Volumen
                      TextFormField(
                        initialValue: _volumen.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Volumen (m³)',
                          prefixIcon: Icon(Icons.crop_free),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el volumen';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Ingrese un volumen válido';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _volumen = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Costo
                      TextFormField(
                        initialValue: _costo.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Costo (\$)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el costo';
                          }
                          if (double.tryParse(value) == null || double.parse(value) < 0) {
                            return 'Ingrese un costo válido';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _costo = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Fecha de Envío
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha de Envío',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_fechaEnvio),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Botón de Crear Envío
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _createShipment,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Crear Envío Simulado'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaEnvio,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _fechaEnvio) {
      setState(() {
        _fechaEnvio = picked;
      });
    }
  }

  Future<void> _createShipment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCliente == null || _selectedCiudad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) return;

      // Crear el despacho simulado
      final despacho = Despacho(
        id: 'sim_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.id,
        cliente: _selectedCliente!,
        ciudad: _selectedCiudad!,
        fecha: _fechaEnvio,
        cajas: _cajas,
        peso: _peso,
        costo: _costo,
        volumen: _volumen,
        mes: DateFormat('MMMM', 'es').format(_fechaEnvio),
        dia: _fechaEnvio.day,
      );

      // Guardar en la base de datos
      await _apiService.insertSimulatedDespacho(despacho);

      // Mostrar éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Envío simulado creado exitosamente para $_selectedCliente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Limpiar formulario
        _resetForm();
        
        // Notificar al padre y cerrar
        widget.onShipmentCreated?.call();
        // Navigator.pop(context); // Optional: close screen after creation? 
        // User might want to create multiple, so let's keep it open.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el envío: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedCliente = null;
      _selectedCiudad = null;
      _cajas = 1;
      _peso = 0.0;
      _volumen = 0.0;
      _costo = 0.0;
      _fechaEnvio = DateTime.now();
    });
  }
}
