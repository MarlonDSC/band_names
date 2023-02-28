import 'package:band_names/services/socket_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../models/band.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatInitial(bands: <Band>[])) {
    on<ChatEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<AddBand>(
      (event, emit) async {
        print(emit);
        print('👌👌👌 ${event.name}');
        // event.socketService.emit('add-band', {name: ${event.name}}');
        event.socketService.emit('add-band', {'name': event.name});
        await Future.delayed(const Duration(seconds: 1));
        ChatState newState = state;
        print('😒😒😒 ${newState.bands}');
        await Future.delayed(const Duration(seconds: 1), () {
          add(ListenBand(socketService: event.socketService));
          // emit(
          //   // ChatLoaded(bands: newState.bands),
          //   ChatLoaded(bands: )
          // );
        });
        // newState.bands.add();
      },
    );

    on<ListenBand>(
      (event, emit) async {
        dynamic newData;
        event.socketService.socket.on(
          'active-bands',
          (data) => {
            print(data),
            newData = data,
          },
        );
        await Future.delayed(const Duration(seconds: 1));
        print(newData);
        await Future.delayed(const Duration(seconds: 1), () {
          emit(
            ChatLoaded(
              bands:
                  (newData as List).map((band) => Band.fromMap(band)).toList(),
            ),
          );
        });
      },
    );

    on<DismissBand>(
      (event, emit) async {
        event.socketService.socket.emit('delete-band', {'id': event.id});
        await Future.delayed(const Duration(seconds: 1));
        emit(ChatLoaded(bands: state.bands));
      },
    );

    on<VoteBand>(
      (event, emit) async {
        event.socketService.socket.emit('vote-band', {'id': event.id});
        await Future.delayed(const Duration(seconds: 1));
        emit(ChatLoaded(bands: state.bands));
      },
    );
  }
}
