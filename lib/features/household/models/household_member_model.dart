class HouseholdMemberModel {
  final String id;
  final String adminId;
  final String? memberId;
  final String name;
  final String role;
  final DateTime createdAt;

  HouseholdMemberModel({
    required this.id,
    required this.adminId,
    this.memberId,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  factory HouseholdMemberModel.fromJson(Map<String, dynamic> json) {
    return HouseholdMemberModel(
      id: json['id'],
      adminId: json['admin_id'],
      memberId: json['member_id'],
      name: json['name'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
    };
  }
}
