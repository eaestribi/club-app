import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Configuración inicial  (Sustituir con credenciales reales)
const supabaseUrl = 'https://isptgfigxrjnubzckdru.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlzcHRnZmlneHJqbnViemNrZHJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk2NDI4NjcsImV4cCI6MjA5NTIxODg2N30.7GR2Spt4tAA5FKqnUDQ35tKnhTyDAgQWR3EdjM5kGI0';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const SociedadApp());
}

class SociedadApp extends StatelessWidget {
  const SociedadApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const DashboardSelector(),
    );
  }
}

// Pantalla de selección de rol (MVP)
class DashboardSelector extends StatelessWidget {
  const DashboardSelector({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sociedad Española MVP")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SocioScreen())), child: const Text("Modo Socio")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MeseroScreen())), child: const Text("Modo Mesero")),
          ],
        ),
      ),
    );
  }
}

// Pantalla Socio: Envío de Pedido
class SocioScreen extends StatefulWidget {
  const SocioScreen({super.key});
  @override
  State<SocioScreen> createState() => _SocioScreenState();
}

class _SocioScreenState extends State<SocioScreen> {
  Future<void> _enviarPedido() async {
    await Supabase.instance.client.from('pedidos').insert({
      'socio_nombre': 'Socio Prueba',
      'mesa_id': 'Mesa 1',
      'estado': 'Enviado'
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pedido Enviado")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menú Digital")),
      body: Center(child: ElevatedButton(onPressed: _enviarPedido, child: const Text("Pedir Café"))),
    );
  }
}

// Pantalla Mesero: Dashboard en Tiempo Real
class MeseroScreen extends StatelessWidget {
  const MeseroScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Mesero")),
      body: StreamBuilder(
        stream: Supabase.instance.client.from('pedidos').stream(primaryKey: ['id']).eq('estado', 'Enviado'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final pedidos = snapshot.data as List<dynamic>;
          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) => ListTile(
              title: Text("Mesa: ${pedidos[index]['mesa_id']}"),
              subtitle: Text("Estado: ${pedidos[index]['estado']}"),
              trailing: IconButton(icon: const Icon(Icons.check), onPressed: () {}),
            ),
          );
        },
      ),
    );
  }
}