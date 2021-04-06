// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseModelAdapter extends TypeAdapter<CourseModel> {
  @override
  final int typeId = 2;

  @override
  CourseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseModel(
      isCustom: fields[0] as bool,
      name: fields[1] as String,
      time: fields[2] as String,
      location: fields[3] as String?,
      className: fields[4] as String?,
      teacher: fields[5] as String?,
      day: fields[6] as int,
      startWeek: fields[7] as int?,
      endWeek: fields[8] as int?,
      classesName: (fields[10] as List?)?.cast<String>(),
      isEleven: fields[11] as bool,
      oddEven: fields[9] as int?,
      rawDay: fields[12] as int,
      rawTime: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CourseModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.isCustom)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.className)
      ..writeByte(5)
      ..write(obj.teacher)
      ..writeByte(6)
      ..write(obj.day)
      ..writeByte(7)
      ..write(obj.startWeek)
      ..writeByte(8)
      ..write(obj.endWeek)
      ..writeByte(9)
      ..write(obj.oddEven)
      ..writeByte(10)
      ..write(obj.classesName)
      ..writeByte(11)
      ..write(obj.isEleven)
      ..writeByte(12)
      ..write(obj.rawDay)
      ..writeByte(13)
      ..write(obj.rawTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoginModelAdapter extends TypeAdapter<LoginModel> {
  @override
  final int typeId = 0;

  @override
  LoginModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginModel(
      sid: fields[0] as String,
      uid: fields[3] as int,
      unitId: fields[4] as int,
      type: fields[5] as int,
      ticket: fields[1] as String?,
      blowfish: fields[2] as String?,
      bindUapAccount: fields[6] as String?,
      pwdTime: fields[7] as Object?,
    );
  }

  @override
  void write(BinaryWriter writer, LoginModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.sid)
      ..writeByte(1)
      ..write(obj.ticket)
      ..writeByte(2)
      ..write(obj.blowfish)
      ..writeByte(3)
      ..write(obj.uid)
      ..writeByte(4)
      ..write(obj.unitId)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.bindUapAccount)
      ..writeByte(7)
      ..write(obj.pwdTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScoreModelAdapter extends TypeAdapter<ScoreModel> {
  @override
  final int typeId = 3;

  @override
  ScoreModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoreModel(
      code: fields[0] as String?,
      courseName: fields[1] as String,
      score: fields[2] as String,
      termId: fields[3] as String,
      credit: fields[4] as double,
      creditHour: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ScoreModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.termId)
      ..writeByte(4)
      ..write(obj.credit)
      ..writeByte(5)
      ..write(obj.creditHour);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      uid: fields[0] as String,
      username: fields[1] as String,
      gender: fields[2] as int,
      workId: fields[3] as String,
      signature: fields[4] as String?,
      type: fields[5] as int,
      sysAvatar: fields[6] as bool,
      isFollowing: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.workId)
      ..writeByte(4)
      ..write(obj.signature)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.sysAvatar)
      ..writeByte(7)
      ..write(obj.isFollowing);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WebAppModelAdapter extends TypeAdapter<WebAppModel> {
  @override
  final int typeId = 4;

  @override
  WebAppModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WebAppModel(
      appId: fields[0] as int,
      sequence: fields[1] as int,
      code: fields[2] as String,
      name: fields[3] as String,
      url: fields[4] as String,
      menuType: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WebAppModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.appId)
      ..writeByte(1)
      ..write(obj.sequence)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.menuType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebAppModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginModel _$LoginModelFromJson(Map<String, dynamic> json) {
  return LoginModel(
    sid: json['sid'] as String,
    uid: json['uid'] as int,
    unitId: json['unitid'] as int,
    type: json['type'] as int,
    ticket: json['ticket'] as String?,
    blowfish: json['blowfish'] as String?,
    bindUapAccount: json['bind_uap_account'] as String?,
    pwdTime: json['pwdtime'],
  );
}

Map<String, dynamic> _$LoginModelToJson(LoginModel instance) =>
    <String, dynamic>{
      'sid': instance.sid,
      'ticket': instance.ticket,
      'blowfish': instance.blowfish,
      'uid': instance.uid,
      'unitid': instance.unitId,
      'type': instance.type,
      'bind_uap_account': instance.bindUapAccount,
      'pwdtime': instance.pwdTime,
    };

ScoreModel _$ScoreModelFromJson(Map<String, dynamic> json) {
  return ScoreModel(
    code: json['code'] as String?,
    courseName: json['courseName'] as String,
    score: json['score'] as String,
    termId: json['termId'] as String,
    credit: ScoreModel._toDouble(json['credit'] as String),
    creditHour: ScoreModel._toDouble(json['creditHour'] as String),
  );
}

Map<String, dynamic> _$ScoreModelToJson(ScoreModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'courseName': instance.courseName,
      'score': instance.score,
      'termId': instance.termId,
      'credit': ScoreModel._toString(instance.credit),
      'creditHour': ScoreModel._toString(instance.creditHour),
    };

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return UserModel(
    uid: UserModel._uidToString(json['uid'] as int),
    username: json['username'] as String,
    gender: json['gender'] as int,
    workId: json['workid'] as String? ?? '0',
    signature: json['signature'] as String?,
    type: json['type'] as int,
    sysAvatar: UserModel._sysAvatarToBool(json['sysavatar'] as int),
    isFollowing: json['is_following'] as bool? ?? false,
  );
}

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'gender': instance.gender,
      'workid': instance.workId,
      'signature': instance.signature,
      'type': instance.type,
      'sysavatar': instance.sysAvatar,
      'is_following': instance.isFollowing,
    };

WebAppModel _$WebAppModelFromJson(Map<String, dynamic> json) {
  return WebAppModel(
    appId: json['appid'] as int,
    sequence: json['sequence'] as int,
    code: json['code'] as String,
    name: json['name'] as String,
    url: json['url'] as String,
    menuType: json['menutype'] as String,
  );
}

Map<String, dynamic> _$WebAppModelToJson(WebAppModel instance) =>
    <String, dynamic>{
      'appid': instance.appId,
      'sequence': instance.sequence,
      'code': instance.code,
      'name': instance.name,
      'url': instance.url,
      'menutype': instance.menuType,
    };
