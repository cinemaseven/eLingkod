import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/common_widget/img_file_upload.dart';
import 'package:elingkod/pages/home.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BusinessClearance extends StatefulWidget {
  const BusinessClearance({super.key});

  @override
  State<BusinessClearance> createState() => _BusinessClearanceState();
}

class _BusinessClearanceState extends State<BusinessClearance> {
  // Controllers
  final TextEditingController appMonth = TextEditingController();
  final TextEditingController appDay = TextEditingController();
  final TextEditingController appYear = TextEditingController();

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
  final TextEditingController contactNum = TextEditingController();
  final TextEditingController email = TextEditingController();

  // Application Type
  String? appType;

  // Ownership Type
  String? ownershipType;

  // Location Status
  String? locationStatus;
  // final TextEditingController contractExpiryMonth = TextEditingController();
  // final TextEditingController contractExpiryDay = TextEditingController();
  // final TextEditingController contractExpiryYear = TextEditingController();

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

  // Pick an image (JPG, PNG)
  Future<void> _pickImage(Function(File) onSelected) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        onSelected(File(pickedFile.path));
      });
    }
  }

  // Pick a file (PDF, DOCX)
  Future<void> _pickFile(Function(File) onSelected) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        onSelected(File(result.files.single.path!));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final isSmallScreen = media.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ElementColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          CustomPageRoute(page: const Home()),
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ElementColors.tertiary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Business Clearance button tapped!"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Future.delayed(const Duration(seconds: 2), () {
                          Navigator.pop(context);
                        });
                      },
                      icon: Icon(Icons.article,
                          size: menuIconSize, color: Colors.white),
                      label: Text("Business Clearance", style: labelStyle),
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
              Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Application Date
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Text("Application Date:", style: labelStyle),
                      ),
                      const SizedBox(height: 6),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (isSmallScreen) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TxtField(
                                  type: TxtFieldType.services,
                                  hint: "MM",
                                  width: media.width * 0.27,
                                  controller: appMonth,
                                  customPadding: EdgeInsets.fromLTRB(30, 5, 0, 0),
                                ),
                                const SizedBox(height: 10),
                                TxtField(
                                  type: TxtFieldType.services,
                                  hint: "DD",
                                  width: media.width * 0.27,
                                  controller: appDay,
                                  customPadding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                ),
                                const SizedBox(height: 10),
                                TxtField(
                                  type: TxtFieldType.services,
                                  hint: "YYYY",
                                  width: media.width * 0.27,
                                  controller: appYear,
                                  customPadding: EdgeInsets.fromLTRB(0, 5, 30, 0),
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: TxtField(
                                    type: TxtFieldType.services,
                                    hint: "MM",
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 8,
                                  child: TxtField(
                                    type: TxtFieldType.services,
                                    hint: "DD",
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 10,
                                  child: TxtField(
                                    type: TxtFieldType.services,
                                    hint: "YYYY",
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
          
                    // Application Type
                    const SizedBox(height: 20),
                    RadioButtons(
                      label: 'Application Type', 
                      options: ['New Application', 'Renewal Application', 'Temporary'], 
                      onChanged: (value) { setState(() { appType = value; });},
                    ),
          
                    // Business Name
                    const SizedBox(height: 10),
                    TxtField(
                      label: "Complete Business Name",
                      type: TxtFieldType.services,
                      hint: "Company / Business Name",
                      controller: businessName),
          
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
                          customPadding: EdgeInsets.fromLTRB(40, 5, 0, 0
                          ),
                        ),
                
                        TxtField(
                          type: TxtFieldType.services,
                          label: 'Building/Unit Number:',
                          hint: "Building/Unit Number",
                          controller: bldgUnit,
                          width: media.width * 0.38,
                          labelFontSize: 15,
                          customPadding: EdgeInsets.fromLTRB(0, 5, 30, 0
                          ),
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
                      ),
          
                    // Nature of Business
                    const SizedBox(height: 20),
                    TxtField(
                      type: TxtFieldType.services,
                      hint: "Nature of Business",
                      label: "Nature of Business",
                      controller: natureOfBusiness
                    ),
          
                    // Ownership
                    const SizedBox(height: 20),
                      RadioButtons(
                        label: 'Business Ownership Type', 
                        options: ['Partnership', 'Corporation', 'Cooperative'], 
                        onChanged: (value) { setState(() { ownershipType = value; });},
                        showOther: true,
                      ),
          
                    // Business Location Status
                    const SizedBox(height: 10),
                      RadioButtons(
                        label: 'Business Location Status', 
                        options: ['Owned', 'Rented', 'Free Lease'], 
                        onChanged: (value) { setState(() { locationStatus = value; });},
                        showOther: true,
                      ),
          
                    // Other Info
                    const SizedBox(height: 10),
                    TxtField(
                      label: "Establishment Total Area",
                      type: TxtFieldType.services,
                      hint: "e.g. 200 sqm",
                      controller: totalArea
                    ),
          
                    const SizedBox(height: 20),
                    TxtField(
                      label: "Capitalization (₱)",
                      type: TxtFieldType.services,
                      hint: "In Philippine Peso",
                      controller: capitalization
                    )
                    ,
                    const SizedBox(height: 20),
                    TxtField(
                      label: "Gross Sales and Receipts (Precedent Year)",
                      type: TxtFieldType.services,
                      hint: "In Philippine Peso",
                      controller: grossSales
                      ),
          
                    const SizedBox(height: 20),
                    TxtField(
                      label: "Business Owner / Manager",
                      type: TxtFieldType.services,
                      hint: "Owner / Manager Full Name",
                      controller: ownerName
                      ),
          
                    const SizedBox(height: 20),
                    TxtField(
                        label: "Contact Number",
                        type: TxtFieldType.services,
                        hint: "09XXXXXXXXX",
                        controller: contactNum,
                        keyboardType: TextInputType.number,
                      ),
          
                    const SizedBox(height: 20),
                    TxtField(
                      label: "Email Address",
                      type: TxtFieldType.services,
                      hint: "example@gmail.com",
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
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
          
                     // D.T.I Certificate (File)
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: UploadFileBox(
                          label: "Valid D.T.I Certificate (For Single Proprietors)",
                          file: dtiCertFile,
                          onTap: () => _pickFile((file) => dtiCertFile= file),
                        ),
                      ),
          
                      // S.E.C Certificate (File)
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: UploadFileBox(
                          label: "Valid S.E.C Certificate (For Partnership or Corporations)",
                          file: secCertFile,
                          onTap: () => _pickFile((file) => secCertFile = file),
                        ),
                      ),
          
                      // C.D.A Certificate (File)
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: UploadFileBox(
                          label: "Valid Cooperative Development Authority Certificate (For Cooperative)",
                          file: cdaFile,
                          onTap: () => _pickFile((file) => cdaFile = file),
                        ),
                      ),
          
                      // Prev. Barangay Clearance (Image)
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: UploadImageBox(
                          label: "Valid Cooperative Development Authority Certificate (If Renewal)",
                          imageFile: barangayClrncImage,
                          onTap: () => _pickImage((file) => barangayClrncImage = file),
                        ),
                      ),
          
                      // Land Title (File)
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: UploadImageBox(
                          label: "Land Title or Tax Declaration (Must be under the name of land owner / lessor)",
                          imageFile: landTitleFile,
                          onTap: () => _pickFile((file) => landTitleFile = file),
                        ),
                      ),
          
                      // Contracts or Agreements (File)
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: UploadImageBox(
                          label: "Duly Notarized Contracts and/or Agreements",
                          imageFile: contractsFile,
                          onTap: () => _pickFile((file) => contractsFile = file),
                        ),
                      ),
          
                       // Establishment (Image)
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: UploadImageBox(
                          label: "4R Format Full-View Establishment Picture",
                          imageFile: establishmentImage,
                          onTap: () => _pickImage((file) => establishmentImage = file),
                        ),
                      ),
          
                      // Owner (Image)
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: UploadImageBox(
                          label: "2x2 Owner Picture",
                          imageFile: ownerImage,
                          onTap: () => _pickImage((file) => ownerImage = file),
                        ),
                      ),
          
                      // Contracts or Agreements (File)
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: UploadImageBox(
                          label: "Association Endorsement",
                          imageFile: endorsementFile,
                          onTap: () => _pickFile((file) => endorsementFile = file),
                        ),
                      ),
          
                      // Signature (Image)
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: UploadImageBox(
                          label: "Upload Signature",
                          imageFile: signatureImage,
                          onTap: () => _pickImage((file) => signatureImage = file),
                        ),
                      ),
          
                      // Signature (Image)
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: UploadImageBox(
                          label: "Applicant Signature over Printed Name",
                          imageFile: signatureImage,
                          onTap: () => _pickImage((file) => signatureImage = file),
                        ),
                      ),
          
                    // for (var doc in [
                    //   "Valid DTI Certificate (for Single Proprietorship)",
                    //   "Valid SEC Certificate (for Partnership/Corporation)",
                    //   "Valid Cooperative Development Authority Certificate",
                    //   "Previous Barangay Clearance (if Renewal)",
                    //   "Land Title and/or Tax Declaration",
                    //   "Duly Notarized Contracts and/or Agreements",
                    //   "4R Format Full-view Establishment Picture",
                    //   "2x2 Format Owner Picture",
                    //   "Association Endorsement",
                    //   "Authorized Signatory Full Name and Signature"
                    // ])
                    //   Container(
                    //     height: isSmallScreen ? 100 : 120,
                    //     width: double.infinity,
                    //     margin: const EdgeInsets.only(bottom: 12),
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.grey.shade400),
                    //       borderRadius: BorderRadius.circular(15),
                    //     ),
                    //     child: Center(
                    //         child: Text("Upload $doc", style: labelStyle)),
                    //   ),
          
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
                          onClick: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Form Submitted!"),
                                duration: const Duration(seconds: 2),
                                backgroundColor: ElementColors.primary,
                              ),
                            );
                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                    ),
                    // const SizedBox(height: 30),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}