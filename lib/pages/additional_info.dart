import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/pages/camera_capture.dart';
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/services/userData_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdditionalInfo extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const AdditionalInfo({super.key, required this.profileData});

  @override
  State<AdditionalInfo> createState() => _AdditionalInfoState();
}

class _AdditionalInfoState extends State<AdditionalInfo> {
  final _formKey = GlobalKey<FormState>();

  // yes/no selections
  String? seniorYesOrNo;
  String? pwdYesOrNo;

  // captured images
  File? _seniorCardImage;
  File? _frontPWDImage;
  File? _backPWDImage;

  // NEW: Save the detected ID type from the camera page (used for verification only)
  String _seniorDetectedType = 'none';
  String _pwdDetectedType = 'none';

  // original extracted maps (from camera) - Kept only for ID number
  Map<String, String> _seniorExtracted = {};
  Map<String, String> _pwdFrontExtracted = {};

  final UserDataService _userDataService = UserDataService();

  // editable controllers for inline editing of OCR results - Only for ID Numbers
  final Map<String, TextEditingController> _seniorControllers = {};
  final Map<String, TextEditingController> _pwdFrontControllers = {};

  // typed ID numbers (kept for manual entry fallback and main form fields)
  final TextEditingController seniorIDNum = TextEditingController();
  final TextEditingController pwdIDNum = TextEditingController();

  final supabase = Supabase.instance.client;
  bool _isSubmitting = false;

  // helper: accept either String url or Map result from upload helper (KEEP)
  String? _extractUrl(dynamic uploadResult) {
    if (uploadResult == null) return null;
    if (uploadResult is String) return uploadResult;
    if (uploadResult is Map && uploadResult.containsKey('url'))
      return uploadResult['url'] as String?;
    return null;
  }

  // open camera capture and populate controllers (MODIFIED: SAVES DETECTED TYPE)
  Future<void> _captureId(String which) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraCapturePage(
          profileData: widget.profileData,
          onCapture: (file, fields, detectedType) {
            // Define ONLY the ID key based on the detected type
            final idKey = detectedType == 'senior' ? 'senior_id_number' : 'pwd_id_number';
            final allKeys = [idKey];

            if (which == 'senior') {
              _seniorCardImage = file;
              _seniorExtracted = Map<String, String>.from(fields);
              _seniorControllers.clear();
              _seniorDetectedType = detectedType; // <<< SAVING DETECTED TYPE

              // --- START: ID Comparison/Validation Logic ---
              final newSeniorID = fields['senior_id_number'] ?? '';
              final currentSeniorID = seniorIDNum.text.trim();

              if (currentSeniorID.isNotEmpty && newSeniorID.isNotEmpty && currentSeniorID != newSeniorID) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '⚠️ Warning: Scanned Senior ID ($newSeniorID) differs from the existing value ($currentSeniorID). Please verify and correct the field below.', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    duration: const Duration(seconds: 5),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: ElementColors.secondary
                  ),
                );
              }
              // --- END: ID Comparison/Validation Logic ---

              for (var k in allKeys) {
                _seniorControllers[k] = TextEditingController(text: fields[k] ?? '');
              }
            } else if (which == 'pwdFront') {
              _frontPWDImage = file;
              _pwdFrontExtracted = Map<String, String>.from(fields);
              _pwdFrontControllers.clear();
              _pwdDetectedType = detectedType; // <<< SAVING DETECTED TYPE

              for (var k in allKeys) {
                if (k == 'pwd_id_number') {
                  pwdIDNum.text = fields[k] ?? '';
                }
                _pwdFrontControllers[k] = TextEditingController(text: fields[k] ?? '');
              }
            } else {
              _backPWDImage = file;
            }
          },
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  // Unused helper methods (kept for completeness)
  bool _ocrContainsKeyword(Map<String, TextEditingController> controllers, String keyword) {
    final kw = keyword.toLowerCase();
    final idKey = keyword == 'senior' ? 'senior_id_number' : 'pwd_id_number';
    if (controllers.containsKey(idKey) && controllers[idKey]!.text.toLowerCase().contains(kw)) {
      return true;
    }
    return false;
  }

  bool _mapContainsKeyword(Map<String, String> map, String keyword) {
    final kw = keyword.toLowerCase();
    for (final v in map.values) {
      if (v.toLowerCase().contains(kw)) return true;
    }
    return false;
  }

  bool _verifyExtractedWithProfile(Map<String, TextEditingController> controllers) {
    if (controllers.isEmpty) return true;
    return true;
  }

