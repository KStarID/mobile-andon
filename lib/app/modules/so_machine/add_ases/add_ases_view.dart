import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import 'add_ases_controller.dart';
import '../../../data/models/assessment_model.dart';

class AddAsesView extends GetView<AddAsesController> {
  const AddAsesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 32),
          onPressed: () {
            Get.offAllNamed('/asesment');
          },
        ),
        title: const Text('Add Assessment', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white
          )
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary400,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary400, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdown(
                      label: 'Shift',
                      value: controller.selectedShiftId,
                      items: controller.shifts,
                      onChanged: controller.updateShift,
                      isRequired: true,
                    ),
                    SizedBox(height: 24),
                    
                    _buildSearchableDropdown<SubArea>(
                      label: 'Sub Area',
                      searchHint: 'Search Sub Area',
                      items: controller.subAreas,
                      selectedValue: controller.selectedSubArea,
                      onChanged: controller.updateSubArea,
                      itemBuilder: (subArea) => Text(subArea.name),
                      displayStringForOption: (subArea) => subArea.name,
                      isRequired: true,
                    ),
                    SizedBox(height: 24),

                    _buildSearchableDropdown<SOP>(
                      label: 'SOP',
                      searchHint: 'Cari SOP',
                      items: controller.sops,
                      selectedValue: controller.selectedSop,
                      onChanged: controller.updateSop,
                      itemBuilder: (sop) => Text(sop.name),
                      displayStringForOption: (sop) => sop.name,
                      isRequired: true,
                    ),
                    SizedBox(height: 24),

                    _buildSearchableDropdown<Model>(
                      label: 'Model',
                      searchHint: 'Search Model',
                      items: controller.models,
                      selectedValue: controller.selectedModel,
                      onChanged: controller.updateModel,
                      itemBuilder: (model) => Text(model.name),
                      displayStringForOption: (model) => model.name,
                      isRequired: true,
                    ),
                    SizedBox(height: 24),

                    _buildMachineCodeInput(),
                    SizedBox(height: 24),

                    _buildMachineNameInput(),
                    SizedBox(height: 24),

                    _buildDropdown(
                      label: 'Machine Status',
                      value: controller.machineStatus,
                      items: controller.machineStatusOptions,
                      onChanged: controller.updateMachineStatus,
                      isRequired: true,
                    ),
                    SizedBox(height: 24),

                    _buildTextField(
                      controller: controller.detailsController,
                      label: 'Remarks',
                      maxLines: 3,
                      isRequired: false, // Ubah menjadi false karena tidak wajib
                    ),
                    SizedBox(height: 32),

                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary400),
              ),
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Obx(() {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
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
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value.value,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: AppColors.primary400),
                items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: onChanged,
              ),
            ),
          );
        }),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary400),
              ),
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
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

  Widget _buildMachineCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Machine Code',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.primary400
                ),
              ),
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
        Row(
          children: [
            Expanded(
              child: Container(
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
                child: TextField(
                  controller: controller.machineCodeAssetController,
                  enabled: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter machine code or scan QR',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => controller.fetchMachineDetails(),
                ),
              ),
            ),
            SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                onPressed: controller.scanQRCode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMachineNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Machine Name',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.primary400
                ),
              ),
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
        Obx(() => Container(
          decoration: BoxDecoration(
            color: controller.isMachineExist.value ? Colors.grey[200] : Colors.white,
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
            controller: controller.machineName,
            enabled: !controller.isMachineExist.value,
            style: TextStyle(
              color: controller.isMachineExist.value ? Colors.grey[700] : Colors.black,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: controller.isMachineExist.value ? Colors.grey[200] : Colors.white,
              hintText: controller.isMachineExist.value 
                  ? controller.machineName.text 
                  : 'Enter machine name',
              hintStyle: TextStyle(
                color: controller.isMachineExist.value ? Colors.black : Colors.grey[400],
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              onPressed: controller.addAssessment,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add', 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                )
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary400,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              onPressed: controller.clearForm,
              icon: Icon(Icons.clear, color: AppColors.primary400),
              label: Text(
                'Clear', 
                style: TextStyle(
                  color: AppColors.primary400,
                  fontSize: 16,
                )
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: AppColors.primary400),
                ),
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
