///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-12-18 16:52
///
part of '../exports/providers.dart';

class DateProvider extends ChangeNotifier {
  DateProvider() {
    initCurrentWeek();
  }

  Timer? _fetchCurrentWeekTimer;

  DateTime? _startDate;

  DateTime? get startDate => _startDate;

  set startDate(DateTime? value) {
    _startDate = value;
    notifyListeners();
  }

  int _currentWeek = 0;

  int get currentWeek => _currentWeek;

  set currentWeek(int value) {
    _currentWeek = value;
    notifyListeners();
  }

  int? _difference;

  int get difference => _difference!;

  set difference(int value) {
    _difference = value;
    notifyListeners();
  }

  late DateTime _now;

  DateTime get now => _now;

  set now(DateTime value) {
    if (value == _now) {
      return;
    }
    _now = value;
    notifyListeners();
  }

  Future<void> initCurrentWeek() async {
    final DateTime? _dateInCache = Boxes.startWeekBox.get('startDate');
    if (_dateInCache != null) {
      _startDate = _dateInCache;
    }
    await getCurrentWeek();
  }

  Future<void> updateStartDate(DateTime date) async {
    _startDate = date;
    await Boxes.startWeekBox.put('startDate', date);
  }

  Future<void> getCurrentWeek() async {
    _now = DateTime.now();
    final Box<DateTime> box = Boxes.startWeekBox;
    try {
      DateTime? _day;
      _day = box.get('startDate');
      final Map<String, dynamic> data = await HttpUtil.fetch(
        FetchType.get,
        url: API.firstDayOfTerm,
      );
      final DateTime onlineDate = DateTime.parse(data['start'] as String);
      if (_day != onlineDate) {
        _day = onlineDate;
      }
      if (_startDate == null) {
        updateStartDate(_day!);
      } else {
        if (_startDate != _day) {
          updateStartDate(_day!);
        }
      }

      final int _d = _startDate!.difference(now).inDays;
      if (_difference != _d) {
        _difference = _d;
      }

      final int _w = -((difference - 1) / 7).floor();
      if (_currentWeek != _w) {
        _currentWeek = _w;
        notifyListeners();
      }
      _fetchCurrentWeekTimer?.cancel();
    } catch (e) {
      LogUtil.e('Failed when fetching current week: $e');
      startFetchCurrentWeekTimer();
    }
  }

  void startFetchCurrentWeekTimer() {
    _fetchCurrentWeekTimer?.cancel();
    _fetchCurrentWeekTimer = Timer.periodic(30.seconds, (_) {
      getCurrentWeek();
    });
  }
}

const Map<int, String> shortWeekdays = <int, String>{
  1: '周一',
  2: '周二',
  3: '周三',
  4: '周四',
  5: '周五',
  6: '周六',
  7: '周日',
};
