---
name: flutter-bug-investigation
description: Investigate and fix reproducible bugs in this repository's Flutter Android and iOS app. Use for playback controls, question switching, audio and transcript synchronization, downloads, local assets, Riverpod or Hook state, GoRouter navigation, Drift persistence, asynchronous races, lifecycle failures, and related regression tests.
---

# Flutter Bug Investigation

## Goal

Find the evidence-backed root cause, change the smallest responsible layer, and prove the fix without disturbing unrelated behavior or user changes.

## 1. Establish scope

1. Read the repository `AGENTS.md`, `docs/product_spec.md`, and relevant reference screenshots before changing files.
2. Determine whether the user requested diagnosis only, a plan, or implementation. Stop before editing for diagnosis-only or planning requests.
3. Record `git status --short` and preserve every pre-existing tracked, staged, and untracked change.
4. Inspect `pubspec.yaml`, the relevant `lib/` flow, and existing tests. Do not infer behavior from a screenshot or file name alone.
5. State a short plan and list files likely to change before implementing.

## 2. Make the failure observable

Translate the report into an explicit expected/actual pair and the smallest repeatable action sequence. Identify:

- the affected route, question, playback state, and delivery mode;
- whether the source is bundled Asset or validated Local File;
- whether the failure occurs before load, while loading, when ready, playing, paused, completed, or after disposal;
- whether rapid input, navigation, a delayed Future, or an out-of-order completion is required;
- whether the issue is UI-only or changes Controller, persistence, or plugin state.

Prefer a narrow failing unit or Widget test. Use a simulator, real device, Android build, or iOS build only when the user requests it or the behavior cannot be established below the platform boundary.

## 3. Trace the real data flow

Trace the complete path instead of patching the visible Widget:

```text
User gesture
-> Widget / Hook-local state
-> Riverpod Provider or Controller
-> Repository / Resolver / Service
-> just_audio, Drift, SharedPreferences, AssetBundle, or file system
-> emitted State
-> rebuilt Widget
```

Use `rg` to locate every producer, consumer, callback, route input, and test double for the affected value. Confirm which layer owns the state and which layer only renders it.

## 4. Apply subsystem checks

### Riverpod and Hooks

- Keep business, shared, and asynchronous state in Provider or Notifier; use Hooks only for small Widget-local lifecycle state.
- Call Hooks unconditionally at the top level of `build` and in a stable order.
- Use `ref.watch` for reactive rendering and `ref.read` for event-time commands.
- Check `context.mounted` before using `BuildContext` after `await`, and check `ref.mounted` before a Notifier publishes after disposal.
- Verify that family keys follow the current exam or question and that stale Provider results cannot overwrite a newer selection.

### Audio and question switching

- Distinguish source readiness from `playing`; paused and completed sources may still support play, seek, speed, repeat, and question navigation.
- Resolve audio by the exact `questionId` and the `Question.audioAssetPath`; never associate by list position, partial file-name matching, or guessed numbering.
- For source changes, preserve the intended order: capture state, stop the old source, select the target question, load from `Duration.zero`, then resume only when the defined playback rule requires it.
- Protect source changes with serialization or request IDs so old stop, load, duration, and error completions cannot overwrite the active question.
- Keep boundary behavior explicit for the first, last, single, empty, and unknown-index cases.
- Keep the target question visible when a local source load fails unless the requested specification says otherwise.

### Transcript synchronization

- Treat a timeline as complete only when every sentence has a valid, ordered, non-overlapping `startMs` and `endMs` pair.
- Use `startMs <= position < endMs`; return no active sentence in gaps or when the timeline is incomplete.
- Route seek bar changes, sentence taps, and repeat jumps through the same active-sentence calculation.
- Trigger automatic scrolling only when the active sentence ID changes, and do not steal an active manual scroll gesture.
- Do not generate or guess missing timestamps.

### Downloads, assets, and persistence

- Respect `bundled` versus `downloadRequired` metadata.
- For downloaded audio, validate both the Drift manifest and the real files, including resource version, count, non-zero size, and absence of `.part` files.
- Do not silently fall back from an invalid required Local File to the bundled Asset.
- Preserve `.part` atomic-write and cleanup guarantees when investigating interrupted downloads.
- Validate nullable answer, explanation, translation, and timeline fields according to current model capabilities instead of inventing content.

### Navigation and lifecycle

- Preserve `StatefulShellRoute` branch stacks and existing route paths unless navigation itself is the defect.
- Verify whether `push`, `pushReplacement`, or `go` is responsible for the expected history behavior.
- Treat `GoRouterState.extra` as temporary route input and ensure the destination can initialize safely without it.
- Test disposal during pending Futures, stream subscriptions, animation controllers, and audio source changes.

## 5. Identify and fix the cause

1. State the root cause with concrete code and state-transition evidence.
2. Change the owner of the incorrect decision, not every caller that exposes the symptom.
3. Preserve public routes, JSON schema, Drift schema, native settings, package dependencies, and UI unless the requested fix requires changing them.
4. Add concise Japanese comments only where the fix introduces non-obvious lifecycle, state transition, or race protection.
5. Do not edit generated `*.g.dart` or `*.freezed.dart` files manually.
6. If the user requested diagnosis only, report the cause and required files, then stop without implementing.

## 6. Prove the behavior

Add or update the narrowest useful tests:

- Unit tests for state transitions, boundary conditions, scoring, synchronization, and stale-request rejection.
- Widget tests for enabled controls, hidden boundaries, route behavior, loading/error presentation, and safe disposal.
- Integration-style tests with Fake Repository and Fake Audio Service for question text and source changes.
- Delayed `Completer` tests for rapid taps, out-of-order loads, disposal, and duplicate callbacks.

Avoid real audio and wall-clock waits when a deterministic Fake can verify the contract. Include real Asset validation only when the bug concerns packaged data or decoding.

After implementation run:

```bash
dart format .
flutter analyze
flutter test
git diff --check
```

Run the repository asset validator when JSON or audio references change. Do not launch a simulator or run Android/iOS builds when the user has excluded them.

## 7. Report clearly

Report:

1. the root cause;
2. changed files and behavior;
3. regression tests added or updated;
4. command results;
5. skipped platform checks and remaining limitations;
6. confirmation that unrelated working-tree changes were preserved.
