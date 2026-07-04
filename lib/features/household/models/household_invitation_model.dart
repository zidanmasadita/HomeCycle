class HouseholdInvitationModel {
  final String id;
  final String inviterId;
  final String inviteeId;
  final String status;
  final DateTime createdAt;
  final String? inviterName;

  HouseholdInvitationModel({
    required this.id,
    required this.inviterId,
    required this.inviteeId,
    required this.status,
    required this.createdAt,
    this.inviterName,
  });

  factory HouseholdInvitationModel.fromJson(Map<String, dynamic> json) {
    return HouseholdInvitationModel(
      id: json['id'],
      inviterId: json['inviter_id'],
      inviteeId: json['invitee_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
