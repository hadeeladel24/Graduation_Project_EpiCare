// class Contact {
//   final int id;
//   final String name;
//   final String relation;
//   final String phone;
//   bool sharingLocation;
//   bool notifyOnSeizure;

//   Contact({
//     required this.id,
//     required this.name,
//     required this.relation,
//     required this.phone,
//     this.sharingLocation = true,
//     this.notifyOnSeizure = true,
//   });

//   static List<Contact> getMockContacts() {
//     return [
//       // Contact(
//       //   id: 1,
//       //   name: 'والدتي - فاطمة',
//       //   relation: 'أم',
//       //   phone: '123-456-7890',
//       // ),
//       // Contact(
//       //   id: 2,
//       //   name: 'أخي - خالد',
//       //   relation: 'أخ',
//       //   phone: '098-765-4321',
//       // ),
//       // Contact(
//       //   id: 3,
//       //   name: 'زوجتي - سارة',
//       //   relation: 'زوجة',
//       //   phone: '555-123-4567',
//       // ),
//     ];
//   }
// }


// class Contact {
//   final int id;
//   final String name;
//   final String relation;
//   final String phone;

//   bool sharingLocation;
//   bool notifyOnSeizure;

//   // ⭐ تمت إضافة هذا المتغير الهام لإرسال إشعارات FCM
//   final String? fcmToken;

//   Contact({
//     required this.id,
//     required this.name,
//     required this.relation,
//     required this.phone,
//     this.sharingLocation = true,
//     this.notifyOnSeizure = true,
//     this.fcmToken, // ← تمت إضافته هنا
//   });

//   // ---------------------- JSON Serialization ----------------------
//   factory Contact.fromJson(Map<String, dynamic> json) {
//     return Contact(
//       id: json["id"] ?? 0,
//       name: json["name"] ?? "",
//       relation: json["relation"] ?? "",
//       phone: json["phone"] ?? "",
//       sharingLocation: json["sharingLocation"] ?? true,
//       notifyOnSeizure: json["notifyOnSeizure"] ?? true,
//       fcmToken: json["fcmToken"], // ← إدخال التوكين من الفايربيس
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "name": name,
//       "relation": relation,
//       "phone": phone,
//       "sharingLocation": sharingLocation,
//       "notifyOnSeizure": notifyOnSeizure,
//       "fcmToken": fcmToken, // ← حفظ التوكين
//     };
//   }

//   // Mock contacts (إن أردت تفعيلهم لاحقاً)
//   static List<Contact> getMockContacts() {
//     return [];
//   }
// }



class Contact {
  final int id;
  final String name;      // "عربي|English"
  final String relation;  // "عربي|English"
  final String phone;
  bool sharingLocation;
  bool notifyOnSeizure;
  final String? fcmToken;

  Contact({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
    this.sharingLocation = true,
    this.notifyOnSeizure = true,
    this.fcmToken,
  });

  // ======================= الاسم حسب اللغة =======================
  String getLocalizedName(String languageCode) {
    if (name.contains('|')) {
      final parts = name.split('|');
      if (parts.length == 2) {
        return languageCode == 'ar' ? parts[0] : parts[1];
      }
    }
    return name;
  }

  // ======================= العلاقة حسب اللغة =======================
  String getLocalizedRelation(String languageCode) {
    if (relation.contains('|')) {
      final parts = relation.split('|');
      if (parts.length == 2) {
        return languageCode == 'ar' ? parts[0] : parts[1];
      }
    }
    return relation;
  }

  // ---------------------- JSON Serialization ----------------------
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      relation: json["relation"] ?? "",
      phone: json["phone"] ?? "",
      sharingLocation: json["sharingLocation"] ?? true,
      notifyOnSeizure: json["notifyOnSeizure"] ?? true,
      fcmToken: json["fcmToken"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "relation": relation,
      "phone": phone,
      "sharingLocation": sharingLocation,
      "notifyOnSeizure": notifyOnSeizure,
      if (fcmToken != null) "fcmToken": fcmToken,
    };
  }
}
