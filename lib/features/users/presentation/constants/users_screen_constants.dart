import 'package:flutter/material.dart';

/// UI constants for Users screen to reduce hardcoded values.
abstract final class UsersScreenConstants {
  // Texts
  static const String title = 'Manajemen User';
  static const String searchLabel = 'Cari nama / email / role';
  static const String searchHint = 'Contoh: rama atau admin';
  static const String addButtonLabel = 'Tambah User';
  static const String previousButtonLabel = 'Sebelumnya';
  static const String nextButtonLabel = 'Berikutnya';

  // Table headers
  static const String noHeader = 'NO';
  static const String nameHeader = 'NAMA';
  static const String emailHeader = 'EMAIL';
  static const String roleHeader = 'ROLE';
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
  static const double emailColumnWidthMobile = 180;
  static const double emailColumnWidthDesktop = 260;
  static const double roleColumnWidthMobile = 120;
  static const double roleColumnWidthDesktop = 150;
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
