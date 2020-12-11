import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlocCommand {}

class CloseScreen extends BlocCommand {}

class ShowSnackBar extends BlocCommand {
  final String message;

  ShowSnackBar(this.message);
}


abstract class ExtendedBloc<Event, State> extends Bloc<Event, State> {

  ExtendedBloc(State initialState) : super(initialState);

  final _commandsController = StreamController<BlocCommand>.broadcast();

  Stream get commandsStream => _commandsController.stream;

  void sendCommand(BlocCommand command) {
    _commandsController.add(command);
  }

  @override
  Future<void> close() async {
    await _commandsController.close();
    return super.close();
  }
}

class BlocCommandsListener<B extends ExtendedBloc> extends StatefulWidget {
  final Function(BuildContext context, BlocCommand command) listener;
  final Widget child;

  BlocCommandsListener({
    @required this.listener,
    this.child,
  });

  @override
  _BlocCommandsListenerState<B> createState() => _BlocCommandsListenerState<B>();
}

class _BlocCommandsListenerState<B extends ExtendedBloc> extends State<BlocCommandsListener> {
  B _bloc;
  StreamSubscription<BlocCommand> _subscription;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<B>(context);
    _subscribe();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _subscribe() {
    if (_bloc != null) {
      _bloc.commandsStream.listen(
        (command) {
          widget.listener(context, command);
        },
      );
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}
