class CustomStack<T> {
  final list = List<T>();
  T pop() {
    return list.removeLast();
  }

  void push(T item) {
    return list.add(item);
  }

  void addAll(List<T> items) {
    for (T item in items) {
      this.push(item);
    }
  }

  T peek() {
    return list[list.length - 1];
  }

  int size() {
    return list.length;
  }

  bool isEmpty() {
    return list.isEmpty;
  }

  bool isNotEmpty() {
    return list.isNotEmpty;
  }
}
