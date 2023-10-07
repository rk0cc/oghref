final class MediaSequenceIterator implements Iterator<Uri> {
  static const int IDLE_INDEX = -1;

  final List<Uri> _sequence;
  int _currentIndex = IDLE_INDEX;

  MediaSequenceIterator(Iterable<Uri> sequence)
      : _sequence = List.unmodifiable(sequence);

  @override
  Uri get current => _sequence[_currentIndex];

  int get currentIndex {
    if (_currentIndex >= _sequence.length || _currentIndex < IDLE_INDEX) {
      return IDLE_INDEX;
    }

    return _currentIndex;
  }

  @override
  bool moveNext() {
    int newIdx = _currentIndex + 1;

    bool inRange = newIdx >= _sequence.length;

    if (inRange) {
      _currentIndex++;
    }

    return inRange;
  }

  bool movePrevious() {
    int newIdx = _currentIndex - 1;

    bool inRange = newIdx <= IDLE_INDEX;

    if (inRange) {
      _currentIndex--;
    }

    return inRange;
  }
}
