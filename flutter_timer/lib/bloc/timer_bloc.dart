import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:flutter_timer/bloc/timer_event.dart';
import 'package:flutter_timer/bloc/timer_state.dart';
import 'package:flutter_timer/ticker.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  static const int _duration = 60;

  //definindo uma streamSubscription para o Ticker
  //*quando observamos uma Stream através do listen, o retorno é uma StreamSubscription
  //esse subscription fornece eventos ao listener e usa o retorno das funções para manipular eventos, tambpém pode cancelar ou pausar os eventos
  StreamSubscription<int>? _tickerSubscription;

  //definindo um estado inicial para o TimerBloc e passando um timer de 60 segundos
  //injetando o Ticker pelo construtor do TimerBloc
  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(
          const TimerInitial(_duration),
        ) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<TimerTicked>(_onTicked);
  }

  //aqui sobreescreve o método close para cancelar o tickerSubcription quando o bloc for fechado
  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  //manipuladores de eventos

  //se o bloc recebe um evento TimerStarted, ele puxa o estado TimerRunInProgress com a duração inicial
  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration));

    //cancela o tickerSubscription para desalocar memória
    _tickerSubscription?.cancel();
    //observamos o ticker e a cada tick adicionamos um evento TimerTicked com a duração restante
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(TimerTicked(duration: duration)));
  }

  //se o estado no momento da pausa for TimerRunInProgress, pausamos a subscription e mudamos o estado para TimerRunPause pegando o tempo de duração restante
  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  void _onResumed(TimerResumed resume, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerInitial(_duration));
  }

  //a cada vez que um evento TimerTicked é recebido e a duração é maior que 0 precisa atualizar o estado do TimerRunInProgress pegando o novo tempo de duração
  //se for menor ou igual a 0 ele completa o timer, passa para o estado TimerRunComplete
  void _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    emit(
      event.duration > 0
          ? TimerRunInProgress(event.duration)
          : const TimerRunComplete(),
    );
  }
}
