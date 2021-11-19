import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:flutter_timer/bloc/timer_event.dart';
import 'package:flutter_timer/bloc/timer_state.dart';
import 'package:flutter_timer/ticker.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  static const int _duration = 60;

  StreamSubscription<int>? _tickerSubscription;

  //definindo um estado inicial para o TimerBloc e passando um timer de 60 segundos
  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(
          const TimerInitial(_duration),
        ) {
    on<TimerStarted>(_onStarted);
  }
}
