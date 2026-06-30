import 'package:cloud_firestore/cloud_firestore.dart';

/// Seeds Firestore with sample venue and booking data for testing.
/// Only runs if the 'venues' collection is empty.
class FirestoreSeeder {
  static Future<void> seedIfEmpty() async {
    try {
      final venuesSnapshot = await FirebaseFirestore.instance.collection('venues').limit(1).get();
      if (venuesSnapshot.docs.isNotEmpty) return; // Already seeded

      await _seedVenues();
      await _seedBookings();
    } catch (e) {
      // Firebase not configured yet — silently skip
    }
  }

  static Future<void> _seedVenues() async {
    final batch = FirebaseFirestore.instance.batch();
    final venuesRef = FirebaseFirestore.instance.collection('venues');

    final venues = [
      {
        'venueName': 'KE Auditorium',
        'blockName': 'Central Block',
        'description': 'A large auditorium suitable for major events, conferences, and university-level inaugurations. Equipped with professional sound and lighting systems.',
        'capacity': 500,
        'imageUrl': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&h=500&fit=crop',
        'inchargeName': 'Mr. Antony Raj',
        'inchargeEmail': 'antony.raj@christuniversity.in',
        'inchargePhone': '+91 98765 43210',
        'facilities': ['Projector', 'AC', 'Mic', 'Stage', 'LED Screen', 'Sound System'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'venueName': 'Mini Auditorium',
        'blockName': 'Main Block, 1st Floor',
        'description': 'Perfect for smaller seminars, guest lectures, and departmental meetings. Intimate setting with modern AV equipment.',
        'capacity': 150,
        'imageUrl': 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&h=500&fit=crop',
        'inchargeName': 'Prof. Rajesh Kumar',
        'inchargeEmail': 'rajesh.kumar@christuniversity.in',
        'inchargePhone': '+91 91234 56789',
        'facilities': ['Projector', 'AC', 'Mic', 'Whiteboard'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'venueName': 'MBA Seminar Hall',
        'blockName': 'MBA Block, 2nd Floor',
        'description': 'Equipped with modern facilities for interactive sessions, case study presentations, and MBA department events.',
        'capacity': 200,
        'imageUrl': 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=800&h=500&fit=crop',
        'inchargeName': 'Dr. Vinay M.',
        'inchargeEmail': 'vinay.m@christuniversity.in',
        'inchargePhone': '+91 94480 12345',
        'facilities': ['Projector', 'AC', 'Mic', 'Whiteboard', 'Video Conferencing'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'venueName': 'BCA Lab Auditorium',
        'blockName': 'Science Block, 3rd Floor',
        'description': 'Ideal for technical workshops, hackathons, and hands-on training sessions. Fitted with computer terminals and projection system.',
        'capacity': 100,
        'imageUrl': 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=800&h=500&fit=crop',
        'inchargeName': 'Mrs. Mary D\'Souza',
        'inchargeEmail': 'mary.dsouza@christuniversity.in',
        'inchargePhone': '+91 98450 98765',
        'facilities': ['Projector', 'AC', 'Computers', 'Whiteboard'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'venueName': 'Dharmaram Auditorium',
        'blockName': 'Dharmaram Block, 1st Floor',
        'description': 'Spacious auditorium with excellent acoustics for cultural events, annual day celebrations, and large-scale performances.',
        'capacity': 400,
        'imageUrl': 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=800&h=500&fit=crop',
        'inchargeName': 'Brother Sunny',
        'inchargeEmail': 'sunny.cmi@christuniversity.in',
        'inchargePhone': '+91 97412 34567',
        'facilities': ['AC', 'Mic', 'Stage', 'LED Screen', 'Sound System', 'Green Room'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'venueName': 'Central Library Hall',
        'blockName': 'Library Block, Ground Floor',
        'description': 'A quiet, well-lit space for academic presentations, book launches, and scholarly readings.',
        'capacity': 120,
        'imageUrl': 'https://images.unsplash.com/photo-1568667256549-094345857637?w=800&h=500&fit=crop',
        'inchargeName': 'Dr. Suresh Babu',
        'inchargeEmail': 'suresh.babu@christuniversity.in',
        'inchargePhone': '+91 96321 45678',
        'facilities': ['Projector', 'AC', 'Mic'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'venueName': 'Block 1 Conference Room',
        'blockName': 'Block 1, 4th Floor',
        'description': 'Premium conference room for important meetings, board discussions, and faculty workshops. Equipped with video conferencing.',
        'capacity': 50,
        'imageUrl': 'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?w=800&h=500&fit=crop',
        'inchargeName': 'Prof. Anita Sharma',
        'inchargeEmail': 'anita.sharma@christuniversity.in',
        'inchargePhone': '+91 99001 23456',
        'facilities': ['Projector', 'AC', 'Whiteboard', 'Video Conferencing'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'venueName': 'Main Auditorium',
        'blockName': 'Central Block, Ground Floor',
        'description': 'The largest auditorium on campus for grand university events, convocations, and distinguished guest lectures.',
        'capacity': 800,
        'imageUrl': 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&h=500&fit=crop',
        'inchargeName': 'Fr. Joseph Thomas',
        'inchargeEmail': 'joseph.thomas@christuniversity.in',
        'inchargePhone': '+91 98760 54321',
        'facilities': ['Projector', 'AC', 'Mic', 'Stage', 'LED Screen', 'Sound System', 'Green Room'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final venue in venues) {
      batch.set(venuesRef.doc(), venue);
    }

    await batch.commit();
  }

  static Future<void> _seedBookings() async {
    final batch = FirebaseFirestore.instance.batch();
    final bookingsRef = FirebaseFirestore.instance.collection('bookings');

    // We need venue IDs, so let's read them back
    final venuesSnapshot = await FirebaseFirestore.instance.collection('venues').get();
    if (venuesSnapshot.docs.length < 4) return;

    final keAudi = venuesSnapshot.docs.firstWhere((d) => d.data()['venueName'] == 'KE Auditorium');
    final mbaHall = venuesSnapshot.docs.firstWhere((d) => d.data()['venueName'] == 'MBA Seminar Hall');
    final bcaLab = venuesSnapshot.docs.firstWhere((d) => d.data()['venueName'] == 'BCA Lab Auditorium');
    final dharmaram = venuesSnapshot.docs.firstWhere((d) => d.data()['venueName'] == 'Dharmaram Auditorium');
    final mainAudi = venuesSnapshot.docs.firstWhere((d) => d.data()['venueName'] == 'Main Auditorium');

    final now = DateTime.now();

    final bookings = [
      {
        'bookingId': 'EVT-20260618-001',
        'auditoriumId': keAudi.id,
        'auditoriumName': 'KE Auditorium',
        'userId': 'u1',
        'userName': 'Mohit B M',
        'userRole': 'Student Coordinator',
        'eventName': 'Annual Tech Fest Inauguration',
        'eventDescription': 'Opening ceremony for the annual university technology festival with guest speakers from industry leaders.',
        'eventCategory': 'Technical',
        'date': Timestamp.fromDate(now.add(const Duration(days: 3))),
        'startTime': '09:00 AM',
        'endTime': '11:30 AM',
        'status': 'confirmed',
        'approvalStage': 'venueApproved',
        'attendees': 450,
        'equipment': ['Projector', 'Microphone', 'Speakers'],
        'clubOrDepartment': 'BCA',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'organizerName': 'Mohit B M',
        'organizerContact': '+91 98765 00001',
        'guestDetails': 'Chief Guest: CEO of TechCorp India',
        'techSetup': 'Dual microphones, presentation screen tested.',
        'securityDetails': '4 Student volunteers at doors.',
        'refreshments': <String>[],
        'coordinatorNote': '',
        'approvalHistory': [
          {'approverName': 'Prof. Rajesh Kumar', 'approverRole': 'Faculty Coordinator', 'action': 'approved', 'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 4))), 'comment': 'Looks good. Approved.'},
          {'approverName': 'Dr. Vinay M.', 'approverRole': 'Head of Department', 'action': 'approved', 'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 3))), 'comment': ''},
          {'approverName': 'Mr. Antony Raj', 'approverRole': 'Venue Incharge', 'action': 'approved', 'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 1))), 'comment': 'Venue confirmed. Setup at 8 AM.'},
        ],
        'resourcesRequested': <String>[],
      },
      {
        'bookingId': 'EVT-20260618-002',
        'auditoriumId': mbaHall.id,
        'auditoriumName': 'MBA Seminar Hall',
        'userId': 'u1',
        'userName': 'Mohit B M',
        'userRole': 'Student Coordinator',
        'eventName': 'Guest Lecture on AI in Business',
        'eventDescription': 'An interactive session by industry experts on the impact of Artificial Intelligence in modern business practices and strategy.',
        'eventCategory': 'Academic',
        'date': Timestamp.fromDate(now.add(const Duration(days: 7))),
        'startTime': '02:00 PM',
        'endTime': '04:00 PM',
        'status': 'pendingHod',
        'approvalStage': 'facultyApproved',
        'attendees': 180,
        'equipment': ['Projector', 'Microphone'],
        'clubOrDepartment': 'BCA',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(hours: 6))),
        'organizerName': 'Mohit B M',
        'organizerContact': '+91 98765 00001',
        'guestDetails': 'Speaker: Christ University Alumni (Batch 2020)',
        'techSetup': 'Wired mic, HDMI input required.',
        'securityDetails': '',
        'refreshments': <String>[],
        'coordinatorNote': '',
        'approvalHistory': [
          {'approverName': 'Prof. Rajesh Kumar', 'approverRole': 'Faculty Coordinator', 'action': 'approved', 'timestamp': Timestamp.fromDate(now.subtract(const Duration(hours: 6))), 'comment': 'Good initiative.'},
        ],
        'resourcesRequested': <String>[],
      },
      {
        'bookingId': 'EVT-20260618-003',
        'auditoriumId': bcaLab.id,
        'auditoriumName': 'BCA Lab Auditorium',
        'userId': 'u2',
        'userName': 'Jane Doe',
        'userRole': 'Student Coordinator',
        'eventName': 'BCA Department Workshop',
        'eventDescription': 'Hands-on workshop on Full Stack Web Development with React and Node.js for 2nd year BCA students.',
        'eventCategory': 'Workshop',
        'date': Timestamp.fromDate(now.add(const Duration(days: 10))),
        'startTime': '10:00 AM',
        'endTime': '01:00 PM',
        'status': 'pendingFaculty',
        'approvalStage': 'submitted',
        'attendees': 80,
        'equipment': ['Projector', 'Whiteboard'],
        'clubOrDepartment': 'BCA',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 12))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(hours: 12))),
        'organizerName': 'Jane Doe',
        'organizerContact': '+91 87654 32100',
        'guestDetails': '',
        'techSetup': '',
        'securityDetails': '',
        'refreshments': <String>[],
        'coordinatorNote': '',
        'approvalHistory': <Map<String, dynamic>>[],
        'resourcesRequested': <String>[],
      },
      {
        'bookingId': 'EVT-20260618-004',
        'auditoriumId': dharmaram.id,
        'auditoriumName': 'Dharmaram Auditorium',
        'userId': 'u3',
        'userName': 'John Smith',
        'userRole': 'Student Coordinator',
        'eventName': 'Annual Cultural Night Rehearsal',
        'eventDescription': 'Full dress rehearsal for the upcoming annual cultural night featuring performances from all departments.',
        'eventCategory': 'Cultural',
        'date': Timestamp.fromDate(now.add(const Duration(days: 5))),
        'startTime': '05:00 PM',
        'endTime': '08:00 PM',
        'status': 'confirmed',
        'approvalStage': 'venueApproved',
        'attendees': 200,
        'equipment': ['Microphone', 'Speakers', 'Stage Lights'],
        'clubOrDepartment': 'Cultural Club',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 4))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'organizerName': 'John Smith',
        'organizerContact': '+91 76543 21009',
        'guestDetails': '',
        'techSetup': '3 wireless mics, spotlight setup needed.',
        'securityDetails': '2 security personnel requested.',
        'refreshments': <String>[],
        'coordinatorNote': '',
        'approvalHistory': [
          {'approverName': 'Dr. Meena R.', 'approverRole': 'Faculty Coordinator', 'action': 'approved', 'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 3))), 'comment': ''},
          {'approverName': 'Dr. Vinay M.', 'approverRole': 'Head of Department', 'action': 'approved', 'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 2))), 'comment': 'Ensure proper cleanup after rehearsal.'},
          {'approverName': 'Brother Sunny', 'approverRole': 'Venue Incharge', 'action': 'approved', 'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 1))), 'comment': ''},
        ],
        'resourcesRequested': <String>[],
      },
      {
        'bookingId': 'EVT-20260618-005',
        'auditoriumId': mainAudi.id,
        'auditoriumName': 'Main Auditorium',
        'userId': 'u4',
        'userName': 'Dr. Priya Nair',
        'userRole': 'Faculty Coordinator',
        'eventName': 'Faculty Research Symposium 2026',
        'eventDescription': 'Annual research symposium for all faculty members to present their papers and discuss collaborative opportunities across departments.',
        'eventCategory': 'Seminar',
        'date': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
        'startTime': '10:00 AM',
        'endTime': '04:00 PM',
        'status': 'completed',
        'approvalStage': 'venueApproved',
        'attendees': 350,
        'equipment': ['Projector', 'Microphone', 'Laptop', 'Podium'],
        'clubOrDepartment': 'Research Dept',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 20))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
        'organizerName': 'Dr. Priya Nair',
        'organizerContact': '+91 99887 76655',
        'guestDetails': 'Keynote: Prof. Ram from IISc Bangalore',
        'techSetup': 'Podium mic + lapel mic for keynote.',
        'securityDetails': '',
        'refreshments': ['Tea/Coffee', 'Lunch'],
        'coordinatorNote': 'Excellent event. Smooth execution.',
        'approvalHistory': [
          {'approverName': 'Dr. Priya Nair', 'approverRole': 'Faculty Coordinator', 'action': 'approved', 'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 18))), 'comment': 'Self-organized.'},
          {'approverName': 'Dr. Vice Chancellor', 'approverRole': 'Head of Department', 'action': 'approved', 'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 15))), 'comment': ''},
          {'approverName': 'Fr. Joseph Thomas', 'approverRole': 'Venue Incharge', 'action': 'approved', 'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 12))), 'comment': 'Main Auditorium reserved all day.'},
        ],
        'resourcesRequested': <String>[],
      },
    ];

    for (final booking in bookings) {
      batch.set(bookingsRef.doc(), booking);
    }

    await batch.commit();
  }
}
