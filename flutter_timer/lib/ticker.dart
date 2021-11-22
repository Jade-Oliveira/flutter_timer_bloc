class Ticker {
  const Ticker();
  //função que pega o número de ticks(segundos) que informamos e retorna uma stream que emite os segundos restantes a cada segundo
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(const Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
  }

  //seria o data source
  //o próximo passo é criar um TimerBloc que vai consumir o Ticker
}
