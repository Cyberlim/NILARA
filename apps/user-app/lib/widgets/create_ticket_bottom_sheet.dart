import 'package:flutter/material.dart';
import 'create_ticket_dialog.dart';
export 'create_ticket_dialog.dart';

/// Backward-compatible alias for showCreateTicketDialog
Future<void> showCreateTicketBottomSheet(
  BuildContext context, {
  VoidCallback? onTicketCreated,
}) {
  return showCreateTicketDialog(
    context,
    onTicketCreated: onTicketCreated,
  );
}
