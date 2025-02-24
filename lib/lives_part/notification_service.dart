//Throwing exceptions

import 'dart:developer';

import 'package:flutter/material.dart';

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
}

var theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
);

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

//! notification services:

abstract class ASenderFacade {
  int currentStage = 0; //0: initial, 1: request sent, 2: request received, 3: request accepted, 4: first line created
  String joinerToken = '';

  Future<void> processSendingNotification(Map<String, dynamic> message);
  Future<void> processIsLive(Map<String, dynamic> message);
  Future<void> processHasAccepted(Map<String, dynamic> message); //could be accepted or rejected
  Future<void> processFirstLineNotification(Map<String, dynamic> message);

  void updateStage(int stage) {
    currentStage = stage;
  }

  setJoinerToken(String token) {
    //set the joiner tokens
    log('Joiner token set to: $token');
    joinerToken = token;
  }
}

abstract class AJoinerFacade {
  int currentStage = 0; //0: initial, 1: request received, 2: request accepted, 3: first line created

  Future<void> processIncomingRequest(Map<String, dynamic> message);
  Future<void> sendAcceptedRequest(Map<String, dynamic> message);
  Future<void> sendRejectedRequest(Map<String, dynamic> message);
  Future<void> sendFirstLineNotification(Map<String, dynamic> message);

  void updateStage(int stage) {
    currentStage = stage;
  }

  void logStage() {
    print('Current stage: $currentStage');
  }
}

class SenderMessengerFacade extends ASenderFacade {
  @override
  Future<void> processSendingNotification(Map<String, dynamic> message) async {
    //incase if an error is inside the connection, don't proceed
    if (CentralFacade.connection.errorType != null) {
      return;
    }

    //send the notification to the joiner
    //simulating the sending of the notification
    CentralFacade.connection.markActive(ConnectionActiveState.sendingNotification);
    await Future.delayed(const Duration(seconds: 2));
    CentralFacade.connection.markComplete(ConnectionCompletionState.notificationSent);

    updateStage(1);
  }

  @override
  Future<void> processIsLive(Map<String, dynamic> message) async {
    if (CentralFacade.connection.errorType != null) {
      return;
    }
    //joiner has received the notification
    CentralFacade.connection.markActive(ConnectionActiveState.receivingNotification);
    await Future.delayed(const Duration(seconds: 2));
    CentralFacade.connection.markComplete(ConnectionCompletionState.friendReceivedNotification);

    updateStage(2);
  }

  @override
  Future<void> processHasAccepted(Map<String, dynamic> message) async {
    if (CentralFacade.connection.errorType != null) {
      return;
    }
    //joiner has accepted the request

    CentralFacade.connection.markActive(ConnectionActiveState.joiningGame);
    await Future.delayed(const Duration(seconds: 2));
    CentralFacade.connection.markComplete(ConnectionCompletionState.friendJoinedGame);

    updateStage(3);
  }

  @override
  Future<void> processFirstLineNotification(Map<String, dynamic> message) async {
    if (CentralFacade.connection.errorType != null) {
      return;
    }
    //joiner has created the first line

    CentralFacade.connection.markActive(ConnectionActiveState.playingFirstMove);
    await Future.delayed(const Duration(seconds: 2));
    CentralFacade.connection.markComplete(ConnectionCompletionState.friendPlayedFirstMove);

    updateStage(4);
  }
}

class JoinerMessengerFacade extends AJoinerFacade {
  @override
  Future<void> processIncomingRequest(Map<String, dynamic> message) async {
    //joiner has received the request

    updateStage(1);
  }

  @override
  Future<void> sendAcceptedRequest(Map<String, dynamic> message) async {
    //joiner has accepted the request

    updateStage(2);
  }

  @override
  Future<void> sendRejectedRequest(Map<String, dynamic> message) async {
    //joiner has rejected the request

    updateStage(2);
  }

  @override
  Future<void> sendFirstLineNotification(Map<String, dynamic> message) async {
    //joiner has created the first line

    updateStage(3);
  }
}

//lets create a centralFacade that will handle the incoming messages and route them to the appropriate facade
class CentralFacade {
  static final ASenderFacade sender = SenderMessengerFacade();
  static final AJoinerFacade joiner = JoinerMessengerFacade();
  static final connection = GameConnection();

  void resetToBasics() {
    sender.updateStage(0);
    sender.joinerToken = '';
    joiner.updateStage(0);
    connection.markComplete(ConnectionCompletionState.notificationSent);
    connection.errorType = null;
    connection.activeState = null;
  }

  Future<void> processIncomingMessage(Map<String, dynamic> message) async {
    switch (message['message_type']) {
      case 'please_play_with_me':
        //check if the joiner token is not empty then that means that sender is already waiting joiner so ignore the message
        if (sender.joinerToken.isNotEmpty) {
          log('Joiner token is not empty, routing message to joiner');
          return;
        }

        log('joiner has received the request to play');
        await joiner.processIncomingRequest(message);
        break;
      case 'i_am_live':
        log('sender has received the notification that joiner is live');
        await sender.processIsLive(message);
        break;
      case 'i_am_down':
        log('joiner has accepted the request to play');
        await sender.processHasAccepted(message);
        break;

      case 'i_am_not_down':
        log('joiner has rejected the request to play');
        await sender.processHasAccepted(message);
        break;

      case 'first_line_created':
        log('joiner has created the first line');
        await sender.processFirstLineNotification(message);
        break;
      default:
        log('Invalid message type');
    }
  }
}

//test the notification services by sending a mock message to the central facade



/*
  await sender.processSendingNotification({
        'message_type': 'please_play_with_me',
        'from': 'sender_token',
        'to': 'joiner_token',
        'time': DateTime.now().millisecondsSinceEpoch,
        'level_index': 1,
      });

      // Test joiner receives and acknowledges
      await joiner.processIncomingRequest({
        'message_type': 'please_play_with_me',
        'from': 'sender_token',
        'to': 'joiner_token',
        'time': DateTime.now().millisecondsSinceEpoch,
        'level_index': 1,
      });

      // Test joiner accepts
      await joiner.sendAcceptedRequest({
        'message_type': 'i_am_down',
        'from': 'joiner_token',
        'to': 'sender_token',
        'time': DateTime.now().millisecondsSinceEpoch,
        'level_index': 1,
      });

      // Test sender processes acceptance
      await sender.processHasAccepted({
        'message_type': 'i_am_down',
        'from': 'joiner_token',
        'to': 'sender_token',
        'time': DateTime.now().millisecondsSinceEpoch,
        'level_index': 1,
      });

      // Test joiner creates first line
      await joiner.sendFirstLineNotification({
        'message_type': 'first_line_created',
        'from': 'joiner_token',
        'to': 'sender_token',
        'time': DateTime.now().millisecondsSinceEpoch,
        'level_index': 1,
      });

      // Test sender receives first line notification
      await sender.processFirstLineNotification({
        'message_type': 'first_line_created',
        'from': 'joiner_token',
        'to': 'sender_token',
        'time': DateTime.now().millisecondsSinceEpoch,
        'level_index': 1,
      });
    });


 */