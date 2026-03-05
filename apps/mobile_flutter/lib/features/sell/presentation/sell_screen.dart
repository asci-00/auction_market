import 'package:flutter/material.dart';

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('출품 Step Form')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(title: Text('1) 카테고리 선택 (GOODS / PRECIOUS)')),
          ListTile(title: Text('2) 상품 정보 입력 + 태그')),
          ListTile(title: Text('3) 시작가/즉시구매가/기간(1,3,5,7일)')),
          ListTile(title: Text('4) 사진 업로드 최대 10장 + GOODS 인증사진 최소1장')),
          ListTile(title: Text('5) PRECIOUS 감정요청 스텁')),
          ListTile(title: Text('6) 미리보기/등록')),
          Card(child: Padding(padding: EdgeInsets.all(12), child: Text('스나이핑 방지: 종료 5분 전 입찰시 +5분(최대3회)'))),
        ],
      ),
    );
  }
}
