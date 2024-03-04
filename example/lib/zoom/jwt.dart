import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_zoom_example/zoom/config.dart';



String generateZoomJWT() {
  final iat = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 30;
  final exp = iat + 60 * 60 * 2;

  final oPayload = {
    'sdkKey': kZoomMeetingSdkKeyForJWT,
    'iat': iat,
    'exp': exp,
    'appKey': kZoomMeetingSdkKeyForJWT,
    'tokenExp': iat + 60 * 60 * 2
  };

  final jwt = JWT(
    oPayload,
    header: {
      'alg': 'HS256',
      'typ': 'JWT',
    },
  );

  final jwtToken = jwt.sign(SecretKey(kZoomMeetingSdkSecretForJWT));

  return jwtToken;
}

bool isTokenExpired(String token) {
  try {
    final decodedToken = JWT.decode(token);
    final expirationTime = decodedToken.payload['tokenExp'] ?? 0;

    final currentTimeInSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return expirationTime <= currentTimeInSeconds;
  } catch (e) {
    return true; // Error during decoding or invalid token
  }
}


String extractTextAfterZak(String url) {
  // Find the index of 'zak='
  int index = url.indexOf('zak=');
  if (index != -1) {
    // Extract the substring after 'zak='
    return url.substring(index + 4);
  } else {
    return ''; // If 'zak=' not found, return an empty string
  }
}