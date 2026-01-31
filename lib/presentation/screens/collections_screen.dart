import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../data/models/collection_model.dart';
import '../../data/repositories/book_repository.dart';
import '../bloc/purchase/purchase_bloc.dart';

/// Collections screen for managing book collections (Premium feature)
class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  bool _isLoading = true;
  List<CollectionModel> _collections = [];
  Map<String, List<BookModel>> _collectionBooks = {};

  // Sample collections (in production, these would be stored in Hive)
  static final List<CollectionModel> _sampleCollections = [
    CollectionModel(
      id: 'favorites',
      name: 'Favorites',
      description: 'My all-time favorite books',
      bookIds: [],
      coverColor: '#EF4444',
      iconName: 'favorite',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSystem: true,
    ),
    CollectionModel(
      id: 'currently_reading',
      name: 'Currently Reading',
      description: 'Books I\'m reading now',
      bookIds: [],
      coverColor: '#3B82F6',
      iconName: 'menu_book',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSystem: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);

    try {
      // Load sample collections
      _collections = _sampleCollections;

      // Load books for each collection
      final bookRepo = context.read<BookRepository>();
      for (final collection in _collections) {
        final books = <BookModel>[];
        for (final bookId in collection.bookIds) {
          final book = await bookRepo.getBookById(bookId);
          if (book != null) {
            books.add(book);
          }
        }
        _collectionBooks[collection.id] = books;
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, purchaseState) {
        bool isPremium = false;
        if (purchaseState is ProductsLoaded) {
          isPremium = purchaseState.isPremium;
        } else if (purchaseState is PremiumStatusChecked) {
          isPremium = purchaseState.isPremium;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Collections'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(RouteNames.home),
            ),
            actions: [
              if (isPremium)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showCreateCollectionDialog(),
                ),
            ],
          ),
          body: isPremium
              ? _buildPremiumContent()
              : _buildPremiumRequired(context),
        );
      },
    );
  }

  Widget _buildPremiumRequired(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.collections_bookmark,
                size: 64,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Collections is a Premium Feature',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Organize your books into custom collections with tags and filters.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Premium features list
            _PremiumFeatureItem(
              icon: Icons.folder_special,
              text: 'Create unlimited collections',
            ),
            const SizedBox(height: 12),
            _PremiumFeatureItem(
              icon: Icons.label,
              text: 'Add custom tags to books',
            ),
            const SizedBox(height: 12),
            _PremiumFeatureItem(
              icon: Icons.filter_list,
              text: 'Advanced filtering options',
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.premium),
              icon: const Icon(Icons.star),
              label: const Text('Upgrade to Premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadCollections,
      child: CustomScrollView(
        slivers: [
          // Quick stats
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_collections.length}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Collections',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.collections_bookmark,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collections grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final collection = _collections[index];
                  final books = _collectionBooks[collection.id] ?? [];
                  return _CollectionCard(
                    collection: collection,
                    books: books,
                    onTap: () => _openCollection(collection),
                  );
                },
                childCount: _collections.length,
              ),
            ),
          ),

          // Add new collection button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () => _showCreateCollectionDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Create New Collection'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  void _openCollection(CollectionModel collection) {
    // Navigate to collection details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${collection.name}...')),
    );
  }

  void _showCreateCollectionDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedColor = '#6366F1';
    String selectedIcon = 'folder';

    final colors = [
      '#EF4444', // Red
      '#F59E0B', // Amber
      '#22C55E', // Green
      '#3B82F6', // Blue
      '#8B5CF6', // Purple
      '#EC4899', // Pink
      '#6366F1', // Indigo
      '#14B8A6', // Teal
    ];

    final icons = [
      'folder',
      'favorite',
      'star',
      'bookmark',
      'collections_bookmark',
      'auto_stories',
      'library_books',
      'menu_book',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Collection',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Collection Name',
                    hintText: 'e.g., Science Fiction',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Describe this collection',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Text(
                  'Color',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: colors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedColor = color),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Icon',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: icons.map((iconName) {
                    final isSelected = selectedIcon == iconName;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedIcon = iconName),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.neutral100,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                        ),
                        child: Icon(
                          _getIconData(iconName),
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.neutral600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        _createCollection(
                          nameController.text,
                          descController.text,
                          selectedColor,
                          selectedIcon,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Create Collection'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'folder':
        return Icons.folder;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'bookmark':
        return Icons.bookmark;
      case 'collections_bookmark':
        return Icons.collections_bookmark;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'library_books':
        return Icons.library_books;
      case 'menu_book':
        return Icons.menu_book;
      default:
        return Icons.folder;
    }
  }

  void _createCollection(
    String name,
    String description,
    String color,
    String icon,
  ) {
    final newCollection = CollectionModel(
      id: const Uuid().v4(),
      name: name,
      description: description.isEmpty ? null : description,
      bookIds: [],
      coverColor: color,
      iconName: icon,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _collections.add(newCollection);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Collection "$name" created!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

/// Collection card widget
class _CollectionCard extends StatelessWidget {
  final CollectionModel collection;
  final List<BookModel> books;
  final VoidCallback onTap;

  const _CollectionCard({
    required this.collection,
    required this.books,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(
      int.parse((collection.coverColor ?? '#6366F1').replaceFirst('#', '0xFF')),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Stack(
          children: [
            // Book covers mosaic (if books exist)
            if (books.isNotEmpty)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Opacity(
                    opacity: 0.3,
                    child: _buildMosaic(books),
                  ),
                ),
              ),
            // Collection info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconData(collection.iconName ?? 'folder'),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    collection.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${collection.bookCount} books',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                  ),
                ],
              ),
            ),
            // System badge
            if (collection.isSystem)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SYSTEM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMosaic(List<BookModel> books) {
    return Row(
      children: books.take(2).map((book) {
        return Expanded(
          child: book.coverUrl != null
              ? Image.network(book.coverUrl!, fit: BoxFit.cover)
              : Container(color: AppColors.neutral200),
        );
      }).toList(),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'folder':
        return Icons.folder;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'bookmark':
        return Icons.bookmark;
      case 'collections_bookmark':
        return Icons.collections_bookmark;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'library_books':
        return Icons.library_books;
      case 'menu_book':
        return Icons.menu_book;
      default:
        return Icons.folder;
    }
  }
}

/// Premium feature list item
class _PremiumFeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PremiumFeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.success, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
