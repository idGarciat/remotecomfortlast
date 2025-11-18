import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Modelo simple de evento local
class _Event {
  final String message;
  final DateTime time;
  _Event(this.message, this.time);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Config: intenta leer la IP desde .env, si no existe usa un fallback
  final String esp32Ip = dotenv.env['ESP32_IP'] ?? '192.168.100.62';

  double _temperatura = 0.0;
  double _umbral = 30.0;
  bool _puertaAbierta = false;
  // Usamos 4 habitaciones: Sala, Cocina, Comedor, Baño
  final List<bool> _habitaciones = [false, false, false, false];
  final List<String> _nombresHabitaciones = ['Sala', 'Habitacion 1', 'Habitacion 2', 'Baño'];

  // Eventos recientes (más nuevo primero)
  final List<_Event> _events = [];

  bool _isLoading = false;
  bool _isFirstLoad = true;
  bool _puertaLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchStatus(background: false);
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isLoading) _fetchStatus(background: true);
    });
  }

  // --- Abrir puerta manualmente (/toggle_puerta) con bloqueo y feedback ---
  Future<void> _abrirPuertaManual() async {
    if (_puertaLoading) return;
    setState(() => _puertaLoading = true);

    // Capture messenger before awaiting network calls to avoid using context after async gaps
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Enviando orden de apertura...'), duration: Duration(milliseconds: 800)));

    try {
      final url = Uri.parse('http://$esp32Ip/toggle_puerta');
      final resp = await http.get(url).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        await _fetchStatus(background: true);
        _events.insert(0, _Event('Puerta abierta manualmente', DateTime.now()));
        if (_events.length > 100) _events.removeLast();
      } else {
        if (mounted) messenger.showSnackBar(SnackBar(content: Text('Error al abrir puerta (${resp.statusCode})')));
        _events.insert(0, _Event('Error al abrir puerta', DateTime.now()));
        if (_events.length > 100) _events.removeLast();
      }
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text('Error al abrir puerta: $e')));
      _events.insert(0, _Event('Error al abrir puerta', DateTime.now()));
      if (_events.length > 100) _events.removeLast();
    } finally {
      if (mounted) setState(() => _puertaLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus({bool background = true}) async {
    // Capture messenger before any async gaps to avoid using `context` after awaits
    final messenger = ScaffoldMessenger.of(context);
    if (!background && mounted) setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://$esp32Ip/status');
      final response = await http.get(url).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);

        setState(() {
          try {
            _temperatura = (data['temperatura'] as num).toDouble();
          } catch (_) {}

          if (!background) {
            try {
              _umbral = (data['umbral'] as num).toDouble();
            } catch (_) {}
          }

          // puerta: si cambia, añadimos evento
          try {
            final newPuerta = data['puerta_abierta'] == true;
            if (newPuerta != _puertaAbierta) {
              _events.insert(0, _Event('Puerta principal ${newPuerta ? 'abierta' : 'cerrada'}', DateTime.now()));
              if (_events.length > 100) _events.removeLast();
            }
            _puertaAbierta = newPuerta;
          } catch (_) {}

          // habitaciones: detectar cambios y generar eventos
          try {
            final habsJson = data['habitaciones'];
            if (habsJson is List) {
              final mapped = habsJson.map((e) => e == 1 || e == true).toList();
              for (int i = 0; i < _habitaciones.length && i < mapped.length; i++) {
                if (mapped[i] != _habitaciones[i]) {
                  _events.insert(0, _Event('Luz ${_nombresHabitaciones[i]} ${mapped[i] ? 'encendida' : 'apagada'}', DateTime.now()));
                  if (_events.length > 100) _events.removeLast();
                }
                _habitaciones[i] = mapped[i];
              }
            }
          } catch (_) {}

          _isLoading = false;
          _isFirstLoad = false;
        });
      }
    } catch (e) {
      if (!background && mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('Error de conexión')));
        setState(() => _isLoading = false);
      }
    }
  }

  // _setUmbral removed; not used in this layout

  Future<void> _toggleHabitacion(int index, bool value) async {
    final old = _habitaciones[index];
    setState(() => _habitaciones[index] = value);
    _events.insert(0, _Event('Usuario: ${_nombresHabitaciones[index]} ${value ? 'encendida' : 'apagada'}', DateTime.now()));
    if (_events.length > 100) _events.removeLast();

    try {
      final stateInt = value ? 1 : 0;
      final url = Uri.parse('http://$esp32Ip/control_hab?id=$index&state=$stateInt');
      final resp = await http.get(url).timeout(const Duration(seconds: 2));
      if (resp.statusCode != 200) {
        // revert on failure
        setState(() => _habitaciones[index] = old);
        _events.insert(0, _Event('Error al cambiar ${_nombresHabitaciones[index]}', DateTime.now()));
        if (_events.length > 100) _events.removeLast();
      }
    } catch (e) {
      setState(() => _habitaciones[index] = old);
      _events.insert(0, _Event('Error al cambiar ${_nombresHabitaciones[index]}', DateTime.now()));
      if (_events.length > 100) _events.removeLast();
    }
  }

  Future<void> _setUmbral(double val) async {
    try {
      await http.get(Uri.parse('http://$esp32Ip/set_umbral?val=${val.toStringAsFixed(1)}')).timeout(const Duration(seconds: 2));
      // añadimos un evento local indicando cambio manual
      _events.insert(0, _Event('Umbral ajustado a ${val.toStringAsFixed(1)}°C', DateTime.now()));
      if (_events.length > 100) _events.removeLast();
    } catch (e) {
      _events.insert(0, _Event('Error al establecer umbral', DateTime.now()));
      if (_events.length > 100) _events.removeLast();
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1173D4);
    const backgroundDark = Color(0xFF101922);

    // tempCardColor no longer used in this layout

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Panel de control', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_isLoading && !_isFirstLoad)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            )
        ],
      ),
      body: SafeArea(
        child: _isFirstLoad
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    const Text('Historial de temperatura', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    // --- Tarjeta de temperatura estilo `pruebamain.dart` pero con tonos azules ---
                    Builder(builder: (context) {
                      // Tres estados: alarma, precaución y normal
                      final bool alarma = _temperatura >= _umbral;
                      final bool precaucion = !alarma && (_temperatura >= (_umbral - 2.0));

                      Color tempTextColor;
                      Color tempCardColor;
                      Color borderColor = Colors.transparent;
                      String tempStatusText;

                      if (alarma) {
                        tempStatusText = '¡ALARMA ACTIVA!';
                        tempTextColor = Colors.redAccent;
                        tempCardColor = Colors.redAccent.withAlpha((0.18 * 255).round());
                        borderColor = Colors.red;
                      } else if (precaucion) {
                        tempStatusText = 'Precaución';
                        tempTextColor = Colors.orangeAccent;
                        tempCardColor = Colors.orange.withAlpha((0.14 * 255).round());
                      } else {
                        tempStatusText = 'Temperatura Normal';
                        tempTextColor = Colors.greenAccent;
                        tempCardColor = primary.withAlpha((0.06 * 255).round());
                      }

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: tempCardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                            width: alarma ? 2 : 0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.thermostat, size: 40, color: primary),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${_temperatura.toStringAsFixed(1)}°C',
                                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                                    Text(tempStatusText, style: TextStyle(color: tempTextColor)),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Umbral Alarma:', style: TextStyle(color: Colors.grey)),
                                Text('${_umbral.toStringAsFixed(1)}°C', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbColor: primary,
                                activeTrackColor: primary,
                                inactiveTrackColor: primary.withAlpha((0.25 * 255).round()),
                              ),
                              child: Slider(
                                value: _umbral,
                                min: 20.0,
                                max: 50.0,
                                onChanged: (v) => setState(() => _umbral = v),
                                onChangeEnd: (v) => _setUmbral(v),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // --- SECCIÓN: ENTRADA PRINCIPAL (SERVO) ---
                    const Text('ENTRADA PRINCIPAL', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: (!_puertaAbierta && !_puertaLoading) ? _abrirPuertaManual : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _puertaAbierta ? Colors.green.withAlpha((0.18 * 255).round()) : primary.withAlpha((0.12 * 255).round()),
                                shape: BoxShape.circle,
                              ),
                              child: _puertaLoading
                                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primary))
                                  : Icon(
                                      _puertaAbierta ? Icons.door_sliding_outlined : Icons.door_front_door,
                                      size: 26,
                                      color: _puertaAbierta ? Colors.green : Colors.white,
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_puertaAbierta ? 'PUERTA ABIERTA' : 'PUERTA CERRADA', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(_puertaAbierta ? 'Detectada presencia' : 'Seguro activado', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            if (!_puertaAbierta)
                              _puertaLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.touch_app, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const SizedBox(height: 20),

                    const Text('CONTROL DE LUCES', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _habitaciones.length,
                      itemBuilder: (context, index) {
                        final isOnt = _habitaciones[index];
                        return Material(
                          color: isOnt ? Colors.indigoAccent.withAlpha((0.18 * 255).round()) : const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _toggleHabitacion(index, !isOnt),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.lightbulb, color: isOnt ? Colors.yellowAccent : Colors.grey),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_nombresHabitaciones[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Switch(
                                        value: isOnt,
                                        thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.indigoAccent : null),
                                        onChanged: (v) => _toggleHabitacion(index, v),
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
                    const SizedBox(height: 20),

                    // Eventos recientes (movidos al final)
                    const Text('Eventos recientes', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _events.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white.withAlpha((0.03 * 255).round()), borderRadius: BorderRadius.circular(12)),
                            child: const Text('No hay eventos recientes', style: TextStyle(color: Colors.grey)),
                          )
                        : Column(
                            children: _events.take(7).map((e) {
                              final msg = e.message;
                              final icon = msg.toLowerCase().contains('puerta')
                                  ? Icons.door_front_door
                                  : (msg.toLowerCase().contains('luz') ? Icons.lightbulb : Icons.event);
                              final timeStr = '${e.time.hour.toString().padLeft(2, '0')}:${e.time.minute.toString().padLeft(2, '0')}';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.white.withAlpha((0.03 * 255).round()), borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(color: primary.withAlpha((0.2 * 255).round()), borderRadius: BorderRadius.circular(8)),
                                        child: Icon(icon, color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 4),
                                            Text(timeStr, style: const TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: backgroundDark,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey[400],
        currentIndex: 1,
        onTap: (index) {
          Navigator.of(context).pushReplacementNamed('/dashboard', arguments: index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
      ),
    );
  }
}
