import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../models/category.dart';
import '../providers/app_provider.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: neo.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, neo, loc),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  // Use default categories for now
                  final categories = CategoryModel.getDefaults();

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSectionHeader(context, loc.expense, neo, 'expense', categories),
                      const SizedBox(height: 24),
                      _buildSectionHeader(context, loc.income, neo, 'income', categories),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddButton(context, neo, loc),
    );
  }

  Widget _buildHeader(BuildContext context, NeoThemeData neo, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: neo.background,
        border: Border(bottom: BorderSide(color: neo.ink, width: 3)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: neo.textMain),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Transform.rotate(
            angle: -0.05,
            child: Text(
              loc.categoryManagement,
              style: NeoTypography.textTheme.displayMedium?.copyWith(
                fontStyle: FontStyle.italic,
                letterSpacing: -1,
                color: neo.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    NeoThemeData neo,
    String type,
    List<CategoryModel> categories,
  ) {
    final filteredCategories = categories.where((c) => c.type == type).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title CATEGORIES',
          style: NeoTypography.mono.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: neo.textSub,
          ),
        ),
        const SizedBox(height: 16),
        ...filteredCategories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCategoryCard(context, category, neo),
          );
        }),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryModel category, NeoThemeData neo) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.color,
              border: Border.all(color: neo.ink, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              category.icon,
              color: NeoColors.ink,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Category info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: NeoTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: neo.textMain,
                  ),
                ),
                if (category.nameVI != category.name) ...[
                  const SizedBox(height: 2),
                  Text(
                    category.nameVI,
                    style: NeoTypography.mono.copyWith(
                      fontSize: 11,
                      color: neo.textSub,
                    ),
                  ),
                ],
                if (category.isDefault) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: neo.ink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'DEFAULT',
                      style: NeoTypography.mono.copyWith(
                        fontSize: 9,
                        color: neo.textSub,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              if (!category.isDefault)
                IconButton(
                  icon: Icon(Icons.edit, size: 20, color: neo.textMain),
                  onPressed: () => _showEditDialog(context, category),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              if (!category.isDefault)
                IconButton(
                  icon: Icon(Icons.delete, size: 20, color: neo.error),
                  onPressed: () => _showDeleteDialog(context, category),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, NeoThemeData neo, AppLocalizations loc) {
    return NeoButton(
      backgroundColor: NeoColors.primary,
      padding: const EdgeInsets.all(16),
      onPressed: () => _showAddDialog(context),
      child: const Icon(Icons.add, color: NeoColors.ink, size: 28),
    );
  }

  void _showAddDialog(BuildContext context) {
    _showCategoryDialog(context, null);
  }

  void _showEditDialog(BuildContext context, CategoryModel category) {
    _showCategoryDialog(context, category);
  }

  void _showCategoryDialog(BuildContext context, CategoryModel? category) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;
    final isEditing = category != null;

    final nameController = TextEditingController(text: isEditing ? category.name : '');
    final nameVIController = TextEditingController(text: isEditing ? category.nameVI : '');
    String selectedType = isEditing ? category.type : 'expense';
    IconData selectedIcon = isEditing ? category.icon : CategoryModel.availableIcons[0];
    Color selectedColor = isEditing ? category.color : CategoryModel.availableColors[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: neo.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: BorderSide(color: neo.ink, width: 3),
            ),
            title: Text(isEditing ? loc.editCategory : loc.addCategory),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Type selector
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: !isEditing
                              ? () => setDialogState(() => selectedType = 'expense')
                              : null,
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: selectedType == 'expense'
                                  ? NeoColors.secondary
                                  : neo.background,
                              border: Border.all(color: neo.ink, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '- ${loc.expense}',
                                style: NeoTypography.mono.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: selectedType == 'expense'
                                      ? Colors.white
                                      : neo.textMain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: !isEditing
                              ? () => setDialogState(() => selectedType = 'income')
                              : null,
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: selectedType == 'income'
                                  ? NeoColors.success
                                  : neo.background,
                              border: Border.all(color: neo.ink, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '+ ${loc.income}',
                                style: NeoTypography.mono.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: selectedType == 'income'
                                      ? Colors.white
                                      : neo.textMain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '${loc.categoryName} (EN)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vietnamese name
                  TextField(
                    controller: nameVIController,
                    decoration: InputDecoration(
                      labelText: '${loc.categoryName} (VI)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Icon selector
                  Text(
                    loc.selectIcon,
                    style: NeoTypography.mono.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: neo.textSub,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 1,
                      ),
                      itemCount: CategoryModel.availableIcons.length,
                      itemBuilder: (context, index) {
                        final icon = CategoryModel.availableIcons[index];
                        final isSelected = selectedIcon == icon;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedIcon = icon),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor : neo.background,
                              border: Border.all(
                                color: isSelected ? neo.ink : neo.ink.withValues(alpha: 0.3),
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icon,
                              color: isSelected ? NeoColors.ink : neo.textMain,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Color selector
                  Text(
                    loc.selectColor,
                    style: NeoTypography.mono.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: neo.textSub,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: CategoryModel.availableColors.length,
                      itemBuilder: (context, index) {
                        final color = CategoryModel.availableColors[index];
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: Container(
                            width: 40,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                color: isSelected ? neo.ink : Colors.transparent,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: isSelected
                                ? Icon(Icons.check, color: NeoColors.ink)
                                : const SizedBox.shrink(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;

                  // TODO: Create/Update category in provider
                  // final updatedCategory = CategoryModel(...);

                  if (isEditing) {
                    // TODO: Update category in provider
                  } else {
                    // TODO: Add category to provider
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(isEditing ? loc.update : loc.add),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CategoryModel category) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: neo.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: neo.ink, width: 3),
        ),
        title: Text(loc.deleteCategory),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete "${category.name}"?'),
            const SizedBox(height: 12),
            Text(
              loc.categoryWarning,
              style: NeoTypography.textTheme.bodySmall?.copyWith(
                color: neo.textSub,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Delete category from provider
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${category.name} deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: neo.error),
            child: Text(loc.delete),
          ),
        ],
      ),
    );
  }
}
