enum UserRole {
  admin,
  accManagerPe,
  accManagerMe,
  me,
  pe,
  leader,
  unknown
}

extension UserRoleExtension on UserRole {
  bool get canReview {
    return this == UserRole.admin || this == UserRole.leader;
  }

  bool get canViewAssessment {
    return this == UserRole.admin || this == UserRole.accManagerMe || this == UserRole.me;
  }

  bool get canAssess {
    return this == UserRole.admin || this == UserRole.accManagerMe || this == UserRole.me;
  }

  String get stringValue {
    return toString().split('.').last;
  }
}

UserRole parseUserRole(String? role) {
  if (role == null) return UserRole.unknown;
  
  switch (role.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'me':
      return UserRole.me;
    case 'pe':
      return UserRole.pe;
    case 'leader':
      return UserRole.leader;
    case 'acc-manager-pe':
      return UserRole.accManagerPe;
    case 'acc-manager-me':
      return UserRole.accManagerMe;
    default:
      return UserRole.unknown;
  }
}
