// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:easy_localization/easy_localization.dart';
// import '../models/contact.dart';
// import '../screens/add_contacts_screen.dart';

// class EmergencyContacts extends StatefulWidget {
//   final List<Contact> contacts;
//   final Function(List<Contact>) onContactsChanged;

//   const EmergencyContacts({
//     super.key,
//     required this.contacts,
//     required this.onContactsChanged,
//   });

//   @override
//   State<EmergencyContacts> createState() => _EmergencyContactsState();
// }

// class _EmergencyContactsState extends State<EmergencyContacts> {
//   @override
//   void initState() {
//     super.initState();
//     _loadContacts();
//   }

//   void _loadContacts() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     final ref = FirebaseDatabase.instance.ref('users/${user.uid}/contacts');
//     final snapshot = await ref.get();

//     if (snapshot.exists) {
//       final data = snapshot.value as Map<dynamic, dynamic>;
//       final loadedContacts = data.entries.map((e) {
//         final c = e.value as Map;
//         return Contact(
//           id: c['id'],
//           name: c['name'],
//           relation: c['relation'],
//           phone: c['phone'],
//           sharingLocation: c['sharingLocation'] ?? true,
//           notifyOnSeizure: c['notifyOnSeizure'] ?? true,
//         );
//       }).toList();

//       setState(() {
//         widget.contacts
//           ..clear()
//           ..addAll(loadedContacts);
//       });
//     }
//   }

//   Future<void> _saveContactToFirebase(Contact contact) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       final ref = FirebaseDatabase.instance.ref('users/${user.uid}/contacts');
//       final snapshot = await ref.get();

//       if (snapshot.exists) {
//         final data = snapshot.value as Map<dynamic, dynamic>;
//         String? contactKey;

//         data.forEach((key, value) {
//           if (value is Map && value['id'] == contact.id) {
//             contactKey = key;
//           }
//         });

//         if (contactKey != null) {
//           await ref.child(contactKey!).update({
//             'sharingLocation': contact.sharingLocation,
//             'notifyOnSeizure': contact.notifyOnSeizure,
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error saving contact: $e');
//     }
//   }

//   void _toggleLocationSharing(int id) async {
//     final updatedContacts = widget.contacts.map((contact) {
//       if (contact.id == id) {
//         contact.sharingLocation = !contact.sharingLocation;
//         _saveContactToFirebase(contact);
//       }
//       return contact;
//     }).toList();
//     widget.onContactsChanged(updatedContacts);
//   }

//   void _toggleNotifications(int id) async {
//     final updatedContacts = widget.contacts.map((contact) {
//       if (contact.id == id) {
//         contact.notifyOnSeizure = !contact.notifyOnSeizure;
//         _saveContactToFirebase(contact);
//       }
//       return contact;
//     }).toList();
//     widget.onContactsChanged(updatedContacts);
//   }

//   void _makePhoneCall(String phoneNumber) async {
//     try {
//       final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
//       final Uri launchUri = Uri(
//         scheme: 'tel',
//         path: cleanNumber,
//       );

//       if (await canLaunchUrl(launchUri)) {
//         await launchUrl(launchUri);
//       } else {
//         debugPrint('Cannot make call to: $phoneNumber');
//       }
//     } catch (e) {
//       debugPrint('Error making call: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final horizontalPadding = screenWidth * 0.04;

//     return SingleChildScrollView(
//       padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: screenWidth * 0.12,
//                 height: screenWidth * 0.12,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.people_rounded,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//               SizedBox(width: screenWidth * 0.03),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'emergency_contacts'.tr(),
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.045,
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFF111827),
//                       ),
//                     ),
//                     Text(
//                       '${widget.contacts.length} ${"active_contacts".tr()}',
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.035,
//                         color: const Color(0xFF6B7280),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: screenHeight * 0.02),
//           ...widget.contacts.map((contact) => _buildContactCard(contact, screenWidth, screenHeight)),
//           SizedBox(height: screenHeight * 0.02),
//           OutlinedButton(
//             onPressed: () async {
//               final newContact = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const AddContactScreen(),
//                 ),
//               );

