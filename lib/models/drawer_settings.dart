class DrawerSettings {
  final String id;
  final String headerTitle;
  final String headerTagline;
  final String phone;
  final String email;
  final String address;
  final String workingHours;
  final String facebookLink;
  final String instagramLink;
  final String phoneLink;
  final String emailLink;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DrawerSettings({
    required this.id,
    required this.headerTitle,
    required this.headerTagline,
    required this.phone,
    required this.email,
    required this.address,
    required this.workingHours,
    required this.facebookLink,
    required this.instagramLink,
    required this.phoneLink,
    required this.emailLink,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create a DrawerSettings instance from a map
  factory DrawerSettings.fromJson(Map<String, dynamic> json) {
    return DrawerSettings(
      id: json['id'] ?? '',
      headerTitle: json['header_title'] ?? 'Tatvan Kepenk',
      headerTagline:
          json['header_tagline'] ?? 'Otomatik Kepenk ve Kapı Sistemleri',
      phone: json['phone'] ?? '+90 XXX XXX XX XX',
      email: json['email'] ?? 'info@tatvankepenk.com.tr',
      address: json['address'] ?? 'Tatvan, Bitlis, Türkiye',
      workingHours:
          json['working_hours'] ?? 'Pazartesi - Cumartesi: 09:00-18:00',
      facebookLink: json['facebook_link'] ?? '',
      instagramLink: json['instagram_link'] ?? '',
      phoneLink: json['phone_link'] ?? '',
      emailLink: json['email_link'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  // Convert a DrawerSettings instance to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'header_title': headerTitle,
      'header_tagline': headerTagline,
      'phone': phone,
      'email': email,
      'address': address,
      'working_hours': workingHours,
      'facebook_link': facebookLink,
      'instagram_link': instagramLink,
      'phone_link': phoneLink,
      'email_link': emailLink,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create a copy of the current instance with the provided values
  DrawerSettings copyWith({
    String? headerTitle,
    String? headerTagline,
    String? phone,
    String? email,
    String? address,
    String? workingHours,
    String? facebookLink,
    String? instagramLink,
    String? phoneLink,
    String? emailLink,
  }) {
    return DrawerSettings(
      id: id,
      headerTitle: headerTitle ?? this.headerTitle,
      headerTagline: headerTagline ?? this.headerTagline,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      workingHours: workingHours ?? this.workingHours,
      facebookLink: facebookLink ?? this.facebookLink,
      instagramLink: instagramLink ?? this.instagramLink,
      phoneLink: phoneLink ?? this.phoneLink,
      emailLink: emailLink ?? this.emailLink,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
