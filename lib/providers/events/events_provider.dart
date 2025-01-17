import 'package:Medito/repositories/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'events_provider.g.dart';

@riverpod
Future<void> events(
  ref, {
  required Map<String, dynamic> event,
}) {
  final events = ref.watch(eventsRepositoryProvider);

  return events.trackEvent(event);
}
