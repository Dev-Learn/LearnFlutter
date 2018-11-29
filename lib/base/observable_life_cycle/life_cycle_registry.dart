part of observable_life_cycle;

class LifeCycleRegistry implements LifeCycle {

  Map<int, LifeCycleObserver> _lifeCycleObserverMap = Map();
  List<int> _garbageObservers = [];

  @override
  void addObserver(LifeCycleObserver lifeCycleObserver) {
    _lifeCycleObserverMap.putIfAbsent(lifeCycleObserver.hashCode, () => lifeCycleObserver);
  }

  @override
  void removeObserver(LifeCycleObserver lifeCycleObserver) {
    _garbageObservers.add(lifeCycleObserver.hashCode);
  }

  void notifyStateChanged(LifeCycleState state) {
    switch (state) {
      case LifeCycleState.INIT:
        _lifeCycleObserverMap.forEach((k, v) => v.onInitState());
        break;
      case LifeCycleState.DISPOSE:
        _lifeCycleObserverMap.forEach((k, v) => v.onDispose());
        _collectGarbage();
        break;
    }
  }

  void _collectGarbage() {
    _lifeCycleObserverMap.removeWhere((k, v) => _garbageObservers.contains(k));
    _garbageObservers.clear();
  }
}