//               if (newContact != null) {
//                 setState(() {
//                   widget.contacts.add(newContact);
//                 });

//                 final user = FirebaseAuth.instance.currentUser;
//                 if (user != null) {
//                   final ref = FirebaseDatabase.instance.ref('users/${user.uid}/contacts');
//                   await ref.push().set({
//                     'id': newContact.id,
//                     'name': newContact.name,
//                     'relation': newContact.relation,
//                     'phone': newContact.phone,
//                     'sharingLocation': newContact.sharingLocation,
//                     'notifyOnSeizure': newContact.notifyOnSeizure,
//                   });
//                 }
//               }
//             },
//             style: OutlinedButton.styleFrom(
//               minimumSize: Size(double.infinity, screenHeight * 0.08),
//               side: const BorderSide(
//                 color: Color(0xFF93C5FD),
//                 width: 2,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: screenWidth * 0.1,
//                   height: screenWidth * 0.1,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFDBEAFE),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(
//                     Icons.person_add_rounded,
//                     color: Color(0xFF2563EB),
//                     size: 20,
//                   ),
//                 ),
//                 SizedBox(width: screenWidth * 0.03),
//                 Text(
//                   'add_new_contact'.tr(),
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.04,
//                     color: const Color(0xFF111827),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContactCard(Contact contact, double screenWidth, double screenHeight) {
//     return Container(
//       margin: EdgeInsets.only(bottom: screenHeight * 0.02),
//       padding: EdgeInsets.all(screenWidth * 0.04),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [Colors.white, Color(0xFFEFF6FF)],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       contact.getLocalizedName('en'), // أو حسب اللغة
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.04,
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFF111827),
//                       ),
//                     ),
//                     SizedBox(height: screenHeight * 0.005),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: screenWidth * 0.03,
//                         vertical: screenHeight * 0.005,
//                       ),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         contact.getLocalizedRelation('en'),
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: screenWidth * 0.032,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: screenWidth * 0.03),
//               Container(
//                 width: screenWidth * 0.12,
//                 height: screenWidth * 0.12,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF10B981), Color(0xFF059669)],
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(16),
//                     onTap: () => _makePhoneCall(contact.phone),
//                     child: const Icon(
//                       Icons.phone_rounded,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: screenHeight * 0.015),
//           Container(
//             padding: EdgeInsets.all(screenWidth * 0.03),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: const Color(0xFFE5E7EB)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: screenWidth * 0.08,
//                   height: screenWidth * 0.08,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFDBEAFE),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.phone_rounded,
//                     color: Color(0xFF2563EB),
//                     size: 16,
//                   ),
//                 ),
//                 SizedBox(width: screenWidth * 0.03),
//                 Expanded(
//                   child: Text(
//                     contact.phone,
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.035,
//                       color: const Color(0xFF111827),
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: screenHeight * 0.015),
//           Container(
//             padding: EdgeInsets.only(top: screenHeight * 0.015),
//             decoration: const BoxDecoration(
//               border: Border(
//                 top: BorderSide(color: Color(0xFFBFDBFE), width: 2),
//               ),
//             ),
//             child: Column(
//               children: [
//                 _buildToggleRow(
//                   icon: Icons.location_on_rounded,
//                   label: 'share_location'.tr(),
//                   value: contact.sharingLocation,
//                   color: const Color(0xFF2563EB),
//                   onChanged: () => _toggleLocationSharing(contact.id),
//                   screenWidth: screenWidth,
//                   screenHeight: screenHeight,
//                 ),
//                 SizedBox(height: screenHeight * 0.01),
//                 _buildToggleRow(
//                   icon: Icons.notifications_rounded,
//                   label: 'notify_on_seizure'.tr(),
//                   value: contact.notifyOnSeizure,
//                   color: const Color(0xFFF97316),
//                   onChanged: () => _toggleNotifications(contact.id),
//                   screenWidth: screenWidth,
//                   screenHeight: screenHeight,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToggleRow({
//     required IconData icon,
//     required String label,
//     required bool value,
//     required Color color,
//     required VoidCallback onChanged,
//     required double screenWidth,
//     required double screenHeight,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Container(
//               width: screenWidth * 0.08,
//               height: screenWidth * 0.08,
//               decoration: BoxDecoration(
//                 color: value ? color : const Color(0xFFD1D5DB),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 icon,
//                 color: Colors.white,
//                 size: screenWidth * 0.04,
//               ),
//             ),
//             SizedBox(width: screenWidth * 0.03),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: screenWidth * 0.035,
//                 color: const Color(0xFF111827),
//               ),
//             ),
//           ],
//         ),
//         GestureDetector(
//           onTap: onChanged,
//           child: Container(
//             width: screenWidth * 0.15,
//             height: screenHeight * 0.04,
//             decoration: BoxDecoration(
//               color: value ? color : const Color(0xFFD1D5DB),
//               borderRadius: BorderRadius.circular(screenHeight * 0.02),
//             ),
//             child: AnimatedAlign(
//               duration: const Duration(milliseconds: 200),
//               alignment: value ? Alignment.centerLeft : Alignment.centerRight,
//               child: Container(
//                 width: screenWidth * 0.08,
//                 height: screenWidth * 0.08,
//                 margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.008),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: value
//                     ? Icon(Icons.check_rounded, size: screenWidth * 0.04, color: color)
//                     : null,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/contact.dart';
import '../screens/add_contacts_screen.dart';

