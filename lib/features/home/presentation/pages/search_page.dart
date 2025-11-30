import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/widgets/widgets.dart';
import '../../../games/presentation/controllers/game_controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<GameController>().loadMoreSearchResults();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<GameController>().searchGames(query);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<GameController>().clearSearch();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                  hintText: 'Buscar juegos...',
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

            // Resultados
            Expanded(
              child: Consumer<GameController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.error.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Ocurrió un error',
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.error,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final results = controller.searchResults;
                  final query = _searchController.text;

                  // Estado inicial o búsqueda vacía
                  if (query.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.manage_search,
                            size: 64,
                            color: colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Encuentra tus juegos favoritos',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Sin resultados
                  if (results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron resultados para "$query"',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Grid de resultados con loading al final
                  return Stack(
                    children: [
                      GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          left: 16, 
                          right: 16, 
                          top: 8, 
                          bottom: 24, // Espacio extra para el loader
                        ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
