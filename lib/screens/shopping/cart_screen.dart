import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/products.dart';
import '../../services/speech_service.dart';
import '../../state/user_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards.dart';
import '../home_screen.dart';
import 'shopping_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  static const routeName = 'Cart';
  static const routePath = '/cart';

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _checkingOut = false;
  final Set<String> _removingProductIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userControllerProvider);
      if (user.settings.voiceEnabled && user.cart.isNotEmpty) {
        final total = _total(user);
        speechService.speak(
          'في سلتك ${user.cart.length} منتجات، الإجمالي $total جنية',
        );
      }
    });
  }

  int _total(UserState user) {
    var sum = 0;
    for (final item in user.cart) {
      final p = getProductById(item.productId);
      if (p == null) continue;
      sum += p.price * item.quantity;
    }
    return sum;
  }

  Future<void> _checkout() async {
    if (_checkingOut) return;
    setState(() => _checkingOut = true);
    final user = ref.read(userControllerProvider);
    try {
      if (user.settings.voiceEnabled) {
        await speechService.speak('تم تقديم طلبك بنجاح! شكراً للتسوق معنا');
      }
      await ref.read(userControllerProvider.notifier).clearCart();
      if (!mounted) return;
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go(HomeScreen.routePath);
    } catch (_) {
      if (!mounted) return;
      setState(() => _checkingOut = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر إتمام الشراء')));
    }
  }

  Future<void> _removeItem(String productId) async {
    if (_removingProductIds.contains(productId)) return;
    setState(() => _removingProductIds.add(productId));
    try {
      await ref.read(userControllerProvider.notifier).removeFromCart(productId);
    } finally {
      if (mounted) {
        setState(() => _removingProductIds.remove(productId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);
    final total = _total(user);

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
                          'سلتك',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          '${user.cart.length} منتجات',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 200),
                      child: user.cart.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Column(
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(48),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_cart_outlined,
                                      color: AppColors.primary,
                                      size: 48,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'سلتك فارغة',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  const _SampleCartPanel(),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 32,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () =>
                                        context.go(ShoppingScreen.routePath),
                                    child: const Text(
                                      'تسوق الآن',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                for (final item in user.cart)
                                  Builder(
                                    builder: (context) {
                                      final p = getProductById(item.productId);
                                      if (p == null) {
                                        return const SizedBox.shrink();
                                      }
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            ProductEmojiBubble(
                                              image: p.image,
                                              size: 58,
                                              fontSize: 31,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p.name,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.text,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    p.nameEn,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    '${p.price} ج.م × ${item.quantity} ${p.unit}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${p.price * item.quantity} ج.م',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.error,
                                                    foregroundColor:
                                                        AppColors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                          horizontal: 12,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed:
                                                      _removingProductIds
                                                          .contains(
                                                            item.productId,
                                                          )
                                                      ? null
                                                      : () => _removeItem(
                                                          item.productId,
                                                        ),
                                                  child: const Text(
                                                    'حذف',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
              if (user.cart.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 70,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      border: Border(
                        top: BorderSide(color: AppColors.lightGray),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'الإجمالي:',
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              '$total ج.م',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _checkingOut ? null : _checkout,
                            child: Text(
                              _checkingOut ? 'جاري الإتمام...' : 'إتمام الشراء',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
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

class _SampleCartPanel extends ConsumerWidget {
  const _SampleCartPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = sampleCartProductIds
        .map(getProductById)
        .whereType<Product>()
        .toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أمثلة مقترحة للسلة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'منتجات يومية تساعد المستخدم على فهم تجربة الشراء.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          for (final product in products) ...[
            _SampleCartItem(product: product),
            if (product != products.last) const Divider(height: 14),
          ],
        ],
      ),
    );
  }
}

class _SampleCartItem extends ConsumerStatefulWidget {
  const _SampleCartItem({required this.product});

  final Product product;

  @override
  ConsumerState<_SampleCartItem> createState() => _SampleCartItemState();
}

class _SampleCartItemState extends ConsumerState<_SampleCartItem> {
  bool _adding = false;

  Future<void> _add() async {
    if (_adding) return;
    setState(() => _adding = true);
    try {
      await ref
          .read(userControllerProvider.notifier)
          .addToCart(widget.product.id);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProductEmojiBubble(image: widget.product.image, size: 44, fontSize: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              Text(
                '${widget.product.price} ج.م / ${widget.product.unit}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 34,
          child: OutlinedButton.icon(
            onPressed: _adding ? null : _add,
            icon: const Icon(Icons.add, size: 16),
            label: Text(_adding ? '...' : 'إضافة'),
          ),
        ),
      ],
    );
  }
}
