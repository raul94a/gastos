import 'package:flutter/material.dart';
import 'package:gastos/presentation/widgets/main/sort_by_date_type.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:provider/provider.dart';

class SliverDateFlexibleAppBar extends StatelessWidget {
  const SliverDateFlexibleAppBar({Key? key, required this.child, required this.controller})
  
      : super(key: key);
  final Widget child;
  final ScrollController controller;
  @override
  Widget build(BuildContext context) {
    print('Adapting SliveDateFlexible');
    return SafeArea(
      
      child: CustomScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 50,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              background: SortDateButtons(
                  expenseState: context.read<ExpenseProvider>()),
            ),
          ),
          SliverList(delegate: SliverChildListDelegate.fixed([
            child
          ]))
          //This results in rebuilding the entire page, so for this case is not good
          //  SliverList(delegate: SliverChildBuilderDelegate((ctx, i) => child))
        ],
      ),
    );
  }
}