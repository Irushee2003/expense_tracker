import 'dart:async';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<Expense>>? _expenseSubscription;

  List<Expense> _allExpenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Search & Filter parameters
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategoryFilter => _selectedCategoryFilter;

  // Filtered expenses list
  List<Expense> get filteredExpenses {
    return _allExpenses.where((expense) {
      // Search Title Filter
      if (_searchQuery.isNotEmpty &&
          !expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !expense.category.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // Category Filter
      if (_selectedCategoryFilter != 'All' &&
          expense.category != _selectedCategoryFilter) {
        return false;
      }

      // Date Range Filter
      if (_startDateFilter != null && expense.date.isBefore(_startDateFilter!)) {
        return false;
      }
      if (_endDateFilter != null && expense.date.isAfter(_endDateFilter!)) {
        return false;
      }

      return true;
    }).toList();
  }

  // All expenses for current user
  List<Expense> get allExpenses => _allExpenses;

  // Expenses for the current month
  List<Expense> get currentMonthExpenses {
    final now = DateTime.now();
    return _allExpenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList();
  }

  // Current Month Total Amount
  double get currentMonthTotal {
    return currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  // Category Total Map (for Donut Chart & Category summary)
  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (var expense in currentMonthExpenses) {
      totals[expense.category] = (totals[expense.category] ?? 0.0) + expense.amount;
    }
    return totals;
  }

  // Daily totals map for current month bar chart (day -> total)
  Map<int, double> get dailyTotalsForCurrentMonth {
    final Map<int, double> totals = {};
    for (var expense in currentMonthExpenses) {
      final day = expense.date.day;
      totals[day] = (totals[day] ?? 0.0) + expense.amount;
    }
    return totals;
  }

  // Listen to Firestore real-time stream
  void listenToExpenses(String userId) {
    _expenseSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _expenseSubscription = _firestoreService.getExpensesStream(userId).listen(
      (expenses) {
        _allExpenses = expenses;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void setDateRangeFilter(DateTime? start, DateTime? end) {
    _startDateFilter = start;
    _endDateFilter = end;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategoryFilter = 'All';
    _startDateFilter = null;
    _endDateFilter = null;
    notifyListeners();
  }

  Future<bool> addExpense(Expense expense) async {
    try {
      await _firestoreService.addExpense(expense);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    try {
      await _firestoreService.updateExpense(expense);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _firestoreService.deleteExpense(expenseId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _expenseSubscription?.cancel();
    super.dispose();
  }
}
