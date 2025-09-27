import 'package:flutter/material.dart';
import 'package:elingkod/common_style/colors_extension.dart';

class CustomSearchBar<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabel;
  final Widget Function(BuildContext, T) itemBuilder;
  final void Function(T) onItemTap;
  final String hintText;
  final void Function(bool isSearching)? onSearchChanged; 

  const CustomSearchBar({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.itemBuilder,
    required this.onItemTap,
    this.hintText = "Search...",
    this.onSearchChanged, // allow parent to listen for search state
  });

  @override
  State<CustomSearchBar<T>> createState() => _CustomSearchBarState<T>();
}

class _CustomSearchBarState<T> extends State<CustomSearchBar<T>> {
  final TextEditingController _controller = TextEditingController();
  String _query = "";
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay(BuildContext context) {
    _removeOverlay();

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final List<T> filteredItems = widget.items
            .where((item) => widget
                .itemLabel(item)
                .toLowerCase()
                .contains(_query.toLowerCase()))
            .toList();

        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height), // directly attached to bar
            child: Material(
              color: Colors.transparent, // keep transparent so your BoxDecoration shows
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: ElementColors.shadow.withOpacity(0.6),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: _query.isEmpty
                      ? const SizedBox.shrink()
                      : filteredItems.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                "No results found",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return GestureDetector(
                                  onTap: () {
                                    widget.onItemTap(item);
                                    _controller.clear();
                                    setState(() => _query = "");
                                    widget.onSearchChanged?.call(false);
                                    _removeOverlay();
                                  },
                                  child: widget.itemBuilder(context, item),
                                );
                              },
                            ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = _query.isNotEmpty || _controller.text.isNotEmpty;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.white : const Color(0xFFF1F1F1),
          borderRadius: isActive
              ? const BorderRadius.vertical(top: Radius.circular(12))
              : BorderRadius.circular(30),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: ElementColors.shadow.withOpacity(0.6),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() => _query = value);
                  widget.onSearchChanged?.call(value.isNotEmpty);
                  if (value.isNotEmpty) {
                    _showOverlay(context);
                  } else {
                    _removeOverlay();
                  }
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: InputBorder.none,
                ),
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
