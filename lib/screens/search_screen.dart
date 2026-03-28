import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';
import '../utils/category_utils.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDateRange = 'allTime';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  String? _selectedCategory;
  int? _selectedWalletId;
  String _sortBy = 'newestFirst';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            _buildSearchBar(context, neo, loc),
            _buildFilterChips(context, neo, loc),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  final filteredTransactions = _filterTransactions(provider.transactions);

                  if (filteredTransactions.isEmpty) {
                    return _buildEmptyState(context, neo, loc);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 100,
                      left: 16,
                      right: 16,
                    ),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTransactionCard(
                          context,
                          filteredTransactions[index],
                          provider,
                          neo,
                          loc,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform.rotate(
            angle: -0.05,
            child: Text(
              loc.search,
              style: NeoTypography.textTheme.displayMedium?.copyWith(
                fontStyle: FontStyle.italic,
                letterSpacing: -1,
                color: neo.textMain,
              ),
            ),
          ),
          NeoButton(
            padding: const EdgeInsets.all(8),
            onPressed: _resetFilters,
            child: Icon(Icons.refresh, color: neo.textMain, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, NeoThemeData neo, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: NeoCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.search, color: neo.textSub),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: loc.searchPlaceholder,
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: neo.textSub),
                ),
                style: NeoTypography.textTheme.titleMedium,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: Icon(Icons.clear, color: neo.textSub),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, NeoThemeData neo, AppLocalizations loc) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            loc.dateRange,
            _getDateRangeLabel(loc),
            Icons.calendar_today,
            () => _showDateRangeFilter(context),
            neo,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            loc.category,
            _selectedCategory ?? 'ALL',
            Icons.category,
            () => _showCategoryFilter(context),
            neo,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            loc.sortBy,
            _getSortLabel(loc),
            Icons.sort,
            () => _showSortOptions(context),
            neo,
          ),
          const SizedBox(width: 8),
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              return _buildFilterChip(
                context,
                loc.wallets,
                _selectedWalletId != null
                    ? provider.wallets.firstWhere((w) => w.id == _selectedWalletId).name
                    : 'ALL',
                Icons.account_balance_wallet,
                () => _showWalletFilter(context),
                neo,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
    NeoThemeData neo,
  ) {
    return NeoButton(
      backgroundColor: neo.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: neo.textMain),
          const SizedBox(width: 8),
          Text(
            value,
            style: NeoTypography.mono.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: neo.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    TransactionModel transaction,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    final wallet = provider.wallets.firstWhere(
      (w) => w.id == transaction.walletId,
      orElse: () => provider.defaultWallet ?? provider.wallets.first,
    );

    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: CategoryUtils.getCategoryColor(transaction.category),
              border: Border.all(color: neo.ink, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CategoryUtils.getCategoryIcon(transaction.category),
              color: NeoColors.ink,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Transaction info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: NeoTypography.textTheme.titleMedium?.copyWith(
                    color: neo.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: neo.ink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        transaction.category,
                        style: NeoTypography.mono.copyWith(
                          fontSize: 10,
                          color: neo.textSub,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                      style: NeoTypography.mono.copyWith(
                        fontSize: 11,
                        color: neo.textSub,
                      ),
                    ),
                  ],
                ),
                if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.note!,
                    style: NeoTypography.textTheme.bodySmall?.copyWith(
                      color: neo.textSub,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (transaction.tags != null && transaction.tags!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: transaction.tagList.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: NeoColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#$tag',
                          style: NeoTypography.mono.copyWith(
                            fontSize: 9,
                            color: neo.textSub,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${provider.currencySymbol}${transaction.amount.toStringAsFixed(0)}',
                style: NeoTypography.numbers.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: transaction.type == 'income'
                      ? NeoColors.success
                      : NeoColors.secondary,
                ),
              ),
              if (wallet.name.isNotEmpty)
                Text(
                  wallet.name,
                  style: NeoTypography.mono.copyWith(
                    fontSize: 10,
                    color: neo.textSub,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, NeoThemeData neo, AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: neo.textSub),
          const SizedBox(height: 16),
          Text(
            loc.noResults,
            style: NeoTypography.textTheme.titleLarge?.copyWith(
              color: neo.textSub,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: NeoTypography.mono.copyWith(color: neo.textSub),
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    var filtered = transactions;

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(query) ||
            t.category.toLowerCase().contains(query) ||
            (t.note?.toLowerCase().contains(query) ?? false) ||
            (t.tags?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Date range filter
    if (_selectedDateRange != 'allTime') {
      final now = DateTime.now();
      DateTime? startDate;
      DateTime? endDate;

      switch (_selectedDateRange) {
        case 'last7Days':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'last30Days':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'last90Days':
          startDate = now.subtract(const Duration(days: 90));
          break;
        case 'thisYear':
          startDate = DateTime(now.year, 1, 1);
          endDate = DateTime(now.year, 12, 31);
          break;
        case 'custom':
          startDate = _customStartDate;
          endDate = _customEndDate;
          break;
      }

      if (startDate != null) {
        filtered = filtered.where((t) => t.date.isAfter(startDate!.subtract(const Duration(days: 1)))).toList();
      }
      if (endDate != null) {
        filtered = filtered.where((t) => t.date.isBefore(endDate!.add(const Duration(days: 1)))).toList();
      }
    }

    // Category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((t) => t.category == _selectedCategory).toList();
    }

    // Wallet filter
    if (_selectedWalletId != null) {
      filtered = filtered.where((t) => t.walletId == _selectedWalletId).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'newestFirst':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'oldestFirst':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'highestAmount':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'lowestAmount':
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'byCategory':
        filtered.sort((a, b) => a.category.compareTo(b.category));
        break;
    }

    return filtered;
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedDateRange = 'allTime';
      _customStartDate = null;
      _customEndDate = null;
      _selectedCategory = null;
      _selectedWalletId = null;
      _sortBy = 'newestFirst';
    });
  }

  String _getDateRangeLabel(AppLocalizations loc) {
    switch (_selectedDateRange) {
      case 'allTime':
        return loc.allTime;
      case 'last7Days':
        return loc.last7Days;
      case 'last30Days':
        return loc.last30Days;
      case 'last90Days':
        return loc.last90Days;
      case 'thisYear':
        return loc.thisYear;
      case 'custom':
        return loc.custom;
      default:
        return loc.dateRange;
    }
  }

  String _getSortLabel(AppLocalizations loc) {
    switch (_sortBy) {
      case 'newestFirst':
        return loc.newestFirst;
      case 'oldestFirst':
        return loc.oldestFirst;
      case 'highestAmount':
        return loc.highestAmount;
      case 'lowestAmount':
        return loc.lowestAmount;
      case 'byCategory':
        return loc.byCategory;
      default:
        return loc.sortBy;
    }
  }

  void _showDateRangeFilter(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: neo.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: neo.ink, width: 3),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.dateRange,
                  style: NeoTypography.textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildDateRangeOption(context, loc.allTime, 'allTime', setSheetState),
                _buildDateRangeOption(context, loc.last7Days, 'last7Days', setSheetState),
                _buildDateRangeOption(context, loc.last30Days, 'last30Days', setSheetState),
                _buildDateRangeOption(context, loc.last90Days, 'last90Days', setSheetState),
                _buildDateRangeOption(context, loc.thisYear, 'thisYear', setSheetState),
                _buildDateRangeOption(context, loc.custom, 'custom', setSheetState),
                if (_selectedDateRange == 'custom') ...[
                  const SizedBox(height: 16),
                  NeoButton(
                    backgroundColor: neo.background,
                    padding: const EdgeInsets.all(12),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _customStartDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setSheetState(() => _customStartDate = date);
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: neo.textMain),
                        const SizedBox(width: 8),
                        Text(
                          _customStartDate != null
                              ? '${_customStartDate!.day}/${_customStartDate!.month}/${_customStartDate!.year}'
                              : loc.selectStartDate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  NeoButton(
                    backgroundColor: neo.background,
                    padding: const EdgeInsets.all(12),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _customEndDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setSheetState(() => _customEndDate = date);
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: neo.textMain),
                        const SizedBox(width: 8),
                        Text(
                          _customEndDate != null
                              ? '${_customEndDate!.day}/${_customEndDate!.month}/${_customEndDate!.year}'
                              : loc.selectEndDate,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateRangeOption(BuildContext context, String label, String value, StateSetter setSheetState) {
    final neo = NeoTheme.of(context);
    final isSelected = _selectedDateRange == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeoButton(
        backgroundColor: isSelected ? NeoColors.primary : neo.background,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        onPressed: () {
          setSheetState(() => _selectedDateRange = value);
          setState(() => _selectedDateRange = value);
          Navigator.pop(context);
        },
        child: Row(
          children: [
            if (isSelected)
              Icon(Icons.check, color: NeoColors.ink)
            else
              SizedBox(width: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: NeoTypography.mono.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? NeoColors.ink : neo.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    final categories = [loc.food, loc.travel, loc.games, loc.coffee, loc.rides, loc.income];

    showModalBottomSheet(
      context: context,
      backgroundColor: neo.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: neo.ink, width: 3),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.category,
              style: NeoTypography.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildCategoryOption(context, 'ALL', null),
            ...categories.map((cat) => _buildCategoryOption(context, cat, cat)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOption(BuildContext context, String label, String? value) {
    final neo = NeoTheme.of(context);
    final isSelected = _selectedCategory == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeoButton(
        backgroundColor: isSelected ? NeoColors.primary : neo.background,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        onPressed: () {
          setState(() => _selectedCategory = value);
          Navigator.pop(context);
        },
        child: Row(
          children: [
            if (value != null)
              Icon(
                CategoryUtils.getCategoryIcon(value),
                size: 20,
                color: isSelected ? NeoColors.ink : neo.textMain,
              )
            else
              Icon(Icons.apps, size: 20, color: isSelected ? NeoColors.ink : neo.textMain),
            const SizedBox(width: 12),
            Text(
              label,
              style: NeoTypography.mono.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? NeoColors.ink : neo.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletFilter(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;
    final provider = context.read<AppProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: neo.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: neo.ink, width: 3),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.wallets,
              style: NeoTypography.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildWalletOption(context, loc.allWallets, null, provider),
            ...provider.wallets.map((wallet) => _buildWalletOption(context, wallet.name, wallet.id, provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletOption(BuildContext context, String label, int? value, AppProvider provider) {
    final neo = NeoTheme.of(context);
    final isSelected = _selectedWalletId == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeoButton(
        backgroundColor: isSelected ? NeoColors.primary : neo.background,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        onPressed: () {
          setState(() => _selectedWalletId = value);
          Navigator.pop(context);
        },
        child: Row(
          children: [
            Icon(
              value != null ? Icons.account_balance_wallet : Icons.apps,
              size: 20,
              color: isSelected ? NeoColors.ink : neo.textMain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: NeoTypography.mono.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? NeoColors.ink : neo.textMain,
                ),
              ),
            ),
            if (value != null)
              Text(
                '${provider.currencySymbol}${provider.wallets.firstWhere((w) => w.id == value).balance.toStringAsFixed(0)}',
                style: NeoTypography.mono.copyWith(
                  fontSize: 11,
                  color: isSelected ? NeoColors.ink : neo.textSub,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    final options = [
      ('newestFirst', loc.newestFirst),
      ('oldestFirst', loc.oldestFirst),
      ('highestAmount', loc.highestAmount),
      ('lowestAmount', loc.lowestAmount),
      ('byCategory', loc.byCategory),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: neo.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: neo.ink, width: 3),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.sortBy,
              style: NeoTypography.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...options.map((option) => _buildSortOption(context, option.$1, option.$2)),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String value, String label) {
    final neo = NeoTheme.of(context);
    final isSelected = _sortBy == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeoButton(
        backgroundColor: isSelected ? NeoColors.primary : neo.background,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        onPressed: () {
          setState(() => _sortBy = value);
          Navigator.pop(context);
        },
        child: Row(
          children: [
            if (isSelected)
              Icon(Icons.check, color: NeoColors.ink)
            else
              SizedBox(width: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: NeoTypography.mono.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? NeoColors.ink : neo.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
