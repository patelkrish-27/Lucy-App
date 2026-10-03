import 'package:flutter/material.dart';
import '../widgets/cute_graphics.dart';
import '../widgets/lucy_orb.dart';

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
          sliver: SliverToBoxAdapter(child: Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Files', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Files from your connected computer', style: TextStyle(color: Color(0xFFB9AEC7))),
            ])),
            LucyMascot(size: 62, state: LucyMascotState.idle),
          ])),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
          sliver: SliverList.list(children: [
            LucyCard(child: Row(children: [
              Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFFB879FF).withValues(alpha: .12), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.folder_rounded, color: Color(0xFFB879FF))),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('~/projects', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 3),
                Text('Connected workspace', style: TextStyle(fontSize: 12, color: Color(0xFFAAA0B5))),
              ])),
              const Icon(Icons.chevron_right_rounded),
            ])),
            const SizedBox(height: 18),
            const Text('Recent', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w750)),
            const SizedBox(height: 10),
            ...[
              ('lucy_orb.dart', 'Dart · 18 KB', Icons.code_rounded),
              ('pubspec.yaml', 'YAML · 2 KB', Icons.description_outlined),
              ('README.md', 'Markdown · 6 KB', Icons.article_outlined),
              ('build.log', 'Text · 14 KB', Icons.terminal_rounded),
            ].map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LucyCard(child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(f.$3, color: const Color(0xFFB879FF)),
                title: Text(f.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(f.$2),
                trailing: const Icon(Icons.download_outlined),
              )),
            )),
          ]),
        ),
      ]),
    );
  }
}