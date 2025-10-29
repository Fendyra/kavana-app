// File: lib/common/timezones.dart
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

List<String> getDisplayTimeZoneOptions() {
  return ['Lokal', ...timeZoneOptions];
}

Map<String, String> getDisplayTimeZoneNames() {
  return {
    'Lokal': 'Waktu Lokal (${tz.local.currentTimeZone.abbreviation})',
    ...timeZoneDisplayNames,
  };
}

const List<String> timeZoneOptions = [
  'Asia/Jakarta',
  'Asia/Makassar',
  'Asia/Jayapura',
  'Europe/London',
  'UTC',
];

const Map<String, String> timeZoneDisplayNames = {
  'Asia/Jakarta': 'WIB',
  'Asia/Makassar': 'WITA',
  'Asia/Jayapura': 'WIT',
  'Europe/London': 'London',
  'UTC': 'UTC',
};

String formatTimeForDisplay({
  required DateTime originalTime,
  required String displayTimeZoneId,
}) {
  try {
    final tz.Location sourceLocation = tz.local;
    final tz.TZDateTime sourceTime = tz.TZDateTime.from(originalTime, sourceLocation);

    tz.Location displayLocation;
    String displayName;

    if (displayTimeZoneId == 'Lokal') {
      displayLocation = sourceLocation;
      displayName = tz.local.currentTimeZone.abbreviation;
    } else {
      displayLocation = tz.getLocation(displayTimeZoneId);
      displayName = timeZoneDisplayNames[displayTimeZoneId] ?? displayTimeZoneId;
    }

    final tz.TZDateTime convertedTime = tz.TZDateTime.from(sourceTime, displayLocation);
    return '${DateFormat('HH:mm').format(convertedTime)} $displayName';
  } catch (e) {
    print('Error converting time: $e');
    return DateFormat('HH:mm').format(originalTime) + ' (Error)';
  }
}

String formatDateForDisplay(DateTime originalTime) {
  final tz.Location sourceLocation = tz.local;
  final tz.TZDateTime sourceTime = tz.TZDateTime.from(originalTime, sourceLocation);
  return DateFormat('EEEE, dd MMMM yyyy').format(sourceTime);
}
