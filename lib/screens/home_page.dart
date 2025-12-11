// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/work_record.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user; // { id, name, email }

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final NumberFormat _currency =
      NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  bool _loading = false;
  List<WorkRecord> _allRecords = [];

  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _loadWork();
  }

  Future<void> _loadWork() async {
    setState(() => _loading = true);
    try {
      final list = await ApiService.getWork(widget.user['id']);
      final records = list
          .map((e) => WorkRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      records.sort((a, b) => b.date.compareTo(a.date));
      setState(() => _allRecords = records);
    } catch (e) {
      _showSnack('Failed to load data');
    } finally {
      setState(() => _loading = false);
    }
  }

  List<WorkRecord> get _filteredRecords {
    return _allRecords.where((r) {
      if (_fromDate != null && r.date.isBefore(_fromDate!)) return false;
      if (_toDate != null && r.date.isAfter(_toDate!)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double get _totalAmount =>
      _allRecords.fold(0.0, (sum, r) => sum + r.amount);

  double get _filteredAmount =>
      _filteredRecords.fold(0.0, (sum, r) => sum + r.amount);

  String get _filterLabel {
    if (_fromDate == null && _toDate == null) {
      return "All dates";
    }
    final from = _fromDate != null ? _dateFormat.format(_fromDate!) : 'start';
    final to = _toDate != null ? _dateFormat.format(_toDate!) : 'end';
    return '$from → $to';
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fromDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _toDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          23,
          59,
          59,
        );
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
  }

  Future<void> _openAddWorkSheet() async {
    final placeCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 8,
          ),
          child: StatefulBuilder(
            builder: (context, setInnerState) {
              Future<void> pickDate() async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setInnerState(() {
                    selectedDate = picked;
                  });
                }
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Work Entry',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            child: Text(_dateFormat.format(selectedDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: placeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Place / Site',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Amount (₹)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: notesCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final place = placeCtrl.text.trim();
                        final amountText = amountCtrl.text.trim();
                        final notes = notesCtrl.text.trim();

                        if (place.isEmpty || amountText.isEmpty) {
                          _showSnack('Enter place and amount');
                          return;
                        }

                        final amount = double.tryParse(amountText);
                        if (amount == null) {
                          _showSnack('Invalid amount');
                          return;
                        }

                        final data = {
                          "userId": widget.user['id'],
                          "date": selectedDate.toIso8601String(),
                          "place": place,
                          "amount": amount,
                          "notes": notes,
                        };

                        Navigator.pop(context); // close sheet
                        await ApiService.addWork(data);
                        await _loadWork();
                        _showSnack('Work added');
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _deleteRecord(WorkRecord r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text(
          'Are you sure you want to delete this work record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.deleteWork(r.id);
      await _loadWork();
      _showSnack('Deleted');
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painter Dashboard'),
        actions: [
          IconButton(
            onPressed: _loadWork,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadWork,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Greeting
                    Text(
                      'Hi, ${widget.user['name']} 👋',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your daily painting jobs and earnings.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[700]),
                    ),

                    const SizedBox(height: 16),

                    // Summary cards
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Total Jobs',
                            value: filtered.length.toString(),
                            icon: Icons.work,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'All-time Amount',
                            value: _currency.format(_totalAmount),
                            icon: Icons.currency_rupee,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Filtered Amount',
                            value: _currency.format(_filteredAmount),
                            icon: Icons.filter_alt,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Date Range',
                            value: _filterLabel,
                            icon: Icons.date_range,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Filter controls
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filter by Date',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickFromDate,
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'From',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      child: Text(
                                        _fromDate == null
                                            ? 'Not set'
                                            : _dateFormat
                                                .format(_fromDate!),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickToDate,
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'To',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      child: Text(
                                        _toDate == null
                                            ? 'Not set'
                                            : _dateFormat.format(
                                                _toDate!,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _clearFilter,
                                child: const Text('Clear Filter'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Work History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),

                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No work records. Tap + to add your first job.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ...filtered.map(
                        (r) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                _dateFormat.format(r.date).split('-').last,
                              ),
                            ),
                            title: Text(r.place),
                            subtitle: Text(
                              '${_dateFormat.format(r.date)}\n${_currency.format(r.amount)}'
                              '${r.notes.isNotEmpty ? '\n${r.notes}' : ''}',
                            ),
                            isThreeLine: r.notes.isNotEmpty,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteRecord(r),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddWorkSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Work'),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatar(
              child: Icon(icon, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      )),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