Future<void> _createProfile() async {
  final scaffold = ScaffoldMessenger.of(context);

  if (!_formKey.currentState!.validate()) {
    scaffold.showSnackBar(
      SnackBar(
        content: const Text(
          "Please fill out all required fields.",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: ElementColors.secondary,
      ),
    );
    return;
  }

  // --- ID Type Verification ---
  if (seniorYesOrNo == 'Yes' && _seniorDetectedType != 'senior') {
    scaffold.showSnackBar(
        SnackBar(
        content: Text(
          'ID Type verification failed. Please ensure a Senior Citizen ID is captured.',
          style: TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary
      ),
    );
    return;
  }

  if (pwdYesOrNo == 'Yes' && _pwdDetectedType != 'pwd') {
    scaffold.showSnackBar(
        SnackBar(
        content: Text(
          'ID Type verification failed. Please ensure a PWD ID is captured.',
          style: TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary
      ),
    );
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    // --- CALL SERVICE INSTEAD OF INLINE UPLOAD ---
    await _userDataService.saveCompleteOnboardingProfile(
      initialProfileData: widget.profileData,
      seniorYesOrNo: seniorYesOrNo,
      seniorIDNum: seniorIDNum.text.trim(),
      seniorCardImage: _seniorCardImage,
      pwdYesOrNo: pwdYesOrNo,
      pwdIDNum: pwdIDNum.text.trim(),
      frontPWDImage: _frontPWDImage,
      backPWDImage: _backPWDImage,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Profile created successfully!',
      style: TextStyle(fontWeight: FontWeight.bold)),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      backgroundColor: ElementColors.secondary
      ),
    );

    Navigator.of(context).pushReplacement(
      CustomPageRoute(page: const Home()),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error completing profile: ${e.toString()}',
      style: TextStyle(fontWeight: FontWeight.bold)),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      backgroundColor: ElementColors.secondary
      ),
    );
  } finally {
    if (mounted) setState(() => _isSubmitting = false);
  }
}


  // _previewImage (KEEP)
  Widget _previewImage(File? f, String label) {
    if (f == null) return Text('$label: no image yet');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Image.file(f, height: 160),
      ],
    );
  }

  // build inline editable fields from controllers map (MODIFIED: ID ONLY)
  List<Widget> _buildEditableFields(Map<String, TextEditingController> controllers) {
    final widgets = <Widget>[];
    controllers.forEach((key, ctrl) {
      // Only include ID number fields
      if (key == 'senior_id_number' || key == 'pwd_id_number') {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            controller: ctrl,
            decoration: InputDecoration(
              labelText: key.replaceAll('_', ' ').toUpperCase(),
              hintText: 'Correct OCR result here',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) => (value == null || value.isEmpty)
                ? 'ID number verification required.'
                : null,
          ),
        ));
      }
    });
    return widgets;
  }

  @override
  void dispose() {
    seniorIDNum.dispose();
    pwdIDNum.dispose();
    _seniorControllers.forEach((k, c) => c.dispose());
    _pwdFrontControllers.forEach((k, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ElementColors.fontColor2,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ElementColors.primary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Back button + title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ElementColors.tertiary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Text(
                      "Additional Information",
                      style: TextStyle(
                        fontSize: media.height * 0.033,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                  child: Text(
                    "Please answer the following question to help us determine your eligibility for senior and PWD-specific benefits and services.",
                    style: TextStyle(fontSize: media.height * 0.017),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 7),
                Divider(
                  color: ElementColors.fontColor1,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Are you a senior citizen (60 years old and above)?',
                  options: const ['Yes', 'No'],
                  onChanged: (value) => setState(() => seniorYesOrNo = value),
                  inline: true,
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Please choose yes or no."
                      : null,
                ),
                if (seniorYesOrNo == 'Yes')
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TxtField(
                          type: TxtFieldType.services,
                          label: 'Senior Citizen ID Number (Manual Input):*',
                          controller: seniorIDNum,
                          keyboardType: TextInputType.number,
                          hint: 'Enter your Senior ID',
                          validator: (value) =>
                          (seniorYesOrNo == 'Yes' &&
                              (value == null || value.isEmpty))
                              ? 'This field is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Buttons(
                          title: "Capture Senior Citizen ID (Front)",
                          type: BtnType.secondary,
                          height: 45,
                          fontSize: media.width * 0.035,
                          width: media.width * 0.7,
                          onClick: () => _captureId('senior'),
                        ),
                        const SizedBox(height: 8),
                        _previewImage(_seniorCardImage, 'Senior ID'),
                        // Show type status for user feedback
                        Text('Status: ID Type Detected: ${_seniorDetectedType.toUpperCase()}',
                            style: TextStyle(color: _seniorDetectedType == 'senior' ? Colors.green : Colors.red)),
                        const SizedBox(height: 8),
                        // editable extracted fields inline (ID ONLY)
                        if (_seniorControllers.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              children: [
                                const Text('OCR Result (Verify/Correct ID Number)', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                ..._buildEditableFields(_seniorControllers),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Are you a registered Person with Disability (PWD)?',
                  options: const ['Yes', 'No'],
                  onChanged: (value) => setState(() => pwdYesOrNo = value),
                  inline: true,
                  validator: (value) =>
                  (value == null || value.isEmpty)
                      ? "Please choose yes or no."
                      : null,
                ),
                if (pwdYesOrNo == 'Yes')
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TxtField(
                          type: TxtFieldType.services,
                          label: 'PWD ID Number (Manual Input):*',
                          controller: pwdIDNum,
                          hint: 'Enter your PWD ID',
                          validator: (value) =>
                          (pwdYesOrNo == 'Yes' &&
                              (value == null || value.isEmpty))
                              ? 'This field is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Buttons(
                          title: "Capture Front PWD ID",
                          type: BtnType.secondary,
                          height: 45,
                          onClick: () => _captureId('pwdFront'),
                        ),
                        const SizedBox(height: 8),
                        _previewImage(_frontPWDImage, 'PWD Front'),
                        // Show type status for user feedback
                        Text('Status: ID Type Detected: ${_pwdDetectedType.toUpperCase()}',
                            style: TextStyle(color: _pwdDetectedType == 'pwd' ? Colors.green : Colors.red)),
                        const SizedBox(height: 8),
                        if (_pwdFrontControllers.isNotEmpty)
                          Column(
                            children: [
                              const Text('OCR Result (Verify/Correct ID Number)', style: TextStyle(fontWeight: FontWeight.bold)),
                              ..._buildEditableFields(_pwdFrontControllers),
                            ],
                          ),

                        const SizedBox(height: 12),
                        Buttons(
                          title: "Capture Back PWD ID (Optional)",
                          type: BtnType.secondary,
                          height: 45,
                          onClick: () => _captureId('pwdBack'),
                        ),
                        const SizedBox(height: 8),
                        _previewImage(_backPWDImage, 'PWD Back'),
                         // Show type status for user feedback
                        Text('Status: ID Type Detected: ${_pwdDetectedType.toUpperCase()}',
                            style: TextStyle(color: _pwdDetectedType == 'pwd' ? Colors.green : Colors.red)),
                        const SizedBox(height: 8),
                        if (_pwdFrontControllers.isNotEmpty)
                          Column(
                            children: [
                              const Text('OCR Result (Verify/Correct ID Number)', style: TextStyle(fontWeight: FontWeight.bold)),
                              ..._buildEditableFields(_pwdFrontControllers),
                            ],
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 40),
                SizedBox(
                  width: media.width * 0.5,
                  child: Buttons(
                    title: _isSubmitting ? "Saving..." : "Create Profile",
                    type: BtnType.secondary,
                    fontSize: 16,
                    height: 45,
                    onClick: () {
                      if (_isSubmitting) return; // prevents multiple taps
                      _createProfile(); // triggers your async function
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}