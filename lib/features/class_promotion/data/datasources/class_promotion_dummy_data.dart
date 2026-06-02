import '../models/class_promotion_entities.dart';

const classPromotionAcademicYears = <String>[
  '2025/2026',
  '2026/2027',
  '2027/2028',
];

const classPromotionClassOptions = <PromotionClassOption>[
  PromotionClassOption(id: 'x_ipa_1', label: 'X IPA 1', level: 'SMA', nextClassId: 'xi_ipa_1'),
  PromotionClassOption(id: 'x_ipa_2', label: 'X IPA 2', level: 'SMA', nextClassId: 'xi_ipa_2'),
  PromotionClassOption(id: 'x_ips_1', label: 'X IPS 1', level: 'SMA', nextClassId: 'xi_ips_1'),
  PromotionClassOption(id: 'xi_ipa_1', label: 'XI IPA 1', level: 'SMA', nextClassId: 'xii_ipa_1'),
  PromotionClassOption(id: 'xi_ipa_2', label: 'XI IPA 2', level: 'SMA', nextClassId: 'xii_ipa_2'),
  PromotionClassOption(id: 'xi_ips_1', label: 'XI IPS 1', level: 'SMA', nextClassId: 'xii_ips_1'),
];

const classPromotionStudentsByClass = <String, List<PromotionStudent>>{
  'x_ipa_1': [
    PromotionStudent(id: 'st_001', name: 'Andi Pratama', nis: '202401001', sourceClass: 'X IPA 1'),
    PromotionStudent(id: 'st_002', name: 'Siti Rahmawati', nis: '202401002', sourceClass: 'X IPA 1'),
    PromotionStudent(id: 'st_003', name: 'Muhammad Fajar', nis: '202401003', sourceClass: 'X IPA 1'),
  ],
  'x_ipa_2': [
    PromotionStudent(id: 'st_004', name: 'Nabila Putri', nis: '202401010', sourceClass: 'X IPA 2'),
    PromotionStudent(id: 'st_005', name: 'Rizky Maulana', nis: '202401011', sourceClass: 'X IPA 2'),
  ],
  'x_ips_1': [
    PromotionStudent(id: 'st_006', name: 'Dewi Lestari', nis: '202401020', sourceClass: 'X IPS 1'),
    PromotionStudent(id: 'st_007', name: 'Arman Syah', nis: '202401021', sourceClass: 'X IPS 1'),
  ],
};
