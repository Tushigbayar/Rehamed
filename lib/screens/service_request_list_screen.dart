import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/service_request.dart';
import '../services/service_request_service.dart';
import '../main.dart';
import 'service_request_form_screen.dart';
import 'service_request_detail_screen.dart';

// Platform-specific imports
import 'dart:io' show Directory, File, Platform;
import 'package:path_provider/path_provider.dart';
import '../utils/web_download.dart' if (dart.library.io) '../utils/web_download_stub.dart';

class ServiceRequestListScreen extends StatefulWidget {
  const ServiceRequestListScreen({super.key});

  @override
  State<ServiceRequestListScreen> createState() => _ServiceRequestListScreenState();
}

class _ServiceRequestListScreenState extends State<ServiceRequestListScreen> {
  ServiceRequestStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
  }

  void _refresh() {
    setState(() {});
  }

  Future<List<ServiceRequest>> _getFilteredRequests() async {
    final requests = await ServiceRequestService.getRequests();
    if (_filterStatus == null) return requests;
    return requests.where((r) => r.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Миний дуудлагууд'),
        backgroundColor: LogoColors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Тайлан татаж авах',
            onPressed: _showExportDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Бүгд', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Хүлээгдэж байна', ServiceRequestStatus.pending),
                  const SizedBox(width: 8),
                  _buildFilterChip('Засварлаж байна', ServiceRequestStatus.inProgress),
                  const SizedBox(width: 8),
                  _buildFilterChip('Дууссан', ServiceRequestStatus.completed),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ServiceRequest>>(
              future: _getFilteredRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final requests = snapshot.data ?? [];
                
                if (requests.isEmpty) {
                  return const Center(
                    child: Text('Дуудлага олдсонгүй'),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    _refresh();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(context, requests[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ServiceRequestFormScreen(),
            ),
          );
          if (result == true) {
            _refresh();
          }
        },
        backgroundColor: LogoColors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, ServiceRequestStatus? status) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? status : null;
        });
      },
      selectedColor: LogoColors.blue.withOpacity(0.2),
      checkmarkColor: LogoColors.blue,
    );
  }

  Future<void> _showExportDialog() async {
    final now = DateTime.now();
    int? selectedYear;
    int? selectedMonth;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Тайлан татаж авах'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Он сар сонгоно уу:'),
              const SizedBox(height: 16),
              // Он сонгох
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Он',
                  border: OutlineInputBorder(),
                ),
                value: selectedYear ?? now.year,
                items: List.generate(5, (index) {
                  final year = now.year - index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (value) {
                  setDialogState(() {
                    selectedYear = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Сар сонгох
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Сар',
                  border: OutlineInputBorder(),
                ),
                value: selectedMonth ?? now.month,
                items: List.generate(12, (index) {
                  final month = index + 1;
                  return DropdownMenuItem(
                    value: month,
                    child: Text(month.toString()),
                  );
                }),
                onChanged: (value) {
                  setDialogState(() {
                    selectedMonth = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Цуцлах'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _exportReport(selectedYear ?? now.year, selectedMonth ?? now.month);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LogoColors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Татаж авах'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportReport(int year, int month) async {
    // Loading indicator харуулах
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await ServiceRequestService.exportReport(
        year: year,
        month: month,
      );

      if (!context.mounted) return;
      
      // Loading dialog хаах
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (result['success'] == true) {
        // CSV өгөгдөл файл болгон хадгалах
        final csvData = result['csvData'] as List<int>;
        
        // Web platform дээр browser download API ашиглах
        if (kIsWeb) {
          try {
            // Web дээр browser download API ашиглах
            final fileName = 'duudlagiin_tailan_${year}_${month.toString().padLeft(2, '0')}.csv';
            downloadFile(csvData, fileName);
            
            if (!context.mounted) return;
            
            // Амжилттай мэдэгдэл харуулах
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.check_circle, color: LogoColors.green, size: 28),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Амжилттай!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Тайлан файл амжилттай татагдлаа.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.insert_drive_file, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Файл: $fileName',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.grey),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Файл таны Downloads хавтас руу татагдлаа.'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Ойлголоо'),
                  ),
                ],
              ),
            );
            return;
          } catch (e) {
            if (!context.mounted) return;
            
            // Loading dialog хаах (хэрэв байгаа бол)
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            
            // Алдааны alert dialog харуулах
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
                content: Text('Файл татахад алдаа гарлаа:\n${e.toString()}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Ойлголоо'),
                  ),
                ],
              ),
            );
            return;
          }
        }
        
        // Mobile/Desktop platform дээр файл систем ашиглах
        if (!kIsWeb) {
          // Download folder олох - platform-аас хамаарч
          // Note: dart:io is only available on non-web platforms
          // ignore: undefined_class
          Directory? directory;
          try {
            // ignore: undefined_getter
            if (Platform.isAndroid) {
              // Android дээр Downloads folder олох
            try {
              final externalDir = await getExternalStorageDirectory();
              if (externalDir != null) {
                try {
                  // Android/data/com.example.app/files дээр
                  final downloadDir = Directory('${externalDir.path.split('/Android')[0]}/Download');
                  if (await downloadDir.exists()) {
                    directory = downloadDir;
                  } else {
                    directory = externalDir;
                  }
                } catch (e) {
                  directory = externalDir;
                }
              }
            } catch (e) {
              // getExternalStorageDirectory() алдаа гарвал getApplicationDocumentsDirectory() ашиглах
              try {
                directory = await getApplicationDocumentsDirectory();
              } catch (e2) {
                // Алдаа гарвал null үлдэнэ
              }
            }
          } else if (Platform.isIOS) {
            // iOS дээр documents directory ашиглах
            try {
              directory = await getApplicationDocumentsDirectory();
            } catch (e) {
              // Алдаа гарвал null үлдэнэ
            }
          } else if (Platform.isWindows) {
            // Windows дээр documents directory ашиглах
            try {
              directory = await getApplicationDocumentsDirectory();
            } catch (e) {
              // Windows дээр алдаа гарвал Downloads folder ашиглах
              try {
                final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '';
                if (userProfile.isNotEmpty) {
                  directory = Directory('$userProfile\\Downloads');
                }
              } catch (e2) {
                // Алдаа гарвал null үлдэнэ
              }
            }
          } else {
            // Бусад platform дээр documents directory ашиглах
            try {
              directory = await getApplicationDocumentsDirectory();
            } catch (e) {
              // Алдаа гарвал null үлдэнэ
            }
          }
          
          // Хэрэв directory олдохгүй бол documents directory ашиглах (сүүлийн оролдлого)
          if (directory == null) {
            try {
              directory = await getApplicationDocumentsDirectory();
            } catch (e) {
              // Бүх оролдлого амжилтгүй болсон
            }
          }
          
          // Directory байгаа эсэхийг шалгах
          if (directory == null) {
            if (!context.mounted) return;
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
                content: Text('Файл хадгалах хавтас олдсонгүй.\nPlatform: ${!kIsWeb ? Platform.operatingSystem : "Web"}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Ойлголоо'),
                  ),
                ],
              ),
            );
            return;
          }
          
          // Directory үүсгэх (хэрэв байхгүй бол)
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }

          // Файл нэр үүсгэх
          final fileName = 'duudlagiin_tailan_${year}_${month.toString().padLeft(2, '0')}.csv';
          final filePath = '${directory.path}/$fileName';
          
          // Файл бичих
          final file = File(filePath);
          await file.writeAsBytes(csvData);

          if (!context.mounted) return;
          
          // Android дээр Download folder-д хадгалагдсан эсэхийг шалгах
          final isDownloadFolder = directory.path.contains('/Download') || directory.path.contains('/download');
          final folderName = isDownloadFolder ? 'Download' : 'App Documents';
          
          // Alert dialog харуулах
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: LogoColors.green, size: 28),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Амжилттай!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Тайлан файл амжилттай татагдлаа.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.insert_drive_file, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Файл: $fileName',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.folder, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('Хавтас: $folderName'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ойлголоо'),
                ),
              ],
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
          
          // Loading dialog хаах (хэрэв байгаа бол)
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          
          // Алдааны alert dialog харуулах
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
              content: Text('Файл хадгалахад алдаа гарлаа:\n${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ойлголоо'),
                ),
              ],
            ),
          );
          }
        }
      } else {
        if (!context.mounted) return;
        
        // Алдааны alert dialog харуулах
        final errorMessage = result['error'] ?? 'Тайлан татахад алдаа гарлаа';
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  result['requiresLogin'] == true ? Icons.warning : Icons.error,
                  color: result['requiresLogin'] == true ? Colors.orange : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result['requiresLogin'] == true ? 'Анхааруулга' : 'Алдаа',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ойлголоо'),
              ),
              if (result['requiresLogin'] == true)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Login screen рүү шилжүүлэх (хэрэв шаардлагатай бол)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LogoColors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Нэвтрэх'),
                ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Loading dialog хаах
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Алдаа гарлаа: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildRequestCard(BuildContext context, ServiceRequest request) {
    Color statusColor;
    IconData statusIcon;
    
    switch (request.status) {
      case ServiceRequestStatus.pending:
        statusColor = LogoColors.amber;
        statusIcon = Icons.pending;
        break;
      case ServiceRequestStatus.accepted:
      case ServiceRequestStatus.inProgress:
        statusColor = LogoColors.blue;
        statusIcon = Icons.work;
        break;
      case ServiceRequestStatus.completed:
        statusColor = LogoColors.green;
        statusIcon = Icons.check_circle;
        break;
      case ServiceRequestStatus.cancelled:
        statusColor = LogoColors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceRequestDetailScreen(requestId: request.id),
            ),
          );
          if (result == true) {
            _refresh();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  request.isUrgent ? Icons.emergency : statusIcon,
                  color: statusColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (request.isUrgent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: LogoColors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ЯАРАЛТАЙ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.typeLabel,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${request.requestedAt.year}-${request.requestedAt.month.toString().padLeft(2, '0')}-${request.requestedAt.day.toString().padLeft(2, '0')} ${request.requestedAt.hour.toString().padLeft(2, '0')}:${request.requestedAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (request.assignedTo != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Засварчин томилогдсон',
                              style: TextStyle(
                                color: LogoColors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (request.assignedTo != null)
                    Icon(Icons.person, color: LogoColors.blue, size: 16),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
