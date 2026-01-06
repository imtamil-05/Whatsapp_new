import 'package:flutter/material.dart';

class ChatFilterChips extends StatefulWidget {
  const ChatFilterChips({ Key? key }) : super(key: key);

  @override
  _ChatFilterChipsState createState() => _ChatFilterChipsState();
}

class _ChatFilterChipsState extends State<ChatFilterChips> {

  final List<String> filters = ['All', 'Unread', 'Groups','+'];

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bool isSelected = selectedIndex == index;

          return ChoiceChip(
            label: Text(filters[index]),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                selectedIndex = index;
              });
            },
            selectedColor: Colors.green.shade100,
            backgroundColor: Colors.grey.shade200,
            labelStyle: TextStyle(
              color: isSelected ? Colors.green : Colors.black,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  
  }
}