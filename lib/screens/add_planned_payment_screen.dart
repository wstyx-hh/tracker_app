import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/planned_payment.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';

class AddPlannedPaymentScreen extends StatefulWidget {
  const AddPlannedPaymentScreen({super.key});

  @override
  State<AddPlannedPaymentScreen> createState() => _AddPlannedPaymentScreenState();
}

class _AddPlannedPaymentScreenState extends State<AddPlannedPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  PaymentRepeat _repeat = PaymentRepeat.once;
  bool _reminder = false;

  final Map<String, IconData> _categoryIcons = {
    'Food': Icons.restaurant_outlined,
    'Transportation': Icons.directions_car_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Bills': Icons.receipt_outlined,
    'Entertainment': Icons.movie_outlined,
    'Health': Icons.favorite_outline,
    'Education': Icons.school_outlined,
    'Other': Icons.more_horiz_outlined,
    'Salary': Icons.work_outline,
    'Business': Icons.business_center_outlined,
    'Gift': Icons.card_giftcard_outlined,
    'Interest': Icons.account_balance_outlined,
  };

  final List<String> _expenseCategories = [
    'Food', 'Transportation', 'Shopping', 'Bills', 'Entertainment', 'Health', 'Education', 'Other',
  ];
  final List<String> _incomeCategories = [
    'Salary', 'Business', 'Gift', 'Interest', 'Other',
  ];
  List<String> get _categories => _type == TransactionType.expense ? _expenseCategories : _incomeCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final payment = PlannedPayment(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory,
        type: _type,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        repeat: _repeat,
        reminder: _reminder,
      );
      Provider.of<ExpenseProvider>(context, listen: false).addPlannedPayment(payment);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Planned payment added'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Planned Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<TransactionType>(
                        segments: [
                          ButtonSegment(
                            value: TransactionType.expense,
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.remove_circle_outline,
                                  color: _type == TransactionType.expense
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                ),
                                const SizedBox(width: 8),
                                Text('Expense'),
                              ],
                            ),
                          ),
                          ButtonSegment(
                            value: TransactionType.income,
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: _type == TransactionType.income
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                ),
                                const SizedBox(width: 8),
                                Text('Income'),
                              ],
                            ),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (Set<TransactionType> selected) {
                          setState(() {
                            _type = selected.first;
                            _selectedCategory = _categories.first;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return theme.colorScheme.primary;
                              }
                              return theme.colorScheme.surfaceVariant;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          prefixIcon: const Icon(Icons.title),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixIcon: const Icon(Icons.attach_money),
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
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(
                                  _categoryIcons[category] ?? Icons.category_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(category),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Category',
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
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  dialogBackgroundColor: theme.colorScheme.surface,
                                  dialogTheme: DialogTheme(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
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
                                    DateFormat('MMM d, y').format(_selectedDate),
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<PaymentRepeat>(
                        value: _repeat,
                        items: PaymentRepeat.values.map((repeat) {
                          return DropdownMenuItem(
                            value: repeat,
                            child: Row(
                              children: [
                                Icon(
                                  repeat == PaymentRepeat.once
                                      ? Icons.event_outlined
                                      : repeat == PaymentRepeat.daily
                                          ? Icons.calendar_today_outlined
                                          : repeat == PaymentRepeat.weekly
                                              ? Icons.view_week_outlined
                                              : repeat == PaymentRepeat.monthly
                                                  ? Icons.calendar_month_outlined
                                                  : Icons.calendar_today_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(repeat.name[0].toUpperCase() + repeat.name.substring(1)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _repeat = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Repeat',
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
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Row(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              color: _reminder
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            const SizedBox(width: 12),
                            Text('Reminder (3 days before)'),
                          ],
                        ),
                        value: _reminder,
                        onChanged: (value) {
                          setState(() {
                            _reminder = value;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Info',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: 'Note (Optional)',
                          prefixIcon: const Icon(Icons.note_outlined),
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
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add Planned Payment'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
} 