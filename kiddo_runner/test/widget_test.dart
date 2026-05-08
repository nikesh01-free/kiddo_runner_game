import 'package:flutter_test/flutter_test.dart';
import 'package:kiddo_runner/models/level_progress.dart';

void main() {
  test('Instantiate entity sanity check', () {
    final now = DateTime.now();
    final progress = LevelProgress(
      id: 'id_123',
      childProfileId: 'profile_123',
      levelNumber: 1,
      isUnlocked: true,
      isCompleted: false,
      mode: 'math',
      createdAt: now,
      updatedAt: now,
    );

    expect(progress.levelNumber, 1);
    expect(progress.isUnlocked, true);
    expect(progress.isCompleted, false);
  });
}
