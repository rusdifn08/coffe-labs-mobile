class CommunitySummary {
  final String id;
  final String handleSlug;
  final String name;
  final String description;
  final String? avatarUrl;
  final String? bannerUrl;
  final String privacyLevel;
  final String ownerId;
  final List<String> focusTags;
  final int membersCount;
  final int threadsCount;
  final int sharedRecipesCount;
  final int totalClubXp;
  final String? viewerRole;
  final bool isMember;
  final double? matchScorePct;
  final DateTime createdAt;

  const CommunitySummary({
    required this.id,
    required this.handleSlug,
    required this.name,
    required this.description,
    this.avatarUrl,
    this.bannerUrl,
    required this.privacyLevel,
    required this.ownerId,
    required this.focusTags,
    required this.membersCount,
    required this.threadsCount,
    required this.sharedRecipesCount,
    required this.totalClubXp,
    this.viewerRole,
    required this.isMember,
    this.matchScorePct,
    required this.createdAt,
  });

  factory CommunitySummary.fromJson(Map<String, dynamic> json) {
    return CommunitySummary(
      id: (json['id'] ?? '').toString(),
      handleSlug: (json['handle_slug'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      avatarUrl: json['avatar_url']?.toString(),
      bannerUrl: json['banner_url']?.toString(),
      privacyLevel: (json['privacy_level'] ?? 'PUBLIC').toString(),
      ownerId: (json['owner_id'] ?? '').toString(),
      focusTags: (json['focus_tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      membersCount: (json['members_count'] as num?)?.toInt() ?? 1,
      threadsCount: (json['threads_count'] as num?)?.toInt() ?? 0,
      sharedRecipesCount: (json['shared_recipes_count'] as num?)?.toInt() ?? 0,
      totalClubXp: (json['total_club_xp'] as num?)?.toInt() ?? 0,
      viewerRole: json['viewer_role']?.toString(),
      isMember: json['is_member'] == true,
      matchScorePct: (json['match_score_pct'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'handle_slug': handleSlug,
        'name': name,
        'description': description,
        'avatar_url': avatarUrl,
        'banner_url': bannerUrl,
        'privacy_level': privacyLevel,
        'owner_id': ownerId,
        'focus_tags': focusTags,
        'members_count': membersCount,
        'threads_count': threadsCount,
        'shared_recipes_count': sharedRecipesCount,
        'total_club_xp': totalClubXp,
        'viewer_role': viewerRole,
        'is_member': isMember,
        'match_score_pct': matchScorePct,
        'created_at': createdAt.toIso8601String(),
      };
}

class CommunityChannel {
  final String id;
  final String communityId;
  final String name;
  final String? description;
  final String kind;
  final String? linkedConversationId;
  final int displayOrder;
  final bool isReadonlyAnnouncement;

  const CommunityChannel({
    required this.id,
    required this.communityId,
    required this.name,
    this.description,
    required this.kind,
    this.linkedConversationId,
    required this.displayOrder,
    required this.isReadonlyAnnouncement,
  });

  factory CommunityChannel.fromJson(Map<String, dynamic> json) {
    return CommunityChannel(
      id: (json['id'] ?? '').toString(),
      communityId: (json['community_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      kind: (json['kind'] ?? 'REALTIME_CHAT').toString(),
      linkedConversationId: json['linked_conversation_id']?.toString(),
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isReadonlyAnnouncement: json['is_readonly_announcement'] == true,
    );
  }
}

class CommunityWorkspace {
  final CommunitySummary community;
  final List<CommunityChannel> channels;
  final String? myRole;
  final bool isMember;
  final bool canPost;
  final bool canManageInvites;
  final String? activeSecretCodePreview;

  const CommunityWorkspace({
    required this.community,
    required this.channels,
    this.myRole,
    required this.isMember,
    required this.canPost,
    required this.canManageInvites,
    this.activeSecretCodePreview,
  });

  factory CommunityWorkspace.fromJson(Map<String, dynamic> json) {
    return CommunityWorkspace(
      community: CommunitySummary.fromJson(
        Map<String, dynamic>.from(json['community'] as Map),
      ),
      channels: (json['channels'] as List<dynamic>? ?? const [])
          .map((e) => CommunityChannel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      myRole: json['my_role']?.toString(),
      isMember: json['is_member'] == true,
      canPost: json['can_post'] == true,
      canManageInvites: json['can_manage_invites'] == true,
      activeSecretCodePreview: json['active_secret_code_preview']?.toString(),
    );
  }
}

class CommunityInviteSecret {
  final String id;
  final String communityId;
  final String secretCodeDisplay;
  final String inviteUrlToken;
  final String inviteDeepLink;
  final String inviteWebLink;
  final String roleGranted;
  final int? maxUses;
  final int usedCount;
  final DateTime? expiresAt;
  final bool isRevoked;

  const CommunityInviteSecret({
    required this.id,
    required this.communityId,
    required this.secretCodeDisplay,
    required this.inviteUrlToken,
    required this.inviteDeepLink,
    required this.inviteWebLink,
    required this.roleGranted,
    this.maxUses,
    required this.usedCount,
    this.expiresAt,
    required this.isRevoked,
  });

  factory CommunityInviteSecret.fromJson(Map<String, dynamic> json) {
    return CommunityInviteSecret(
      id: (json['id'] ?? '').toString(),
      communityId: (json['community_id'] ?? '').toString(),
      secretCodeDisplay: (json['secret_code_display'] ?? '').toString(),
      inviteUrlToken: (json['invite_url_token'] ?? '').toString(),
      inviteDeepLink: (json['invite_deep_link'] ?? '').toString(),
      inviteWebLink: (json['invite_web_link'] ?? '').toString(),
      roleGranted: (json['role_granted'] ?? 'BARISTA_MEMBER').toString(),
      maxUses: (json['max_uses'] as num?)?.toInt(),
      usedCount: (json['used_count'] as num?)?.toInt() ?? 0,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      isRevoked: json['is_revoked'] == true,
    );
  }
}

class JoinClubResponse {
  final bool joined;
  final bool alreadyMember;
  final String assignedRole;
  final CommunitySummary club;
  final String? defaultConversationId;

  const JoinClubResponse({
    required this.joined,
    required this.alreadyMember,
    required this.assignedRole,
    required this.club,
    this.defaultConversationId,
  });

  factory JoinClubResponse.fromJson(Map<String, dynamic> json) {
    return JoinClubResponse(
      joined: json['joined'] == true,
      alreadyMember: json['already_member'] == true,
      assignedRole: (json['assigned_role'] ?? 'BARISTA_MEMBER').toString(),
      club: CommunitySummary.fromJson(
        Map<String, dynamic>.from(json['club'] as Map),
      ),
      defaultConversationId: json['default_conversation_id']?.toString(),
    );
  }
}

class CommunityLeaderboardEntry {
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final int baristaLevel;
  final String baristaRankTitle;
  final String role;
  final int clubXpContributed;
  final int brewsSharedCount;
  final bool isFollowedByViewer;

  const CommunityLeaderboardEntry({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.baristaLevel,
    required this.baristaRankTitle,
    required this.role,
    required this.clubXpContributed,
    required this.brewsSharedCount,
    required this.isFollowedByViewer,
  });

  factory CommunityLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return CommunityLeaderboardEntry(
      userId: (json['user_id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      avatarUrl: json['avatar_url']?.toString(),
      baristaLevel: (json['barista_level'] as num?)?.toInt() ?? 1,
      baristaRankTitle:
          (json['barista_rank_title'] ?? 'Home Brewer').toString(),
      role: (json['role'] ?? 'BARISTA_MEMBER').toString(),
      clubXpContributed: (json['club_xp_contributed'] as num?)?.toInt() ?? 0,
      brewsSharedCount: (json['brews_shared_count'] as num?)?.toInt() ?? 0,
      isFollowedByViewer: json['is_followed_by_viewer'] == true,
    );
  }
}

class DiscoverCommunitiesResponse {
  final List<CommunitySummary> myClubs;
  final List<CommunitySummary> discoverClubs;
  final bool hasMore;

  const DiscoverCommunitiesResponse({
    required this.myClubs,
    required this.discoverClubs,
    required this.hasMore,
  });

  factory DiscoverCommunitiesResponse.fromJson(Map<String, dynamic> json) {
    return DiscoverCommunitiesResponse(
      myClubs: (json['my_clubs'] as List<dynamic>? ?? const [])
          .map((e) => CommunitySummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      discoverClubs: (json['discover_clubs'] as List<dynamic>? ?? const [])
          .map((e) => CommunitySummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      hasMore: json['has_more'] == true,
    );
  }
}
