import 'package:bulka_frontend/models/public_listing.dart';

/// What kind of file was attached to a [SupportTicket] — drives which icon
/// (or image preview) is shown for it.
enum SupportAttachmentType { image, document }

/// A file attached to a support ticket: either picked on this device for a
/// new ticket ([localPath]) or one the backend already has ([url]).
class SupportAttachment {
  const SupportAttachment({
    required this.fileName,
    required this.type,
    this.localPath = '',
    this.url,
    this.sizeBytes,
  });

  /// From a ticket's `attachments` in `GET /api/me/tickets/{id}`. The
  /// backend hasn't returned one yet, so this reads the usual media asset
  /// field names and tolerates any of them being missing.
  factory SupportAttachment.fromJson(Map<String, dynamic> json) {
    final url = resolveMediaUrl((json['publicUrl'] ?? json['url']) as String?);
    final fileName =
        (json['originalFileName'] ?? json['fileName']) as String? ??
        Uri.tryParse(url ?? '')?.pathSegments.lastOrNull ??
        '';
    final contentType = (json['contentType'] ?? json['mimeType']) as String?;
    final size = json['sizeBytes'] ?? json['fileSizeBytes'];
    return SupportAttachment(
      fileName: fileName,
      url: url,
      type: _isImage(contentType, fileName)
          ? SupportAttachmentType.image
          : SupportAttachmentType.document,
      sizeBytes: size is num ? size.toInt() : null,
    );
  }

  static bool _isImage(String? contentType, String fileName) {
    if (contentType != null) return contentType.startsWith('image/');
    final name = fileName.toLowerCase();
    return const [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.heic',
    ].any(name.endsWith);
  }

  final String fileName;
  final SupportAttachmentType type;

  /// Where the picked file is on this device; empty for a backend file.
  final String localPath;

  /// Where the backend serves the file; null for a picked file.
  final String? url;
  final int? sizeBytes;
}
