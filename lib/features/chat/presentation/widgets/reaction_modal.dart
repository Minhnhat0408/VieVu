import 'package:flutter/material.dart';
import 'package:vievu/features/chat/domain/entities/message.dart';

class ReactionsModal extends StatefulWidget {
  final Message message;
  const ReactionsModal({
    super.key,
    required this.message,
  });

  @override
  State<ReactionsModal> createState() => _ReactionsModalState();
}

class _ReactionsModalState extends State<ReactionsModal> {
  // create a map of reactions and their count
  final Map<String, int> _reactions = {};
  String _selectedReaction = 'All';

  @override
  void initState() {
    super.initState();
    // count the reactions
    _reactions['All'] = widget.message.reactions.length;
    for (var element in widget.message.reactions) {
      if (_reactions.containsKey(element.reaction)) {
        _reactions[element.reaction] = _reactions[element.reaction]! + 1;
      } else {
        _reactions[element.reaction] = 1;
      }
    }

    //insert "All" to the map
    _reactions['All'] = widget.message.reactions.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tương tác'),
        leading: null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...widget.message.reactions
                      .where((e) =>
                          _selectedReaction == 'All' ||
                          e.reaction == _selectedReaction)
                      .map((e) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(e.user.avatarUrl ?? ''),
                      ),
                      title: Text("${e.user.lastName} ${e.user.firstName}"),
                      trailing: Badge(
                        label: const Text(
                          "vote",
                        ),
                        isLabelVisible:
                            e.reaction == '👍' || e.reaction == '👎',
                        child: Text(e.reaction,
                            style: const TextStyle(fontSize: 24)),
                      ),

                      horizontalTitleGap: 20,
                      contentPadding: const EdgeInsets.fromLTRB(16, 8, 32, 8),
                      // subtitle: Text(e.value.toString()),
                    );
                  }),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // list of filter by reactions
                ..._reactions.entries.map((e) {
                  final reaction = e.key;
                  final count = e.value;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedReaction = reaction;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedReaction == reaction
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                      ),
                      child: Text("$reaction  $count"),
                    ),
                  );
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
