///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/4/2 16:49
///
part of 'data_model.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
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

  final String sid;
  final String ticket;
  final int uid;
  final int unitid;
  final int type;
  final String bindUapAccount;
  final Object? pwdtime;

  @override
  List<Object?> get props =>
      <Object?>[sid, ticket, uid, unitid, type, bindUapAccount, pwdtime];

  @override
  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}
