import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/services/planting_session_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final PlantingSessionService _sessionService = PlantingSessionService();
  List<Map<String, dynamic>> sessions = [];
  Map<String, List<Map<String, dynamic>>> sessionsByDate = {};
  List<String> dates = [];
  List<BarChartGroupData> barGroups = [];
  List<String> displayDates = [];
  int totalPoints = 0;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _sessionService.getPlantingHistory();
      setState(() {
        sessions = data;
        totalPoints = sessions.fold(0, (sum, session) => sum + (session['points_earned'] as int));

        sessionsByDate = {};
        for (var session in sessions) {
          String date = session['date'];
          if (!sessionsByDate.containsKey(date)) {
            sessionsByDate[date] = [];
          }
          sessionsByDate[date]!.add(session);
        }

        dates = sessionsByDate.keys.toList()
          ..sort((a, b) => DateFormat('dd/MM/yyyy')
              .parse(b)
              .compareTo(DateFormat('dd/MM/yyyy').parse(a)));

        Map<String, int> sessionCountByDay = {};
        for (var session in sessions) {
          String date = session['date'];
          sessionCountByDay[date] = (sessionCountByDay[date] ?? 0) + 1;
        }

        displayDates = dates.reversed.take(5).toList().reversed.toList();
        barGroups = [];
        for (int i = 0; i < displayDates.length; i++) {
          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: sessionCountByDay[displayDates[i]]!.toDouble(),
                  color: Colors.green,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
          );
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lịch sử cây trồng'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: const Color(0xFF50B36A),
        ),
        body: Center(
          child: Text(
            error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (sessions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lịch sử cây trồng'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: const Color(0xFF50B36A),
        ),
        body: const Center(
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
        ),
      );
    }

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
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
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
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng điểm: ',
                    style: TextStyle(fontSize: 16),
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final sessionsForDate = sessionsByDate[date]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text(
                        date == DateFormat('dd/MM/yyyy').format(DateTime.now())
                            ? 'Hôm nay'
                            : date,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sessionsForDate.length,
                      itemBuilder: (context, sessionIndex) {
                        final session = sessionsForDate[sessionIndex];
                        String formattedTime = 'Unknown';
                        final timestamp = session['timestamp'];
                        if (timestamp != null && timestamp is Timestamp) {
                          formattedTime = DateFormat('hh:mm a').format(timestamp.toDate());
                        }

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
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}