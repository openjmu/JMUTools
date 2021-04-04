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
@HiveType(typeId: HiveAdapterTypeIds.user)
class UserModel extends DataModel {
  const UserModel({
    required this.uid,
    required this.username,
    required this.gender,
    required this.workId,
    required this.signature,
    required this.type,
    this.sysAvatar = false,
    this.isFollowing = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserModel copyWith({
    String? uid,
    String? username,
    int? gender,
    String? workId,
    String? signature,
    int? type,
    bool? sysAvatar,
    bool? isFollowing,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      workId: workId ?? this.workId,
      signature: signature ?? this.signature,
      type: type ?? this.type,
      sysAvatar: sysAvatar ?? this.sysAvatar,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @JsonKey(fromJson: _uidToString)
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final int gender;
  @JsonKey(defaultValue: '0', name: 'workid')
  @HiveField(3)
  final String workId;
  @HiveField(4)
  final String? signature;
  @HiveField(5)
  final int type;
  @JsonKey(fromJson: _sysAvatarToBool, name: 'sysavatar')
  @HiveField(6)
  final bool sysAvatar;
  @JsonKey(defaultValue: false)
  @HiveField(7)
  final bool isFollowing;

  @override
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Methods for json fields convert.
  static String _uidToString(int value) => value.toString();

  static bool _sysAvatarToBool(int value) => value == 1;

  String get genderText => gender == 2 ? '女' : '男';

  /// 是否为教师
  bool get isTeacher => type == 1;

  /// 是否为研究生
  bool get isPostgraduate {
    if (workId.length != 12) {
      return false;
    } else {
      final int? code = int.tryParse(workId.substring(4, 6));
      if (code == null) {
        return false;
      }
      return code >= 10 && code <= 19;
    }
  }

  /// 是否为继续教育学生
  bool get isContinuingEducation {
    if (workId.length != 12) {
      return false;
    } else {
      final int? code = int.tryParse(workId.substring(4, 6));
      if (code == null) {
        return false;
      }
      return code >= 30 && code <= 39;
    }
  }

  /// 是否为诚毅学院学生
  bool get isCY {
    if (workId.length != 12) {
      return false;
    } else {
      final int? code = int.tryParse(workId.substring(4, 6));
      if (code == null) {
        return false;
      }
      return code >= 41 && code <= 45;
    }
  }

  @override
  List<Object?> get props => <Object?>[];
}
