///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-21 11:33
///
part of '../exports/providers.dart';

class ScoresProvider extends ChangeNotifier {
  Box<Map<dynamic, dynamic>> get _scoreBox => Boxes.scoresBox;

  final List<int> _rawData = <int>[];
  Socket? _socket;
  String _scoreData = '';

  bool _loaded = false;

  bool get loaded => _loaded;

  set loaded(bool value) {
    if (value == _loaded) {
      return;
    }
    _loaded = value;
    notifyListeners();
  }

  bool _loading = true;

  bool get loading => _loading;

  set loading(bool value) {
    if (value == _loading) {
      return;
    }
    _loading = value;
    notifyListeners();
  }

  bool _loadError = false;

  bool get loadError => _loadError;
  String _errorString = '';

  String get errorString => _errorString;

  List<String>? _terms;

  List<String>? get terms => _terms;

  set terms(List<String>? value) {
    if (value == _terms) {
      return;
    }
    _terms = List<String>.from(value ?? <String>[]);
    notifyListeners();
  }

  String? _selectedTerm;

  String? get selectedTerm => _selectedTerm;

  set selectedTerm(String? value) {
    if (value == _selectedTerm) {
      return;
    }
    _selectedTerm = value;
    notifyListeners();
  }

  bool get hasScore => _scores?.isNotEmpty ?? false;

  List<ScoreModel>? _scores;

  List<ScoreModel>? get scores => _scores;

  set scores(List<ScoreModel>? value) {
    if (value == _scores) {
      return;
    }
    _scores = List<ScoreModel>.from(value ?? <ScoreModel>[]);
    notifyListeners();
  }

  List<ScoreModel>? get filteredScores => _scores
      ?.filter((ScoreModel score) => score.termId == _selectedTerm)
      .toList();

  List<ScoreModel>? scoresByTerm(String term) {
    return _scores?.filter((ScoreModel score) => score.termId == term).toList();
  }

  Future<void> initScore() async {
    final Map<dynamic, dynamic>? data = _scoreBox.get(UserAPI.user.uid);
    if (data != null && data['terms'] != null && data['scores'] != null) {
      _terms =
          (data['terms'] as List<dynamic>).reversed.toList().cast<String>();
      _scores = (data['scores'] as List<dynamic>).cast<ScoreModel>();
      _loaded = true;
    }
    if (await initSocket()) {
      requestScore();
    }
  }

  Future<bool> initSocket() async {
    try {
      _socket = await Socket.connect(API.openjmuHost, 4000);
      _socket
        ?..setOption(SocketOption.tcpNoDelay, true)
        ..timeout(2.minutes);
      _socket?.listen(onReceive, onDone: destroySocket);
      LogUtil.d('Score socket connect success.');
      return true;
    } catch (e) {
      _loading = false;
      _loadError = true;
      _errorString = e.toString();
      LogUtil.e('Score socket connect error: $e');
      return false;
    }
  }

  Future<void> requestScore() async {
    if (!loading) {
      loading = true;
    }
    _rawData.clear();
    _scoreData = '';
    try {
      _socket?.add(jsonEncode(<String, dynamic>{
        'uid': UserAPI.user.uid,
        'sid': UserAPI.loginModel!.sid,
        'workid': UserAPI.user.workId,
      }).toUtf8());
    } catch (e) {
      if (e.toString().contains('StreamSink is closed')) {
        if (await initSocket()) {
          requestScore();
        }
      } else {
        loading = false;
        LogUtil.e('Error when request score: $e');
      }
    }
  }

  Future<void> onReceive(List<int> data) async {
    try {
      _rawData.addAll(data);
      final String value = utf8.decode(_rawData);
      _scoreData += value;
      if (_scoreData.endsWith(']}}')) {
        tryDecodeScores();
      }
    } catch (_) {}
  }

  void tryDecodeScores() {
    try {
      final Map<dynamic, dynamic> response =
          jsonDecode(_scoreData)['obj'] as Map<dynamic, dynamic>;
      if ((response['terms'] as List<dynamic>).isNotEmpty &&
          (response['scores'] as List<dynamic>).isNotEmpty) {
        final List<ScoreModel> scoreList = <ScoreModel>[];
        _terms = List<String>.from(response['terms'] as List<dynamic>);
        _selectedTerm = _terms!.last;
        for (final dynamic score in response['scores'] as List<dynamic>) {
          scoreList.add(ScoreModel.fromJson(score as Map<String, dynamic>));
        }
        if (_scores != scoreList) {
          _scores = scoreList;
        }
      }
      _rawData.clear();
      _scoreData = '';
      updateScoreCache();
      if (_loadError) {
        _loadError = false;
      }
      if (!_loaded) {
        _loaded = true;
      }
      _loading = false;
      notifyListeners();
      LogUtil.d(
        'Scores decoded successfully with ${_scores?.length ?? 0} scores.',
      );
    } catch (e) {
      LogUtil.e('Decode scores response error: $e');
    }
  }

  Future<void> updateScoreCache() async {
    final Map<String, dynamic>? beforeData =
        _scoreBox.get(UserAPI.user.uid)?.cast<String, dynamic>();
    if (beforeData == null || beforeData['scores'] != _scores) {
      final Map<String, dynamic> presentData = <String, dynamic>{
        'terms': _terms,
        'scores': _scores,
      };
      await _scoreBox.put(UserAPI.user.uid, presentData);
      LogUtil.d('Scores cache updated successfully.');
    } else {
      LogUtil.d('Scores cache don\'t need to update.');
    }
  }

  void selectTerm(String term) {
    if (_selectedTerm != term) {
      selectedTerm = term;
    }
  }

  void unloadScore() {
    _loaded = false;
    _loading = true;
    _loadError = false;
    _terms = null;
    _selectedTerm = null;
    _rawData.clear();
    _scores = null;
    _scoreData = '';
  }

  Future<void> destroySocket() async {
    await _socket?.close();
    _socket?.destroy();
  }

  @override
  void dispose() {
    unloadScore();
    destroySocket();
    super.dispose();
  }
}
