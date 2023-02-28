part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {
  final SocketService socketService;

  const ChatEvent({this.socketService});
}

class AddBand extends ChatEvent {
  final String name;

  const AddBand({
    SocketService socketService,
    this.name,
  }) : super(socketService: socketService);
}

class ListenBand extends ChatEvent {
  const ListenBand({
    SocketService socketService,
  }) : super(socketService: socketService);
}

class DismissBand extends ChatEvent {
  final String id;
  const DismissBand({
    SocketService socketService,
    this.id,
  }) : super(socketService: socketService);
}

class VoteBand extends ChatEvent {
  final String id;
  const VoteBand({
    SocketService socketService,
    this.id,
  }) : super(socketService: socketService);
}
