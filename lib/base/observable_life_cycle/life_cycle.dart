part of observable_life_cycle;


abstract class LifeCycle {
  void addObserver(LifeCycleObserver lifeCycleObserver);

  void removeObserver(LifeCycleObserver lifeCycleObserver);
}

enum LifeCycleState {
  INIT, DISPOSE
}