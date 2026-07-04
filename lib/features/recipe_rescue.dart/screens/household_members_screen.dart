import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/core/constants/app_assets.dart';
import 'package:homesikil/core/utils/app_snackbar.dart';
import 'package:homesikil/features/auth/provider/auth_provider.dart';
import 'package:homesikil/features/household/provider/household_provider.dart';
import 'package:homesikil/features/household/models/household_invitation_model.dart';
import 'package:provider/provider.dart';

class HouseholdMembersScreen extends StatelessWidget {
  const HouseholdMembersScreen({super.key});

  Widget _buildMemberCard(
    String name,
    String role, {
    bool isMe = false,
    VoidCallback? onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Image.asset(AppAssets.mascot1, width: 24, height: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name + (isMe ? ' (You)' : ''),
                  style: AppTextStyles.title.copyWith(fontSize: 16),
                ),
                Text(
                  role,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (!isMe && onRemove != null)
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: AppColors.red,
              ),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(
    BuildContext context,
    HouseholdInvitationModel invite,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Household Invitation',
            style: AppTextStyles.title.copyWith(
              fontSize: 16,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You have been invited to join a household.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final provider = context.read<HouseholdProvider>();
                    final success = await provider.acceptInvite(invite.id);
                    if (!context.mounted) return;
                    if (success) {
                      AppSnackbar.showSuccess('Joined household successfully!');
                    } else {
                      AppSnackbar.showError(
                        provider.errorMessage ?? 'Error',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await context.read<HouseholdProvider>().declineInvite(
                      invite.id,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Decline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog(BuildContext context) {
    final usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite Member'),
        content: TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            hintText: 'Enter username to invite',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (usernameController.text.trim().isNotEmpty) {
                final provider = context.read<HouseholdProvider>();
                final success = await provider.inviteMember(usernameController.text.trim());

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  if (success) {
                    AppSnackbar.showSuccess('Invitation sent successfully');
                  } else {
                    AppSnackbar.showError(
                      provider.errorMessage ?? 'Failed to send invite',
                    );
                  }
                }
              }
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveHousehold(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Household?'),
        content: const Text(
          'Are you sure you want to leave this household? You will lose access to its inventory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<HouseholdProvider>();
              Navigator.pop(ctx);
              final success = await provider.leaveHousehold();
              if (context.mounted) {
                if (success) {
                  AppSnackbar.showSuccess('Left household successfully');
                } else {
                  AppSnackbar.showError(
                    provider.errorMessage ?? 'Failed to leave',
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final householdProvider = context.watch<HouseholdProvider>();

    final currentUser = authProvider.currentUser;
    final members = householdProvider.members;
    final invites = householdProvider.pendingInvitations;

    final isAdmin =
        householdProvider.adminId == currentUser?.id ||
        householdProvider.adminId == null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Household Members',
          style: AppTextStyles.heading.copyWith(
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: householdProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pending Invitations Section
                  if (invites.isNotEmpty) ...[
                    Text(
                      'Pending Invitations',
                      style: AppTextStyles.title.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    ...invites.map(
                      (invite) => _buildInviteCard(context, invite),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Members Section
                  if (isAdmin && currentUser != null)
                    _buildMemberCard(
                      currentUser.username ?? currentUser.email,
                      'Admin (You)',
                      isMe: true,
                    ),

                  if (!isAdmin)
                    _buildMemberCard(householdProvider.adminName, 'Admin'),

                  ...members.map((member) {
                    final isMe = member.memberId == currentUser?.id;
                    return _buildMemberCard(
                      member.name,
                      member.role,
                      isMe: isMe,
                      onRemove: isAdmin
                          ? () {
                              context.read<HouseholdProvider>().removeMember(
                                member.id,
                              );
                            }
                          : null,
                    );
                  }),

                  const SizedBox(height: 24),

                  if (isAdmin)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _showInviteMemberDialog(context),
                        icon: const Icon(
                          Icons.person_add_alt_1,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Invite Member',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                  if (!isAdmin)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmLeaveHousehold(context),
                        icon: const Icon(
                          Icons.exit_to_app,
                          color: AppColors.red,
                        ),
                        label: const Text(
                          'Leave Household',
                          style: TextStyle(
                            color: AppColors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                  Center(
                    child: Opacity(
                      opacity: 0.7,
                      child: Image.asset(
                        'assets/images/mascots/Mascot6.png',
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Manage food together with your family.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Track food and save more together',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
