import 'package:flutter/material.dart';

String getAppointmentStatus(Map<String, dynamic> data, DateTime date) {
  if (data['status'] == 'cancelled') return 'Cancelled';

  final today = DateTime.now();
  final onlyToday = DateTime(today.year, today.month, today.day);
  final onlyDate = DateTime(date.year, date.month, date.day);

  if (onlyDate.isBefore(onlyToday)) return 'Closed';

  return 'Pending';
}

Color getStatusColor(String status) {
  switch (status) {
    case 'Cancelled':
      return Colors.red;
    case 'Closed':
      return Colors.green;
    default:
      return Colors.orange;
  }
}
