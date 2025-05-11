import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:focus_app/services/planting_session_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:focus_app/services/user_provider.dart';
import 'package:focus_app/screens/drawer_menu.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

        Map<String, int> successSessionCountByDay = {};
        for (var session in sessions) {
          String date = session['date'];
          if (session['status'] == 'Thành công') {
            successSessionCountByDay[date] = (successSessionCountByDay[date] ?? 0) + 1;
          }
        }

        displayDates = dates.where((date) => successSessionCountByDay[date] != null && successSessionCountByDay[date]! > 0).toList()
          ..sort((a, b) => DateFormat('dd/MM/yyyy')
              .parse(b)
              .compareTo(DateFormat('dd/MM/yyyy').parse(a)));

        displayDates = displayDates.take(5).toList();

        barGroups = [];
        for (int i = 0; i < displayDates.length; i++) {
          int sessionCount = successSessionCountByDay[displayDates[i]] ?? 0;
          if (sessionCount > 0) {
            barGroups.add(
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: sessionCount.toDouble(),
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
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Không thể tải lịch sử: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/statistics';
    if (isLoading) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(currentRoute: currentRoute, coins: Provider.of<UserProvider>(context).coins),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Lịch sử cây trồng'),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          backgroundColor: const Color(0xFF50B36A),
        ),
        drawer: AppDrawer(currentRoute: currentRoute, coins: Provider.of<UserProvider>(context).coins),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (sessions.isEmpty) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Lịch sử cây trồng'),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          backgroundColor: const Color(0xFF50B36A),
        ),
        drawer: AppDrawer(currentRoute: currentRoute, coins: Provider.of<UserProvider>(context).coins),
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

    // Tìm giá trị lớn nhất của toY để đặt maxY
    double maxY = barGroups.isNotEmpty
        ? barGroups.map((group) => group.barRods[0].toY).reduce((a, b) => a > b ? a : b)
        : 1;
    maxY = (maxY + 1).ceilToDouble(); // Làm tròn lên để có không gian

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Lịch sử cây trồng'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        backgroundColor: const Color(0xFF50B36A),
      ),
      drawer: AppDrawer(currentRoute: currentRoute, coins: Provider.of<UserProvider>(context).coins),
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
                        interval: 1, // Đặt khoảng cách đều nhau là 1
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value > maxY) return const Text('');
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
                  minY: 0,
                  maxY: maxY,
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