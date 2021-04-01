// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return UserModel(
    sid: json['sid'] as String,
    uid: json['uid'] as String,
    name: json['name'] as String,
    signature: json['signature'] as String?,
    ticket: json['ticket'] as String,
    blowfish: json['blowfish'] as String,
    isTeacher: json['is_teacher'] as bool? ?? false,
    unitId: json['unit_id'] as int,
    workId: json['work_id'] as String?,
    gender: json['gender'] as int,
    isFollowing: json['is_following'] as bool? ?? false,
    sysAvatar: json['sys_avatar'] as bool? ?? false,
  );
}

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'sid': instance.sid,
      'ticket': instance.ticket,
      'blowfish': instance.blowfish,
      'is_teacher': instance.isTeacher,
      'uid': instance.uid,
      'unit_id': instance.unitId,
      'gender': instance.gender,
      'name': instance.name,
      'signature': instance.signature,
      'work_id': instance.workId,
      'is_following': instance.isFollowing,
      'sys_avatar': instance.sysAvatar,
    };
