import 'package:flutter/material.dart';

abstract final class AdminsScreenConstants {
  static const String title = 'Manajemen Admin';
  static const String searchLabel = 'Cari nama / phone number / address / nik';
  static const String searchHint = 'Contoh: rama atau 0812';
  static const String addButtonLabel = 'Tambah Admin';
  static const String previousButtonLabel = 'Sebelumnya';
  static const String nextButtonLabel = 'Berikutnya';

  static const String noHeader = 'NO';
  static const String nameHeader = 'NAMA';
  static const String phoneNumberHeader = 'PHONE NUMBER';
  static const String addressHeader = 'ADDRESS';
  static const String nikHeader = 'NIK';
  static const String actionsHeader = 'ACTIONS';

  static const int rowsPerPage = 5;

  static const double desktopSearchWidth = 320;
  static const double desktopAddButtonRightPadding = 8;
  static const double desktopAddButtonBottomPadding = 4;

  static const double noColumnWidth = 44;
  static const double nameColumnWidthMobile = 180;
  static const double nameColumnWidthDesktop = 240;
  static const double phoneNumberColumnWidthMobile = 150;
  static const double phoneNumberColumnWidthDesktop = 180;
  static const double addressColumnWidthMobile = 220;
  static const double addressColumnWidthDesktop = 280;
  static const double nikColumnWidthMobile = 180;
  static const double nikColumnWidthDesktop = 200;
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

  static const IconData searchIcon = Icons.search;
  static const IconData addIcon = Icons.admin_panel_settings_outlined;
  static const IconData rowAvatarIcon = Icons.admin_panel_settings;
  static const IconData viewIcon = Icons.visibility_outlined;
  static const IconData editIcon = Icons.edit_outlined;
  static const IconData deleteIcon = Icons.delete_outline;
}
