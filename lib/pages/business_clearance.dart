import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/applicant_undertaking.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/date_picker.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/common_widget/img_file_upload.dart';
import 'package:elingkod/common_widget/pdf_generator.dart'; // pdf widget
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/services/submitRequests_service.dart';
import 'package:elingkod/services/userData_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class BusinessClearance extends StatefulWidget {
  const BusinessClearance({super.key});

  @override
  State<BusinessClearance> createState() => _BusinessClearanceState();
}

class _BusinessClearanceState extends State<BusinessClearance> {
  final _formKey = GlobalKey<FormState>();
  UserDetails? _initialUserDetails;
  bool _loading = true;
  DateTime? _selectedApplicationDate;
  String? appType;
  String? ownershipType;
  String? locationStatus;
  final double menuIconSize = 28;
  final TextStyle labelStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  // Files
  File? dtiCertFile;
  File? secCertFile;
  File? cdaFile;
  File? landTitleFile;
  File? contractsFile;
  File? endorsementFile;

  // Images
  File? barangayClrncImage;
  File? establishmentImage;
  File? ownerImage;
  File? signatureImage;
  File? applicantSignatureImage;

  final ImagePicker _picker = ImagePicker();
  

  // Controllers
  final TextEditingController applicationDate = TextEditingController();

  final TextEditingController businessName = TextEditingController();
  final TextEditingController houseNum = TextEditingController();
  final TextEditingController bldgUnit = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController village = TextEditingController();
  final TextEditingController natureOfBusiness =
  TextEditingController();

  final TextEditingController totalArea = TextEditingController();
  final TextEditingController capitalization = TextEditingController();
  final TextEditingController grossSales = TextEditingController();
  final TextEditingController ownerName = TextEditingController();
  final TextEditingController contactNumber = TextEditingController();
  final TextEditingController email = TextEditingController();

  // final TextEditingController contractExpiryMonth = TextEditingController();
  // final TextEditingController contractExpiryDay = TextEditingController();
  // final TextEditingController contractExpiryYear = TextEditingController();

  // Autofill info
  @override
  void initState() {
    super.initState();
    // Sets application date to today
    _selectedApplicationDate = DateTime.now();
    applicationDate.text = DateFormat('MM/dd/yyyy').format(_selectedApplicationDate!);

    // Fetch data
    _loadAndAutofillUserDetails();
  }

