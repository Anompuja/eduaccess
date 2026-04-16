import '../models/academic_entities.dart';

const academicDummyLevels = <AcademicLevel>[
  AcademicLevel(id: 'lvl_sd', name: 'SD'),
  AcademicLevel(id: 'lvl_smp', name: 'SMP'),
  AcademicLevel(id: 'lvl_sma', name: 'SMA'),
];

const academicDummyClasses = <AcademicClass>[
  AcademicClass(id: 'cls_sd_1', levelId: 'lvl_sd', name: 'Kelas 1'),
  AcademicClass(id: 'cls_sd_2', levelId: 'lvl_sd', name: 'Kelas 2'),
  AcademicClass(id: 'cls_smp_7', levelId: 'lvl_smp', name: 'Kelas 7'),
  AcademicClass(id: 'cls_smp_8', levelId: 'lvl_smp', name: 'Kelas 8'),
  AcademicClass(id: 'cls_sma_10', levelId: 'lvl_sma', name: 'Kelas 10'),
  AcademicClass(id: 'cls_sma_11', levelId: 'lvl_sma', name: 'Kelas 11'),
];

const academicDummySubClasses = <AcademicSubClass>[
  AcademicSubClass(id: 'sub_sd_1a', classId: 'cls_sd_1', name: 'A'),
  AcademicSubClass(id: 'sub_sd_1b', classId: 'cls_sd_1', name: 'B'),
  AcademicSubClass(id: 'sub_smp_7a', classId: 'cls_smp_7', name: 'A'),
  AcademicSubClass(id: 'sub_smp_8a', classId: 'cls_smp_8', name: 'A'),
  AcademicSubClass(id: 'sub_sma_10ipa1', classId: 'cls_sma_10', name: 'IPA 1'),
  AcademicSubClass(id: 'sub_sma_10ips1', classId: 'cls_sma_10', name: 'IPS 1'),
];
