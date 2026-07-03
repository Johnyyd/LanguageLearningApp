import 'package:hive/hive.dart';
import '../../domain/entities/vocab_item.dart';
import '../../core/constants/app_constants.dart';

class LocalVocabDataSource {
    Box? _box;

    Future<void> init() async {
        if (_box == null || !_box!.isOpen) {
            _box = await Hive.openBox(AppConstants.srsBoxName);
        }
    }

    Future<List<VocabItem>> getLocalVocab({int lessonId = 1}) async {
        await init();
        final List<dynamic> rawList = _box!.values.toList();
        if (rawList.isEmpty) return [];
        
        final allItems = rawList.map((e) => VocabItem(
            id: e['id'] ?? 'jap_000',
            character: e['character'] ?? 'あ',
            romaji: e['romaji'] ?? 'a',
            type: e['type'] ?? 'Hiragana',
            meaning: e['meaning'] ?? '',
            example: e['example'] ?? '',
            strokeOrderUrl: e['strokeOrderUrl'] ?? '',
            srsInterval: e['srsInterval'] ?? 1,
            srsRepetition: e['srsRepetition'] ?? 0,
            srsEfactor: (e['srsEfactor'] ?? 2.5).toDouble(),
        )).toList();

        final prefix = 'jap_${lessonId}';
        final lessonItems = allItems.where((item) => item.id.startsWith(prefix) || (lessonId == 1 && item.id.startsWith('jap_0'))).toList();
        return lessonItems;
    }

    Future<void> cacheVocabList(List<VocabItem> list) async {
        await init();
        for (var item in list) {
            await _box!.put(item.id, {
                'id': item.id,
                'character': item.character,
                'romaji': item.romaji,
                'type': item.type,
                'meaning': item.meaning,
                'example': item.example,
                'strokeOrderUrl': item.strokeOrderUrl,
                'srsInterval': item.srsInterval,
                'srsRepetition': item.srsRepetition,
                'srsEfactor': item.srsEfactor,
            });
        }
    }

    Future<void> updateVocabItem(VocabItem item) async {
        await init();
        await _box!.put(item.id, {
            'id': item.id,
            'character': item.character,
            'romaji': item.romaji,
            'type': item.type,
            'meaning': item.meaning,
            'example': item.example,
            'strokeOrderUrl': item.strokeOrderUrl,
            'srsInterval': item.srsInterval,
            'srsRepetition': item.srsRepetition,
            'srsEfactor': item.srsEfactor,
        });
    }
}
