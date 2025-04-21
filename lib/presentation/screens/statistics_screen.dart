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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sessionService.getPlantingHistory(),
        builder: (context, snapshot) {
          // Xử lý trạng thái tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Xử lý lỗi
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Lỗi khi tải dữ liệu. Vui lòng thử lại!',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          // Xử lý khi không có dữ liệu
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_florist, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có phiên trồng cây nào.\nHãy bắt đầu trồng cây ngay!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final sessions = snapshot.data!;
          // Tính tổng điểm
          int totalPoints = sessions.fold(0, (sum, session) => sum + (session['points_earned'] as int));

          // Tạo dữ liệu cho biểu đồ
          Map<String, int> sessionCountByDay = {};
          for (var session in sessions) {
            String date = session['date'];
            sessionCountByDay[date] = (sessionCountByDay[date] ?? 0) + 1;
          }
          List<FlSpot> spots = [];
          List<String> dates = sessionCountByDay.keys.toList()
            ..sort((a, b) => DateFormat('dd/MM/yyyy')
                .parse(b)
                .compareTo(DateFormat('dd/MM/yyyy').parse(a)));
          int index = 0;
          for (var date in dates.reversed.take(5)) { // Lấy 5 ngày gần nhất
            spots.add(FlSpot(index.toDouble(), sessionCountByDay[date]!.toDouble()));
            index++;
          }

          return SingleChildScrollView(
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
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final displayDates = dates.reversed.take(5).toList();
                              if (value.toInt() >= displayDates.length) return const Text('');
                              final date = displayDates[value.toInt()];
                              return Text(
                                date == DateFormat('dd/MM/yyyy').format(DateTime.now())
                                    ? 'Hôm nay'
                                    : DateFormat('dd/MM').format(DateFormat('dd/MM/yyyy').parse(date)),
                                style: const TextStyle(fontSize: 12),
                              );
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
                        child: Text('+$totalPoints', style: const TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
                // Danh sách session
                Column(
                  children: sessions.map((session) {
                    // Xử lý timestamp an toàn hơn
                    String formattedTime = 'Unknown';
                    final timestamp = session['timestamp'];
                    if (timestamp != null && timestamp is Timestamp) {
                      formattedTime = DateFormat('hh:mm a').format(timestamp.toDate());
                    }

                    // Phân biệt trạng thái
                    Color statusColor = session['status'] == 'Thành công' ? Colors.green : Colors.red;
                    IconData statusIcon = session['status'] == 'Thành công' ? Icons.check_circle : Icons.cancel;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.yellow[100],
                          child: Icon(statusIcon, color: statusColor),
                        ),
                        title: Text(
                          '$formattedTime - ${session['status']}',
                          style: TextStyle(color: statusColor),
                        ),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}