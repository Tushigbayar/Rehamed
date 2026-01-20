import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../main.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _ipController = TextEditingController();
  bool _isLoading = false;
  String? _currentIP;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _loadCurrentIP();
  }

  Future<void> _loadCurrentIP() async {
    final ip = await ApiConfig.getSavedIP();
    setState(() {
      _currentIP = ip;
      _ipController.text = ip;
    });
  }

  Future<void> _saveIP() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      _showError('IP хаяг оруулна уу');
      return;
    }

    // IP хаягийн формат шалгах
    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!ipRegex.hasMatch(ip)) {
      _showError('IP хаягийн формат буруу байна\nЖишээ: 192.168.1.100');
      return;
    }

    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      // IP хаягийг турших
      final testUrl = Uri.parse('http://$ip:5000/api/health');
      final response = await http.get(testUrl).timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('Timeout'),
      );

      if (response.statusCode == 200) {
        // Амжилттай IP хаягийг хадгалах
        await ApiConfig.saveIP(ip);
        await ApiConfig.saveLastWorkingIP(ip);
        // IP хаягийг initialize хийх
        await ApiConfig.initialize();
        ApiConfig.currentIP = ip; // Update current IP
        
        setState(() {
          _currentIP = ip;
          _testResult = 'Амжилттай';
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('IP хаяг амжилттай хадгалагдлаа'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Server responded with ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _testResult = 'Алдаа: ${e.toString()}';
        _isLoading = false;
      });
      _showError('IP хаягт холбогдох боломжгүй байна\n\nШалгах зүйлс:\n1. Backend server ажиллаж байгаа эсэх\n2. IP хаяг зөв эсэх\n3. Device болон computer ижил WiFi дээр байгаа эсэх');
    }
  }

  Future<void> _autoFindIP() async {
    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      final workingIP = await ApiConfig.findWorkingIP();
      if (workingIP != null) {
        setState(() {
          _ipController.text = workingIP;
          _currentIP = workingIP;
          _testResult = 'Амжилттай IP хаяг олдлоо: $workingIP';
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Амжилттай IP хаяг олдлоо: $workingIP'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _testResult = 'Амжилттай IP хаяг олдсонгүй';
          _isLoading = false;
        });
        _showError('Бүх IP хаягт холбогдох боломжгүй байна\n\nШалгах зүйлс:\n1. Backend server ажиллаж байгаа эсэх\n2. Device болон computer ижил WiFi дээр байгаа эсэх');
      }
    } catch (e) {
      setState(() {
        _testResult = 'Алдаа: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Алдаа', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ойлголоо'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Тохиргоо'),
        backgroundColor: LogoColors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Server IP хаягийн хэсэг
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings_ethernet, color: LogoColors.blue, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Server IP хаяг',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Backend server-ийн IP хаягийг оруулна уу',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ipController,
                      decoration: InputDecoration(
                        labelText: 'IP хаяг',
                        hintText: 'Жишээ: 192.168.1.100',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.computer),
                        suffixIcon: _ipController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _ipController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    if (_testResult != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: (_testResult?.contains('Амжилттай') ?? false)
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (_testResult?.contains('Амжилттай') ?? false)
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              (_testResult?.contains('Амжилттай') ?? false)
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: (_testResult?.contains('Амжилттай') ?? false)
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _testResult!,
                                style: TextStyle(
                                  color: (_testResult?.contains('Амжилттай') ?? false)
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _saveIP,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.save),
                            label: Text(_isLoading ? 'Хадгалж байна...' : 'Хадгалах'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LogoColors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _autoFindIP,
                            icon: const Icon(Icons.search),
                            label: const Text('Автоматаар олох'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: LogoColors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Мэдээлэл хэсэг
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: LogoColors.blue, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Мэдээлэл',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Одоогийн IP хаяг:', _currentIP ?? 'Тодорхойгүй'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Platform:', Platform.operatingSystem),
                    const SizedBox(height: 8),
                    _buildInfoRow('Base URL:', ApiConfig.baseUrl),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Зөвлөмж:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• IP хаяг солигдоход "Автоматаар олох" товчийг дарах\n'
                            '• Эсвэл шинэ IP хаягийг оруулж "Хадгалах" товчийг дарах\n'
                            '• Бүх төхөөрөмж ижил WiFi network дээр байх ёстой',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
