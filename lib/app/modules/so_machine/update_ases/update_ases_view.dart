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
        title: const Text('Update Assessment'),
        centerTitle: true,
        backgroundColor: AppColors.primary100,
      ),
      body: Obx(() {
        if (controller.assessment.value == null) {
          return Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedShift.value,
                  onChanged: controller.updateShift,
                  items: controller.shifts.map((shift) => DropdownMenuItem(value: shift, child: Text(shift))).toList(),
                  decoration: InputDecoration(label: Text('Shift', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                )),
                SizedBox(height: 15),

                SearchableDropdown<SubArea>(
                  label: 'Sub Area',
                  searchHint: 'Search Sub Area',
                  items: controller.filteredSubAreas,
                  selectedValue: controller.selectedSubArea.value,
                  onChanged: controller.updateSubArea,
                  itemBuilder: (subArea) => Text(subArea.name),
                  displayStringForOption: (subArea) => subArea.name,
                ),

                TextFormField(
                  controller: controller.sopNumberController,
                  decoration: InputDecoration(label: Text('SOP Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                ),
                SizedBox(height: 20),

                SearchableDropdown<Model>(
                  label: 'Model',
                  searchHint: 'Search Model',
                  items: controller.filteredModels,
                  selectedValue: controller.selectedModel.value,
                  onChanged: controller.updateModel,
                  itemBuilder: (model) => Text(model.name),
                  displayStringForOption: (model) => model.name,
                ),

                TextFormField(
                  controller: controller.machineCodeAssetController,
                  decoration: InputDecoration(label: Text('Machine Code Asset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  readOnly: true,
                ),
                SizedBox(height: 20),

                Obx(() => DropdownButtonFormField<String>(
                  value: controller.machineStatus.value,
                  onChanged: controller.updateMachineStatus,
                  items: controller.machineStatusOptions.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                  decoration: InputDecoration(label: Text('Machine Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                )),
                SizedBox(height: 8),

                TextFormField(
                  controller: controller.detailsController,
                  decoration: InputDecoration(label: Text('Remarks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.updateAssessment(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Update Assessment', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final String searchHint;
  final List<T> items;
  final T? selectedValue;
  final Function(T?) onChanged;
  final Widget Function(T) itemBuilder;
  final String Function(T) displayStringForOption;

  const SearchableDropdown({
    Key? key,
    required this.label,
    required this.searchHint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    required this.displayStringForOption,
  }) : super(key: key);

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
            child: Container(
              height: 200,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: widget.searchHint,
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedValue != null
                          ? widget.displayStringForOption(widget.selectedValue as T)
                          : 'Select ${widget.label}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}