import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import '../models/expense_hive.dart';
import '../models/account.dart';
import '../models/account_transaction.dart';
import '../services/isar_service.dart';

final dateFormat = DateFormat('dd.MM.yyyy');

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Income
  final _incomeAmountController = TextEditingController();
  final _incomeDescController = TextEditingController();
  String _incomeSource = 'Card';
  DateTime _incomeDate = DateTime.now();
  final List<String> _incomeSources = ['Card', 'Cash'];

  // Expense
  final _expenseAmountController = TextEditingController();
  final _expenseDescController = TextEditingController();
  String _expenseCategory = 'Entertainment';
  DateTime _expenseDate = DateTime.now();
  final List<String> _expenseCategories = [
    'Entertainment', 'Health', 'Shopping', 'Bills', 'Transportation', 'Food', 'Education', 'Other',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Entertainment': Icons.movie_outlined,
    'Health': Icons.favorite_outline,
    'Shopping': Icons.shopping_bag_outlined,
    'Bills': Icons.receipt_outlined,
    'Transportation': Icons.directions_car_outlined,
    'Food': Icons.restaurant_outlined,
    'Education': Icons.school_outlined,
    'Other': Icons.more_horiz_outlined,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _incomeAmountController.dispose();
    _incomeDescController.dispose();
    _expenseAmountController.dispose();
    _expenseDescController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(DateTime initialDate, Function(DateTime) onSelect) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) onSelect(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.add_circle_outline),
              text: 'Income',
            ),
            Tab(
              icon: const Icon(Icons.remove_circle_outline),
              text: 'Expense',
            ),
          ],
          labelStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIncomeForm(),
          _buildExpenseForm(),
        ],
      ),
    );
  }

  Widget _buildIncomeForm() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 0,
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Only Salary can be added as income.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildDropdownField(
            value: _incomeSource,
            items: _incomeSources,
            onChanged: (val) => setState(() => _incomeSource = val!),
            label: 'Source',
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _incomeAmountController,
            label: 'Amount',
            prefixIcon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _incomeDescController,
            label: 'Description',
            prefixIcon: Icons.description_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildDateField(
            date: _incomeDate,
            onTap: () => _selectDate(_incomeDate, (date) => setState(() => _incomeDate = date)),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _addIncome,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add Income'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCategoryGrid(),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _expenseAmountController,
            label: 'Amount',
            prefixIcon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _expenseDescController,
            label: 'Description',
            prefixIcon: Icons.description_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildDateField(
            date: _expenseDate,
            onTap: () => _selectDate(_expenseDate, (date) => setState(() => _expenseDate = date)),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _addExpense,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add Expense'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final theme = Theme.of(context);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _expenseCategories.length,
      itemBuilder: (context, index) {
        final category = _expenseCategories[index];
        final isSelected = category == _expenseCategory;
        
        return InkWell(
          onTap: () => setState(() => _expenseCategory = category),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.2),
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _categoryIcons[category],
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(date),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addIncome() async {
    if (_incomeAmountController.text.isEmpty) {
      _showError('Please enter an amount');
      return;
    }
    
    final amount = double.tryParse(_incomeAmountController.text);
    if (amount == null) {
      _showError('Please enter a valid amount');
      return;
    }

    final income = Income.create(
      amount: amount,
      description: '${_incomeSource}: ${_incomeDescController.text}',
      date: _incomeDate,
    );
    
    await IsarService().addIncome(income);
    await IsarService().addAccountTransaction(AccountTransaction.create(
      accountId: 0,
      amount: amount,
      description: '${_incomeSource}: ${_incomeDescController.text}',
      date: _incomeDate,
      type: 'deposit',
    ));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Income added successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _addExpense() async {
    if (_expenseAmountController.text.isEmpty) {
      _showError('Please enter an amount');
      return;
    }
    
    final amount = double.tryParse(_expenseAmountController.text);
    if (amount == null) {
      _showError('Please enter a valid amount');
      return;
    }

    final expense = ExpenseHive.create(
      category: _expenseCategory,
      amount: amount,
      description: _expenseDescController.text,
      date: _expenseDate,
    );
    
    await IsarService().addExpense(expense);
    await IsarService().addAccountTransaction(AccountTransaction.create(
      accountId: 0,
      amount: amount,
      description: _expenseDescController.text,
      date: _expenseDate,
      type: 'withdrawal',
    ));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Expense added successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
