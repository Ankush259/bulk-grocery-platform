import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
 
void main() => runApp(const GroupBuyApp());
 
class GroupBuyApp extends StatelessWidget {
  const GroupBuyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colony Group Buy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0B17),
      ),
      home: const HomeScreen(),
    );
  }
}
 
// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------
 
class GroceryItem {
  final String name;
  final String unit;
  final double price;
  final IconData icon;
  final Color accent;
 
  const GroceryItem({
    required this.name,
    required this.unit,
    required this.price,
    required this.icon,
    required this.accent,
  });
}
 
const List<GroceryItem> kItems = [
  GroceryItem(name: 'Basmati Rice', unit: '1 kg', price: 92, icon: Icons.grain, accent: Color(0xFFFFC857)),
  GroceryItem(name: 'Fresh Milk', unit: '1 L', price: 62, icon: Icons.local_drink, accent: Color(0xFF4FC3F7)),
  GroceryItem(name: 'Farm Eggs', unit: '1 Dozen', price: 84, icon: Icons.egg_alt, accent: Color(0xFFFFB74D)),
  GroceryItem(name: 'Wheat Flour', unit: '5 kg', price: 235, icon: Icons.bakery_dining, accent: Color(0xFFD7A86E)),
  GroceryItem(name: 'Toor Dal', unit: '1 kg', price: 148, icon: Icons.soup_kitchen, accent: Color(0xFFFFD54F)),
  GroceryItem(name: 'Tomatoes', unit: '1 kg', price: 38, icon: Icons.local_pizza, accent: Color(0xFFFF6B6B)),
  GroceryItem(name: 'Onions', unit: '2 kg', price: 64, icon: Icons.spa, accent: Color(0xFFCE93D8)),
  GroceryItem(name: 'Potatoes', unit: '2 kg', price: 58, icon: Icons.eco, accent: Color(0xFFA1887F)),
  GroceryItem(name: 'Sunflower Oil', unit: '1 L', price: 138, icon: Icons.opacity, accent: Color(0xFFFFEE58)),
  GroceryItem(name: 'Sugar', unit: '1 kg', price: 47, icon: Icons.cookie, accent: Color(0xFFF8BBD0)),
  GroceryItem(name: 'Tea Leaves', unit: '500 g', price: 210, icon: Icons.emoji_food_beverage, accent: Color(0xFF81C784)),
  GroceryItem(name: 'Fresh Bananas', unit: '1 Dozen', price: 56, icon: Icons.apple, accent: Color(0xFFFFF176)),
];
 
// ---------------------------------------------------------------------------
// Home screen
// ---------------------------------------------------------------------------
 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
 
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen> {
  Duration _remaining = const Duration();
  Timer? _timer;
  bool _isLoading = true;
  List<GroceryItem> _liveItems = [];
  
  final Map<String, int> _cart = {};
  int _currentPoolId = 0;
  final Map<String, int> _productIds = {};

  @override
  void initState() {
    super.initState();
    fetchPoolData();
  }

  Future<void> fetchPoolData() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/get_active_pool.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          DateTime closesAt = DateTime.parse(data['closes_at']);
          _currentPoolId = int.parse(data['pool_id'].toString());
          
          List<GroceryItem> fetchedItems = [];
          for (var p in data['products']) {
            _productIds[p['name']] = int.parse(p['product_id'].toString());
            
            GroceryItem defaultStyle = kItems.firstWhere(
              (item) => item.name == p['name'],
              orElse: () => GroceryItem(name: p['name'], unit: p['unit_size'], price: 0, icon: Icons.shopping_bag, accent: const Color(0xFF69F0AE)),
            );
            fetchedItems.add(GroceryItem(name: p['name'], unit: p['unit_size'], price: double.parse(p['base_price'].toString()), icon: defaultStyle.icon, accent: defaultStyle.accent));
          }

          setState(() {
            _liveItems = fetchedItems;
            _remaining = closesAt.difference(DateTime.now()).isNegative ? const Duration() : closesAt.difference(DateTime.now());
            _isLoading = false;
          });

          _timer = Timer.periodic(const Duration(seconds: 1), (_) {
            if (!mounted) return;
            setState(() {
              if (_remaining.inSeconds > 0) _remaining -= const Duration(seconds: 1);
              else _timer?.cancel();
            });
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitOrder() async {
    if (_cart.isEmpty) return;
    
    // This is the line that got corrupted during paste
    var cartPayload = [];
    
    _cart.forEach((name, qty) {
      if (_productIds.containsKey(name)) {
        cartPayload.add({"product_id": _productIds[name], "quantity": qty});
      }
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/add_to_cart.php'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"pool_id": _currentPoolId, "user_id": 1, "cart": cartPayload}),
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() => _cart.clear());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order securely added to the pool!')));
      }
    } catch (e) {
      print("Checkout error: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _cartCount => _cart.values.fold(0, (a, b) => a + b);
  double get _cartTotal => _liveItems.fold(0, (sum, item) => sum + ((_cart[item.name] ?? 0) * item.price));

  void _addToGroupBuy(GroceryItem item, int qty) {
    setState(() => _cart[item.name] = (_cart[item.name] ?? 0) + qty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const _GradientBackground(),
          SafeArea(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF)))
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: _Header(cartCount: _cartCount))),
                    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: _CountdownBanner(remaining: _remaining))),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.68),
                        delegate: SliverChildBuilderDelegate((context, i) => ItemCard(item: _liveItems[i], inGroup: _cart[_liveItems[i].name] ?? 0, onAdd: (qty) => _addToGroupBuy(_liveItems[i], qty)), childCount: _liveItems.length),
                      ),
                    ),
                  ],
                ),
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _cartCount == 0 ? const SizedBox.shrink() : _CartBar(count: _cartCount, total: _cartTotal, onCheckout: _submitOrder),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
// ---------------------------------------------------------------------------
// Background
// ---------------------------------------------------------------------------
 
