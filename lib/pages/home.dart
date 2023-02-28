import 'dart:io';

import 'package:band_names/services/chat/chat_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   List<Band> bands = [];

//   @override
//   void initState() {
//     // final socketService = Provider.of<SocketService>(context, listen: false);

//     // socketService.socket.on('active-bands', _handleActiveBands);
//     super.initState();
//   }

  // _handleActiveBands(dynamic payload) {
  //   bands = (payload as List).map((band) => Band.fromMap(band)).toList();

  //   setState(() {});
  // }

  // @override
  // void dispose() {
  //   final socketService = Provider.of<SocketService>(context, listen: false);
  //   socketService.socket.off('active-bands');
  //   super.dispose();
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Container();
  // }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    // context.read<ChatBloc>().add(ChatInitial(bands: []));
    context.read<ChatBloc>().add(ListenBand(socketService: socketService));

    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 10),
            // child: (socketService.serverStatus == ServerStatus.online)
            //     ? Icon(Icons.check_circle, color: Colors.blue[300])
            //     : const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              switch (state.runtimeType) {
                case ChatInitial:
                  return const Center(
                    child: Text('No data to display'),
                  );
                case ChatLoaded:
                  return _showGraph(state.bands);
                default:
                  return Center(
                    child: Text('State: ${state.toString()}'),
                  );
              }
            },
          ),
          Expanded(
            // child: Container(color: Colors.blue),
            child: BlocBuilder<ChatBloc, ChatState>(
              // listener: (context, state) {
              //   // TODO: implement listener
              // },
              builder: (context, state) {
                switch (state.runtimeType) {
                  case ChatInitial:
                    return const Center(
                      child: Text('No bands'),
                    );
                  case ChatLoaded:
                    return ListView.builder(
                      itemCount: state.bands.length,
                      itemBuilder: (context, i) =>
                          _bandTile(context, state.bands[i]),
                    );
                  default:
                    return Center(
                      child: Text('State: ${state.toString()}'),
                    );
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: () => addNewBand(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(BuildContext context, Band band) {
    // final socketService = Provider.of<SocketService>(context, listen: false);

    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      // onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
      onDismissed: (_) => context
          .read<ChatBloc>()
          .add(DismissBand(socketService: socketService, id: band.id)),
      // onDismissed: BlocProvider.of<ChatBloc>(context, listen: false).add(DismissBand(socketService: socketService, id: band.id)),
      background: Container(
          padding: const EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Delete Band', style: TextStyle(color: Colors.white)),
          )),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        // onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
        onTap: () => context
            .read<ChatBloc>()
            .add(VoteBand(socketService: socketService, id: band.id)),
      ),
    );
  }

  addNewBand(BuildContext context) {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      // Android
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('New band name:'),
          content: TextField(
            controller: textController,
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList(context, textController.text),
              child: const Text('Add'),
            )
          ],
        ),
      );
    }

    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: const Text('New band name:'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: const Text('Add'),
                    onPressed: () =>
                        addBandToList(context, textController.text)),
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: const Text('Dismiss'),
                    onPressed: () => Navigator.pop(context))
              ],
            ));
  }

  void addBandToList(BuildContext context, String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      context
          .read<ChatBloc>()
          .add(AddBand(socketService: socketService, name: name));
      // socketService.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  // Mostrar gráfica
  Widget _showGraph(List<Band> bands) {
    Map<String, double> dataMap = {};
    // dataMap.putIfAbsent('Flutter', () => 5);
    for (var band in bands) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }

    final List<Color> colorList = [
      Colors.blue[50],
      Colors.blue[200],
      Colors.pink[50],
      Colors.pink[200],
      Colors.yellow[50],
      Colors.yellow[200],
    ];

    return Container(
        padding: const EdgeInsets.only(top: 10),
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: const Duration(milliseconds: 800),
          // showChartValuesInPercentage: true,
          // showChartValues: true,
          // showChartValuesOutside: false,
          // chartValueBackgroundColor: Colors.grey[200],
          colorList: colorList,
          // showLegends: true,
          // decimalPlaces: 0,
          chartType: ChartType.ring,
        ));
  }
}