class EmergencyContacts extends StatefulWidget {
  final List<Contact> contacts;
  final Function(List<Contact>) onContactsChanged;

  const EmergencyContacts({
    super.key,
    required this.contacts,
    required this.onContactsChanged,
  });

  @override
  State<EmergencyContacts> createState() => _EmergencyContactsState();
}

class _EmergencyContactsState extends State<EmergencyContacts> {
  @override
  void initState() {
    super.initState();
    _loadContacts();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.phone,
      Permission.contacts,
    ].request();
  }

  void _loadContacts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref('users/${user.uid}/contacts');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final loadedContacts = data.entries.map((e) {
        final c = e.value as Map;
        return Contact(
          id: c['id'],
          name: c['name'],
          relation: c['relation'],
          phone: c['phone'],
          sharingLocation: c['sharingLocation'] ?? true,
          notifyOnSeizure: c['notifyOnSeizure'] ?? true,
        );
      }).toList();

      setState(() {
        widget.contacts
          ..clear()
          ..addAll(loadedContacts);
      });
    }
  }

  Future<void> _saveContactToFirebase(Contact contact) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final ref = FirebaseDatabase.instance.ref('users/${user.uid}/contacts');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        String? contactKey;

        data.forEach((key, value) {
          if (value is Map && value['id'] == contact.id) {
            contactKey = key;
          }
        });

        if (contactKey != null) {
          await ref.child(contactKey!).update({
            'sharingLocation': contact.sharingLocation,
            'notifyOnSeizure': contact.notifyOnSeizure,
          });
        }
      }
    } catch (e) {
      debugPrint('Error saving contact: $e');
    }
  }

  void _toggleLocationSharing(int id) async {
    final updatedContacts = widget.contacts.map((contact) {
      if (contact.id == id) {
        contact.sharingLocation = !contact.sharingLocation;
        _saveContactToFirebase(contact);
      }
      return contact;
    }).toList();
    widget.onContactsChanged(updatedContacts);
  }

  void _toggleNotifications(int id) async {
    final updatedContacts = widget.contacts.map((contact) {
      if (contact.id == id) {
        contact.notifyOnSeizure = !contact.notifyOnSeizure;
        _saveContactToFirebase(contact);
      }
      return contact;
    }).toList();
    widget.onContactsChanged(updatedContacts);
  }

  // Future<void> _makePhoneCall(String phoneNumber) async {
  //   try {
  //     // اطلب إذن المكالمات أولاً
  //     var status = await Permission.phone.status;
      
  //     if (!status.isGranted) {
  //       status = await Permission.phone.request();
  //     }
      
  //     if (status.isGranted) {
  //       final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  //       final Uri launchUri = Uri(
  //         scheme: 'tel',
  //         path: cleanNumber,
  //       );

  //       if (await canLaunchUrl(launchUri)) {
  //         await launchUrl(launchUri);
  //       } else {
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('لا يمكن إجراء المكالمة')),
  //           );
  //         }
  //       }
  //     } else {
  //       // المستخدم رفض الإذن
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('يجب السماح بإذن المكالمات')),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error making call: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('خطأ في إجراء المكالمة: $e')),
  //       );
  //     }
  //   }
  // }

