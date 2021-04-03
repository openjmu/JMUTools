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
    required this.uid,
    required this.unitId,
    required this.type,
    required this.bindUapAccount,
    this.ticket,
    this.blowfish,
    this.pwdTime,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  @HiveField(0)
  final String sid;
  @HiveField(1)
  final String? ticket;
  @HiveField(2)
  final String? blowfish;
  @HiveField(3)
  final int uid;
  @JsonKey(name: 'unitid')
  @HiveField(4)
  final int unitId;
  @HiveField(5)
  final int type;
  @HiveField(6)
  final String bindUapAccount;
  @JsonKey(name: 'pwdtime')
  @HiveField(7)
  final Object? pwdTime;

  @override
  List<Object?> get props => <Object?>[
        sid,
        ticket,
        blowfish,
        uid,
        unitId,
        type,
        bindUapAccount,
        pwdTime,
      ];

  @override
  Map<String, dynamic> toJson() => _$LoginModelToJson(this);

  LoginModel copyWith({
    String? sid,
    String? ticket,
    String? blowfish,
    int? uid,
    int? unitId,
    int? type,
    String? bindUapAccount,
    Object? pwdTime,
  }) {
    return LoginModel(
      sid: sid ?? this.sid,
      ticket: ticket ?? this.ticket,
      blowfish: blowfish ?? this.blowfish,
      uid: uid ?? this.uid,
      unitId: unitId ?? this.unitId,
      type: type ?? this.type,
      bindUapAccount: bindUapAccount ?? this.bindUapAccount,
      pwdTime: pwdTime ?? this.pwdTime,
    );
  }

  LoginModel merge(LoginModel other) {
    return LoginModel(
      sid: other.sid,
      ticket: other.ticket ?? ticket,
      blowfish: other.blowfish ?? blowfish,
      uid: other.uid,
      unitId: other.unitId,
      type: other.type,
      bindUapAccount: other.bindUapAccount,
      pwdTime: other.pwdTime ?? pwdTime,
    );
  }
}
