// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginModel _$LoginModelFromJson(Map<String, dynamic> json) {
  return LoginModel(
    sid: json['sid'] as String,
    ticket: json['ticket'] as String,
    uid: json['uid'] as int,
    unitid: json['unitid'] as int,
    type: json['type'] as int,
    bindUapAccount: json['bind_uap_account'] as String,
    pwdtime: json['pwdtime'],
  );
}

Map<String, dynamic> _$LoginModelToJson(LoginModel instance) =>
    <String, dynamic>{
      'sid': instance.sid,
      'ticket': instance.ticket,
      'uid': instance.uid,
      'unitid': instance.unitid,
      'type': instance.type,
      'bind_uap_account': instance.bindUapAccount,
      'pwdtime': instance.pwdtime,
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
