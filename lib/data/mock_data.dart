import '../models/user_model.dart';
import '../models/enums.dart';

class MockData {
  static final UserModel defaultUser = UserModel(
    id: 'u1',
    name: 'Mohit B M',
    email: 'mohit.bm@christuniversity.in',
    role: UserRole.studentCoordinator,
    department: 'BCA',
  );

  static final List<String> allFacilities = [
    'Projector', 'AC', 'Mic', 'Stage', 'LED Screen', 'Whiteboard', 'Computers', 'Sound System', 'Video Conferencing', 'Green Room'
  ];

  static final List<String> allBlocks = [
    'Central Block', 'Main Block', 'MBA Block', 'Science Block', 'Library Block', 'Dharmaram Block', 'Block 1'
  ];

  static final List<String> allEquipment = [
    'Projector', 'Microphone', 'Speakers', 'Whiteboard', 'Laptop', 'Extension Board', 'Podium', 'Stage Lights'
  ];
}
