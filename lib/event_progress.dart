import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

//Throwing exceptions

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

  void markComplete(ConnectionCompletionState state) {
    completionState = state;
    notifyListeners();
  }

  void markActive(ConnectionActiveState state) {
    activeState = state;
    notifyListeners();
  }

  void markConnectionError(ConnectionErrorType error) {
    errorType = error;
    notifyListeners();
  }

  Future<void> simulateConnection() async {
    await Future.delayed(const Duration(seconds: 2));
    markConnectionError(ConnectionErrorType.notificationSent);
    // markConnectionError(ConnectionErrorType.notificationSent);
    markActive(ConnectionActiveState.receivingNotification);
    await Future.delayed(const Duration(seconds: 2));

    await Future.delayed(const Duration(seconds: 2));
    markComplete(ConnectionCompletionState.friendReceivedNotification);
    // setConnectionError(ConnectionErrorType.notificationSent);

    // setConnectionError(ConnectionErrorType.receivingNotification);
    await Future.delayed(const Duration(seconds: 2));
    markActive(ConnectionActiveState.joiningGame);

    await Future.delayed(const Duration(seconds: 2));
    markComplete(ConnectionCompletionState.friendJoinedGame);

    await Future.delayed(const Duration(seconds: 2));
    markComplete(ConnectionCompletionState.friendPlayedFirstMove);
  }
}

var theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
);

class EventProgress extends StatelessWidget {
  const EventProgress({super.key});

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => GameConnection(),
      child: Consumer<GameConnection>(
        builder: (context, connection, _) => Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedTimeline.tileBuilder(
                builder: TimelineTileBuilder.connected(
                  nodePositionBuilder: (_, __) => 0.1,
                  connectionDirection: ConnectionDirection.after,
                  itemCount: 4,
                  connectorBuilder: (_, index, __) => SolidLineConnector(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                  contentsBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return _buildTimelineContent('Sending Notification', true, connection.errorType == ConnectionErrorType.notificationSent);
                      case 1:
                        return _buildTimelineContent('Friend Received Notification', connection.completionState.index >= ConnectionCompletionState.friendReceivedNotification.index, connection.errorType == ConnectionErrorType.receivingNotification);
                      case 2:
                        return _buildTimelineContent('Friend Joined Game', connection.completionState.index >= ConnectionCompletionState.friendJoinedGame.index, connection.errorType == ConnectionErrorType.joiningGame);
                      case 3:
                        return _buildTimelineContent('Friend Played First Move', connection.completionState == ConnectionCompletionState.friendPlayedFirstMove, connection.errorType == ConnectionErrorType.playingFirstMove);
                      default:
                        return null;
                    }
                  },
                  indicatorBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return _buildIndicator(false, true, connection.errorType == ConnectionErrorType.notificationSent);
                      case 1:
                        return _buildIndicator(connection.activeState == ConnectionActiveState.receivingNotification, connection.completionState.index >= ConnectionCompletionState.friendReceivedNotification.index, connection.errorType == ConnectionErrorType.receivingNotification);
                      case 2:
                        return _buildIndicator(connection.activeState == ConnectionActiveState.joiningGame, connection.completionState.index >= ConnectionCompletionState.friendJoinedGame.index, connection.errorType == ConnectionErrorType.joiningGame);
                      case 3:
                        return _buildIndicator(connection.activeState == ConnectionActiveState.playingFirstMove, connection.completionState == ConnectionCompletionState.friendPlayedFirstMove, connection.errorType == ConnectionErrorType.playingFirstMove);
                      default:
                        return null;
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => connection.simulateConnection(),
                child: const Text('Start Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineContent(String title, bool isComplete, bool hasError) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: hasError
              ? theme.colorScheme.errorContainer.withOpacity(0.1)
              : isComplete
                  ? theme.colorScheme.primaryContainer.withOpacity(0.1)
                  : theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
          boxShadow: [
            if (isComplete)
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: AnimatedDefaultTextStyle(
          curve: Curves.easeOutQuad,
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            color: hasError ? theme.colorScheme.error : theme.colorScheme.onSurface,
            fontWeight: isComplete ? FontWeight.w900 : FontWeight.normal,
            fontSize: 16,
          ),
          child: Text(title),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive, bool isComplete, bool hasError) {
    log('isActive: $isActive, isComplete: $isComplete, hasError: $hasError');
    if (hasError) {
      return DotIndicator(
        size: 26,
        color: theme.colorScheme.error,
        child: Icon(Icons.close, color: theme.colorScheme.onError, size: 20),
      );
    }
    if (isComplete) {
      return const DotIndicator(size: 26, color: Colors.green, child: Icon(Icons.check, color: Colors.white, size: 20));
    }
    if (isActive) {
      return DotIndicator(
        size: 26,
        color: theme.colorScheme.surface,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          strokeWidth: 3,
          strokeCap: StrokeCap.round,
        ),
      );
    }

    return OutlinedDotIndicator(
      color: Colors.transparent,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: Colors.grey),
        ),
      ),
    );
  }
}
