import 'package:flutter/material.dart';

class TripTodoListPage extends StatefulWidget {
  const TripTodoListPage({super.key});

  @override
  State<TripTodoListPage> createState() => _TripTodoListPageState();
}

class _TripTodoListPageState extends State<TripTodoListPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('trip-todo-list-page'),
      slivers: [
        SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        const SliverAppBar(
          leading: null,
          title: Text('Saved Services'),
          floating: true,
          pinned: true,
          automaticallyImplyLeading: false,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ListTile(
                title: Text('Service $index'),
              );
            },
            childCount: 20,
          ),
        ),
      ],
    );
  }
}
