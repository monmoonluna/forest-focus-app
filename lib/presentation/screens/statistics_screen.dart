import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/services/planting_session_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsScreen extends StatelessWidget {
  final PlantingSessionService _sessionService = PlantingSessionService();

  StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử cây trồng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF50B36A),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Biểu đồ
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 200,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _sessionService.getPlantingHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu'));
                  }
                  final sessions = snapshot.data!;
                  // Tạo dữ liệu cho biểu đồ
                  Map<String, int> sessionCountByDay = {};
                  for (var session in sessions) {
                    String date = session['date'];
                    sessionCountByDay[date] = (sessionCountByDay[date] ?? 0) + 1;
                  }
                  List<FlSpot> spots = [];
                  int index = 0;
                  sessionCountByDay.forEach((date, count) {
                    if (index < 5) { // Hiển thị tối đa 5 ngày
                      spots.add(FlSpot(index.toDouble(), count.toDouble()));
                      index++;
                    }
                  });
                  return LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final dates = ['-4', '-3', '-2', '-1', 'Hôm nay'];
                              return Text(dates[value.toInt()]);
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: false,
                          color: Colors.green,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Tổng điểm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    style: const TextStyle(fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('+200', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
            // Danh sách session
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _sessionService.getPlantingHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Không có dữ liệu');
                }
                final sessions = snapshot.data!;
                return Column(
                  children: sessions.map((session) {
                    // Sửa phần xử lý timestamp
                    final timestamp = session['timestamp'];
                    final formattedTime = timestamp != null
                        ? DateFormat('hh:mm a').format((timestamp as Timestamp).toDate())
                        : 'Unknown';
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.yellow[100],
                          child: const Icon(Icons.local_florist, color: Colors.green),
                        ),
                        title: Text('$formattedTime - ${session['status']}'),
                        subtitle: Text('${session['duration']} phút'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('+${session['points_earned']}'),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}