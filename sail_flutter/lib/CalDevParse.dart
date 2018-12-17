import 'dart:async';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';

// Event Calendar: aglqj6c518aatdsn5244ubgnr4@group.calendar.google.com
// Harbor: moe6r4aen5mu8aelggtli24q3k@group.calendar.google.com

final accountCredentials = new ServiceAccountCredentials.fromJson({
  "type": "service_account",
  "project_id": "skilled-boulder-207219",
  "private_key_id": "a98663eb578157fe2994c0b117cc86190ce7d0fe",
  "private_key":
      "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCz8YDXq+Ac45Yg\n3BRt5TEqNBhq1W22OLZ0uuSJtgAWW1Rh6tVHYDggq/YW/WIO4rQQSBWcelBfrJcO\nhgS11ofeluD8kzqpMCgZQU9DpBaqCnmumRYwpf9hlPdR+z95D4wfAgdwOsHs1qFg\nf6r9vWyI+wCI4KLjQo1qTXTZ4g2im8EcWYvYmc3obMUaHTkbMD3IVq08We14uBXL\nmkG/Rtogw2H1/n1sZ6x+X8Ompn+xHqtekYnw6vYjpZtlckiMW4kJg4Y1T+4c1uQJ\nHqHhdqQvL3bAkdbHs3RVpSmO8yjVuars4F5lwoBes6Zo0tQycVZOR738XNv3m4eD\nE0fdaj4nAgMBAAECggEAFSmMYRDuKQedAt1PK8N+HjwFOR9DqWAPGThXo1h7tyVj\njaZ8Ecpfn3wJ05dWHnEMAzQvEnmSFUZrd4JMcIQ783IkIKBCEF7BAINdSpO0NKhJ\nuj53zR3gpH3L/mDBjL/G12i6LjlC0FNHpF0vY2sRJiT64Z4lmfucPQnB+dPrjZl4\nAJF3rYTSUneQYrrb56YtdgsupCEnpVk5WBI1Rc6shkFwEplh4DcLIAQbNF0Jqmwn\nFwn9ZOnlSBtqgzf5YFYTyaI8B7JFdxUyFfzHDTFbZCxpVaUqzxsAOYb/btkUki2r\nMbBadfTpOCgpBhhsAMGLxwAzhsdjz6gqSpgGtTRRRQKBgQDuSENKTUybnwGLEak1\nw29WQhTgw843jiC4+VbdPkmmudkFwtzaroISQ6YqjpWYxrjviuHC1raHO1yeDujQ\n2fTG+HCvYQfCrkgRlu3JVRsyhnplkjxDM8Ggz8Peuc70DUrnnvE61nbfOuoxYDqn\nY4KitqAkR7SVWUGDaTXgVTKbPQKBgQDBUsBFusgUEZbXk2XCdUuFYpi7NKVLDIYq\n8KtXnbznPmUo1RpYkh973pSfgWF+7DJvAyF5DT3X0KFAvgASsrwucDLrOaRq0467\nwSme1tfyA9qqYWsAVFQpw2K/K9BgL4FvAtF09TwUSrfdN/oBOaHPICZlPoQ3+C5G\nPSlFz9OlMwKBgQCqnoXIW2dCe22wddnyzFkZq8GlW696qkOWD7v6OdKlFqhmbqyT\nzacHivcdu/E0bv8XTxvu1q3mUUQ1TTm56odSPaz6d4EGDqM+LRNhOZZ67D4SIs8R\n06qPCpYXEnc025vKFE5pMg32NApjhqMZHrD478nlkI6m7j1x6lEQrBDLhQKBgG99\n7e1I/0Kzsi65jyJKyzct2a99eSaDHo19JxPsoJksXuLho8QY4ZdqkoQ69aNhTOTB\nBXjurg/c/mJ8MUaXVffiNTt7jtsdD2Aw0nQMq5Wjq2Q/spoKCE/dowFln1MZkqgX\nE/1DwVZikQ8/zSsPtcXiYMJa/53Xv7g6ZachaIoJAoGAOyIAHR/zGLpt3sh9Onq1\nP6BXOCNrMvPP8qz6/QpvVh3FXJAVNjg7FD9HEtwy2ac+EJ9U4oSTVd0wtiNb5af5\nWUUi5hDFwc50+BqP50tYwHm4Xf1c52o6XlArSawNsZ9eg7Vj+SUGZb6yB5pF6iUP\nZuf+MoQTfIW2omLsjAMxHn8=\n-----END PRIVATE KEY-----\n",
  "client_email":
      "sail-calendar-access@skilled-boulder-207219.iam.gserviceaccount.com",
  "client_id": "116321247615690400407",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://accounts.google.com/o/oauth2/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url":
      "https://www.googleapis.com/robot/v1/metadata/x509/sail-calendar-access%40skilled-boulder-207219.iam.gserviceaccount.com"
});

var _scopes = [CalendarApi.CalendarReadonlyScope];

class CalDevParse {
  Events currLine;
  CalDevParse();
  // Future<bool> get initEventCal => _initEvent();
  // Future<bool> get initRoomCal => _initRoom();
  Future<Events> get eventList => _getEvents();
  Future<Events> get pastEvent => _getPastEvents();
  Future<Events> get roomAvailable => _getOpen();
  Events get lineUp => currLine;

  Future<Events> _getEvents() async {
    var completer = new Completer();
    Events returnOnHit = new Events();

    await clientViaServiceAccount(accountCredentials, _scopes)
        .then((client) async {
      print("sucess");
      print("${client.runtimeType.toString()}");
      var calendar = new CalendarApi(client);
      var now = new DateTime.now();
      try {
        var something = await calendar.events.list('aglqj6c518aatdsn5244ubgnr4@group.calendar.google.com', timeMin: now.toUtc(), singleEvents: false);
        print('the stream: ${something.runtimeType.toString()}');
        returnOnHit = something;
      } catch (e) {
        print('Error state: ${e.toString()}');
      }
    });
    completer.complete();
    print('hit end.');
    return returnOnHit;
  }

  Future<Events> _getPastEvents() async {
    var completer = new Completer();
    Events returnOnHit = new Events();

    await clientViaServiceAccount(accountCredentials, _scopes)
        .then((client) async {
      print("sucess");
      print("${client.runtimeType.toString()}");
      var calendar = new CalendarApi(client);
      var now = new DateTime.now();
      try {
        var result = await calendar.events
            .list('aglqj6c518aatdsn5244ubgnr4@group.calendar.google.com',
                singleEvents: false, timeMax: now.toUtc());
        returnOnHit = result;
        return returnOnHit;
      } catch (e) {
        print(e.toString());
      }
    });
    completer.complete();
    print('hit end.');
    return returnOnHit;
  }

  Future<Events> _getOpen() async {
    Events returnOnHit = new Events();
    var completer = new Completer();
    await clientViaServiceAccount(accountCredentials, _scopes)
        .then((client) async {
      print("sucess");
      print("${client.runtimeType.toString()}");
      var calendar = new CalendarApi(client);
      var now = new DateTime.now();
      try {
        var result = await calendar.events
            .list('moe6r4aen5mu8aelggtli24q3k@group.calendar.google.com',
                singleEvents: false, timeMin: now.toUtc(), timeMax: now.toUtc(),);
        returnOnHit = result;
        return returnOnHit;
      } catch (e) {
        print(e.toString());
      }
    });
    completer.complete();
    print('hit end.');
    return returnOnHit;
  }

  // Future<bool> _initEvent() {
  //   bool data = true;
  //   ;
  // }

  // Future<bool> _initRoom() {
  //   return true;
  // }
}
