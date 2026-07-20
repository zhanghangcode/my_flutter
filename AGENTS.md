# Japanese Listening App

## Project goal

Build a Flutter Japanese listening practice application for Android and iOS.

The application contains:

- Practice exam list grouped by year and month
- Japanese transcript display
- Multiple-choice questions
- Transcript and question combined display
- Chinese translation and explanation
- Audio playback
- Audio and transcript synchronization
- Favorites
- Practice records
- Test mode
- Offline resource support

Read these files before making changes:

- docs/product_spec.md
- docs/reference/*.png

## MVP scope

The first version must support:

1. Bottom navigation with:
    - Practice
    - Test
    - Favorites
    - Settings

2. Practice list page.

3. Practice detail page with four tabs:
    - Transcript
    - Question
    - Transcript + Question
    - Explanation

4. Audio controls:
    - Play and pause
    - Seek bar
    - Playback speed
    - Previous sentence
    - Next sentence
    - Repeat current sentence
    - Repeat current question

5. Transcript synchronization:
    - Each sentence has startMs and endMs
    - Current sentence is red
    - Current sentence has a red line on its left
    - Tapping a sentence seeks to its start time
    - Automatically scroll to the active sentence

6. Multiple-choice answers.

7. Favorite questions and sentences.

8. Local persistence.

## Technical requirements

Use Flutter stable and Dart stable.

Use the latest mutually compatible stable versions of:

- flutter_riverpod
- flutter_hooks
- hooks_riverpod
- go_router
- just_audio
- drift
- sqlite3_flutter_libs
- path_provider
- shared_preferences
- freezed_annotation
- json_annotation
- build_runner
- freezed
- json_serializable

Do not hardcode package versions without checking compatibility.

Target platforms:

- Android
- iOS

Do not implement Web or Desktop unless explicitly requested.

## Architecture

Use feature-first architecture.

Recommended structure:

lib/
app/
core/
features/
practice/
player/
test/
favorites/
settings/
database/

Separate:

- UI widgets
- State management
- Domain models
- Repositories
- Local database
- Audio player logic

Widgets must not directly access the database or audio player package.

Use `HookConsumerWidget` when a presentation Widget only needs small,
Widget-local lifecycle state and Hooks make that lifecycle easier to follow.
Keep business state, shared state, and asynchronous workflows in Riverpod
Providers or Notifiers. Call Hooks unconditionally at the top level of `build`
and keep their call order stable. Do not migrate complex lifecycle code only to
standardize Widget types.

## UI rules

- Dark background
- White primary text
- Dark gray cards
- Red active transcript text
- Respect SafeArea
- Bottom audio player stays visible
- Screen content must not be covered by the player
- Support small and large phone screens
- Avoid copying advertisements from the reference screenshots

## Data rules

Use local JSON demo data during MVP development.

Do not embed copyrighted commercial exam audio or text.

If an asset is missing:

- Show a clear empty or error state
- Do not crash
- Document where the developer should add the asset

## Working rules

Before coding:

1. Inspect the existing project.
2. Read the product specification.
3. Produce a short implementation plan.
4. Identify files that will be created or changed.

## コードコメント規則

- 手動で作成する Dart コードには、必要に応じて日本語コメントを追加する。
- コメントは自然で簡潔な日本語を使用する。
- Flutter、Dart、Riverpod、GoRouter、Widget などの技術用語は英語表記を維持する。
- 公開 class、公開メソッド、Provider、Repository、Controller には `///` を使用する。
- 複雑なビジネスロジック、状態遷移、非同期処理、ライフサイクルには `//` を使用する。
- コメントではコードの直訳ではなく、設計理由、責務、データフローを説明する。
- import、単純な代入、明らかな Widget に不要なコメントを追加しない。
- すべての行にコメントを追加しない。
- コメント追加のためだけにリファクタリングしない。
- 実装を変更した場合は、関連するコメントも更新する。
- 実装内容と一致しない推測コメントを追加しない。
- 中国語コメントがある場合は、意味を保持した自然な日本語へ置き換える。
- 以下の自動生成ファイルは変更しない。
   - `*.g.dart`
   - `*.freezed.dart`
- テストでは必要に応じて Given / When / Then の日本語コメントを使用する。

During implementation:

- Implement only the requested milestone.
- Do not rewrite unrelated files.
- Do not remove working code without explanation.
- Keep files reasonably small.
- Add error handling.
- Add loading, empty and error states.
- Use const widgets where appropriate.

After implementation run:

```bash
dart format .
flutter analyze
flutter test
