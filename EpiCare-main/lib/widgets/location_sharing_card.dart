// import 'package:flutter/material.dart';

// class LocationSharingCard extends StatelessWidget {
//   const LocationSharingCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [Color(0xFFD1FAE5), Colors.white],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF10B981), Color(0xFF059669)],
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(
//                       Icons.location_on_rounded,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'مشاركة الموقع',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF111827),
//                         ),
//                       ),
//                       Text(
//                         'قيد المتابعة المستمرة',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF6B7280),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF10B981), Color(0xFF059669)],
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.navigation_rounded, color: Colors.white, size: 16),
//                     SizedBox(width: 4),
//                     Text(
//                       'نشط',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFFD1FAE5), Colors.white],
//               ),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color(0xFF6EE7B7), width: 2),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Stack(
//                       children: [
//                         Container(
//                           width: 56,
//                           height: 56,
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF10B981), Color(0xFF059669)],
//                             ),
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: const Icon(
//                             Icons.location_on_rounded,
//                             color: Colors.white,
//                             size: 28,
//                           ),
//                         ),
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: Container(
//                             width: 16,
//                             height: 16,
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF34D399),
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.white, width: 2),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(width: 16),
//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'موقعك الحالي',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF111827),
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             'شارع الملك حسين، عمان، الأردن',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Color(0xFF374151),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: const Color(0xFFE5E7EB)),
//                   ),
//                   child: Column(
//                     children: [
//                       _buildLocationRow('خط العرض:', '31.9522°'),
//                       const SizedBox(height: 8),
//                       _buildLocationRow('خط الطول:', '35.9104°'),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'دقة الموقع:',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Color(0xFF6B7280),
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFD1FAE5),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: const Text(
//                               '±10م',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Color(0xFF065F46),
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFFEFF6FF), Colors.white],
//               ),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
//                             ),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: const Icon(
//                             Icons.people_rounded,
//                             color: Colors.white,
//                             size: 20,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const Text(
//                           'يشاهد موقعك',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF111827),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Text(
//                         '3 أشخاص',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: const Color(0xFFE5E7EB)),
//                   ),
//                   child: Row(
//                     children: [
//                       Stack(
//                         children: [
//                           _buildAvatar('ف', 0),
//                           Positioned(
//                             right: 30,
//                             child: _buildAvatar('خ', 1),
//                           ),
//                           Positioned(
//                             right: 60,
//                             child: _buildAvatar('س', 2),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(width: 80),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'والدتي، أخي، زوجتي',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Color(0xFF374151),
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               'متصلون الآن',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Color(0xFF6B7280),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFFF9FAFB), Colors.white],
//               ),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: const Color(0xFFE5E7EB)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 8,
//                       height: 8,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFF10B981),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'آخر تحديث',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF6B7280),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Text(
//                   'الآن',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFF111827),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLocationRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             color: Color(0xFF6B7280),
//           ),
//         ),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 14,
//             color: Color(0xFF111827),
//             fontFamily: 'monospace',
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAvatar(String letter, int index) {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
//         ),
//         shape: BoxShape.circle,
//         border: Border.all(color: Colors.white, width: 3),
//       ),
//       child: Center(
//         child: Text(
//           letter,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }


// lib/widgets/location_sharing_card.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LocationSharingCard extends StatelessWidget {
  final bool enabled;
  final String? lastUpdate;
  final double? lat;
  final double? lng;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onOpenMap;

  const LocationSharingCard({
    super.key,
    required this.enabled,
    required this.onToggle,
    this.lastUpdate,
    this.lat,
    this.lng,
    this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // أحجام نسبية
    final padding = screenWidth * 0.05;
    final iconSize = screenWidth * 0.12;
    final iconRadius = iconSize * 0.3;
    final spacingSmall = screenHeight * 0.015;
    final spacingMedium = screenHeight * 0.02;
    final titleFontSize = screenWidth * 0.04;
    final descFontSize = screenWidth * 0.03;
    final statusFontSize = screenWidth * 0.033;
    final lastUpdateFontSize = screenWidth * 0.027;
    final buttonFontSize = screenWidth * 0.033;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFE0F2FE), Colors.white],
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- العنوان + السويتش ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
                        ),
                        borderRadius: BorderRadius.circular(iconRadius),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: iconSize * 0.55,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "location_sharing".tr(),
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            "location_sharing_desc".tr(),
                            style: TextStyle(
                              fontSize: descFontSize,
                              color: const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF22C55E),
              ),
            ],
          ),

          SizedBox(height: spacingMedium),

          // --- حالة الخدمة ---
          Row(
            children: [
              Icon(
                enabled ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                size: iconSize * 0.38,
                color: enabled ? const Color(0xFF16A34A) : const Color(0xFFF97316),
              ),
              SizedBox(width: screenWidth * 0.015),
              Expanded(
                child: Text(
                  enabled
                      ? "location_sharing_enabled_msg".tr()
                      : "location_sharing_disabled_msg".tr(),
                  style: TextStyle(fontSize: statusFontSize, color: const Color(0xFF475569)),
                ),
              ),
            ],
          ),

          SizedBox(height: spacingSmall),

          if (lastUpdate != null)
            Text(
              "${"last_update".tr()}: $lastUpdate",
              style: TextStyle(
                fontSize: lastUpdateFontSize,
                color: const Color(0xFF94A3B8),
              ),
            ),

          SizedBox(height: spacingMedium),

          if (enabled && lat != null && lng != null && onOpenMap != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onOpenMap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03, vertical: screenHeight * 0.008),
                  foregroundColor: const Color(0xFF0369A1),
                ),
                icon: Icon(Icons.map_rounded, size: iconSize * 0.4),
                label: Text(
                  "view_on_map".tr(),
                  style: TextStyle(fontSize: buttonFontSize),
                ),
              ),
            ),
        ],
      ),
    );
  }
}