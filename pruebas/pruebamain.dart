import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Home ESP32',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark, // Tema oscuro estilo "Cyberpunk/IoT"
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ==========================================
  // ⚠️ IMPORTANTE: PON LA IP DE TU ESP32 AQUÍ
  // ==========================================
  final String esp32Ip = "192.168.100.62"; 
  // ==========================================

  // Variables de Estado
  double _temperatura = 0.0;
  double _umbral = 30.0;
  bool _puertaAbierta = false;
  
  // Estado de las 6 habitaciones
  List<bool> _habitaciones = [false, false, false, false, false, false];
  
  // Nombres para tus 6 LEDs
  final List<String> _nombresHabitaciones = [
    "Sala", "Cocina", "Comedor", 
    "Baño", "Dormitorio 1", "Dormitorio 2"
  ];

  bool _isLoading = false;
  bool _isFirstLoad = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchStatus(background: false);
    
    // Polling: Refresca datos cada 2 segundos
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isLoading) _fetchStatus(background: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- 1. OBTENER ESTADO GLOBAL (GET /status) ---
  Future<void> _fetchStatus({bool background = true}) async {
    if (!background && mounted) setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://$esp32Ip/status');
      final response = await http.get(url).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        
        setState(() {
          _temperatura = (data['temperatura'] as num).toDouble();
          _puertaAbierta = data['puerta_abierta']; // true/false desde el JSON
          
          // Solo actualizamos el umbral si es carga de fondo para no interrumpir el slider
          if (background) {
             // Opcional: sincronizar slider si cambia remotamente
             // _umbral = (data['umbral'] as num).toDouble(); 
          } else {
             _umbral = (data['umbral'] as num).toDouble();
          }

          // Actualizar interruptores
          List<dynamic> habsJson = data['habitaciones'];
          _habitaciones = habsJson.map((e) => e == 1).toList();
          
          _isLoading = false;
          _isFirstLoad = false;
        });
      }
    } catch (e) {
      if (!background && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
         setState(() => _isLoading = false);
      }
    }
  }

  // --- 2. CAMBIAR UMBRAL (GET /set_umbral) ---
  Future<void> _setUmbral(double val) async {
    try {
      await http.get(Uri.parse('http://$esp32Ip/set_umbral?val=${val.toStringAsFixed(1)}'));
    } catch (e) {
      print(e);
    }
  }

  // --- 3. ABRIR PUERTA MANUALMENTE (GET /toggle_puerta) ---
  Future<void> _abrirPuertaManual() async {
    // Feedback inmediato visual
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enviando orden de apertura..."), duration: Duration(milliseconds: 800)),
    );
    
    try {
      await http.get(Uri.parse('http://$esp32Ip/toggle_puerta'));
      // Refrescar inmediatamente para ver el cambio de icono
      await _fetchStatus(background: true);
    } catch (e) {
      print(e);
    }
  }

  // --- 4. CONTROLAR LUCES (GET /control_hab) ---
  Future<void> _toggleHabitacion(int index, bool value) async {
    // Cambio optimista en UI
    setState(() {
      _habitaciones[index] = value;
    });

    try {
      final stateInt = value ? 1 : 0;
      final url = Uri.parse('http://$esp32Ip/control_hab?id=$index&state=$stateInt');
      await http.get(url);
    } catch (e) {
      print(e);
      // Si falla, revertir visualmente en el próximo refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lógica de color para la tarjeta de temperatura (Replica lógica de Arduino)
    Color tempCardColor = const Color(0xFF2C2C2C); // Normal
    Color tempTextColor = Colors.greenAccent;
    String tempStatusText = "Normal";

    if (_temperatura >= _umbral) {
      // Alarma Activa
      tempCardColor = Colors.red.withOpacity(0.2);
      tempTextColor = Colors.redAccent;
      tempStatusText = "¡ALARMA DE CALOR!";
    } else if (_temperatura >= (_umbral - 2.0)) {
      // Preventiva
      tempCardColor = Colors.orange.withOpacity(0.2);
      tempTextColor = Colors.orangeAccent;
      tempStatusText = "Precaución";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Casa Domótica'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (_isLoading && !_isFirstLoad)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width:15, height:15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            )
        ],
      ),
      body: _isFirstLoad 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // === SECCIÓN 1: CLIMATIZACIÓN ===
                  Text("CLIMATIZACIÓN", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: tempCardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (_temperatura >= _umbral) ? Colors.red : Colors.transparent,
                        width: 2
                      )
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.thermostat, size: 40, color: tempTextColor),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("${_temperatura.toStringAsFixed(1)}°C", 
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                Text(tempStatusText,
                                  style: TextStyle(color: tempTextColor, fontWeight: FontWeight.bold),
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Umbral Alarma:"),
                            Text("${_umbral.toStringAsFixed(1)}°C", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Slider(
                          value: _umbral,
                          min: 20.0, 
                          max: 40.0,
                          activeColor: tempTextColor,
                          onChanged: (v) => setState(() => _umbral = v),
                          onChangeEnd: (v) => _setUmbral(v),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // === SECCIÓN 2: PUERTA PRINCIPAL (BOTÓN INTERACTIVO) ===
                  Text("ENTRADA PRINCIPAL", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 10),
                  
                  // InkWell hace que el contenedor sea "tocable" con efecto visual
                  InkWell(
                    onTap: _puertaAbierta ? null : _abrirPuertaManual, // Solo permite abrir si está cerrada
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      decoration: BoxDecoration(
                        color: _puertaAbierta 
                            ? Colors.green.withOpacity(0.2) 
                            : const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10)
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _puertaAbierta ? Colors.green : Colors.blueGrey,
                              shape: BoxShape.circle
                            ),
                            child: Icon(
                              _puertaAbierta ? Icons.door_sliding_outlined : Icons.door_front_door, 
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_puertaAbierta ? "PUERTA ABIERTA" : "PUERTA CERRADA",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 16,
                                    color: _puertaAbierta ? Colors.greenAccent : Colors.white
                                  )),
                                Text(_puertaAbierta 
                                    ? "Cerrando automáticamente..." 
                                    : "Toca aquí para abrir manualmente",
                                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          if (!_puertaAbierta)
                             const Icon(Icons.touch_app, color: Colors.grey)
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // === SECCIÓN 3: LUCES HABITACIONES ===
                  Text("LUCES DE HABITACIONES", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      bool isOn = _habitaciones[index];
                      return Material(
                        color: isOn ? Colors.indigo.withOpacity(0.3) : const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(15),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () => _toggleHabitacion(index, !isOn),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.lightbulb, 
                                  color: isOn ? Colors.yellowAccent : Colors.grey[700], size: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_nombresHabitaciones[index], 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Switch(
                                        value: isOn,
                                        activeColor: Colors.yellowAccent,
                                        activeTrackColor: Colors.indigo,
                                        onChanged: (val) => _toggleHabitacion(index, val),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}