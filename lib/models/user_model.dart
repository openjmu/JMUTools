///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-01 20:41
///
part of 'data_model.dart';

/// 用户信息实体
///
/// [sid] 用户token, [ticket] 用户用于更新token的凭证, [blowfish] 用户设备随机uuid,
/// [uid] 用户uid, [unitId] 组织/学校id, [workId] 工号/学号,
/// [name] 名字, [signature] 签名, [gender] 性别, [isFollowing] 是否已关注
@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel extends DataModel {
  const UserModel({
    required this.sid,
    required this.uid,
    required this.name,
    required this.signature,
    required this.ticket,
    required this.blowfish,
    this.isTeacher = false,
    required this.unitId,
    required this.workId,
    required this.gender,
    this.isFollowing = false,
    this.sysAvatar = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserModel copyWith({
    String? sid,
    String? ticket,
    String? blowfish,
    bool? isTeacher,
    String? uid,
    int? unitId,
    int? gender,
    String? name,
    String? signature,
    String? workId,
    bool? isFollowing,
    bool? sysAvatar,
  }) {
    return UserModel(
      sid: sid ?? this.sid,
      ticket: ticket ?? this.ticket,
      blowfish: blowfish ?? this.blowfish,
      isTeacher: isTeacher ?? this.isTeacher,
      uid: uid ?? this.uid,
      unitId: unitId ?? this.unitId,
      gender: gender ?? this.gender,
      name: name ?? this.name,
      signature: signature ?? this.signature,
      workId: workId ?? this.workId,
      isFollowing: isFollowing ?? this.isFollowing,
      sysAvatar: sysAvatar ?? this.sysAvatar,
    );
  }

  final String sid;
  final String ticket;
  final String blowfish;
  @JsonKey(defaultValue: false)
  final bool isTeacher;
  final String uid;
  final int unitId;
  final int gender;
  final String name;
  final String? signature;
  final String? workId;
  @JsonKey(defaultValue: false)
  final bool isFollowing;
  @JsonKey(defaultValue: false)
  final bool sysAvatar;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get genderText => gender == 2 ? '女' : '男';

  /// 是否为研究生
  bool get isPostgraduate {
    if (workId?.length != 12) {
      return false;
    } else {
      final int? code = int.tryParse(workId!.substring(4, 6));
      if (code == null) {
        return false;
      }
      return code >= 10 && code <= 19;
    }
  }

  /// 是否为继续教育学生
  bool get isContinuingEducation {
    if (workId?.length != 12) {
      return false;
    } else {
      final int? code = int.tryParse(workId!.substring(4, 6));
      if (code == null) {
        return false;
      }
      return code >= 30 && code <= 39;
    }
  }

  /// 是否为诚毅学院学生
  bool get isCY {
    if (workId?.length != 12) {
      return false;
    } else {
      final int? code = int.tryParse(workId!.substring(4, 6));
      if (code == null) {
        return false;
      }
      return code >= 41 && code <= 45;
    }
  }

  @override
  List<Object?> get props => <Object?>[];
}
