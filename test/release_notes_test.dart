import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/release_notes.dart';

void main() {
  String pubspecVersion() {
    final line = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((l) => l.startsWith('version:'));
    return line.split(':').last.trim().split('+').first;
  }

  test('every release has notes for its pubspec version (update both together)',
      () {
    final v = pubspecVersion();
    expect(kReleaseNotes.containsKey(v), isTrue,
        reason: 'Add a kReleaseNotes["$v"] entry in lib/data/release_notes.dart');
    expect(kReleaseNotes[v]!.highlights, isNotEmpty);
  });

  test('every note is short enough to read in the sheet', () {
    for (final e in kReleaseNotes.entries) {
      expect(e.value.highlights.length, inInclusiveRange(1, 6), reason: e.key);
      for (final h in e.value.highlights) {
        expect(h.$2.length, lessThan(160), reason: '${e.key}: ${h.$2}');
      }
    }
  });

  test('compareVersions orders numerically, ignores build number', () {
    expect(compareVersions('1.0.10', '1.0.9'), greaterThan(0));
    expect(compareVersions('1.0.5+12', '1.0.5'), 0);
    expect(compareVersions('1.1.0', '1.0.99'), greaterThan(0));
    expect(compareVersions('1.0.4', '1.0.5'), lessThan(0));
  });

  test('user jumping 1.0.3 → 1.0.5 sees 1.0.5 then 1.0.4', () {
    final notes = unseenReleaseNotes(lastSeen: '1.0.3', current: '1.0.5');
    expect(notes.map((e) => e.key), ['1.0.5', '1.0.4']);
  });

  test('already seen → nothing; unknown version → nothing stale', () {
    expect(unseenReleaseNotes(lastSeen: '1.0.5', current: '1.0.5'), isEmpty);
    expect(unseenReleaseNotes(lastSeen: '1.0.5', current: '1.0.6'), isEmpty);
  });

  test('no previous record → only the current version', () {
    final notes = unseenReleaseNotes(lastSeen: null, current: '1.0.5');
    expect(notes.map((e) => e.key), ['1.0.5']);
  });
}
