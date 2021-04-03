///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/1/21 4:46 PM
///
import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:jmu_tools/apis/course_api.dart';
import 'package:jmu_tools/apis/user_api.dart';
import 'package:jmu_tools/constants/boxes.dart';
import 'package:jmu_tools/exports/utils.dart';

part 'data_model.d.dart';

part 'data_model.g.dart';

part 'course_model.dart';

part 'login_model.dart';

part 'score_model.dart';

part 'user_model.dart';

part 'web_app_model.dart';

abstract class DataModel extends Equatable {
  const DataModel();

  Map<String, dynamic> toJson();

  @override
  String toString() => GlobalJsonEncoder.convert(toJson());
}

typedef DataFactory<T extends DataModel> = T Function(
  Map<String, dynamic> json,
);

T makeModel<T extends DataModel>(Map<dynamic, dynamic> json) {
  if (!dataModelFactories.containsKey(T)) {
    LogUtil.e(
      'You\'re reflecting an unregistered/abnormal model type: $T',
    );
    throw TypeError();
  }
  return dataModelFactories[T]!(json) as T;
}

List<T> makeModels<T extends DataModel>(List<dynamic> json) {
  if (!dataModelFactories.containsKey(T)) {
    LogUtil.e(
      'You\'re reflecting an unregistered/abnormal model type: $T',
    );
    throw TypeError();
  }
  return json.map((dynamic e) => dataModelFactories[T]!(e) as T).toList();
}

class EmptyDataModel extends DataModel {
  const EmptyDataModel();

  factory EmptyDataModel.fromJson(Map<String, dynamic> _) =>
      const EmptyDataModel();

  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};

  @override
  List<Object?> get props => <Object?>[null];
}
