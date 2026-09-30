import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';
import '../../utils/constants.dart';
import '../expenses/edit_expense_screen.dart';
import 'filter_modal.dart';

class ExpenseHistoryScreen extends StatelessWidget {
  const ExpenseHistoryScreen({super.key});

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const FilterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final filteredList = expenseProvider.filteredExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterModal(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // Search Input Bar
              TextField(
                onChanged: (val) => expenseProvider.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search expenses...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: expenseProvider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => expenseProvider.setSearchQuery(''),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 14),

              // Category Horizontal Chips Filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip(context, 'All', expenseProvider),
                    ...AppCategories.categories.map((cat) {
                      return _buildCategoryChip(context, cat, expenseProvider);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Expenses List
              Expanded(
                child: expenseProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : expenseProvider.errorMessage != null
                        ? _buildErrorState(context, expenseProvider)
                        : filteredList.isEmpty
                            ? _buildEmptyState(context)
                            : ListView.builder(
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final expense = filteredList[index];
                                  final catIcon = AppCategories.getCategoryIcon(expense.category);
                                  final catColor = AppCategories.getCategoryColor(expense.category);
                                  final formattedDate = DateFormat('MMM dd, yyyy').format(expense.date);

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: catColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(catIcon, color: catColor),
                                      ),
                                      title: Text(
                                        expense.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        '${expense.category} • $formattedDate',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                      trailing: Text(
                                        'Rs. ${expense.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditExpenseScreen(expense: expense),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String category, ExpenseProvider provider) {
    final isSelected = provider.selectedCategoryFilter == category;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        selectedColor: primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            provider.setCategoryFilter(category);
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Expenses Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ExpenseProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage ?? 'Failed to load expenses',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
