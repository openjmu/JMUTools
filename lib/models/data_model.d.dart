part of 'data_model.dart';

final Map<Type, Function> dataModelFactories = <Type, DataFactory>{
  EmptyDataModel: (Map<String, dynamic> json) => EmptyDataModel.fromJson(json),
  LoginModel: (Map<String, dynamic> json) => LoginModel.fromJson(json),
  ScoreModel: (Map<String, dynamic> json) => ScoreModel.fromJson(json),
  UserModel: (Map<String, dynamic> json) => UserModel.fromJson(json),
  WebAppModel: (Map<String, dynamic> json) => WebAppModel.fromJson(json),
};
