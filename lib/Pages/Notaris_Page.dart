import 'package:flutter/material.dart';

class NotarisPage extends StatefulWidget {
  const NotarisPage({super.key});

  @override
  State<NotarisPage> createState() => _NotarisPageState();
}

class _NotarisPageState extends State<NotarisPage> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', 'In Progress', 'Selesai', 'Draf'];

  final List<_AktaItem> _items = const [
    _AktaItem(
      nama: 'PT. Teknologi Nusantara',
      jenis: 'Pendirian Perseroan Terbatas',
      nomorAkta: '124/Leg/X/2023',
      tanggal: '12 Okt 2023',
      status: 'SELESAI',
    ),
    _AktaItem(
      nama: 'Bapak Ahmad Subardjo',
      jenis: 'Akta Jual Beli Tanah',
      nomorAkta: '45/AJB/XI/2023',
      tanggal: '28 Nov 2023',
      status: 'IN PROGRESS',
    ),
    _AktaItem(
      nama: 'CV. Mandiri Sejahtera',
      jenis: 'Perubahan Anggaran Dasar',
      nomorAkta: '12/PAD/XII/2023',
      tanggal: '05 Des 2023',
      status: 'REVIEWING',
    ),
    _AktaItem(
      nama: 'Ibu Maria Simatupang',
      jenis: 'Akta Hibah',
      nomorAkta: '08/HB/I/2024',
      tanggal: '12 Jan 2024',
      status: 'SELESAI',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _AktaCard(item: _items[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: const Color(0xCCF6F7F8),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0x1AF7E3E2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.gavel, color: Color(0xFF913632), size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Berkas Notaris',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            label: const Text(
              'Berkas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF913632),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  // ─── SEARCH ─────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xCCF6F7F8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: Color(0xFF94A3B8), size: 22),
            const SizedBox(width: 8),
            const Expanded(
              child: TextField(
                style: TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: 'Cari Nama Klien atau Nomor Akta...',
                  hintStyle: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  // ─── FILTER CHIPS ────────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return Container(
      color: const Color(0xCCF6F7F8),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (i) {
            final isActive = _selectedFilter == i;
            return Padding(
              padding: EdgeInsets.only(right: i < _filters.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF913632) : Colors.white,
                    border: isActive
                        ? null
                        : Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    _filters[i],
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF475569),
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── AKTA CARD ───────────────────────────────────────────────────────────────

class _AktaCard extends StatelessWidget {
  final _AktaItem item;
  const _AktaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.jenis,
                      style: const TextStyle(
                        color: Color(0xFF2B8CEE),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: item.status),
            ],
          ),
          const SizedBox(height: 12),
          // Divider
          const Divider(height: 1, color: Color(0xFFF8FAFC)),
          const SizedBox(height: 12),
          // Meta row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined,
                        color: Color(0xFF94A3B8), size: 18),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOMOR AKTA',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          item.nomorAkta,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Color(0xFF94A3B8), size: 18),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TANGGAL',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          item.tanggal,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── STATUS BADGE ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case 'SELESAI':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case 'IN PROGRESS':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case 'REVIEWING':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── DATA MODEL ──────────────────────────────────────────────────────────────

class _AktaItem {
  final String nama;
  final String jenis;
  final String nomorAkta;
  final String tanggal;
  final String status;

  const _AktaItem({
    required this.nama,
    required this.jenis,
    required this.nomorAkta,
    required this.tanggal,
    required this.status,
  });
}