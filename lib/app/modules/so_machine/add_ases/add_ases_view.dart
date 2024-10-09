import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import 'add_ases_controller.dart';
import '../../../data/models/assessment_model.dart';

class AddAsesView extends GetView<AddAsesController> {
  const AddAsesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Assessment', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primary100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedShiftId.value,
                decoration: InputDecoration(label: Text('Shift', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                items: controller.shifts.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: controller.updateShift,
              )),
              SizedBox(height: 20),

              Obx(() => SearchableDropdown<SubArea>(
                label: 'Sub Area',
                searchHint: 'Search Sub Area',
                items: controller.subAreas,
                selectedValue: controller.selectedSubArea.value,
                onChanged: controller.updateSubArea,
                itemBuilder: (subArea) => Text(subArea.name),
                displayStringForOption: (subArea) => subArea.name,
              )),

              TextField(
                controller: controller.sopNumberController,
                decoration: InputDecoration(label: Text('SOP Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ),
              SizedBox(height: 15),

              Obx(() => SearchableDropdown<Model>(
                label: 'Model',
                searchHint: 'Search Model',
                items: controller.models,
                selectedValue: controller.selectedModel.value,
                onChanged: controller.updateModel,
                itemBuilder: (model) => Text(model.name),
                displayStringForOption: (model) => model.name,
              )),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.machineCodeAssetController,
                      decoration: InputDecoration(label: Text('Machine Code Asset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      onEditingComplete: controller.fetchMachineDetails,
                      enabled: false,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.qr_code_scanner),
                    iconSize: 50,
                    onPressed: controller.scanQRCode,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Obx(() => TextField(
                controller: TextEditingController(text: controller.machineName.value),
                decoration: InputDecoration(label: Text('Machine Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                enabled: false,
              )),
              SizedBox(height: 10),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.machineStatus.value,
                decoration: InputDecoration(label: Text('Machine Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                items: controller.machineStatusOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: controller.updateMachineStatus,
                hint: Text('Select machine status'),
              )),
              SizedBox(height: 10),
              TextField(
                controller: controller.detailsController,
                decoration: InputDecoration(label: Text('Remarks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: controller.addAssessment,
                    child: Text('Add Assessment', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: controller.clearForm,
                    child: Text('Clear Form', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
  late List<dynamic> _filteredItems;

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
                                  .itemBuilder(item)
                                  .toString()
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
                        title: widget.itemBuilder(item as T),
                        onTap: () {
                          widget.onChanged(item as T);
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