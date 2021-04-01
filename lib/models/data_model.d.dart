///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/1/21 5:19 PM
///
part of 'data_model.dart';

final Map<Type, Function> dataModelFactories = <Type, DataFactory>{
  EmptyDataModel: (Map<String, dynamic> json) => EmptyDataModel.fromJson(json),
};
