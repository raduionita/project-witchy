/// Short human summary of a multi-select log set, e.g. 'Medium' or 'Happy +2'.
/// Falls back to [empty] so callers can always render one line of the same
/// height and the tile/card never collapses when nothing is logged yet.
String summarizeLogSet(Set<String> values, {String empty = 'Not logged'}) {
  if (values.isEmpty) return empty;
  return values.length > 1 ? '${values.first} +${values.length - 1}' : values.first;
}
