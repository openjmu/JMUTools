///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/1/21 4:46 PM
///
import 'package:equatable/equatable.dart';
import 'package:jmu_tools/constants/constants.dart';
import 'package:jmu_tools/utils/log_util.dart';

part 'data_model.d.dart';

abstract class DataModel extends Equatable {
  const DataModel();

  Map<String, dynamic> toJson();

  @override
  String toString() => GlobalJsonEncoder.convert(toJson());
}

typedef DataFactory<T extends DataModel> = T Function(
  Map<String, dynamic> json,
);

T? makeModel<T extends DataModel>(dynamic json) {
  if (!dataModelFactories.containsKey(T)) {
    LogUtil.e(
      'You\'re reflecting an unregistered/abnormal model type: $T',
    );
    return null;
  }
  return dataModelFactories[T]!(json) as T;
}

class EmptyDataModel extends DataModel {
  const EmptyDataModel();

  factory EmptyDataModel.fromJson(dynamic _) => const EmptyDataModel();

  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};

  @override
  List<Object?> get props => <Object?>[null];
}
