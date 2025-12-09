import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'cubits/movies_cubit.dart';
import 'cubits/favorites_cubit.dart';
import 'cubits/recommendations_cubit.dart';

import 'data/openai_service.dart'; 
import 'data/movie_api_service.dart'; 

import 'pages/home_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final openAIService = OpenAIService();
    final movieApiService = MovieApiService();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MoviesCubit()),
        BlocProvider(create: (_) => FavoritesCubit()),
        
        BlocProvider(
          create: (_) => RecommendationsCubit(
            openAIService: openAIService,
            movieApiService: movieApiService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'KINO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}