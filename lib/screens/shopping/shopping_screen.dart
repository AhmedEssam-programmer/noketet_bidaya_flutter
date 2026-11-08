import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/products.dart';
import '../../services/speech_service.dart';
import '../../state/user_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards.dart';
import 'cart_screen.dart';

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  static const routeName = 'Shopping';
  static const routePath = '/shopping';

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  String? _selectedCategory;
  String _searchQuery = '';
  late List<Product> _displayed;
  final _controller = TextEditingController();
  final Set<String> _addingProductIds = <String>{};
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _displayed = products;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(userControllerProvider).settings;
      if (settings.voiceEnabled) {
        speechService.speak('مرحباً في السوق، اختر منتجاً أو ابحث');
      }
    });
  }

  void _applyFilters() {
    if (_searchQuery.trim().isNotEmpty) {
      _displayed = searchProducts(_searchQuery);
      _selectedCategory = null;
      return;
    }

    if (_selectedCategory != null) {
      _displayed = getProductsByCategory(_selectedCategory!);
      return;
    }

    _displayed = products;
  }

  void _onCategoryTap(String id) {
    setState(() {
      _selectedCategory = _selectedCategory == id ? null : id;
      _searchQuery = '';
      _controller.text = '';
      _applyFilters();
    });
  }

  Future<void> _addToCart(String productId) async {
    if (_addingProductIds.contains(productId)) return;
    setState(() => _addingProductIds.add(productId));
    try {
      await ref.read(userControllerProvider.notifier).addToCart(productId);
      final settings = ref.read(userControllerProvider).settings;
      if (settings.voiceEnabled) {
        unawaited(speechService.speak('تمت الإضافة للسلة'));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر إضافة المنتج')));
    } finally {
      if (mounted) {
        setState(() => _addingProductIds.remove(productId));
      }
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'السوق',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(CartScreen.routePath),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.shopping_cart,
                                color: AppColors.primary,
                                size: 28,
                              ),
                              if (user.cart.isNotEmpty)
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${user.cart.length}',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: 'ابحث عن منتج...',
                                border: InputBorder.none,
                              ),
                              onChanged: (v) {
                                _searchDebounce?.cancel();
                                _searchDebounce = Timer(
                                  const Duration(milliseconds: 250),
                                  () {
                                    if (!mounted) return;
                                    setState(() {
                                      _searchQuery = v;
                                      _applyFilters();
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                _searchDebounce?.cancel();
                                setState(() {
                                  _searchQuery = '';
                                  _controller.text = '';
                                  _applyFilters();
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.gray,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        for (final cat in categories)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () => _onCategoryTap(cat.id),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedCategory == cat.id
                                      ? AppColors.primary
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    _CategoryEmojiBubble(
                                      emoji: cat.icon,
                                      selected: _selectedCategory == cat.id,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      cat.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedCategory == cat.id
                                            ? AppColors.white
                                            : AppColors.text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      child: _displayed.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    color: AppColors.gray,
                                    size: 48,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'لا توجد منتجات',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Wrap(
                              spacing: 12,
                              runSpacing: 16,
                              children: [
                                for (final p in _displayed)
                                  SizedBox(
                                    width:
                                        (MediaQuery.of(context).size.width -
                                            16 * 2 -
                                            12) /
                                        2,
                                    child: ProductCard(
                                      name: p.name,
                                      image: p.image,
                                      onTap: () {
                                        if (user.settings.voiceEnabled) {
                                          speechService.speak(p.name);
                                        }
                                      },
                                      onAddToCart: () => _addToCart(p.id),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.pop(),
                    child: const Text(
                      'رجوع',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryEmojiBubble extends StatelessWidget {
  const _CategoryEmojiBubble({required this.emoji, required this.selected});

  final String emoji;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: selected ? const Color(0x26FFFFFF) : const Color(0xFFF0F7F4),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          emoji,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            height: 1,
            fontFamilyFallback: [
              'Apple Color Emoji',
              'Segoe UI Emoji',
              'Noto Color Emoji',
            ],
          ),
        ),
      ),
    );
  }
}
