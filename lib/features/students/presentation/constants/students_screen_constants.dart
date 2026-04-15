import 'package:flutter/material.dart';

/// UI constants for Students screen to reduce hardcoded values.
abstract final class StudentsScreenConstants {
  // Texts
  static const String title = 'Manajemen Siswa';
  static const String searchLabel = 'Cari nama / email / NIS / NISN';
  static const String searchHint = 'Contoh: dina atau 2024001';
  static const String addButtonLabel = 'Tambah Siswa';
  static const String previousButtonLabel = 'Sebelumnya';
  static const String nextButtonLabel = 'Berikutnya';

  // Filter labels
  static const String educationLevelLabel = 'Education Level';
  static const String classLabel = 'Kelas';
  static const String subClassLabel = 'Sub-Kelas';

  // Table headers
  static const String noHeader = 'NO';
  static const String nameHeader = 'NAMA';
  static const String nisHeader = 'NIS';
  static const String classHeader = 'KELAS';
  static const String statusHeader = 'STATUS';
  static const String actionsHeader = 'ACTIONS';

  // Data conventions
  static const String activeStatus = 'Aktif';
  static const int rowsPerPage = 5;

  // Layout dimensions
  static const double desktopSearchWidth = 320;
  static const double desktopAddButtonLeftPadding = 30;
  static const double desktopAddButtonBottomPadding = 4;

  static const double noColumnWidth = 44;
  static const double nameColumnWidthMobile = 180;
  static const double nameColumnWidthDesktop = 280;
  static const double nisColumnWidthMobile = 90;
  static const double nisColumnWidthDesktop = 110;
  static const double classColumnWidthMobile = 100;
  static const double classColumnWidthDesktop = 120;
  static const double statusColumnWidthMobile = 100;
  static const double statusColumnWidthDesktop = 120;
  static const double actionsColumnWidthMobile = 132;
  static const double actionsColumnWidthDesktop = 150;

  static const double tableColumnSpacingMobile = 24;
  static const double tableColumnSpacingDesktop = 36;
  static const double headingRowHeightMobile = 50;
  static const double headingRowHeightDesktop = 56;
  static const double dataRowHeightMobile = 70;
  static const double dataRowHeightDesktop = 78;

  static const double rowAvatarRadius = 16;
  static const double rowAvatarIconSize = 16;
  static const double actionIconSize = 18;
  static const double actionButtonSize = 34;
  static const double addButtonHeight = 50;

  // Icons
  static const IconData searchIcon = Icons.search;
  static const IconData addIcon = Icons.person_add_alt_1;
  static const IconData rowAvatarIcon = Icons.person;
  static const IconData viewIcon = Icons.visibility_outlined;
  static const IconData editIcon = Icons.edit_outlined;
  static const IconData deleteIcon = Icons.delete_outline;
}