class _GradientBackground extends StatelessWidget {
  const _GradientBackground();
 
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B0B17), Color(0xFF14102B), Color(0xFF0A1A2A)],
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -60,
          child: _blob(const Color(0xFF7C4DFF), 260),
        ),
        Positioned(
          top: 280,
          right: -90,
          child: _blob(const Color(0xFF00E5FF), 240),
        ),
        Positioned(
          bottom: -100,
          left: 40,
          child: _blob(const Color(0xFFFF4081), 260),
        ),
      ],
    );
  }
 
  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.35), color.withOpacity(0.0)],
        ),
      ),
    );
  }
}
 
// ---------------------------------------------------------------------------
// Reusable glass container
// ---------------------------------------------------------------------------
 
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final Color? tint;
 
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.blur = 18,
    this.tint,
  });
 
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (tint ?? Colors.white).withOpacity(0.14),
                (tint ?? Colors.white).withOpacity(0.04),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}
 
// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------
 
class _Header extends StatelessWidget {
  final int cartCount;
  const _Header({required this.cartCount});
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Namaste 👋',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Colony Group Buy',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          radius: 16,
          padding: const EdgeInsets.all(10),
          child: Badge(
            isLabelVisible: cartCount > 0,
            label: Text('$cartCount'),
            child: const Icon(Icons.shopping_basket_outlined, size: 24),
          ),
        ),
      ],
    );
  }
}
 
// ---------------------------------------------------------------------------
// Countdown banner
// ---------------------------------------------------------------------------
 
class _CountdownBanner extends StatelessWidget {
  final Duration remaining;
  const _CountdownBanner({required this.remaining});
 
  String _two(int n) => n.toString().padLeft(2, '0');
 
  @override
  Widget build(BuildContext context) {
    final h = _two(remaining.inHours);
    final m = _two(remaining.inMinutes.remainder(60));
    final s = _two(remaining.inSeconds.remainder(60));
    final urgent = remaining.inMinutes < 30;
    final accent = urgent ? const Color(0xFFFF5252) : const Color(0xFF69F0AE);
 
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(20),
      tint: const Color(0xFF9C7BFF),
      child: LayoutBuilder(
        builder: (context, c) {
          final compact = c.maxWidth < 420;
          final timer = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TimeBox(value: h, label: 'HRS', accent: accent),
              _colon(),
              _TimeBox(value: m, label: 'MIN', accent: accent),
              _colon(),
              _TimeBox(value: s, label: 'SEC', accent: accent),
            ],
          );
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: accent.withOpacity(0.7), blurRadius: 8),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE • REVERSE AUCTION',
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Colony Order Pool',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'More neighbours join, lower the price drops.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.groups_2_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '38 households joined',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ],
          );
 
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info,
                const SizedBox(height: 16),
                Center(child: timer),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: 16),
              timer,
            ],
          );
        },
      ),
    );
  }
 
  Widget _colon() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          ':',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      );
}
 
class _TimeBox extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;
  const _TimeBox({required this.value, required this.label, required this.accent});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              letterSpacing: 1.2,
              color: Colors.white.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}
 
// ---------------------------------------------------------------------------
// Item card
// ---------------------------------------------------------------------------
 
class ItemCard extends StatefulWidget {
  final GroceryItem item;
  final int inGroup;
  final ValueChanged<int> onAdd;
 
  const ItemCard({
    super.key,
    required this.item,
    required this.inGroup,
    required this.onAdd,
  });
 
  @override
  State<ItemCard> createState() => _ItemCardState();
}
 
class _ItemCardState extends State<ItemCard> {
  int _qty = 1;
 
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item.accent.withOpacity(0.35),
                    item.accent.withOpacity(0.08),
                  ],
                ),
                border: Border.all(color: item.accent.withOpacity(0.25)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(item.icon, size: 42, color: item.accent),
                  ),
                  if (widget.inGroup > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF69F0AE).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.inGroup} in pool',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                item.unit,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '~₹${item.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: item.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _QuantitySelector(
            qty: _qty,
            onChanged: (v) => setState(() => _qty = v),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton.icon(
              onPressed: () {
                widget.onAdd(_qty);
                setState(() => _qty = 1);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.group_add_outlined, size: 17),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Add to Group Buy',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
class _QuantitySelector extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  const _QuantitySelector({required this.qty, required this.onChanged});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          _btn(Icons.remove, qty > 1 ? () => onChanged(qty - 1) : null),
          Expanded(
            child: Center(
              child: Text(
                '$qty',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _btn(Icons.add, qty < 99 ? () => onChanged(qty + 1) : null),
        ],
      ),
    );
  }
 
  Widget _btn(IconData icon, VoidCallback? onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? Colors.white24 : Colors.white,
        ),
      ),
    );
  }
}
 
// ---------------------------------------------------------------------------
// Floating cart bar
// ---------------------------------------------------------------------------
 
class _CartBar extends StatelessWidget {
  final int count;
  final double total;
  final VoidCallback onCheckout;
  const _CartBar({super.key, required this.count, required this.total, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22, blur: 24, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), tint: const Color(0xFF7C4DFF),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart_checkout, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count item${count == 1 ? '' : 's'} in your pool', style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('Est. ₹${total.toStringAsFixed(0)}', style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11.5)),
              ],
            ),
          ),
          FilledButton(
            onPressed: onCheckout,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF69F0AE), foregroundColor: Colors.black),
            child: const Text('Review & Submit', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}