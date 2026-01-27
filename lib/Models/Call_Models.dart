class CallModel {
  final String callId;
  final String callerId;
  final String receiverId;
  final String type;
  final String status;
  final String channelId;

  CallModel({
    required this.callId,
    required this.callerId,
    required this.receiverId,
    required this.type,
    required this.status,
    required this.channelId,
  });

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'receiverId': receiverId,
      'type': type,
      'status': status,
      'channelId': channelId,
      'timestamp': DateTime.now(),
    };
  }

  factory CallModel.fromMap(Map<String, dynamic> map) {
    return CallModel(
      callId: map['callId'],
      callerId: map['callerId'],
      receiverId: map['receiverId'],
      type: map['type'],
      status: map['status'],
      channelId: map['channelId'],
    );
  }
}
