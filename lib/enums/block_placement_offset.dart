enum BlockPlacementOffset {
  none(0, 'None'),
  low(50, 'Low'),
  medium(100, 'Medium'),
  high(150, 'High');

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