  Future <void> _loadAndAutofillUserDetails() async {
    try {
      final details = await UserDataService().fetchUserDetails();
      if (!mounted) return;

      _initialUserDetails = details;

      contactNumber.text = details.contactNumber ?? '';
      email.text = details.email ?? '';
  } catch (e) {
      print("Error loading user details for autofill: $e");
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
}

  @override
  void dispose() {
    applicationDate.dispose();
    businessName.dispose();
    houseNum.dispose();
    bldgUnit.dispose();
    street.dispose();
    village.dispose();
    natureOfBusiness.dispose();
    totalArea.dispose();
    capitalization.dispose();
    grossSales.dispose();
    ownerName.dispose();
    contactNumber.dispose();
    email.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Pick an image
  Future<void> _pickImage(Function(File) onSelected) async {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: ElementColors.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: ElementColors.fontColor2),
                title: Text("Take a photo", style: TextStyle(color:ElementColors.fontColor2)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      onSelected(File(pickedFile.path));
                    });
                  }
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: Icon(Icons.photo_library, color: ElementColors.fontColor2),
                title: Text("Choose from gallery", style: TextStyle(color:ElementColors.fontColor2)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      onSelected(File(pickedFile.path));
                    });
                  }
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: Icon(Icons.cancel, color: ElementColors.fontColor2),
                title: Text("Cancel", style: TextStyle(color:ElementColors.fontColor2)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  // Pick a file
  Future<void> _pickFile(Function(File) onSelected) async {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: ElementColors.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.folder_open, color: ElementColors.fontColor2),
                title: Text("Choose from files", style: TextStyle(color:ElementColors.fontColor2)),
                onTap: () async {
                  Navigator.pop(context); // close the sheet first
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'docx'],
                  );
                  if (result != null && result.files.single.path != null) {
                    setState(() {
                      onSelected(File(result.files.single.path!));
                    });
                  }
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: Icon(Icons.cancel, color: ElementColors.fontColor2),
                title: Text("Cancel",style: TextStyle(color:ElementColors.fontColor2)),
                onTap: () => Navigator.pop(context), // just close sheet
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Future<void> _selectDate(BuildContext context, TextEditingController controller, Function(DateTime?) onDateSelected) async {
  final pickedDate = await showCustomDatePicker(context);
  if (pickedDate != null) {
    onDateSelected(pickedDate);
    controller.text = DateFormat('MM/dd/yyyy').format(pickedDate);
  }
}

  void _submitBusinessClearance() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Validate form fields first
    if (!_formKey.currentState!.validate()) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text("Please fill out all required fields.",
              style: TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary,
        ),
      );
        return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BusinessClearancePopup(
        onConfirmed: () async {
          try {
          // 1. Collect all the data
          final Map<String, dynamic> formData = {
            'applicationDate': applicationDate.text,
            'appType': appType,
            'businessName': businessName.text,
            'houseNum': houseNum.text,
            'bldgUnit': bldgUnit.text,
            'street': street.text,
            'village': village.text,
            'natureOfBusiness': natureOfBusiness.text,
            'ownershipType': ownershipType,
            'locationStatus': locationStatus,
            'totalArea': totalArea.text,
            'capitalization': capitalization.text,
            'grossSales': grossSales.text,
            'ownerName': ownerName.text,
            'contactNumber': contactNumber.text,
            'email': email.text,
            'dtiCertFile': ownershipType == 'Single Proprietor' ? dtiCertFile : null,
            'secCertFile': ownershipType == 'Partnership' || ownershipType == 'Corporation' ? secCertFile : null,
            'cdaFile': ownershipType == 'Cooperative' ? cdaFile : null,
            'barangayClrncImage': appType == 'Renewal Application' ? barangayClrncImage : null,
            'landTitleFile': landTitleFile,
            'contractsFile': contractsFile,
            'establishmentImage': establishmentImage,
            'ownerImage': ownerImage,
            'endorsementFile': endorsementFile,
            'signatureImage': signatureImage,
          };

            // 2. Show loading indicator while submitting
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          // 3. Submit to Supabase
          final submitService = SubmitRequestService();
          await submitService.submitBusinessClearance(formData: formData);

          // 4. Close all dialogs first (loading and terms)
          Navigator.of(context, rootNavigator: true).pop();

          // 5. Navigate AFTER dialogs are closed
          if (mounted) {
            Navigator.of(context).pushReplacement(
              CustomPageRoute(page: const Home(showConfirmation: true)),
            );
          }
        } on Exception catch (e) {
          Navigator.pop(context);
          Navigator.pop(dialogContext);
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Failed to submit request: ${e.toString()}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              backgroundColor: ElementColors.secondary,
            ),
          );
        }
      },
    )
  );
}

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final isSmallScreen = media.width < 600;

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator())
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ElementColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            CustomPageRoute(page: const Home()),
          );
        },
      ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ElementColors.tertiary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          PdfFormGenerator.generateBusinessClearance();
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("Business Clearance"), 
                      ),
                    ],
                  ),
                ),
            
                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      const Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child:
                        Text("Form to be Accomplished", style: labelStyle),
                      ),
                      const Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                ),
            
                // Form Fields
                InkWell(
                  // Use the reusable function here
                  onTap: () => _selectDate(context, applicationDate, (date) => _selectedApplicationDate = date),
                  child: IgnorePointer(
                    child: TxtField(
                      type: TxtFieldType.services,
                      label: 'Application Date',
                      hint: "MM/DD/YYYY",
                      controller: applicationDate,
                      suffixIcon: Icon(Icons.calendar_today, color: ElementColors.primary),
                      validator:  _requiredValidator
                    ),
                  ),
                  ),
                
                // Application Type
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Application Type', 
                  options: ['New Application', 'Renewal Application', 'Temporary'], 
                  onChanged: (value) { setState(() { appType = value; });},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select an application type.";
                    }
                    return null;
                  },
                ),
                              
                  // Business Name
                  const SizedBox(height: 10),
                  TxtField(
                  label: "Complete Business Name",
                  type: TxtFieldType.services,
                  hint: "Company / Business Name",
                  controller: businessName,
                  validator:  _requiredValidator
                  ),
                            
                // Address
                const SizedBox(height: 20),
                Padding(
                padding: const EdgeInsets.fromLTRB(30, 5, 30, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Complete Business Address', 
                      style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: ElementColors.fontColor1,
                      ),
                    ),
                  ],
                ),
                ),
      
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'House/Unit Number:',
                    hint: "House/Unit Number",
                    controller: houseNum,
                    width: media.width * 0.35,
                    labelFontSize: 15,
                    customPadding: EdgeInsets.fromLTRB(40, 5, 0, 0),
                    validator:  _requiredValidator
                  ),
                                  
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'Building/Unit Number:',
                    hint: "Building/Unit Number",
                    controller: bldgUnit,
                    width: media.width * 0.38,
                    labelFontSize: 15,
                    customPadding: EdgeInsets.fromLTRB(0, 5, 30, 0),
                    validator:  _requiredValidator
                  ),
                ],
                ),
      
                // Street Avenue
                const SizedBox(height: 10),
                TxtField(
                label: "Street / Avenue",
                  type: TxtFieldType.services,
                  hint: "Street / Avenue",
                  controller: street,
                  labelFontSize: 15,
                  customPadding: EdgeInsets.fromLTRB(40, 5, 30, 0),
                  validator:  _requiredValidator
                ),
                
                // Village
                const SizedBox(height: 10),
                TxtField(
                label: "Village / Subdivision / Area",
                  type: TxtFieldType.services,
                  hint: "Village / Subdivision / Area",
                  controller: village,
                  labelFontSize: 15,
                  customPadding: EdgeInsets.fromLTRB(40, 5, 30, 0),
                  validator:  _requiredValidator
                ),
                            
                // Nature of Business
                const SizedBox(height: 20),
                TxtField(
                type: TxtFieldType.services,
                hint: "Nature of Business",
                label: "Nature of Business",
                controller: natureOfBusiness,
                validator:  _requiredValidator
                ),
      
                // Ownership
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Business Ownership Type', 
                  options: ['Single Proprietor', 'Partnership', 'Corporation', 'Cooperative'], 
                  onChanged: (value) { setState(() { ownershipType = value; });},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select ownership type.';
                    }
                    return null;
                  },
                ),
                            
                // Business Location Status
                const SizedBox(height: 10),
                RadioButtons(
                  label: 'Business Location Status', 
                  options: ['Owned', 'Rented', 'Free Lease'], 
                  onChanged: (value) { setState(() { locationStatus = value; });},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select status.';
                    }
                    return null;
                  },
                ),
                            
                // Other Info
                const SizedBox(height: 10),
                TxtField(
                label: "Establishment Total Area",
                type: TxtFieldType.services,
                hint: "e.g. 200 sqm",
                controller: totalArea,
                validator:  _requiredValidator
                ),
      
                const SizedBox(height: 20),
                TxtField(
                label: "Capitalization (₱)",
                type: TxtFieldType.services,
                hint: "In Philippine Peso",
                controller: capitalization,
                validator:  _requiredValidator
                )
                ,
                const SizedBox(height: 20),
                TxtField(
                label: "Gross Sales and Receipts (Precedent Year)",
                type: TxtFieldType.services,
                hint: "In Philippine Peso",
                controller: grossSales,
                validator:  _requiredValidator
                ),
                            
                const SizedBox(height: 20),
                TxtField(
                label: "Business Owner / Manager",
                type: TxtFieldType.services,
                hint: "Owner / Manager Full Name",
                controller: ownerName,
                validator:  _requiredValidator
                ),
                            
                  const SizedBox(height: 20),
                  TxtField(
                  label: "Contact Number",
                  type: TxtFieldType.services,
                  hint: "09XXXXXXXXX",
                  controller: contactNumber,
                  keyboardType: TextInputType.number,
                  validator:  _requiredValidator
                ),
                            
                const SizedBox(height: 20),
                TxtField(
                label: "Email Address",
                type: TxtFieldType.services,
                hint: "example@gmail.com",
                controller: email,
                keyboardType: TextInputType.emailAddress,
                validator:  _requiredValidator
                ),

                const SizedBox(height: 40),
                Divider(
                color: ElementColors.fontColor1,
                thickness: 1,
                indent: 20,
                endIndent: 20,
                ),
                            
                // Documentary Requirements Text
                Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'DOCUMENTARY REQUIREMENTS',
                    style: TextStyle(fontSize: media.height * 0.022, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

                // Files and Images
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      // D.T.I Certificate (File)
                      if (ownershipType == 'Single Proprietor') ... [
                        UploadFileBox(
                        label: "Valid D.T.I Certificate",
                        file: dtiCertFile,
                        onPickFile: () async {
                        await _pickFile((file) => dtiCertFile = file);
                        return dtiCertFile;
                        },
                        // validator: (file) {
                        //   if (file == null) {
                        //     return 'Please upload the required file.';
                        //   }
                        //   return null;
                        // },
                        onChanged: (file) => setState(() => dtiCertFile = file),
                        ),
                      ],
                      // S.E.C Certificate (File)
                      if (ownershipType == 'Partnership' || ownershipType == 'Corporation') ... [
                        const SizedBox(height: 10),
                        UploadFileBox(
                          label: "Valid S.E.C Certificate",
                          file: secCertFile,
                          onPickFile: () async {
                              await _pickFile((file) => secCertFile = file);
                              return secCertFile;
                          },
                          // validator: (file) {
                          //   if (file == null) {
                          //     return 'Please upload the required file.';
                          //   }
                          //   return null;
                          // },
                          onChanged: (file) => setState(() => secCertFile = file),
                        ),
                      ],
                      // C.D.A Certificate (File)
                      if (ownershipType == 'Cooperative') ... [
                        const SizedBox(height: 10),
                        UploadFileBox(
                          label: "Valid Cooperative Development Authority Certificate",
                          file: cdaFile,
                          onPickFile: () async {
                              await _pickFile((file) => cdaFile = file);
                              return cdaFile;
                          },
                          // validator: (file) {
                          //   if (file == null) {
                          //     return 'Please upload the required file.';
                          //   }
                          //   return null;
                          // },
                          onChanged: (file) => setState(() => cdaFile = file),
                        ),
                      ],
                      // Prev. Barangay Clearance (Image)
                      if (appType == 'Renewal Application') ... [
                        const SizedBox(height: 10),
                        UploadImageBox(
                          label: "Previous Barangay Clearance",
                          imageFile: barangayClrncImage, 
                          onPickFile: () async {
                            await  _pickImage((file) => barangayClrncImage = file);
                            return barangayClrncImage;
                          },
                          // validator: (imageFile) {
                          //   if (imageFile == null) {
                          //     return 'Please upload the required file.';
                          //   }
                          //   return null;
                          // },
                          onChanged: (image) => setState(() => barangayClrncImage = image),
                        ),
                      ],
                      // Land Title (File)
                      const SizedBox(height: 10),
                      UploadFileBox(
                        label: "Land Title or Tax Declaration (Must be under the name of land owner / lessor)",
                        file: landTitleFile, 
                        onPickFile: () async {
                          await  _pickFile((file) => landTitleFile = file);
                          return landTitleFile;
                        },
                        // validator: (file) {
                        //   if (file == null) {
                        //     return 'Please upload the required file.';
                        //   }
                        //   return null;
                        // },
                        onChanged: (file) => setState(() => landTitleFile = file),
                      ),
                      // Contracts or Agreements (File)
                      const SizedBox(height: 10),
                      UploadFileBox(
                        label: "Duly Notarized Contracts and/or Agreements",
                        file: contractsFile, 
                        onPickFile: () async {
                          await  _pickFile((file) => contractsFile = file);
                          return contractsFile;
                        },
                        // validator: (file) {
                        //   if (file == null) {
                        //     return 'Please upload the required file.';
                        //   }
                        //   return null;
                        // },
                        onChanged: (file) => setState(() => contractsFile = file),
                      ),
                      // Establishment (Image)
                      const SizedBox(height: 10),
                      UploadImageBox(
                        label: "4R Format Full-View Establishment Picture",
                        imageFile: establishmentImage, 
                        onPickFile: () async {
                          await  _pickImage((file) => establishmentImage = file);
                          return establishmentImage;
                        },
                        // validator: (imageFile) {
                        //   if (imageFile == null) {
                        //     return 'Please upload the required file.';
                        //   }
                        //   return null;
                        // },
                        onChanged: (image) => setState(() => establishmentImage = image),
                      ),
                      // Owner (Image)
                      const SizedBox(height: 10),
                      UploadImageBox(
                        label: "2x2 Owner Picture",
                        imageFile: ownerImage, 
                        onPickFile: () async {
                          await  _pickImage((file) => ownerImage = file);
                          return ownerImage;
                        },
                        // validator: (imageFile) {
                        //   if (imageFile == null) {
                        //     return 'Please upload the required file.';
                        //   }
                        //   return null;
                        // },
                        onChanged: (image) => setState(() => ownerImage = image),
                      ),
                      // Contracts or Agreements (File)
                      const SizedBox(height: 10),
                      UploadFileBox(
                        label: "Association Endorsement",
                        file: endorsementFile,
                        onPickFile: () async {
                            await _pickFile((file) => endorsementFile = file);
                            return endorsementFile;
                        },
                        // validator: (file) {
                        //   if (file == null) {
                        //     return 'Please upload the required file.';
                        //   }
                        //   return null;
                        // },
                        onChanged: (file) => setState(() => endorsementFile = file),
                      ),
                      // Signature (Image)
                      const SizedBox(height: 10),
                      UploadImageBox(
                        label: "Applicant Signature over Printed Name",
                        imageFile: signatureImage, 
                        onPickFile: () async {
                          await  _pickImage((file) => signatureImage = file);
                          return signatureImage;
                        },
                        // validator: (imageFile) {
                        //   if (imageFile == null) {
                        //     return 'Please upload the required file.';
                        //   }
                        //   return null;
                        // },
                        onChanged: (image) => setState(() => signatureImage = image),
                      ),
                    ],
                  ),
                ),              

              // Submit button
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: isSmallScreen ? media.width * 0.5 : media.width * 0.3,
                  child: Buttons(
                    title: "Submit",
                    type: BtnType.secondary,
                    fontSize: isSmallScreen ? 16 : 14 ,
                    height: 45,
                onClick: _submitBusinessClearance,
                  ),
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