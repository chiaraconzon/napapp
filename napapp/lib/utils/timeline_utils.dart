import '../screens/calendar_page.dart';
import '../models/nap_models.dart';

// Represents an item displayed in the timeline (event or nap)
class ListItem {
  final MyEvent? event;
  final NapResult? napResult;
  // Creates a timeline item containing an event
  ListItem.event(this.event) : napResult = null;
  // Creates a timeline item containing a nap suggestion
  ListItem.nap(this.napResult) : event = null;

  // Checks whether this item is a nap
  bool get isNap => napResult != null;

  // Returns the starting time in minutes from midnight
  int get startMin {
    if (isNap) {
      final s = napResult!.suggestedStart!;
      return s.hour * 60 + s.minute;
    }
    return event!.startTime.hour * 60 + event!.startTime.minute;
  }
}

// Builds a sorted timeline containing events and recommended naps
List<ListItem> buildTimeline(List<MyEvent> eventi, NapResult? r) {
  final items = <ListItem>[];

  // Add existing calendar events to the timeline
  for (final ev in eventi) {
    items.add(ListItem.event(ev));
  }

  // Add nap suggestion only if it is valid and available
  if (r != null &&
      r.zone != NapZone.red &&
      r.napEffectiveMin > 0 &&
      r.suggestedStart != null) {
    items.add(ListItem.nap(r));
  }

  // Sort all items chronologically
  items.sort((a, b) => a.startMin.compareTo(b.startMin));

  return items;
}
