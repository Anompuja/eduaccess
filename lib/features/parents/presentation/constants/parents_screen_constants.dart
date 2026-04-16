import 'package:flutter/material.dart';

/// UI constants for Parents screen to reduce hardcoded values.
abstract final class ParentsScreenConstants {
  // Texts
  static const String title = 'Manajemen Orang Tua';
  static const String searchLabel = 'Cari nama / email / no hp';
  static const String searchHint = 'Contoh: iwan atau parent@edu.id';
  static const String addButtonLabel = 'Tambah Orang Tua';
  static const String previousButtonLabel = 'Sebelumnya';
  static const String nextButtonLabel = 'Berikutnya';

  // Table headers
  static const String noHeader = 'NO';
  static const String nameHeader = 'NAMA';
  static const String emailHeader = 'EMAIL';
  static const String phoneHeader = 'NO. HP';
  static const String childrenHeader = 'ANAK';
  static const String actionsHeader = 'ACTIONS';

  // Data conventions
  static const int rowsPerPage = 5;
  static const String childrenSuffix = 'siswa';

  // Layout dimensions
  static const double desktopSearchWidth = 320;
  static const double desktopAddButtonRightPadding = 5;
  static const double desktopAddButtonBottomPadding = 4;

  static const double noColumnWidth = 44;
  static const double nameColumnWidthMobile = 170;
  static const double nameColumnWidthDesktop = 240;
  static const double emailColumnWidthMobile = 220;
  static const double emailColumnWidthDesktop = 250;
  static const double phoneColumnWidthMobile = 120;
  static const double phoneColumnWidthDesktop = 130;
  static const double childrenColumnWidthMobile = 90;
  static const double childrenColumnWidthDesktop = 120;
  static const double actionsColumnWidthMobile = 132;
  static const double actionsColumnWidthDesktop = 150;

  static const double tableColumnSpacingMobile = 24;
  static const double tableColumnSpacingDesktop = 36;
  static const double headingRowHeightMobile = 50;
  static const double headingRowHeightDesktop = 56;
  static const double dataRowHeightMobile = 70;
  static const double dataRowHeightDesktop = 78;

  static const double childrenPillHorizontalPadding = 8;
  static const double childrenPillVerticalPadding = 4;
  static const double actionButtonSize = 34;
  static const double actionIconSize = 18;
  static const double addButtonHeight = 50;

  // Icons
  static const IconData searchIcon = Icons.search;
  static const IconData addIcon = Icons.group_add;
  static const IconData viewIcon = Icons.visibility_outlined;
  static const IconData editIcon = Icons.edit_outlined;
  static const IconData deleteIcon = Icons.delete_outline;
}
