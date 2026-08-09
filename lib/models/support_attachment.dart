/// What kind of file was attached to a [SupportTicket] — drives which icon
/// the New Ticket screen shows for the selected attachment.
enum SupportAttachmentType { image, document }

/// Local metadata for a file picked for a support ticket. No upload
/// happens yet — this only records enough to show the user what they
/// selected (and later, to hand off to a real upload call).
class SupportAttachment {
  const SupportAttachment({
    required this.fileName,
    required this.localPath,
    required this.type,
    this.sizeBytes,
  });

  final String fileName;
  final String localPath;
  final SupportAttachmentType type;
  final int? sizeBytes;
}
