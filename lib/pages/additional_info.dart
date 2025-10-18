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

  String? seniorYesOrNo;
  String? pwdYesOrNo;

  File? _seniorCardImage;
  File? _frontPWDImage;
  File? _backPWDImage;

  String _seniorDetectedType = 'none';

  String _pwdDetectedType = 'none';

  Map<String, String> _seniorExtracted = {};
  Map<String, String> _pwdFrontExtracted = {};

  final UserDataService _userDataService = UserDataService();

  // Initialize the TextEditingControllers
  final Map<String, TextEditingController> _seniorControllers = {};
  final Map<String, TextEditingController> _pwdFrontControllers = {};

  final TextEditingController seniorIDNum = TextEditingController();
  final TextEditingController pwdIDNum = TextEditingController();

  final supabase = Supabase.instance.client;
  bool _isSubmitting = false;

  String? _extractUrl(dynamic uploadResult) {
    if (uploadResult == null) return null;
    if (uploadResult is String) return uploadResult;
    if (uploadResult is Map && uploadResult.containsKey('url')) {
      return uploadResult['url'] as String?;
    }
    return null;
  }

  // open camera capture and populate controllers
  Future<void> _captureId(String which) async {
    if (!mounted) return;

    // prepares data to send to the camera page for logic handling
    final Map<String, dynamic> cameraProfileData = {
      'pwd_id_number': pwdIDNum.text.trim(),
      'capture_target': which,
      ...widget.profileData,
    };

    if (which.startsWith('senior') && (seniorIDNum.text
        .trim()
        .isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text(
                'Please enter the Senior ID Number manually first.',
                style: TextStyle(fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary
        ),
      );
      return;
    }

    if (which.startsWith('pwd') && (pwdIDNum.text
        .trim()
        .isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text(
                'Please enter the PWD ID Number manually first.',
                style: TextStyle(fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CameraCapturePage(
              profileData: cameraProfileData,
              onCapture: (file, fields, detectedType) {
                final idKey = detectedType == 'senior'
                    ? 'senior_id_number'
                    : 'pwd_id_number';
                final allKeys = [idKey];

                if (which == 'senior') {
                  _seniorCardImage = file;
                  _seniorExtracted = Map<String, String>.from(fields);
                  _seniorControllers.clear();
                  _seniorDetectedType = detectedType;

                  bool mismatchWarningShown = false;
                  // --- SENIOR: ID comparison/validation ---
                  final newSeniorID = fields['senior_id_number'] ?? '';
                  final currentSeniorID = seniorIDNum.text.trim();

                  if (currentSeniorID.isNotEmpty && newSeniorID.isNotEmpty &&
                      currentSeniorID != newSeniorID) {
                    mismatchWarningShown = true;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Warning: Scanned Senior ID ($newSeniorID) differs from the existing value ($currentSeniorID). Please verify and correct the field below.',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          duration: const Duration(seconds: 5),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: ElementColors.primary
                      ),
                    );
                  }

                  for (var k in allKeys) {
                    _seniorControllers[k] =
                        TextEditingController(text: fields[k] ?? '');
                  }

                  if (!mismatchWarningShown &&
                      _seniorExtracted.containsKey('senior_id_number') &&
                      _seniorExtracted['senior_id_number']!.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Senior ID Captured. Please ensure the manual input matches the card.',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          duration: const Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green
                      ),
                    );
                  }
                } else if (which == 'pwdFront') {
                  _frontPWDImage = file;
                  _pwdFrontExtracted = Map<String, String>.from(fields);
                  _pwdFrontControllers.clear();
                  _pwdDetectedType = detectedType;
                  bool mismatchWarningShown = false;

                  // --- PWD: ID comparison/validation ---
                  final extractedPwdID = fields['pwd_id_number'] ?? '';
                  final currentPwdID = pwdIDNum.text.trim();

                  if (currentPwdID.isNotEmpty && extractedPwdID.isNotEmpty &&
                      currentPwdID != extractedPwdID) {
                    mismatchWarningShown = true;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Warning: Scanned PWD ID ($extractedPwdID) differs from the manually entered value ($currentPwdID). Please verify and correct the field below.',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          duration: const Duration(seconds: 5),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: ElementColors.primary
                      ),
                    );
                  }

                  for (var k in allKeys) {
                    _pwdFrontControllers[k] =
                        TextEditingController(text: fields[k] ?? '');
                  }

                  if (!mismatchWarningShown &&
                      _pwdFrontExtracted.containsKey('pwd_id_number') &&
                      _pwdFrontExtracted['pwd_id_number']!.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('PWD Front ID Captured. Please ensure the manual input matches the card.',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          duration: const Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green
                      ),
                    );
                  }
                } else if (which == 'pwdBack') {
                  _backPWDImage = file;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'PWD Back ID Captured.',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green
                    ),
                  );
                }
              },
            ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

