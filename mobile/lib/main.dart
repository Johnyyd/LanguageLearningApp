import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'data/datasources/local_vocab_datasource.dart';
import 'data/datasources/remote_ai_datasource.dart';
import 'data/repositories/vocab_repository_impl.dart';
import 'data/repositories/ielts_repository_impl.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'presentation/blocs/vocab/vocab_bloc.dart';
import 'presentation/blocs/ielts/ielts_bloc.dart';
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Hive for offline SRS Flashcard database
    await Hive.initFlutter();
    
    // Setup Data Sources & Repositories
    final apiClient = ApiClient();
    final localVocabDs = LocalVocabDataSource();
    await localVocabDs.init();
    
    final remoteAiDs = RemoteAiDataSource(apiClient);
    
    final vocabRepo = VocabRepositoryImpl(localVocabDs, remoteAiDs);
    final ieltsRepo = IeltsRepositoryImpl(remoteAiDs);
    final chatRepo = ChatRepositoryImpl(remoteAiDs);

    runApp(LanguageLearningApp(
        vocabRepo: vocabRepo,
        ieltsRepo: ieltsRepo,
        chatRepo: chatRepo,
    ));
}

class LanguageLearningApp extends StatelessWidget {
    final VocabRepositoryImpl vocabRepo;
    final IeltsRepositoryImpl ieltsRepo;
    final ChatRepositoryImpl chatRepo;

    const LanguageLearningApp({
        super.key,
        required this.vocabRepo,
        required this.ieltsRepo,
        required this.chatRepo,
    });

    @override
    Widget build(BuildContext context) {
        return MultiBlocProvider(
            providers: [
                BlocProvider<VocabBloc>(
                    create: (context) => VocabBloc(vocabRepo),
                ),
                BlocProvider<IeltsBloc>(
                    create: (context) => IeltsBloc(ieltsRepo),
                ),
                BlocProvider<ChatBloc>(
                    create: (context) => ChatBloc(chatRepo),
                ),
            ],
            child: MaterialApp(
                title: 'Language & IELTS AI Coach (3D Avatar)',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.system,
                home: const HomeScreen(),
            ),
        );
    }
}
