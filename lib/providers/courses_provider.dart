///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-14 16:22
///
part of '../exports/providers.dart';

class CoursesProvider extends ChangeNotifier {
  Box<Map<dynamic, dynamic>> get _courseBox => Boxes.coursesBox;

  Box<String> get _courseRemarkBox => Boxes.courseRemarkBox;

  final int maxCoursesPerDay = 12;

  DateTime? _now;

  DateTime? get now => _now;

  set now(DateTime? value) {
    if (value == _now) {
      return;
    }
    _now = value;
    notifyListeners();
  }

  Map<int, Map<dynamic, dynamic>>? _courses;

  Map<int, Map<dynamic, dynamic>>? get courses => _courses;

  set courses(Map<int, Map<dynamic, dynamic>>? value) {
    _courses = <int, Map<dynamic, dynamic>>{...?value};
    notifyListeners();
  }

  String? _remark;

  String? get remark => _remark;

  set remark(String? value) {
    _remark = value;
    notifyListeners();
  }

  bool _firstLoaded = false;

  bool get firstLoaded => _firstLoaded;

  set firstLoaded(bool value) {
    _firstLoaded = value;
    notifyListeners();
  }

  bool _hasCourses = false;

  bool get hasCourses => _hasCourses;

  set hasCourses(bool value) {
    _hasCourses = value;
    notifyListeners();
  }

  bool _showError = false;

  bool get showError => _showError;

  set showError(bool value) {
    _showError = value;
    notifyListeners();
  }

  /// 当前的错误是否为外网访问
  bool _isOuterError = false;

  bool get isOuterError => _isOuterError;

  set isOuterError(bool value) {
    if (value == _isOuterError) {
      return;
    }
    _isOuterError = value;
    notifyListeners();
  }

  void initCourses() {
    now = DateTime.now();
    _courses =
        _courseBox.get(UserAPI.user.uid)?.cast<int, Map<dynamic, dynamic>>();
    _remark = _courseRemarkBox.get(UserAPI.user.uid);
    _hasCourses = _courses != null;
    if (_courses == null) {
      _courses = resetCourses();
    } else {
      for (final Map<dynamic, dynamic> _map in _courses!.values) {
        final Map<int, List<dynamic>> map = _map.cast<int, List<dynamic>>();
        final List<List<dynamic>> lists =
            map.values.toList().cast<List<dynamic>>();
        for (final List<dynamic> list in lists) {
          final List<CourseModel> courses = list.cast<CourseModel>();
          for (final CourseModel course in courses) {
            if (course.color == null) {
              CourseModel.uniqueColor(course, CourseAPI.randomCourseColor());
            }
          }
        }
      }
      firstLoaded = true;
    }
    updateCourses();
  }

  void unloadCourses() {
    _courses = null;
    _remark = null;
    _firstLoaded = false;
    _hasCourses = true;
    _showError = false;
    _now = null;
  }

  Map<int, Map<int, dynamic>> resetCourses() {
    final Map<int, Map<int, dynamic>> courses = <int, Map<int, dynamic>>{
      for (int i = 1; i < 7 + 1; i++)
        i: <int, dynamic>{
          for (int i = 1; i < maxCoursesPerDay + 1; i++) i: <dynamic>[],
        },
    };
    for (final int key in courses.keys) {
      courses[key] = <int, dynamic>{
        for (int i = 1; i < maxCoursesPerDay + 1; i++) i: <dynamic>[],
      };
    }
    return courses;
  }

  Future<void> updateCourses({bool isOuterNetwork = false}) async {
    final DateProvider dateProvider =
        Provider.of<DateProvider>(currentContext, listen: false);
    try {
      final List<Response<String>> responses =
          await Future.wait<Response<String>>(
        <Future<Response<String>>>[
          CourseAPI.getCourse(isOuterNetwork: isOuterNetwork),
          CourseAPI.getRemark(isOuterNetwork: isOuterNetwork),
        ],
      );
      await courseResponseHandler(responses[0]);
      await remarkResponseHandler(responses[1]);
      if (!_firstLoaded) {
        if (dateProvider.currentWeek != 0) {
          _firstLoaded = true;
        }
      }
      if (_showError) {
        _showError = false;
      }
      notifyListeners();
    } on DioError catch (dioError) {
      if (!isOuterNetwork &&
          (dioError.response?.statusCode == HttpStatus.forbidden ||
              dioError.type == DioErrorType.connectTimeout)) {
        updateCourses(isOuterNetwork: true);
      } else {
        _showError = true;
        _firstLoaded = true;
        _isOuterError = true;
        notifyListeners();
      }
    } catch (e) {
      _showError = !_hasCourses; // 有课则不显示错误
      if (isOuterNetwork && e is FormatException) {
        LogUtil.d('Displaying courses from cache...');
        _isOuterError = true;
      } else {
        LogUtil.e('Error when updating course: $e');
        _isOuterError = false;
      }
      if (!firstLoaded && dateProvider.currentWeek != 0) {
        _firstLoaded = true;
      }
      notifyListeners();
    }
  }

  Future<void> courseResponseHandler(Response<String> response) async {
    final Map<String, dynamic> data =
        jsonDecode(response.data!) as Map<String, dynamic>;
    final List<dynamic> _courseList = data['courses'] as List<dynamic>;
    final List<dynamic> _customCourseList = data['othCase'] as List<dynamic>;
    Map<int, Map<int, dynamic>> _s;
    _s = resetCourses();
    _hasCourses = _courseList.isNotEmpty || _customCourseList.isNotEmpty;
    for (final dynamic course in _courseList) {
      final CourseModel _c =
          CourseModel.fromJson(course as Map<String, dynamic>);
      addCourse(_c, _s);
    }
    for (final dynamic _course in _customCourseList) {
      final Map<String, dynamic> course = _course as Map<String, dynamic>;
      if ((course['content'] as String?)?.trim().isNotEmpty != true) {
        final CourseModel _c = CourseModel.fromJson(course, isCustom: true);
        addCourse(_c, _s);
      }
    }
    _courses = _s;
    await _courseBox.delete(UserAPI.user.uid);
    await _courseBox.put(
        UserAPI.user.uid, Map<int, Map<int, dynamic>>.from(_s));
  }

  Future<void> remarkResponseHandler(Response<String> response) async {
    Map<String, dynamic>? data;
    if (response.data != null) {
      data = jsonDecode(response.data!) as Map<String, dynamic>;
    }

    String? _r;
    if (data != null) {
      _r = data['classScheduleRemark'] as String;
    }
    if (_r.isNotNullOrEmpty) {
      _remark = _r;
      await _courseRemarkBox.delete(UserAPI.user.uid);
      await _courseRemarkBox.put(UserAPI.user.uid, _r!);
    }
  }

  void addCourse(CourseModel course, Map<int, Map<int, dynamic>> courses) {
    final int courseDay = course.day;
    final int courseTime = course.time.toInt();
    try {
      courses[courseDay]![courseTime].add(course);
    } catch (e) {
      LogUtil.e(
        'Failed when trying to add course at day($courseDay) time($courseTime)',
      );
      LogUtil.e('$course');
    }
  }

  Future<void> setCourses(Map<int, Map<int, dynamic>> courses) async {
    await _courseBox.put(UserAPI.user.uid, courses);
    _courses = Map<int, Map<int, dynamic>>.from(courses);
  }

  Future<void> setRemark(String value) async {
    await _courseRemarkBox.put(UserAPI.user.uid, value);
    _remark = value;
  }
}
