/*

the followoing is the existing code to track the progress of joining on the sender side:

class SendingNotificationException implements Exception {
  final String message;

  SendingNotificationException(this.message);

  @override
  String toString() => "SendingNotificationException: $message";
}

class ReceivingNotificationException implements Exception {
  final String message;

  ReceivingNotificationException(this.message);

  @override
  String toString() => "ReceivingNotificationException: $message";
}

class JoiningGameException implements Exception {
  final String message;

  JoiningGameException(this.message);

  @override
  String toString() => "JoiningGameException: $message";
}

class RejectingGameException implements Exception {
  final String message;

  RejectingGameException(this.message);

  @override
  String toString() => "RejectingGameException: $message";
}

class PlayingFirstMoveException implements Exception {
  final String message;

  PlayingFirstMoveException(this.message);

  @override
  String toString() => "PlayingFirstMoveException: $message";
}

abstract class Connection {
  void sendNotification(String message);
  void friendReceivedNotification();
  void friendJoinedGame();
  void friendRejected();
  void friendPlayedFirstMove();
}

enum ConnectionCompletionState {
  notificationSent,
  friendReceivedNotification,
  friendJoinedGame,
  friendRejected,
  friendPlayedFirstMove,
}

//enums for active state
enum ConnectionActiveState {
  sendingNotification,
  receivingNotification,
  joiningGame,
  rejectingGame,
  playingFirstMove,
}

//enums for err
enum ConnectionErrorType {
  notificationSent,
  receivingNotification,
  joiningGame,
  rejectingGame,
  playingFirstMove,
}

class GameConnection with ChangeNotifier {
  ConnectionCompletionState completionState = ConnectionCompletionState.notificationSent;
  ConnectionErrorType? errorType;
  ConnectionActiveState? activeState;
  Exception? exception;

  void markComplete(ConnectionCompletionState state) {
    completionState = state;
    notifyListeners();
  }

  void markActive(ConnectionActiveState state) {
    activeState = state;
    notifyListeners();
  }

  void markConnectionError(ConnectionErrorType error, [Exception? exception]) {
    errorType = error;
    this.exception = exception;
    notifyListeners();
  }

  Future<void> simulateConnection() async {
    // markActive(ConnectionActiveState.sendingNotification);
    await Future.delayed(const Duration(seconds: 2));
    // markConnectionError(ConnectionErrorType.notificationSent);
    markActive(ConnectionActiveState.receivingNotification);
    await Future.delayed(const Duration(seconds: 2));

    // markComplete(ConnectionCompletionState.friendReceivedNotification);
    // setConnectionError(ConnectionErrorType.notificationSent);

    // setConnectionError(ConnectionErrorType.receivingNotification);
    // await Future.delayed(const Duration(seconds: 2));
    // markActive(ConnectionActiveState.joiningGame);

    // await Future.delayed(const Duration(seconds: 2));
    // markComplete(ConnectionCompletionState.friendJoinedGame);
    //friend rejects to join
    // markConnectionError(ConnectionErrorType.joiningGame, JoiningGameException('Friend rejected to join'));

    // markActive(ConnectionActiveState.playingFirstMove);

    // await Future.delayed(const Duration(seconds: 2));
    // markComplete(ConnectionCompletionState.friendPlayedFirstMove);
  }
}


final connection = GameConnection();



Here we are gonna test a complicated messaging scenario. here is the scenario:

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Initialize Firebase for background handlers if needed
    await Firebase.initializeApp();

    log('Handling background message');
    log('Background Message data: ${message.data}');
    log('Background notification title: ${message.notification?.title ?? ''}');
    log('Background notification body: ${message.notification?.body ?? ''}');
    userProvider.forceShowMaterialBanner(
      title: message.notification?.title ?? '',
      content: message.notification?.body ?? '',
    );
  }

  static void firebaseInit() {
    // Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');
      log(message.notification?.title ?? '');
      log(message.notification?.body ?? '');

      userProvider.forceShowMaterialBanner(
        title: message.notification?.title ?? '',
        content: message.notification?.body ?? '',
      );
    });

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // When app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        log('App opened from terminated state');
        log('Initial Message data: ${message.data}');
        log('Initial notification title: ${message.notification?.title ?? ''}');
        log('Initial notification body: ${message.notification?.body ?? ''}');
        userProvider.forceShowMaterialBanner(
          title: message.notification?.title ?? '',
          content: message.notification?.body ?? '',
        );
      }
    });

    // When app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('App opened from background state');
      log('Background Message data: ${message.data}');
      log('Background notification title: ${message.notification?.title ?? ''}');
      log('Background notification body: ${message.notification?.body ?? ''}');
      userProvider.forceShowMaterialBanner(
        title: message.notification?.title ?? '',
        content: message.notification?.body ?? '',
      );
    });
  }


  we need to create a stream that simulates the incoming messages and test the behavior of the app in each case.
  we also need to test for sending message.
    static Future<void> sendNotificationToToken(String tokenID, RemoteMessage message) async {
    try {
      // FCM server URL
      const String fcmUrl = 'https://fcm.googleapis.com/v1/projects/cellz-final/messages:send';

      // Get server key from Firebase console
      String serverKey = await GetServiceKey.getServiceKeyToken();

      // Headers required by FCM
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      };

      // Construct message payload
      final Map<String, dynamic> messageData = {
        'message': {
          'token': tokenID,
          'notification': {
            'title': message.notification?.title,
            'body': message.notification?.body,
          },
          'data': message.data,
        }
      };

      // Make HTTP POST request with JSON-encoded body
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: headers,
        body: jsonEncode(messageData), // Properly encode the JSON body
      );

      if (response.statusCode == 200) {
        log('FCM message sent successfully to token: $tokenID');
      } else {
        log('Failed to send FCM message. Status code: ${response.statusCode}');
        log('Error: ${response.body}');
        throw NotificationException('Failed to send FCM message');
      }
    } catch (e) {
      log('Error sending FCM message: $e');
      throw NotificationGeneralFailException('Failed to send FCM message');
      // rethrow;
    }
  }
}

all the above code is from the current messaging api class that i have setup in the app. which needs to be refined and tested.

we need to use the Facade pattern to make the code more testable and maintainable.
Following is what the scenario is about:
this app is about connecting two users to play with each other.
first person is the sender who sends the request to the second person who is the joiner.
SenderMessengerFacade is the class that is responsible for sending the request to the joiner.
JoinerMessengerFacade is the class that is responsible for receiving the request from the sender.

Following is the series of messages exchanged for the game to start:
lets first specify the types of messages that can be exchanged:
SenderMessengerFacade:
  message_type: 'please_play_with_me'
  message_type: 'i_am_busy' //this is to tell other people that the sender is already asking someone else to play with him.

JoinerMessengerFacade:
  message_type: 'i_am_live' //this is to tell the sender has recieved and noticed the notification. either from background or foreground.
  message_type: 'i_am_down' //this is to tell the sender that the joiner agrees to play with the sender.
  message_type: 'i_am_not_down' //this is to tell the sender that the joiner has rejected the request to play with the sender.
  message_type: 'first_line_created' //this is to tell the sender that the joiner has created the first line of the game. now the sender can start the game.

StoryLine:
here is what the exchange of messages looks like:
  1. Sender sends the request to the joiner.
  2. Joiner receives the request and sends the 'i_am_live' message to the sender.
  3. Joiner sends the 'i_am_down' message to the sender. or 'i_am_not_down' message to the sender.
  4. Sender receives the 'i_am_down' message.
  5. Joiner sends the 'first_line_created' message to the sender.

here is what the payload of the message looks like:
  {
    'message_type': 'please_play_with_me',
    'from': 'sender's token',
    'to': 'joiner's token',
    time: 'time of the message in milliseconds since epoch'
    level_index: 'integer value of the level index'
  }

*we will also need to update the ui on the sender side to show the progress of joining the game.
we need to make sure that the state updates based on the success, failure or progress of the messages exchanged.

 */


