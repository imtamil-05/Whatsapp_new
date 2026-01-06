import 'package:intl/intl.dart';

String formatLastSeen(String isoTime) {
  final lastSeen= DateTime.parse(isoTime);

  final now = DateTime.now();
  final difference = now.difference(lastSeen);

  if (difference.inMinutes<20) {
    return 'Online';
  }

  if(now.day==lastSeen.day&&now.month==lastSeen.month&&now.year==lastSeen.year){ 
    return 'last seen today at ${DateFormat('hh:mm a').format(lastSeen)}';
  }

  if (now.subtract(Duration(days: 1)).day ==lastSeen.day){
    return 'last seen yesterday at ${DateFormat('hh:mm a').format(lastSeen)}';
  }

  return 'last seen on ${DateFormat('dd/MM/yyyy').format(lastSeen)} at ${DateFormat('hh:mm a').format(lastSeen)}';
}