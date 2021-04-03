///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 14:55
///
part of 'data_model.dart';

@JsonSerializable()
@HiveType(typeId: HiveAdapterTypeIds.webapp)
class WebAppModel extends DataModel {
  const WebAppModel({
    required this.appId,
    required this.sequence,
    required this.code,
    required this.name,
    required this.url,
    required this.menuType,
  });

  factory WebAppModel.fromJson(Map<String, dynamic> json) =>
      _$WebAppModelFromJson(json);

  @JsonKey(name: 'appid')
  @HiveField(0)
  final int appId;
  @HiveField(1)
  final int sequence;
  @HiveField(2)
  final String code;
  @HiveField(3)
  final String name;
  @HiveField(4)
  final String url;
  @JsonKey(name: 'menutype')
  @HiveField(5)
  final String menuType;

  @override
  List<Object?> get props =>
      <Object?>[appId, sequence, code, name, url, menuType];

  @override
  Map<String, dynamic> toJson() => _$WebAppModelToJson(this);

  /// Using [appId] and [code] to produce an unique id.
  String get uniqueId => '$appId-$code';

  String get replacedUrl {
    final RegExp sidReg = RegExp(r'{SID}');
    final RegExp uidReg = RegExp(r'{UID}');
    final String result = url
        .replaceAllMapped(sidReg, (Match match) => UserAPI.loginModel!.sid)
        .replaceAllMapped(uidReg, (Match match) => UserAPI.user.uid);
    return result;
  }

  static const Map<String, String> category = <String, String>{
//        '10': '个人事务',
    'A4': '我的服务',
    'A3': '我的系统',
    'A8': '流程服务',
    'A2': '我的媒体',
    'A1': '我的网站',
    'A5': '其他',
    '20': '行政办公',
    '30': '客户关系',
    '40': '知识管理',
    '50': '交流中心',
    '60': '人力资源',
    '70': '项目管理',
    '80': '档案管理',
    '90': '教育在线',
    'A0': '办公工具',
    'Z0': '系统设置',
  };
}
