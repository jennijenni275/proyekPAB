import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({
    super.key,
    required List museums,
    required String museumName,
  });

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<Museum> _museums = [];
  String? _selectedMuseumId;
  String? _selectedMuseumName;
  DateTime? _selectedDate;
  int _ticketAmount = 1;

  @override
  void initState() {
    super.initState();
    _fetchMuseums();
  }

  Future<void> _fetchMuseums() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('museums').get();
    setState(() {
      _museums.clear();
      _museums.addAll(snapshot.docs.map((doc) => Museum.fromFirestore(doc)));
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesan Tiket Museum')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown Museum
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Pilih Museum',
                    border: InputBorder.none,
                    icon: Icon(Icons.museum),
                  ),
                  value: _selectedMuseumId,
                  isExpanded: true,
                  items:
                      _museums.map((museum) {
                        return DropdownMenuItem(
                          value: museum.id,
                          child: Text(museum.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    final selected = _museums.firstWhere((m) => m.id == value);
                    setState(() {
                      _selectedMuseumId = value;
                      _selectedMuseumName = selected.name;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Input Nama
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pengunjung',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tanggal
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _selectedDate == null
                      ? 'Pilih Tanggal Kunjungan'
                      : 'Tanggal: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () => _selectDate(context),
              ),
            ),

            const SizedBox(height: 16),

            // Jumlah Tiket
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.confirmation_number),
                    const SizedBox(width: 12),
                    const Text('Jumlah Tiket:', style: TextStyle(fontSize: 16)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed:
                          _ticketAmount > 1
                              ? () => setState(() => _ticketAmount--)
                              : null,
                    ),
                    Text(
                      '$_ticketAmount',
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () => setState(() => _ticketAmount++),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Pesan Tiket'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Tiket Dipesan'),
                          content: Text(
                            'Nama: ${_nameController.text}\n'
                            'Museum: $_selectedMuseumName\n'
                            'Tanggal: ${_selectedDate?.toLocal().toString().split(' ')[0]}\n'
                            'Jumlah Tiket: $_ticketAmount',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Museum {
  final String id;
  final String name;

  Museum({required this.id, required this.name});

  factory Museum.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Museum(id: doc.id, name: data['name'] ?? 'Unknown');
  }
}
