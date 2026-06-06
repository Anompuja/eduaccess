import 'package:flutter/material.dart';

abstract final class HeadmastersScreenConstants {
  static const String title = 'Manajemen Kepala Sekolah';
  static const String searchHint =
      'Contoh: andi, 198704122010011002, atau kepala.sekolah';
  static const String addButtonLabel = 'Tambah Kepala Sekolah';

  static const String noHeader = 'NO';
  static const String nameHeader = 'NAMA';
  static const String nipHeader = 'NIP';
  static const String emailHeader = 'EMAIL';
  static const String statusHeader = 'STATUS';
  static const String actionsHeader = 'ACTIONS';

  static const String activeStatus = 'Aktif';
  static const int rowsPerPage = 10;

  static const double desktopSearchWidth = 320;
  static const double desktopAddButtonRightPadding = 8;
  static const double desktopAddButtonBottomPadding = 4;

  static const double noColumnWidth = 44;
  static const double nameColumnWidthMobile = 180;
  static const double nameColumnWidthDesktop = 280;
  static const double nipColumnWidthMobile = 140;
  static const double nipColumnWidthDesktop = 180;
  static const double emailColumnWidthMobile = 180;
  static const double emailColumnWidthDesktop = 260;
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

  static const IconData addIcon = Icons.account_balance_outlined;
  static const IconData rowAvatarIcon = Icons.account_balance_outlined;
  static const IconData viewIcon = Icons.visibility_outlined;
  static const IconData editIcon = Icons.edit_outlined;
  static const IconData deleteIcon = Icons.delete_outline;
}
