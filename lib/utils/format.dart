import 'package:intl/intl.dart';

String timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} hour${d.inHours == 1 ? '' : 's'} ago';
  if (d.inDays < 7) return '${d.inDays} day${d.inDays == 1 ? '' : 's'} ago';
  return DateFormat.yMMMd().format(t);
}

String fullDate(DateTime t) => DateFormat("MMM d, y 'at' h:mm a").format(t);
String shortStamp(DateTime t) => DateFormat('MMM d, h:mm a').format(t);
