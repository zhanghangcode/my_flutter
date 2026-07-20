import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../downloads/application/download_controller.dart';
import '../../downloads/data/local_audio_resource_resolver.dart';
import '../domain/audio_resource_resolver.dart';

/// 教材の配送方式に応じてAsset/Fileを決定するResolverを提供します。
final audioResourceResolverProvider = Provider<AudioResourceResolver>(
  (ref) => LocalAudioResourceResolver(
    ref.watch(practiceRepositoryProvider),
    ref.watch(downloadRepositoryProvider),
  ),
);
