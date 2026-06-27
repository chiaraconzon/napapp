import '../screens/calendar_page.dart';
import '../models/nap_models.dart';

// =============================================================================
// ITEM LISTA (evento o pisolino)
// =============================================================================
class ListItem {
  final MyEvent? event;
  final NapResult? napResult;

  ListItem.event(this.event) : napResult = null;
  ListItem.nap(this.napResult) : event = null;

  bool get isNap => napResult != null;

  int get startMin {
    if (isNap) {
      final s = napResult!.suggestedStart!;
      return s.hour * 60 + s.minute;
    }
    return event!.startTime.hour * 60 + event!.startTime.minute;
  }
}

List<ListItem> buildTimeline(List<MyEvent> eventi, NapResult? r) {
  final items = <ListItem>[];

  for (final ev in eventi) {
    items.add(ListItem.event(ev));
  }

  if (r != null &&
      r.zone != NapZone.red &&
      r.napEffectiveMin > 0 &&
      r.suggestedStart != null) {
    items.add(ListItem.nap(r));
  }

  items.sort((a, b) => a.startMin.compareTo(b.startMin));

  return items;
}
