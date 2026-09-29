import 'package:flutter/material.dart';
import '../models/station.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class MapExplorerScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(Station) onSelectStation;

  const MapExplorerScreen({
    Key? key,
    required this.profile,
    required this.onSelectStation,
  }) : super(key: key);

  @override
  State<MapExplorerScreen> createState() => _MapExplorerScreenState();
}

class _MapExplorerScreenState extends State<MapExplorerScreen> {
  List<Station> _stations = [];
  bool _isLoading = true;
  String _filter = "all"; // all, fast, available
  Station? _selectedStation;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    setState(() => _isLoading = true);
    final list = await ApiService.getStations(
      lat: widget.profile.lat,
      lon: widget.profile.lon,
      radius: 30.0,
    );
    if (mounted) {
      setState(() {
        _stations = list;
        _isLoading = false;
        if (_stations.isNotEmpty) _selectedStation = _stations[0];
      });
    }
  }

  List<Station> get _filteredStations {
    if (_filter == "fast") {
      return _stations.where((s) => s.powerKw >= 90).toList();
    } else if (_filter == "available") {
      return _stations.where((s) => s.chargersAvailable > 0).toList();
    }
    return _stations;
  }

  Color _getStatusColor(Station s) {
    if (s.status == "maintenance") return AppColors.textTertiary;
    if (s.chargersAvailable == 0) return AppColors.fullRed;
    if (s.chargersAvailable <= 2) return AppColors.busyYellow;
    return AppColors.availableGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Charging Stations Map"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStations,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildChip("all", "All Stations (${_stations.length})"),
                      const SizedBox(width: 8),
                      _buildChip("available", "Available Now"),
                      const SizedBox(width: 8),
                      _buildChip("fast", "Ultra Fast (90kW+)"),
                    ],
                  ),
                ),

                // 2. Interactive Stylized Map Viewport Canvas
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Gridlines background
                          CustomPaint(
                            size: Size.infinite,
                            painter: MapGridPainter(),
                          ),
                          // User Location Marker
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryVariant,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryVariant.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 3,
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text("You (EV)", style: TextStyle(fontSize: 10, color: Colors.white)),
                                )
                              ],
                            ),
                          ),
                          // Station Markers distributed on simulated map
                          ..._filteredStations.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final st = entry.value;
                            final color = _getStatusColor(st);
                            final isSelected = _selectedStation?.id == st.id;

                            // Calculate visual offsets around user center
                            final double angle = (idx * 0.75) + 0.3;
                            final double dist = 55.0 + (idx % 4) * 35.0;
                            final double dx = dist * (idx.isEven ? 1.0 : -0.9) * 0.9;
                            final double dy = dist * (idx.isEven ? 0.7 : -1.1) * 0.8;

                            return Positioned(
                              left: 170.0 + dx,
                              top: 130.0 + dy,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedStation = st),
                                child: AnimatedScale(
                                  scale: isSelected ? 1.25 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected ? Colors.white : Colors.black87,
                                            width: isSelected ? 2.5 : 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.withOpacity(0.6),
                                              blurRadius: isSelected ? 12 : 4,
                                            )
                                          ],
                                        ),
                                        child: const Icon(Icons.bolt, color: Colors.black, size: 16),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.85),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          "${st.chargersAvailable}/${st.chargersTotal}",
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          // Map legend overlay
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  _legendDot(AppColors.availableGreen, "Available"),
                                  const SizedBox(width: 8),
                                  _legendDot(AppColors.busyYellow, "Busy"),
                                  const SizedBox(width: 8),
                                  _legendDot(AppColors.fullRed, "Full"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Selected Station Details Card
                if (_selectedStation != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedStation!.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    _selectedStation!.address,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(_selectedStation!).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _getStatusColor(_selectedStation!)),
                              ),
                              child: Text(
                                "${_selectedStation!.chargersAvailable} FREE",
                                style: TextStyle(
                                  color: _getStatusColor(_selectedStation!),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statMini("POWER", "${_selectedStation!.powerKw.toInt()} kW"),
                            _statMini("EST. WAIT", "~${_selectedStation!.predictedWaitMin.toStringAsFixed(1)} min"),
                            _statMini("GRID LOAD", "${(_selectedStation!.gridLoad * 100).toInt()}%"),
                            _statMini("PRICE", "₹${_selectedStation!.pricePerKwh}/u"),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => widget.onSelectStation(_selectedStation!),
                            child: const Text("PROCEED TO RESERVE SLOT"),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildChip(String key, String label) {
    final active = _filter == key;
    return GestureDetector(
      onTap: () => setState(() => _filter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active ? Colors.black : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  Widget _statMini(String title, String val) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Concentric radar circles around user
    final circlePaint = Paint()
      ..color = AppColors.primaryVariant.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 60, circlePaint);
    canvas.drawCircle(center, 120, circlePaint);
    canvas.drawCircle(center, 180, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
