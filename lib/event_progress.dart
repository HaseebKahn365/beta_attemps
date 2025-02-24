import 'dart:developer';

import 'package:beta_attemps/lives_part/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

CentralFacade centralFacade = CentralFacade();

class EventProgress extends StatelessWidget {
  const EventProgress({super.key});

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return ChangeNotifierProvider.value(
      value: CentralFacade.connection,
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
                        return _buildTimelineContent('Sending Notification', true, connection.errorType == ConnectionErrorType.notificationSent, context);
                      case 1:
                        return _buildTimelineContent('Friend Received Notification', connection.completionState.index >= ConnectionCompletionState.friendReceivedNotification.index, connection.errorType == ConnectionErrorType.receivingNotification, context);
                      case 2:
                        return _buildTimelineContent('Friend Joined Game', connection.completionState.index >= ConnectionCompletionState.friendJoinedGame.index, connection.errorType == ConnectionErrorType.joiningGame, context);
                      case 3:
                        return _buildTimelineContent('Friend Played First Move', connection.completionState == ConnectionCompletionState.friendPlayedFirstMove, connection.errorType == ConnectionErrorType.playingFirstMove, context);
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
                onPressed: () async {
                  await centralFacade.processIncomingMessage({
                    'message_type': 'please_play_with_me',
                    'from': 'sender_token',
                    'to': 'joiner_token',
                    'time': DateTime.now().millisecondsSinceEpoch,
                    'level_index': 1,
                  });

                  //lets mark an error in the connection

                  await centralFacade.processIncomingMessage({
                    'message_type': 'i_am_live',
                    'from': 'joiner_token',
                    'to': 'sender_token',
                    'time': DateTime.now().millisecondsSinceEpoch,
                    'level_index': 1,
                  });

                  await centralFacade.processIncomingMessage({
                    'message_type': 'i_am_down',
                    'from': 'joiner_token',
                    'to': 'sender_token',
                    'time': DateTime.now().millisecondsSinceEpoch,
                    'level_index': 1,
                  });
                  CentralFacade.connection.markConnectionError(ConnectionErrorType.notificationSent, SendingNotificationException('Notification not sent'));

                  await centralFacade.processIncomingMessage({
                    'message_type': 'first_line_created',
                    'from': 'joiner_token',
                    'to': 'sender_token',
                    'time': DateTime.now().millisecondsSinceEpoch,
                    'level_index': 1,
                  });
                },
                child: const Text('Start Connection'),
              ),

              //another button to reset the central facade
              ElevatedButton(
                onPressed: () {
                  centralFacade.resetToBasics();
                },
                child: const Text('Reset Connection'),
              ),

              //if an error has occured, show the leave game button
              if (connection.errorType != null)
                ElevatedButton(
                  onPressed: () {
                    centralFacade.resetToBasics();
                  },
                  child: const Text('Leave Game'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineContent(String title, bool isComplete, bool hasError, BuildContext context) {
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              curve: Curves.easeInBack,
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: hasError ? theme.colorScheme.error : theme.colorScheme.onSurface,
                fontWeight: isComplete ? FontWeight.w900 : FontWeight.normal,
                fontSize: 16,
              ),
              child: Text(title),
            ),
            //icon button for dialog box in case of exception
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  icon: const Icon(Icons.error_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: Text(CentralFacade.connection.exception.toString()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
          ],
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
