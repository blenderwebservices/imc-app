import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'bmi_record.dart';
import 'database_helper.dart';

void main() {
  runApp(const BMICalculatorApp());
}

class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora de IMC',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      ),
      home: const BMIHistoryScreen(),
    );
  }
}

class BMIHistoryScreen extends StatefulWidget {
  const BMIHistoryScreen({super.key});

  @override
  State<BMIHistoryScreen> createState() => _BMIHistoryScreenState();
}

class _BMIHistoryScreenState extends State<BMIHistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<BMIRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final records = await _dbHelper.getRecords();
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de IMC'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(
                  child: Text('No hay registros aún',
                      style: TextStyle(fontSize: 18, color: Colors.white54)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: _getColorForBMI(record.bmi),
                          child: Text(
                            record.bmi.toStringAsFixed(1),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                        title: Text(record.comment,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(record.date),
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BMIDetailScreen(record: record),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const BMICalculatorScreen()),
          );
          if (result == true) {
            _loadRecords();
          }
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Color _getColorForBMI(double bmi) {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.yellow;
    return Colors.red;
  }
}

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  double? _bmi;
  String _message = '';
  Color _resultColor = Colors.teal;

  void _calculateBMI() {
    final double? height = double.tryParse(_heightController.text);
    final double? weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0 && weight > 0) {
      setState(() {
        _bmi = weight / (height * height);
        if (_bmi! < 18.5) {
          _message = 'Bajo peso';
          _resultColor = Colors.orange;
        } else if (_bmi! < 25) {
          _message = 'Peso normal';
          _resultColor = Colors.green;
        } else if (_bmi! < 30) {
          _message = 'Sobrepeso';
          _resultColor = Colors.yellow;
        } else {
          _message = 'Obesidad';
          _resultColor = Colors.red;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese valores válidos')),
      );
    }
  }

  Future<void> _saveRecord() async {
    if (_bmi == null) return;

    final record = BMIRecord(
      weight: double.parse(_weightController.text),
      height: double.parse(_heightController.text),
      bmi: _bmi!,
      comment: _message,
      date: DateTime.now(),
    );

    await _dbHelper.insertRecord(record);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Calculación'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.fitness_center, size: 80, color: Colors.teal),
            const SizedBox(height: 32),
            TextField(
              controller: _heightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Estatura (m)',
                hintText: 'Ej: 1.75',
                prefixIcon: const Icon(Icons.height),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Peso (kg)',
                hintText: 'Ej: 70',
                prefixIcon: const Icon(Icons.monitor_weight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _calculateBMI,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Calcular', style: TextStyle(fontSize: 18)),
            ),
            if (_bmi != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _resultColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _resultColor, width: 2),
                ),
                child: Column(
                  children: [
                    Text('Tu IMC es:', style: Theme.of(context).textTheme.bodyLarge),
                    Text(
                      _bmi!.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(color: _resultColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _message,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _resultColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveRecord,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Resultado'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}

class BMIDetailScreen extends StatelessWidget {
  final BMIRecord record;

  const BMIDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final Color resultColor = _getColorForBMI(record.bmi);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Registro'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: resultColor, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('dd MMMM yyyy, HH:mm').format(record.date),
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    record.bmi.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: resultColor,
                          fontSize: 64,
                        ),
                  ),
                  Text(
                    record.comment,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailRow(Icons.height, 'Estatura', '${record.height} m'),
            const Divider(height: 32, color: Colors.white12),
            _buildDetailRow(Icons.monitor_weight, 'Peso', '${record.weight} kg'),
            const SizedBox(height: 48),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver al Historial'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 28),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 18, color: Colors.white70)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _getColorForBMI(double bmi) {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.yellow;
    return Colors.red;
  }
}
