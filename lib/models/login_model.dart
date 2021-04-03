///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/4/2 16:49
///
part of 'data_model.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: HiveAdapterTypeIds.login)
class LoginModel extends DataModel {
  const LoginModel({
    required this.sid,
    required this.ticket,
    required this.uid,
    required this.unitid,
    required this.type,
    required this.bindUapAccount,
    this.pwdtime,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  @HiveField(0)
  final String sid;
  @HiveField(1)
  final String ticket;
  @HiveField(2)
  final int uid;
  @HiveField(3)
  final int unitid;
  @HiveField(4)
  final int type;
  @HiveField(5)
  final String bindUapAccount;
  @HiveField(6)
  final Object? pwdtime;

  @override
  List<Object?> get props =>
      <Object?>[sid, ticket, uid, unitid, type, bindUapAccount, pwdtime];

  @override
  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}
