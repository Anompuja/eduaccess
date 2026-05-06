import 'package:flutter/material.dart';

/// UI constants for Teachers screen to reduce hardcoded values.
abstract final class TeachersScreenConstants {
  // Texts
  static const String title = 'Manajemen Guru';
  static const String searchLabel = 'Cari nama / NIP / mapel';
  static const String searchHint = 'Contoh: budi atau 198704122010011002';
  static const String addButtonLabel = 'Tambah Guru';
  static const String previousButtonLabel = 'Sebelumnya';
  static const String nextButtonLabel = 'Berikutnya';

  // Table headers
  static const String noHeader = 'NO';
  static const String nameHeader = 'NAMA';
  static const String nipHeader = 'NIP';
  static const String subjectHeader = 'MAPEL';
  static const String statusHeader = 'STATUS';
  static const String actionsHeader = 'ACTIONS';

  // Data conventions
  static const String activeStatus = 'Aktif';
  static const int rowsPerPage = 5;

  // Layout dimensions
  static const double desktopSearchWidth = 320;
  static const double desktopAddButtonRightPadding = 5;
  static const double desktopAddButtonBottomPadding = 4;

  static const double noColumnWidth = 44;
  static const double nameColumnWidthMobile = 180;
  static const double nameColumnWidthDesktop = 280;
  static const double nipColumnWidthMobile = 120;
  static const double nipColumnWidthDesktop = 160;
  static const double subjectColumnWidthMobile = 120;
  static const double subjectColumnWidthDesktop = 150;
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