// استبدل function الـ _makePhoneCall في ملفاتك بهاد الكود:

Future<void> _makePhoneCall(String phoneNumber) async {
  try {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );

    // محاولة مباشرة بدون تحقق معقد
    bool launched = await launchUrl(
      launchUri,
      mode: LaunchMode.externalApplication, // مهم جداً!
    );

    if (!launched) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text("the_call_could_not_be_made".tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    debugPrint('Error making call: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error.tr() $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ملاحظة مهمة: تأكد إنك مستورد url_launcher بشكل صحيح:
// import 'package:url_launcher/url_launcher.dart';
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.04;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'emergency_contacts'.tr(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      '${widget.contacts.length} ${"active_contacts".tr()}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          ...widget.contacts.map((contact) => _buildContactCard(contact, screenWidth, screenHeight)),
          SizedBox(height: screenHeight * 0.02),
          OutlinedButton(
            onPressed: () async {
              final newContact = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddContactScreen(),
                ),
              );

              if (newContact != null) {
                setState(() {
                  widget.contacts.add(newContact);
                });

                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final ref = FirebaseDatabase.instance.ref('users/${user.uid}/contacts');
                  await ref.push().set({
                    'id': newContact.id,
                    'name': newContact.name,
                    'relation': newContact.relation,
                    'phone': newContact.phone,
                    'sharingLocation': newContact.sharingLocation,
                    'notifyOnSeizure': newContact.notifyOnSeizure,
                  });
                }
              }
            },
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, screenHeight * 0.08),
              side: const BorderSide(
                color: Color(0xFF93C5FD),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.1,
                  height: screenWidth * 0.1,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  'add_new_contact'.tr(),
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Contact contact, double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.white, Color(0xFFEFF6FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.getLocalizedName('en'),
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.005,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        contact.getLocalizedRelation('en'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.032,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _makePhoneCall(contact.phone),
                    child: const Icon(
                      Icons.phone_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: screenWidth * 0.08,
                  height: screenWidth * 0.08,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.phone_rounded,
                    color: Color(0xFF2563EB),
                    size: 16,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    contact.phone,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: const Color(0xFF111827),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Container(
            padding: EdgeInsets.only(top: screenHeight * 0.015),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFBFDBFE), width: 2),
              ),
            ),
            child: Column(
              children: [
                _buildToggleRow(
                  icon: Icons.location_on_rounded,
                  label: 'share_location'.tr(),
                  value: contact.sharingLocation,
                  color: const Color(0xFF2563EB),
                  onChanged: () => _toggleLocationSharing(contact.id),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                SizedBox(height: screenHeight * 0.01),
                _buildToggleRow(
                  icon: Icons.notifications_rounded,
                  label: 'notify_on_seizure'.tr(),
                  value: contact.notifyOnSeizure,
                  color: const Color(0xFFF97316),
                  onChanged: () => _toggleNotifications(contact.id),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required Color color,
    required VoidCallback onChanged,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: screenWidth * 0.08,
              height: screenWidth * 0.08,
              decoration: BoxDecoration(
                color: value ? color : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: screenWidth * 0.04,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onChanged,
          child: Container(
            width: screenWidth * 0.15,
            height: screenHeight * 0.04,
            decoration: BoxDecoration(
              color: value ? color : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(screenHeight * 0.02),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: screenWidth * 0.08,
                height: screenWidth * 0.08,
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.008),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: value
                    ? Icon(Icons.check_rounded, size: screenWidth * 0.04, color: color)
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
