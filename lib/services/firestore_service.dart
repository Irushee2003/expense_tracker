import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get live expense stream for current user
  Stream<List<Expense>> getExpensesStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    return _db
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      List<Expense> list = snapshot.docs
          .map((doc) => Expense.fromFirestore(doc))
          .toList();
      // Sort in memory by date descending
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  // Add expense
  Future<void> addExpense(Expense expense) async {
    await _db.collection('expenses').add(expense.toMap());
  }

  // Update expense
  Future<void> updateExpense(Expense expense) async {
    await _db.collection('expenses').doc(expense.id).update(expense.toMap());
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    await _db.collection('expenses').doc(expenseId).delete();
  }
}