//hahhaha ayaw ko na
  bool _ocrContainsKeyword(Map<String, TextEditingController> controllers,
      String keyword) {
    final kw = keyword.toLowerCase();
    final idKey = keyword == 'senior' ? 'senior_id_number' : 'pwd_id_number';
    if (controllers.containsKey(idKey) &&
        controllers[idKey]!.text.toLowerCase().contains(kw)) {
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

  bool _verifyExtractedWithProfile(
      Map<String, TextEditingController> controllers) {
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

    // ID type & image verification
    if (seniorYesOrNo == 'Yes') {
      if (_seniorCardImage == null) {
        scaffold.showSnackBar(SnackBar(
          content: Text('Please capture the Senior Citizen ID.',
              style: TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary,
        ));
        return;
      }

      if (_seniorDetectedType != 'senior') {
        scaffold.showSnackBar(SnackBar(
          content: Text(
              'ID Type verification failed for Senior ID. Please ensure a Senior Citizen ID is captured.',
              style: TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary,
        ));
        return;
      }
      final extractedSeniorID = _seniorExtracted['senior_id_number']?.trim() ?? '';
      final typedSeniorID = seniorIDNum.text.trim();
      if (extractedSeniorID.isNotEmpty && typedSeniorID.isNotEmpty &&
          extractedSeniorID != typedSeniorID) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              'The entered Senior ID does not match the scanned ID number. Please verify before continuing.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary,
          ),
        );
        return;
      }
    }


    if (pwdYesOrNo == 'Yes') {
      if (_frontPWDImage == null) {
        scaffold.showSnackBar(SnackBar(
          content: Text('Please capture the PWD ID (Front).',
              style: TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary,
        ));
        return;
      }
      if (_backPWDImage == null) {
        scaffold.showSnackBar(SnackBar(
          content: Text('Please capture the PWD ID (Back).',
              style: TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary,
        ));
        return;
      }
      if (_pwdDetectedType != 'pwd') {
        scaffold.showSnackBar(SnackBar(
          content: Text(
              'ID Type verification failed for PWD ID. Please ensure a PWD ID is captured.',
              style: TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary,
        ));
        return;
      }
      final extractedPwdID = _pwdFrontExtracted['pwd_id_number']?.trim() ?? '';
      final typedPwdID = pwdIDNum.text.trim();
      if (extractedPwdID.isNotEmpty && typedPwdID.isNotEmpty &&
          extractedPwdID != typedPwdID) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              'The entered PWD ID does not match the scanned ID number. Please verify before continuing.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary,
          ),
        );
        return;
      }
    }


    setState(() => _isSubmitting = true);

    try {
      // --- call service instead of inline upload ---
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
        SnackBar(content: Text('Profile created successfully!',
            style: TextStyle(fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green
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

  List<Widget> _buildEditableFields(
      Map<String, TextEditingController> controllers) {
    final widgets = <Widget>[];
    controllers.forEach((key, ctrl) {
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
            validator: (value) =>
            (value == null || value.isEmpty)
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
    var media = MediaQuery
        .of(context)
        .size;

    final pwdStatusText = _frontPWDImage != null
        ? 'Status: ID Type Detected: ${_pwdDetectedType.toUpperCase()}'
        : 'Status: Awaiting PWD Front Capture';
    final pwdStatusColor = _pwdDetectedType == 'pwd'
        ? Colors.green
        : (_frontPWDImage != null ? Colors.red : Colors.grey);

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
                  validator: (value) =>
                  (value == null || value.isEmpty)
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
                          title: "Capture Senior Citizen ID",
                          type: BtnType.secondary,
                          height: 45,
                          fontSize: media.width * 0.035,
                          width: media.width * 0.7,
                          onClick: () => _captureId('senior'),
                        ),
                        const SizedBox(height: 8),
                        _previewImage(_seniorCardImage, 'Senior ID'),
                        Text('Status: ID Type Detected: ${_seniorDetectedType
                            .toUpperCase()}',
                            style: TextStyle(color: _seniorDetectedType ==
                                'senior' ? Colors.green : Colors.red)),
                        const SizedBox(height: 8),
                        if (_seniorControllers.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              children: [
                                const Text(
                                    'OCR Result (Verify/Correct ID Number)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
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
                          keyboardType: TextInputType.number,
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
                          fontSize: media.width * 0.035,
                          width: media.width * 0.7,
                          onClick: () => _captureId('pwdFront'),
                        ),
                        const SizedBox(height: 8),
                        _previewImage(_frontPWDImage, 'PWD Front'),
                        // Show type status for user feedback
                        Text( 'Status: ID Type Detected: ${_pwdDetectedType.toUpperCase()}', style: TextStyle(color: _pwdDetectedType == 'pwd' ? Colors.green : Colors.red)),
                        const SizedBox(height: 8),
                        if (_pwdFrontControllers.isNotEmpty)
                          Column(
                            children: [
                              const Text(
                                  'OCR Result (Verify/Correct ID Number)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                              ..._buildEditableFields(_pwdFrontControllers),
                            ],
                          ),

                        const SizedBox(height: 12),
                        Buttons(
                          title: "Capture Back PWD ID",
                          type: BtnType.secondary,
                          height: 45,
                          fontSize: media.width * 0.035,
                          width: media.width * 0.7,
                          onClick: () => _captureId('pwdBack'),
                        ),
                        const SizedBox(height: 8),
                        _previewImage(_backPWDImage, 'PWD Back'),
                        Text(
                            _backPWDImage != null
                                ? 'Status: PWD Back Image Captured'
                                : 'Status: Awaiting PWD Back Capture',
                            style: TextStyle(color: _backPWDImage != null
                                ? Colors.green
                                : Colors.grey)
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
                      if (_isSubmitting) return;
                      _createProfile();
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
