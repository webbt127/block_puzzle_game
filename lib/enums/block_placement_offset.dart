enum BlockPlacementOffset {
  none(0, 'None'),
  low(40, 'Low'),
  medium(70, 'Medium'),
  high(100, 'High');

  final int value;
  final String label;
  const BlockPlacementOffset(this.value, this.label);

  static BlockPlacementOffset fromString(String value) {
    return BlockPlacementOffset.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => BlockPlacementOffset.medium,
    );
  }
}
