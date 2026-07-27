import 'package:flutter/material.dart';

import '../models/qualification_group.dart';
import '../models/qualification_table_row.dart';

class QualificationTables extends StatelessWidget {
  final List<QualificationGroup> groups;
  final String? selectedTeamName;

  const QualificationTables({
    super.key,
    required this.groups,
    required this.selectedTeamName,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const Center(
        child: Text('Qualification tables are not available yet.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _QualificationGroupTable(
        group: groups[index],
        selectedTeamName: selectedTeamName,
      ),
    );
  }
}

class _QualificationGroupTable extends StatelessWidget {
  final QualificationGroup group;
  final String? selectedTeamName;

  const _QualificationGroupTable({
    required this.group,
    required this.selectedTeamName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: colors.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Group ${group.name}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Team')),
                DataColumn(label: Text('P'), numeric: true),
                DataColumn(label: Text('W'), numeric: true),
                DataColumn(label: Text('D'), numeric: true),
                DataColumn(label: Text('L'), numeric: true),
                DataColumn(label: Text('GF'), numeric: true),
                DataColumn(label: Text('GA'), numeric: true),
                DataColumn(label: Text('GD'), numeric: true),
                DataColumn(label: Text('Pts'), numeric: true),
              ],
              rows: [
                for (var index = 0; index < group.table.length; index++)
                  _buildRow(context, index, group.table[index]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(
    BuildContext context,
    int index,
    QualificationTableRow row,
  ) {
    final isSelected = row.team.name == selectedTeamName;
    final textStyle = TextStyle(
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );

    DataCell numberCell(int value) =>
        DataCell(Text(value.toString(), style: textStyle));

    return DataRow(
      color: isSelected
          ? WidgetStatePropertyAll(
              Theme.of(context).colorScheme.secondaryContainer,
            )
          : null,
      cells: [
        numberCell(index + 1),
        DataCell(
          Row(
            children: [
              Text(row.team.flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(row.team.name, style: textStyle),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.star,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
        numberCell(row.played),
        numberCell(row.wins),
        numberCell(row.draws),
        numberCell(row.losses),
        numberCell(row.goalsFor),
        numberCell(row.goalsAgainst),
        numberCell(row.goalDifference),
        numberCell(row.points),
      ],
    );
  }
}
