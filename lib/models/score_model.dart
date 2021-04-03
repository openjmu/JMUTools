///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 01:20
///
part of 'data_model.dart';

@JsonSerializable()
@HiveType(typeId: HiveAdapterTypeIds.score)
class ScoreModel extends DataModel {
  const ScoreModel({
    required this.code,
    required this.courseName,
    required this.score,
    required this.termId,
    required this.credit,
    required this.creditHour,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreModelFromJson(json);

  @HiveField(0)
  final String code;
  @HiveField(1)
  final String courseName;
  @HiveField(2)
  final String score;
  @HiveField(3)
  final String termId;
  @JsonKey(fromJson: _toDouble, toJson: _toString)
  @HiveField(4)
  final double credit;
  @JsonKey(fromJson: _toDouble, toJson: _toString)
  @HiveField(5)
  final double creditHour;

  static double _toDouble(String value) => value.toDouble();

  static String _toString(Object value) => value.toString();

  /// Replace `XX.00` to `XX`.
  String get formattedScore => score.removeSuffix('.00');

  bool get isPass {
    bool _isPass;
    if (double.tryParse(score) != null) {
      _isPass = double.parse(score) >= 60.0;
    } else {
      if (fiveBandScale.containsKey(score)) {
        _isPass = fiveBandScale[score]!.score >= 60.0;
      } else if (twoBandScale.containsKey(score)) {
        _isPass = twoBandScale[score]!.score >= 60.0;
      } else {
        _isPass = false;
      }
    }
    return _isPass;
  }

  double get scorePoint {
    double _scorePoint = 0.0;
    if (score.toDoubleOrNull() != null) {
      final String oneDigitScoreString = score.toDouble().toStringAsFixed(1);
      final double oneDigitScore = oneDigitScoreString.toDouble();
      _scorePoint = (oneDigitScore - 50) / 10;
      if (_scorePoint < 1.0) {
        _scorePoint = 0.0;
      }
    } else {
      if (fiveBandScale.containsKey(score)) {
        _scorePoint = fiveBandScale[score]!.point;
      } else if (twoBandScale.containsKey(score)) {
        _scorePoint = twoBandScale[score]!.point;
      }
    }
    return _scorePoint;
  }

  @override
  List<Object?> get props =>
      <Object?>[code, courseName, score, termId, credit, creditHour];

  @override
  Map<String, dynamic> toJson() => _$ScoreModelToJson(this);
}

class _ScoreBand {
  const _ScoreBand(this.score, this.point);

  final double score;
  final double point;
}

/// 五级绩点标准
const Map<String, _ScoreBand> fiveBandScale = <String, _ScoreBand>{
  '优秀': _ScoreBand(95.0, 4.625),
  '良好': _ScoreBand(85.0, 3.875),
  '中等': _ScoreBand(75.0, 3.125),
  '及格': _ScoreBand(65.0, 2.375),
  '不及格': _ScoreBand(55.0, 0.0),
};

/// 二级绩点标准
const Map<String, _ScoreBand> twoBandScale = <String, _ScoreBand>{
  '合格': _ScoreBand(80.0, 3.5),
  '不合格': _ScoreBand(50.0, 0.0),
};
