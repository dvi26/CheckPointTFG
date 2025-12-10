import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/widgets/widgets.dart';
import '../../../games/presentation/controllers/game_controller.dart';
import '../../../soundtracks/presentation/controllers/soundtrack_controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();
  
  // Controllers para scroll infinito en cada tab
  final ScrollController _gamesScrollController = ScrollController();
  final ScrollController _ostScrollController = ScrollController();
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _gamesScrollController.addListener(_onGamesScroll);
    _ostScrollController.addListener(_onOstScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _focusNode.dispose();
    _gamesScrollController.dispose();
    _ostScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onGamesScroll() {
    if (_gamesScrollController.position.pixels >= _gamesScrollController.position.maxScrollExtent - 200) {
      context.read<GameController>().loadMoreSearchResults();
    }
  }

  void _onOstScroll() {
    if (_ostScrollController.position.pixels >= _ostScrollController.position.maxScrollExtent - 200) {
      context.read<SoundtrackController>().loadMoreSearchResults();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      // Buscar en ambos controladores
      context.read<GameController>().searchGames(query);
      context.read<SoundtrackController>().searchSoundtracks(query);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<GameController>().clearSearch();
    context.read<SoundtrackController>().clearSearch();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    //final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar juegos y soundtracks...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _clearSearch,
                        )
                      : null,
                ),
                textInputAction: TextInputAction.search,
              ),
            ),

            // Tabs y Resultados
            Expanded(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
                    indicatorColor: colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Juegos'),
                      Tab(text: 'Soundtracks'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _GamesResults(scrollController: _gamesScrollController),
                        _SoundtracksResults(scrollController: _ostScrollController),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamesResults extends StatelessWidget {
  const _GamesResults({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<GameController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error));
        }

        final results = controller.searchResults;

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videogame_asset_off,
                  size: 64,
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'No se encontraron juegos',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final game = results[index];
                return GameCard(
                  gameId: game.id,
                  name: game.name,
                  coverUrl: game.coverUrl,
                  rating: game.rating,
                  genres: game.genres,
                  year: game.releaseYear,
                  width: double.infinity,
                  margin: EdgeInsets.zero,
                );
              },
            ),
            if (controller.isLoadingMore)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SoundtracksResults extends StatelessWidget {
  const _SoundtracksResults({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<SoundtrackController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error));
        }

        final results = controller.searchResults;

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.music_off,
                  size: 64,
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'No se encontraron soundtracks',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8, // Un poco más ancho/bajo para OSTs
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final ost = results[index];
                return SoundtrackCard(
                  spotifyId: ost.id,
                  name: ost.name,
                  coverUrl: ost.coverUrl,
                  gameName: ost.gameName,
                  gameId: ost.gameId,
                  composer: ost.composer,
                  width: double.infinity,
                  margin: EdgeInsets.zero,
                );
              },
            ),
            if (controller.isLoadingMore)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                ),
              ),
          ],
        );
      },
    );
  }
}
