part of 'chat_bloc.dart';

@immutable
abstract class ChatState {
  // final SocketService socketService;
  final List<Band> bands;

  const ChatState({this.bands});
}

class ChatInitial extends ChatState {
  const ChatInitial({List<Band> bands}) : super(bands: bands);
}

class ChatLoaded extends ChatState {
  const ChatLoaded({List<Band> bands}) : super(bands: bands);
}
