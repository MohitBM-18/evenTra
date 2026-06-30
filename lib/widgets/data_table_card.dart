import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class DataTableCard extends StatelessWidget {
  final String title;
  final Widget? action;
  final List<DataColumn> columns;
  final List<DataRow> rows;

  const DataTableCard({
    super.key,
    required this.title,
    this.action,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          const Divider(height: 1),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No records found.',
                  style: GoogleFonts.inter(
                    color: AppTheme.secondaryTextColor(context),
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(AppTheme.bgColor(context)),
                dataRowMinHeight: 56,
                dataRowMaxHeight: 56,
                horizontalMargin: 16,
                columnSpacing: 24,
                columns: columns,
                rows: rows,
              ),
            ),
        ],
      ),
    );
  }
}
