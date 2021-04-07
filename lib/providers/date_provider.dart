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

  String get dateString {
    final DateTime now = currentTime;
    return '${now.mDddd}，第$_currentWeek周';
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

      final int _d = _startDate!.difference(currentTime).inDays;
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
