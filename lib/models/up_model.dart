///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-10 21:58
///
part of 'data_model.dart';

/// 懂的都懂。
@HiveType(typeId: HiveAdapterTypeIds.up)
class UPModel extends DataModel {
  const UPModel(this.u, this.p);

  @HiveField(0)
  final String u;
  @HiveField(1)
  final String p;

  @override
  List<Object?> get props => <Object?>[u, p];

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'u': u, 'p': p};
}
