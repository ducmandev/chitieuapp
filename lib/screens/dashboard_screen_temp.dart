  Widget _buildQuickAccessSection(BuildContext context, NeoThemeData neo) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACCESS',
          style: NeoTypography.mono.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: neo.textSub,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildQuickAccessCard(
                    context,
                    Icons.pie_chart_outline,
                    loc.navBreakdown,
                    NeoColors.tertiary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BreakdownScreen()),
                    ),
                    neo,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickAccessCard(
                    context,
                    Icons.account_balance_wallet_outlined,
                    loc.navBudgets,
                    NeoColors.primary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BudgetsScreen()),
                    ),
                    neo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAccessCard(
                    context,
                    Icons.flag_outlined,
                    loc.navGoals,
                    NeoColors.success,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GoalsScreen()),
                    ),
                    neo,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickAccessCard(
                    context,
                    Icons.bar_chart_outline,
                    loc.navStatistics,
                    NeoColors.secondary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                    ),
                    neo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
