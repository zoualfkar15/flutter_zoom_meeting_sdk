import 'dart:convert';

import 'package:flutter_zoom_example/zoom/config.dart';
import 'package:http/http.dart' as http;



generateZoomAccessToken()async{
  var url = Uri.https('zoom.us','/oauth/token');
  var response = await http.post(url,

      headers:{
       'Content-Type':'application/x-www-form-urlencoded',
        'Authorization':'Basic $kBase64Key',
      },
      body: {
    'grant_type': 'account_credentials',
        'account_id': kAccountId
  });
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');


  return jsonDecode(response.body);
}


createMeeting(zoomAccessToken)async{
  var url = Uri.https('api.zoom.us','/v2/users/me/meetings');
  var response = await http.post(url,
      headers:{
        'Content-Type':'application/json',
        'Authorization':'Bearer $zoomAccessToken',
      },
      body: jsonEncode({
        "topic": "My New Meeting",
        "type": 2,
        "start_time": "2024-01-15T12:03:00Z",
        "duration": 60,
        "password":"123456",
        "timezone": "UTC",
        "settings": {
          //"auto_recording": "cloud"

        }
      }));
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  return jsonDecode(response.body);

}
