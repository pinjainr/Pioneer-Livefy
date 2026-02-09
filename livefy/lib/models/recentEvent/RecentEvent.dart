class RecentEvent {
  final String tripId;
  final String eventType;
  final String timestamp;
  final PresignedUrl? presignedUrl;

  RecentEvent({
    required this.tripId,
    required this.eventType,
    required this.timestamp,
    this.presignedUrl,
  });

  factory RecentEvent.fromJson(Map<String, dynamic> json) {
    return RecentEvent(
      tripId: json['tripId'] ?? '',
      eventType: json['eventType'] ?? '',
      timestamp: json['timestamp'] ?? '',
      presignedUrl: json['presignedUrl'] != null
          ? PresignedUrl.fromJson(json['presignedUrl'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PresignedUrl {
  final String front;
  final String rear;
  final String cabin;

  PresignedUrl({
    required this.front,
    required this.rear,
    required this.cabin,
  });

  factory PresignedUrl.fromJson(Map<String, dynamic> json) {
    return PresignedUrl(
      front: json['front'] ?? '',
      rear: json['rear'] ?? '',
      cabin: json['cabin'] ?? '',
    );
  }
}
