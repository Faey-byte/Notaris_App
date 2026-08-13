class PendingUploadData {
  final String label;
  final String fileId;
  final String matchKey;
  final String url;
  final String localFilePath;

  PendingUploadData({
    required this.label,
    required this.fileId,
    required this.matchKey,
    required this.url,
    required this.localFilePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'file_id': fileId,
      'matchkey': matchKey,
      'url': url,
      'local_path': localFilePath,
    };
  }
}
