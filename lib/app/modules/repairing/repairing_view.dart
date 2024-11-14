import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/andon_model.dart';
import 'repairing_controller.dart';
import '../../../../utils/app_colors.dart';

class RepairingView extends GetView<RepairingController> {
  final _formKey = GlobalKey<FormState>();

  RepairingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments;
    final int andonId = args['andonId'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary400, Colors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(andonId),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(andonId),
                    SizedBox(height: 24),
                    _buildFormSection(),
                  ],
                ),
              ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            controller.addRepairing(andonId);
          }
        },
        icon: Icon(Icons.save),
        label: Text('Submit'),
        backgroundColor: AppColors.primary400,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSliverAppBar(int andonId) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('Repairing Andon #$andonId',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary400, AppColors.primary300],
            ),
          ),
          child: Center(
            child: Icon(Icons.build_circle, size: 80, color: Colors.white),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 32),
        onPressed: () => Get.offAllNamed('/andon-home'),
      ),
    );
  }

  Widget _buildInfoCard(int andonId) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Andon Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary400)),
            Divider(color: AppColors.primary400),
            Text('Issued Andon ID :$andonId', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Repairing Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary400)),
            Divider(color: AppColors.primary400),
            SizedBox(height: 16),
            _buildDropdown(
              label: 'Shift',
              value: controller.selectedShift,
              items: controller.shifts,
              onChanged: controller.updateShift,
              isRequired: true,
            ),
            SizedBox(height: 16),
            _buildSearchableDropdown<Leader>(
              label: 'Leader',
              searchHint: 'Search Leader',
              items: controller.leaders,
              selectedValue: controller.selectedLeader,
              onChanged: controller.updateLeader,
              itemBuilder: (leader) => Text(leader.name),
              displayStringForOption: (leader) => leader.name,
              isRequired: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: controller.problemController,
              label: 'Problem',
              isRequired: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: controller.solutionController,
              label: 'Solution',
              isRequired: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: controller.remarksController,
              label: 'Remarks',
              isRequired: false,
            ),
            // Menambahkan tombol untuk pemindaian QR
            SizedBox(height: 30),
            GetBuilder<RepairingController>(
              builder: (controller) {
                return Obx(() => Visibility(
                  visible: controller.canAssess.value,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Get.toNamed('/qr-scan', arguments: true);
                      if (result != null) {
                        Get.offAllNamed('/detail-history', arguments: result);
                      }
                    },
                    child: Text('Please Update the machine status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary400,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )); 
              },
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required Rx<String?> value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary400),
              ),
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary400),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary400),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSearchableDropdown<T>({
    required String label,
    required String searchHint,
    required RxList<T> items,
    required Rx<T?> selectedValue,
    required Function(T?) onChanged,
    required Widget Function(T) itemBuilder,
    required String Function(T) displayStringForOption,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary400),
              ),
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Obx(() => SearchableDropdown<T>(
          searchHint: searchHint,
          items: items,
          selectedValue: selectedValue.value,
          onChanged: onChanged,
          itemBuilder: itemBuilder,
          displayStringForOption: displayStringForOption,
        )),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool isRequired = true,
    bool? enabled,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.primary400
                ),
              ),
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.red
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled == false ? Colors.grey[200] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            enabled: enabled ?? true,
            style: TextStyle(
              color: enabled == false ? Colors.grey[700] : Colors.black,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: enabled == false ? Colors.grey[200] : Colors.white,
              hintText: hintText,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SearchableDropdown<T> extends StatefulWidget {
  final String searchHint;
  final List<T> items;
  final T? selectedValue;
  final Function(T?) onChanged;
  final Widget Function(T) itemBuilder;
  final String Function(T) displayStringForOption;

  const SearchableDropdown({
    super.key,
    required this.searchHint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    required this.displayStringForOption,
  });

  @override
  _SearchableDropdownState<T> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final _searchController = TextEditingController();
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _searchController.clear();
    _filteredItems = widget.items;
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: widget.searchHint,
                        prefixIcon: Icon(Icons.search, color: AppColors.primary400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.primary400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.primary400, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filteredItems = widget.items
                              .where((item) => widget.displayStringForOption(item)
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                        _overlayEntry?.markNeedsBuild();
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: _filteredItems.map((item) => ListTile(
                        title: widget.itemBuilder(item),
                        onTap: () {
                          widget.onChanged(item);
                          _closeDropdown();
                          setState(() {
                            _isOpen = false;
                          });
                        },
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.selectedValue != null
                      ? widget.displayStringForOption(widget.selectedValue as T)
                      : widget.searchHint,
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: AppColors.primary400),
            ],
          ),
        ),
      ),
    );
  }
}
