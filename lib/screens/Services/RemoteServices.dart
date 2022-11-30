
import 'package:http/http.dart' as http;
import 'package:smart_shop/Announcements.dart';

import '../../main.dart';

class RemoteServices{
  Future <List<Announcements>?> getAllAnnouncements() async{
    var client = http.Client();

    var uri = Uri.parse("${Domain.dgaExpressPort}announcements");
    var response = await client.get(uri);
    if(response.statusCode == 200){
      var json = response.body;
      return announcementsFromJson(json);
    }
  }
}