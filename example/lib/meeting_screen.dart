import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_meeting/zoom_options.dart';
import 'package:flutter_zoom_meeting/zoom_view.dart';
import 'package:flutter_zoom_example/services/zoom_api.dart';
import 'package:flutter_zoom_example/zoom/jwt.dart';
import 'package:flutter_zoom_example/zoom/zoom_functions.dart';


class MeetingWidget extends StatefulWidget {
  const MeetingWidget({Key? key}) : super(key: key);

  @override
  _MeetingWidgetState createState() => _MeetingWidgetState();
}

class _MeetingWidgetState extends State<MeetingWidget> {
  TextEditingController meetingIdController = TextEditingController();
  TextEditingController meetingPasswordController = TextEditingController();
  late Timer timer;

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text('Zoom Meeting'),
      ),
      body: SizedBox(
         width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Builder(
                builder: (context) {
                  // The basic Material Design action button.
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    onPressed: ()  async{
                      {

                        var responseToken =await generateZoomAccessToken();

                        String zoomAccessToken=responseToken['access_token'];



                       var responseMeeting =await createMeeting(zoomAccessToken);


                        joinMeeting(
                            meetingId: responseMeeting['id'].toString(),
                            zoomAccessToken: zoomAccessToken,
                            displayName: 'Zoualfkar',
                            password: responseMeeting['password']
                        );
                      }
                    },
                    child: const Text('Join'),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    onPressed: () async{

                      var responseToken =await generateZoomAccessToken();

                      String zoomAccessToken=responseToken['access_token'];



                      var responseMeeting =await createMeeting(zoomAccessToken);





                      startMeeting(
                        meetingId: responseMeeting['id'].toString(),
                        displayName: 'Zoualfkar',
                        zoomAccessToken: extractTextAfterZak(responseMeeting['start_url']),

                    );

                      },
                    child: const Text('Start Meeting'),
                  );
                },
              ),
            ),


          ],
        ),
      ),
    );
  }







}
