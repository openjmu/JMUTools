part of 'data_model.dart';

final Map<Type, Function> dataModelFactories = <Type, DataFactory>{
  EmptyDataModel: (Map<String, dynamic> json) => EmptyDataModel.fromJson(json),
  UserModel: (Map<String, dynamic> json) => UserModel.fromJson(json),
};
