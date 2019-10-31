///
/// Create by Hugo.Guo
/// Date: 2019-06-17
///
class ResultData {
  var data;
  bool result;
  int code;
  var headers;

  ResultData(this.data, this.result, this.code, {this.headers});

  @override
  String toString() {
    // TODO: implement toString
    return "code:$code,result=$result,data=$data";
  }
}
