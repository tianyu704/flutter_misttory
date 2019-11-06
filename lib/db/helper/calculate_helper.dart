import 'package:flutter/material.dart';
import 'package:misstory/db/helper/location_helper.dart';
import 'package:misstory/models/mslocation.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-11-04
///
class CalculateHelper {
  static final CalculateHelper _instance = new CalculateHelper._internal();

  factory CalculateHelper() => _instance;

  CalculateHelper._internal();

  Future createOrUpdateLocation(Mslocation mslocation) async{
    if (mslocation != null && mslocation.errorCode == 0) {
      Mslocation targetLocation = await LocationHelper().findTargetLocationWithPicture(mslocation);
      if(targetLocation != null){

      }else{

      }
    }
  }
}
