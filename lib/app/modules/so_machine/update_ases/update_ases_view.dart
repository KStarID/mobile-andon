import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../data/models/assessment_model.dart';
import 'update_ases_controller.dart';

class UpdateAsesView extends GetView<UpdateAsesController> {
  const UpdateAsesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Assessment', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primary400,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.assessment.value == null) {
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary400)));
        }
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary400, Colors.white],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown(
                    label: 'Shift',
                    value: controller.selectedShift.value,
                    items: controller.shifts,
                    onChanged: controller.updateShift,
                  ),
                  SizedBox(height: 24),
                  
                  _buildSearchableDropdown<SubArea>(
                    label: 'Sub Area',
                    searchHint: 'Search Sub Area',
                    items: controller.subAreas,
                    selectedValue: controller.selectedSubArea.value,
                    onChanged: controller.updateSubArea,
                    itemBuilder: (subArea) => Text(subArea.name),
                    displayStringForOption: (subArea) => subArea.name,
                  ),
                  SizedBox(height: 24),

                  _buildSearchableDropdown<SOP>(
                    label: 'SOP',
                    searchHint: 'Search SOP',
                    items: controller.sops,
                    selectedValue: controller.selectedSop.value,
                    onChanged: controller.updateSop,
                    itemBuilder: (sop) => Text(sop.name),
                    displayStringForOption: (sop) => sop.name,
                  ),
                  SizedBox(height: 24),

                  _buildSearchableDropdown<Model>(
                    label: 'Model',
                    searchHint: 'Search Model',
                    items: controller.filteredModels,
                    selectedValue: controller.selectedModel.value,
                    onChanged: controller.updateModel,
                    itemBuilder: (model) => Text(model.name),
                    displayStringForOption: (model) => model.name,
                  ),
                  SizedBox(height: 24),

                  _buildTextField(
                    controller: controller.machineCodeAssetController,
                    label: 'Machine Code Asset',
                    readOnly: true,
                  ),
                  SizedBox(height: 24),

                  _buildDropdown(
                    label: 'Machine Status',
                    value: controller.assessmentStatus.value,
                    items: controller.machineStatusOptions,
                    onChanged: controller.updateAssessmentStatus,
                  ),
                  SizedBox(height: 24),

                  _buildTextField(
                    controller: controller.detailsController,
                    label: 'Remarks',
                    maxLines: 3,
                  ),
                  SizedBox(height: 32),
                  
                  Center(
                    child: ElevatedButton(
                      onPressed: () => controller.updateAssessment(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary400,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text('Update Assessment', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8),
        Container(
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
              value: value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary400),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8),
        Container(
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
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchableDropdown<T>({
    required String label,
    required String searchHint,
    required List<T> items,
    required T? selectedValue,
    required Function(T?) onChanged,
    required Widget Function(T) itemBuilder,
    required String Function(T) displayStringForOption,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8),
        Container(
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
          child: SearchableDropdown<T>(
            items: items,
            selectedValue: selectedValue,
            onChanged: onChanged,
            itemBuilder: itemBuilder,
            displayStringForOption: displayStringForOption,
            searchHint: searchHint,
          ),
        ),
      ],
    );
  }
}

class SearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedValue;
  final Function(T?) onChanged;
  final Widget Function(T) itemBuilder;
  final String Function(T) displayStringForOption;
  final String searchHint;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    required this.displayStringForOption,
    required this.searchHint,
  });

  @override
  _SearchableDropdownState<T> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _closeDropdown();
      }
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _searchController.dispose();
    _focusNode.dispose();
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
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary400, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filteredItems = widget.items
                              .where((item) => widget
                                  .displayStringForOption(item)
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
            border: Border.all(color: AppColors.primary400),
            borderRadius: BorderRadius.circular(12),
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
