import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('검색/필터')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: '키워드')),
            SizedBox(height: 8),
            Wrap(spacing: 8, children: [Chip(label: Text('카테고리')), Chip(label: Text('가격대')), Chip(label: Text('종료임박')), Chip(label: Text('즉시구매'))]),
          ],
        ),
      ),
    );
  }
}
