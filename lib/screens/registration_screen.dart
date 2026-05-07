import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_portal/providers/student_provider.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:math';
import 'package:student_portal/utils/app_colors.dart';
import 'package:student_portal/models/master.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;
  final List<GlobalKey<FormState>> _formKeys = List.generate(
    5,
    (_) => GlobalKey<FormState>(),
  );

  // Controllers for all form fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _clubAffiliationController =
      TextEditingController();
  final TextEditingController _physicalIndexController =
      TextEditingController();
  final TextEditingController _identityDocNumberController =
      TextEditingController();
  final TextEditingController _otherDocNameController = TextEditingController();
  final TextEditingController _otherDocNumberController =
      TextEditingController();
  final TextEditingController _beltDocNumberController =
      TextEditingController();
  final TextEditingController _medicalDocNumberController =
      TextEditingController();

  String _selectedGender = 'Male';
  final List<String> _genders = ['Male', 'Female', 'Other'];

  int? _selectedCountryId;
  int? _selectedStateId;
  int? _selectedDistrictId;
  int? _selectedCityId;

  String? _selectedCountryName;
  String? _selectedStateName;
  String? _selectedDistrictName;
  String? _selectedCityName;

  Uint8List? _pickedImageBytes;
  String? _imageBase64;
  String _imageContentType = "image/jpeg"; // Default
  final ImagePicker _picker = ImagePicker();

  int? _selectedIdentityDocId;
  String? _selectedIdentityDocName;
  Uint8List? _identityDocBytes;
  String? _identityDocFileName;
  String? _identityDocBase64;
  String? _identityDocExtension;

  int? _selectedOtherDocId;
  String? _selectedOtherDocName;
  Uint8List? _otherDocBytes;
  String? _otherDocFileName;
  String? _otherDocBase64;
  String? _otherDocExtension;

  int? _selectedBeltDocId;
  String? _selectedBeltDocName;
  Uint8List? _beltDocBytes;
  String? _beltDocFileName;
  String? _beltDocBase64;
  String? _beltDocExtension;

  int? _medicalDocId;
  String? _medicalDocName;
  Uint8List? _medicalDocBytes;
  String? _medicalDocFileName;
  String? _medicalDocBase64;
  String? _medicalDocExtension;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      final String extension = image.name.contains('.')
          ? image.name.split('.').last.toLowerCase()
          : 'jpeg';

      setState(() {
        _pickedImageBytes = bytes;

        if (extension == 'png') {
          _imageContentType = "image/png";
        } else {
          _imageContentType = "image/jpeg";
        }

        final String base64Data = base64Encode(bytes);
        _imageBase64 = "data:$_imageContentType;base64,$base64Data";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<StudentProvider>(context, listen: false);
      provider.fetchCountries();
      provider.fetchRequiredDocuments();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _aadharController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _emergencyContactController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _clubAffiliationController.dispose();
    _physicalIndexController.dispose();
    _identityDocNumberController.dispose();
    _otherDocNameController.dispose();
    _otherDocNumberController.dispose();
    _beltDocNumberController.dispose();
    _medicalDocNumberController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < _totalSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _submitRegistration();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _fillDemoData() async {
    final random = Random();
    final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    final randomSuffix = (10000 + random.nextInt(89999)).toString();

    setState(() {
      _fullNameController.text = "John Doe ${randomSuffix.substring(0, 3)}";
      _selectedGender = 'Male';
      _dobController.text = "2005-05-15";
      _ageController.text = "19";
      _aadharController.text =
          "5$randomSuffix${randomSuffix.substring(0, 5)}"; // 12 digits
      _emailController.text =
          "demo_${timestamp.substring(timestamp.length - 8)}@gmail.com";
      _contactController.text =
          "98$randomSuffix${randomSuffix.substring(0, 3)}"; // 10 digit number
      _addressController.text = "Demo Street No ${random.nextInt(100)}";
      _pincodeController.text = "400001";
      _fatherNameController.text = "Senior Doe";
      _motherNameController.text = "Jane Doe";
      _emergencyContactController.text =
          "88$randomSuffix${randomSuffix.substring(0, 3)}";
      _heightController.text = "175";
      _weightController.text = "68";
      _physicalIndexController.text = "22.5";
      _clubAffiliationController.text = "Fit India Club";
    });

    final provider = Provider.of<StudentProvider>(context, listen: false);

    if (provider.countries.isNotEmpty) {
      final country = provider.countries.firstWhere(
        (c) => c.id == 1,
        orElse: () => provider.countries.first,
      );
      setState(() {
        _selectedCountryId = country.id;
        _selectedCountryName = country.name;
        _selectedStateId = null;
        _selectedDistrictId = null;
        _selectedCityId = null;
      });

      await provider.fetchStates(country.id);
      if (provider.states.isNotEmpty) {
        final state = provider.states.firstWhere(
          (s) => s.id == 1,
          orElse: () => provider.states.first,
        );
        setState(() {
          _selectedStateId = state.id;
          _selectedStateName = state.name;
        });

        await provider.fetchDistricts(state.id);
        if (provider.districts.isNotEmpty) {
          final district = provider.districts.firstWhere(
            (d) => d.id == 40,
            orElse: () => provider.districts.first,
          );
          setState(() {
            _selectedDistrictId = district.id;
            _selectedDistrictName = district.name;
          });

          await provider.fetchCities(district.id);
          if (provider.cities.isNotEmpty) {
            final city = provider.cities.firstWhere(
              (c) => c.id == 83,
              orElse: () => provider.cities.first,
            );
            setState(() {
              _selectedCityId = city.id;
              _selectedCityName = city.name;
            });
          }
        }
      }
    }

    if (provider.requiredDocuments.isNotEmpty) {
      final identityDocs = provider.requiredDocuments
          .where((d) => d.isActive && d.isIdentityDoc)
          .toList();
      provider.requiredDocuments
          .where((d) => d.isActive && !d.isIdentityDoc)
          .toList();

      setState(() {
        if (identityDocs.isNotEmpty) {
          final doc = identityDocs.first;
          _selectedIdentityDocId = doc.id;
          _selectedIdentityDocName = doc.name;
          _identityDocNumberController.text = "ID-$randomSuffix";
          _identityDocBase64 = "data:image/jpeg;base64,/9j/4AAQSkZJRg==";
          _identityDocExtension = "jpeg";
        }

        // Find a Belt doc for demo
        final beltDocs = provider.requiredDocuments.where((d) {
          if (!d.isActive || d.isIdentityDoc) return false;
          final parts = d.name.split(' ');
          if (parts.length > 2) {
            for (int i = 1; i < parts.length - 1; i++) {
              if (parts[i].toLowerCase() == 'belt') return true;
            }
          }
          return false;
        }).toList();

        if (beltDocs.isNotEmpty) {
          final doc = beltDocs.first;
          _selectedBeltDocId = doc.id;
          _selectedBeltDocName = doc.name;
          _beltDocNumberController.text = "BELT-$randomSuffix";
          _beltDocBase64 = "data:image/jpeg;base64,/9j/4AAQSkZJRg==";
          _beltDocExtension = "jpeg";
        }

        // Find Medical doc for demo
        final medicalDoc = provider.requiredDocuments.where((d) {
          return d.isActive &&
              !d.isIdentityDoc &&
              d.name.toLowerCase().startsWith('medical');
        }).firstOrNull;

        if (medicalDoc != null) {
          _medicalDocId = medicalDoc.id;
          _medicalDocName = medicalDoc.name;
          _medicalDocNumberController.text = "MED-$randomSuffix";
          _medicalDocBase64 = "data:image/jpeg;base64,/9j/4AAQSkZJRg==";
          _medicalDocExtension = "jpeg";
        }

        final otherDocsFiltered = provider.requiredDocuments.where((d) {
          if (!d.isActive || d.isIdentityDoc) return false;
          if (d.name.toLowerCase().startsWith('medical')) return false;
          final parts = d.name.split(' ');
          bool isBelt = false;
          if (parts.length > 2) {
            for (int i = 1; i < parts.length - 1; i++) {
              if (parts[i].toLowerCase() == 'belt') {
                isBelt = true;
                break;
              }
            }
          }
          if (isBelt) return false;
          return true;
        }).toList();

        if (otherDocsFiltered.isNotEmpty) {
          final doc = otherDocsFiltered.first;
          _selectedOtherDocId = doc.id;
          _selectedOtherDocName = doc.name;
          _otherDocNameController.text = "Demo Certificate";
          _otherDocNumberController.text = "CERT-$randomSuffix";
          _otherDocBase64 = "data:image/jpeg;base64,/9j/4AAQSkZJRg==";
          _otherDocExtension = "jpeg";
        }
      });
    }

    setState(() {
      _imageContentType = "image/jpeg";
      _imageBase64 = "data:image/jpeg;base64,/9j/4AAQSkZJRg==";
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo data filled successfully!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _submitRegistration() async {
    final Map<String, dynamic> studentData = {
      "first_name": _fullNameController.text,
      "middle_name": "",
      "last_name": "",
      "gender": _selectedGender,
      "dob": _dobController.text,
      "date_of_birth": _dobController.text,
      "age": int.tryParse(_ageController.text) ?? 19,
      "height": double.tryParse(_heightController.text) ?? 175,
      "weight": double.tryParse(_weightController.text) ?? 65,
      "physical_index": double.tryParse(_physicalIndexController.text) ?? 22.5,
      "club_affiliation": _clubAffiliationController.text,
      "father_name": _fatherNameController.text,
      "mother_name": _motherNameController.text,
      "emergency_contact": int.tryParse(_emergencyContactController.text) ?? 0,
      "country_id": _selectedCountryId,
      "state_id": _selectedStateId,
      "district_id": _selectedDistrictId,
      "city_id": _selectedCityId,
      "pincode": int.tryParse(_pincodeController.text) ?? 0,
      "address": _addressController.text,
      "aadhar_number": _aadharController.text,
      "email": _emailController.text,
      "contact_number": _contactController.text,
      "is_fee_paid": false,
      "student_profile_image": _imageBase64,
      "profile_image_cont_type": _imageContentType,
      "StudentDocuments": [
        if (_identityDocBase64 != null)
          {
            "doc_id": 0,
            "is_active": true,
            "uuid": null,
            "doc_file_name": _identityDocBase64,
            "doc_content_type": _identityDocExtension == 'pdf'
                ? "application/pdf"
                : "image/jpeg",
            "doc_type": null,
            "document_type_id": _selectedIdentityDocId,
            "document_type_name": _selectedIdentityDocName,
            "document_number": _identityDocNumberController.text,
            "doc_file_ext": _identityDocExtension,
          },
        if (_beltDocBase64 != null)
          {
            "doc_id": 0,
            "is_active": true,
            "uuid": null,
            "doc_file_name": _beltDocBase64,
            "doc_content_type": _beltDocExtension == 'pdf'
                ? "application/pdf"
                : "image/jpeg",
            "doc_type": null,
            "document_type_id": _selectedBeltDocId,
            "document_type_name": _selectedBeltDocName,
            "document_number": _beltDocNumberController.text,
            "doc_file_ext": _beltDocExtension,
          },
        if (_medicalDocBase64 != null)
          {
            "doc_id": 0,
            "is_active": true,
            "uuid": null,
            "doc_file_name": _medicalDocBase64,
            "doc_content_type": _medicalDocExtension == 'pdf'
                ? "application/pdf"
                : "image/jpeg",
            "doc_type": null,
            "document_type_id": _medicalDocId,
            "document_type_name": _medicalDocName,
            "document_number": _medicalDocNumberController.text,
            "doc_file_ext": _medicalDocExtension,
          },
        if (_otherDocBase64 != null)
          {
            "doc_id": 0,
            "is_active": true,
            "uuid": null,
            "doc_file_name": _otherDocBase64,
            "doc_content_type": _otherDocExtension == 'pdf'
                ? "application/pdf"
                : "image/jpeg",
            "doc_type": null,
            "document_type_id": _selectedOtherDocId,
            "document_type_name": _selectedOtherDocName,
            "document_number": _otherDocNumberController.text,
            "doc_file_ext": _otherDocExtension,
          },
      ],
      "application_status": "PENDING",
      "SopApprovalStep": 1,
      "IsApproval": false,
      "country_name": _selectedCountryName,
      "state_name": _selectedStateName,
      "district_name": _selectedDistrictName,
      "city_name": _selectedCityName,
      "platform_id": 2,
    };

    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );
    final response = await studentProvider.createStudent(studentData);

    if (response != null && response['Table'] != null) {
      // Send the enriched student data (with S3 URLs, UUID, etc.) to Kudo
      await studentProvider.createStudentKudo(response['Table']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration completed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              studentProvider.errorMessage ?? 'Registration failed',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.fieldBg,
        body: SafeArea(
          bottom: true,
          top: false,
          child: Column(
            children: [
              _buildHeader(),
              _buildCustomStepper(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentStep = index);
                  },
                  children: [
                    _buildStep(
                      formKey: _formKeys[0],
                      fields: [
                        _buildHeadshotUpload(),
                        const SizedBox(height: 32),
                        _buildSectionHeader(
                          Icons.person_outline,
                          'BASIC DETAILS',
                        ),
                        const SizedBox(height: 24),
                        _buildFieldLabelWrapper(
                          'FULL NAME',
                          _buildModernTextField(
                            _fullNameController,
                            'Full Name',
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabelWrapper(
                          'GENDER',
                          _buildModernRadioGroup(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildFieldLabelWrapper(
                                'DATE OF BIRTH',
                                _buildModernDateField(
                                  _dobController,
                                  'dd-mm-yyyy',
                                ),
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: _buildFieldLabelWrapper(
                                'AGE',
                                Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    _buildModernTextField(
                                      _ageController,
                                      '14',
                                      keyboardType: TextInputType.number,
                                      readOnly: true,
                                      validator: (v) =>
                                          _ageController.text.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Text(
                                        'YRS',
                                        style: TextStyle(
                                          color: AppColors.textDisabled,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                isRequired: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabelWrapper(
                          'AADHAR NUMBER',
                          _buildModernTextField(
                            _aadharController,
                            '0000-0000-0000',
                            icon: Icons.credit_card_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                              _AadharFormatter(),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v.replaceAll('-', '').length < 12) {
                                return 'Enter 12 digits';
                              }
                              return null;
                            },
                          ),
                          isRequired: true,
                        ),
                      ],
                    ),
                    _buildStep(
                      formKey: _formKeys[1],
                      fields: [
                        _buildSectionHeader(
                          Icons.contact_mail_outlined,
                          'CONTACT',
                        ),
                        const SizedBox(height: 24),
                        _buildFieldLabelWrapper(
                          'EMAIL ADDRESS',
                          _buildModernTextField(
                            _emailController,
                            'example@domain.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(v)) {
                                return 'Enter valid email';
                              }
                              return null;
                            },
                          ),
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabelWrapper(
                          'MOBILE NUMBER',
                          _buildModernTextField(
                            _contactController,
                            '9876543210',
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v.length < 10) return 'Enter 10 digits';
                              if (!RegExp(r'^[6-9]').hasMatch(v)) {
                                return 'Enter valid mobile no';
                              }
                              return null;
                            },
                          ),
                          isRequired: true,
                        ),
                        const SizedBox(height: 32),
                        _buildSectionHeader(
                          Icons.location_on_outlined,
                          'ADDRESS',
                        ),
                        const SizedBox(height: 24),
                        Consumer<StudentProvider>(
                          builder: (context, provider, child) {
                            return _buildFieldLabelWrapper(
                              'COUNTRY',
                              _buildModernDropdown<int>(
                                value: _selectedCountryId,
                                options: provider.countries
                                    .map((c) => c.id)
                                    .toList(),
                                getTitle: (id) => provider.countries
                                    .firstWhere((c) => c.id == id)
                                    .name,
                                validator: (v) => v == null ? 'Required' : null,
                                onChanged: (val) {
                                  setState(() {
                                    _selectedCountryId = val;
                                    _selectedCountryName = provider.countries
                                        .firstWhere((c) => c.id == val)
                                        .name;
                                    _selectedStateId = null;
                                    _selectedDistrictId = null;
                                    _selectedCityId = null;
                                  });
                                  provider.fetchStates(val!);
                                },
                                hint: 'Select Country',
                              ),
                              isRequired: true,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Consumer<StudentProvider>(
                          builder: (context, provider, child) {
                            return _buildFieldLabelWrapper(
                              'STATE',
                              _buildModernDropdown<int>(
                                value: _selectedStateId,
                                options: provider.states
                                    .map((s) => s.id)
                                    .toList(),
                                getTitle: (id) => provider.states
                                    .firstWhere((s) => s.id == id)
                                    .name,
                                validator: (v) => v == null ? 'Required' : null,
                                onChanged: (val) {
                                  setState(() {
                                    _selectedStateId = val;
                                    _selectedStateName = provider.states
                                        .firstWhere((s) => s.id == val)
                                        .name;
                                    _selectedDistrictId = null;
                                    _selectedCityId = null;
                                  });
                                  provider.fetchDistricts(val!);
                                },
                                hint: 'Select State',
                              ),
                              isRequired: true,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Consumer<StudentProvider>(
                                builder: (context, provider, child) {
                                  return _buildFieldLabelWrapper(
                                    'DISTRICT',
                                    _buildModernDropdown<int>(
                                      value: _selectedDistrictId,
                                      options: provider.districts
                                          .map((d) => d.id)
                                          .toList(),
                                      getTitle: (id) => provider.districts
                                          .firstWhere((d) => d.id == id)
                                          .name,
                                      validator: (v) =>
                                          v == null ? 'Required' : null,
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedDistrictId = val;
                                          _selectedDistrictName = provider
                                              .districts
                                              .firstWhere((d) => d.id == val)
                                              .name;
                                          _selectedCityId = null;
                                        });
                                        provider.fetchCities(val!);
                                      },
                                      hint: 'Select District',
                                    ),
                                    isRequired: true,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Consumer<StudentProvider>(
                                builder: (context, provider, child) {
                                  return _buildFieldLabelWrapper(
                                    'CITY',
                                    _buildModernDropdown<int>(
                                      value: _selectedCityId,
                                      options: provider.cities
                                          .map((c) => c.id)
                                          .toList(),
                                      getTitle: (id) => provider.cities
                                          .firstWhere((c) => c.id == id)
                                          .name,
                                      validator: (v) =>
                                          v == null ? 'Required' : null,
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedCityId = val;
                                          _selectedCityName = provider.cities
                                              .firstWhere((c) => c.id == val)
                                              .name;
                                        });
                                      },
                                      hint: 'Select City',
                                    ),
                                    isRequired: true,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabelWrapper(
                          'PINCODE',
                          _buildModernTextField(
                            _pincodeController,
                            '000000',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v.length < 6) return 'Enter 6 digits';
                              return null;
                            },
                          ),
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabelWrapper(
                          'RESIDENTIAL ADDRESS',
                          _buildModernTextField(
                            _addressController,
                            'Street name, Area, House no.',
                            maxLines: 2,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                          isRequired: true,
                        ),
                      ],
                    ),
                    _buildStep(
                      formKey: _formKeys[2],
                      fields: [
                        _buildSectionHeader(Icons.people_outline, 'PARENTS'),
                        const SizedBox(height: 24),
                        _buildFieldLabelWrapper(
                          "FATHER'S NAME",
                          _buildModernTextField(
                            _fatherNameController,
                            'Full Name',
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabelWrapper(
                          "MOTHER'S NAME",
                          _buildModernTextField(
                            _motherNameController,
                            'Full Name',
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabelWrapper(
                          'EMERGENCY CONTACT',
                          _buildModernTextField(
                            _emergencyContactController,
                            '9876543210',
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v.length < 10) return 'Enter 10 digits';
                              if (!RegExp(r'^[6-9]').hasMatch(v)) {
                                return 'Enter valid mobile no';
                              }
                              return null;
                            },
                          ),
                          isRequired: true,
                        ),
                      ],
                    ),
                    _buildStep(
                      formKey: _formKeys[3],
                      fields: [
                        _buildSectionHeader(Icons.straighten, 'MEASUREMENTS'),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFieldLabelWrapper(
                                'HEIGHT (CM)',
                                _buildModernTextField(
                                  _heightController,
                                  '170',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFieldLabelWrapper(
                                'WEIGHT (KG)',
                                _buildModernTextField(
                                  _weightController,
                                  '65',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                isRequired: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabelWrapper(
                          'PHYSICAL INDEX',
                          _buildModernTextField(
                            _physicalIndexController,
                            '0.00',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) {
                                return 'Enter valid decimal';
                              }
                              return null;
                            },
                          ),
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabelWrapper(
                          'CLUB AFFILIATION',
                          _buildModernTextField(
                            _clubAffiliationController,
                            'Club Name',
                          ),
                        ),
                      ],
                    ),
                    _buildStep(
                      formKey: _formKeys[4],
                      fields: [
                        _buildSectionHeader(
                          Icons.description_outlined,
                          'DOCUMENTS',
                          showDot: false,
                        ),
                        const SizedBox(height: 32),
                        _buildModernDocumentCard(
                          title: 'IDENTITY DOCUMENT',
                          type: 'identity',
                        ),
                        const SizedBox(height: 16),
                        _buildModernDocumentCard(
                          title: 'BELT CERTIFICATE',
                          type: 'belt',
                        ),
                        const SizedBox(height: 16),
                        _buildModernDocumentCard(
                          title: 'MEDICAL CERTIFICATE',
                          type: 'medical',
                        ),
                        const SizedBox(height: 16),
                        _buildModernDocumentCard(
                          title: 'OTHER DOCUMENTS',
                          type: 'other',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildModernFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.darkBg,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkBg, AppColors.deepAccent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                children: [
                  InkWell(
                    onTap: _previousStep,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.textPrimary.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      const SizedBox(height: 4),
                      const Text(
                        'Athlete Enrollment',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  InkWell(
                    onTap: _fillDemoData,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primaryAccent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_fix_high,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  //const Spacer(),
                ],
              ),
            ),
            Stack(
              children: [
                Container(
                  height: 1.5,
                  width: double.infinity,
                  color: AppColors.textPrimary.withOpacity(0.08),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 1.5,
                  width:
                      MediaQuery.of(context).size.width *
                      ((_currentStep + 1) / _totalSteps),
                  color: AppColors.primaryAccent,
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              width: double.infinity,
              color: AppColors.darkBg.withOpacity(0.15),
              child: Row(
                children: [
                  Text(
                    '›  ${_getStepName(_currentStep)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        'NEXT',
                        style: TextStyle(
                          color: AppColors.textPrimary.withOpacity(0.56),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStepName(_currentStep + 1),
                        style: TextStyle(
                          color: AppColors.textPrimary.withOpacity(0.55),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepName(int index) {
    if (index >= _totalSteps) return "FINISH";
    final names = [
      "IDENTITY",
      "CONTACT DETAILS",
      "FAMILY DETAILS",
      "PHYSICAL",
      "DOCUMENTS",
    ];
    return names[index];
  }

  Widget _buildCustomStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
      decoration: const BoxDecoration(
        color: AppColors.textPrimary,
        border: Border(
          bottom: BorderSide(color: AppColors.fieldBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_totalSteps, (index) {
          bool isActive = index == _currentStep;
          bool isCompleted = index < _currentStep;

          return Expanded(
            child: InkWell(
              onTap: () {
                // If trying to go forward, validate the current form step first
                if (index > _currentStep) {
                  if (!_formKeys[_currentStep].currentState!.validate()) {
                    return;
                  }
                }

                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.secondaryAccent.withOpacity(0.8)
                          : (isCompleted
                                ? AppColors.deepAccent
                                : AppColors.textPrimary),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive || isCompleted
                            ? AppColors.darkBg.withOpacity(0.3)
                            : AppColors.fieldBorder,
                        width: 1.5,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.secondaryAccent.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '0${index + 1}',
                        style: TextStyle(
                          color: isActive || isCompleted
                              ? AppColors.textPrimary
                              : AppColors.textDisabled,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  if (index < _totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: 1.5,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: isCompleted
                            ? AppColors.darkBg
                            : AppColors.fieldBorder,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep({
    required List<Widget> fields,
    required GlobalKey<FormState> formKey,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...fields, const SizedBox(height: 40)],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    IconData icon,
    String title, {
    bool showDot = true,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: AppColors.deepAccent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppColors.deepAccent,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: AppColors.fieldBorder)),
        if (showDot) ...[
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.deepAccent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeadshotUpload() {
    return FormField<Uint8List?>(
      initialValue: _pickedImageBytes,
      validator: (val) => val == null ? 'Profile image is required' : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.darkBg, AppColors.deepAccent],
                    ),
                    border: state.hasError
                        ? Border.all(color: AppColors.error, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkBg.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -40,
                        top: 10,
                        child: Icon(
                          Icons.person,
                          size: 150,
                          color: AppColors.textPrimary.withOpacity(0.03),
                        ),
                      ),
                      if (_pickedImageBytes != null)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _pickedImageBytes = null;
                                _imageBase64 = null;
                              });
                              state.didChange(null);
                              state.validate();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.textPrimary,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () async {
                                await _pickImage();
                                state.didChange(_pickedImageBytes);
                                state.validate();
                              },
                              borderRadius: BorderRadius.circular(40),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.textPrimary
                                            .withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: _pickedImageBytes != null
                                          ? Image.memory(
                                              _pickedImageBytes!,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              Icons.person,
                                              color: AppColors.deepAccent,
                                              size: 40,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.surfaceDark,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.secondaryAccent
                                                .withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PROFILE IMAGE',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _pickedImageBytes != null
                                        ? 'Image selected successfully'
                                        : 'Upload a clear profile photo',
                                    style: TextStyle(
                                      color: AppColors.textPrimary.withOpacity(
                                        0.5,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'JPG / PNG · Max 2MB',
                                    style: TextStyle(
                                      color: AppColors.textPrimary.withOpacity(
                                        0.5,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.hasError)
                  Positioned(
                    top: -8,
                    right: 16,
                    child: _buildRequiredBadge(state.errorText),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFieldLabelWrapper(
    String label,
    Widget field, {
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.deepAccent.withOpacity(0.8),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  Widget _buildRequiredBadge([String? text]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        (text ?? 'REQUIRED').toUpperCase(),
        style: const TextStyle(
          color: AppColors.error,
          fontSize: 7,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    TextEditingController controller,
    String hint, {
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      builder: (state) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              readOnly: readOnly,
              inputFormatters: inputFormatters,
              onChanged: (val) {
                state.didChange(val);
                if (state.hasError) state.validate();
              },
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.textGrey.withOpacity(0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: icon != null
                    ? Icon(icon, color: AppColors.deepAccent, size: 18)
                    : null,
                filled: true,
                fillColor: AppColors.fieldBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: state.hasError
                        ? AppColors.error
                        : AppColors.fieldBorder,
                    width: state.hasError ? 2 : 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: state.hasError
                        ? AppColors.error
                        : AppColors.fieldBorder,
                    width: state.hasError ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.secondaryAccent,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
            ),
            if (state.hasError)
              Positioned(
                top: -8,
                right: 16,
                child: _buildRequiredBadge(state.errorText),
              ),
          ],
        );
      },
    );
  }

  Widget _buildModernRadioGroup() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: _genders.map((gender) {
          final isSelected = _selectedGender == gender;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedGender = gender),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondaryAccent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.secondaryAccent.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    gender.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModernDateField(TextEditingController controller, String hint) {
    return FormField<String>(
      initialValue: controller.text,
      validator: (v) => controller.text.isEmpty ? 'Required' : null,
      builder: (state) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            TextFormField(
              controller: controller,
              readOnly: true,
              onTap: () async {
                DateTime initialDate = DateTime.now();
                if (controller.text.isNotEmpty) {
                  initialDate =
                      DateTime.tryParse(controller.text) ?? DateTime.now();
                }

                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.deepAccent,
                          onPrimary: Colors.white,
                          onSurface: AppColors.deepAccent,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null) {
                  setState(() {
                    controller.text = pickedDate.toString().split(' ')[0];
                    final age = DateTime.now().year - pickedDate.year;
                    _ageController.text = age.toString();
                  });
                  state.didChange(controller.text);
                  state.validate();

                  // Auto-validate current form step to clear error on auto-filled age field
                  _formKeys[_currentStep].currentState?.validate();
                }
              },
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.textGrey.withOpacity(0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                suffixIcon: Icon(
                  Icons.calendar_month,
                  color: AppColors.deepAccent,
                  size: 18,
                ),
                filled: true,
                fillColor: AppColors.fieldBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: state.hasError
                        ? AppColors.error
                        : AppColors.fieldBorder,
                    width: state.hasError ? 2 : 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: state.hasError
                        ? AppColors.error
                        : AppColors.fieldBorder,
                    width: state.hasError ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primaryAccent,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
            ),
            if (state.hasError)
              Positioned(
                top: -8,
                right: 16,
                child: _buildRequiredBadge(state.errorText),
              ),
          ],
        );
      },
    );
  }

  Widget _buildModernDropdown<T>({
    required T? value,
    required List<T> options,
    required String Function(T) getTitle,
    required ValueChanged<T?> onChanged,
    String? hint,
    String? Function(T?)? validator,
  }) {
    return FormField<T>(
      validator: validator,
      initialValue: value,
      builder: (state) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            DropdownButtonFormField<T>(
              value: value,
              dropdownColor: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(16),
              itemHeight: 55,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textGrey,
              ),
              hint: hint != null
                  ? Text(
                      hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textGrey.withOpacity(0.4),
                        fontSize: 14,
                      ),
                    )
                  : null,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.fieldBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: state.hasError
                        ? AppColors.error
                        : AppColors.fieldBorder,
                    width: state.hasError ? 2 : 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: state.hasError
                        ? AppColors.error
                        : AppColors.fieldBorder,
                    width: state.hasError ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primaryAccent,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                errorStyle: const TextStyle(height: 00, fontSize: 0),
              ),
              onChanged: (val) {
                state.didChange(val);
                onChanged(val);
                if (state.hasError) state.validate();
              },
              selectedItemBuilder: (context) {
                return options.map((opt) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      getTitle(opt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList();
              },
              items: options.map((opt) {
                final isSelected = opt == value;
                return DropdownMenuItem<T>(
                  value: opt,
                  alignment: Alignment.center,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.secondaryAccent
                          : AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      getTitle(opt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (state.hasError)
              Positioned(
                top: -8,
                right: 36,
                child: _buildRequiredBadge(state.errorText),
              ),
          ],
        );
      },
    );
  }

  Widget _buildModernDocumentCard({
    required String title,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppColors.deepAccent,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (type == 'identity')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'REQUIRED',
                    style: TextStyle(
                      color: AppColors.secondaryAccent,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Consumer<StudentProvider>(
            builder: (context, provider, child) {
              List<RequiredDocument> docs = [];
              if (type == 'identity') {
                docs = provider.requiredDocuments
                    .where((d) => d.isActive && d.isIdentityDoc)
                    .toList();
              } else if (type == 'belt') {
                docs = provider.requiredDocuments.where((d) {
                  if (!d.isActive || d.isIdentityDoc) return false;
                  final parts = d.name.split(' ');
                  // "White Belt Certificate" -> ["White", "Belt", "Certificate"]
                  // We check if "Belt" or "belt" is in the middle (not first, not last)
                  if (parts.length > 2) {
                    for (int i = 1; i < parts.length - 1; i++) {
                      if (parts[i].toLowerCase() == 'belt') return true;
                    }
                  }
                  return false;
                }).toList();
              } else if (type == 'medical') {
                // Find the medical certificate doc from the list
                final medicalDocs = provider.requiredDocuments.where((d) {
                  return d.isActive &&
                      !d.isIdentityDoc &&
                      d.name.toLowerCase().startsWith('medical');
                }).toList();
                final medicalDoc = medicalDocs.isNotEmpty
                    ? medicalDocs.first
                    : null;

                if (medicalDoc != null) {
                  final mId = medicalDoc.id;
                  final mName = medicalDoc.name;
                  // We don't show a dropdown for medical, we just set the ID
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_medicalDocId != mId) {
                      setState(() {
                        _medicalDocId = mId;
                        _medicalDocName = mName;
                      });
                    }
                  });
                  // User requested to hide this field
                  return const SizedBox.shrink();
                } else {
                  return const SizedBox.shrink();
                }
              } else if (type == 'other') {
                // Find the other document doc from the list
                final otherDocs = provider.requiredDocuments.where((d) {
                  return d.isActive &&
                      !d.isIdentityDoc &&
                      !d.name.toLowerCase().startsWith('medical') &&
                      !d.name.toLowerCase().contains('belt');
                }).toList();
                final otherDoc = otherDocs.isNotEmpty ? otherDocs.first : null;

                if (otherDoc != null) {
                  final oId = otherDoc.id;
                  final oName = otherDoc.name;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_selectedOtherDocId != oId) {
                      setState(() {
                        _selectedOtherDocId = oId;
                        _selectedOtherDocName = oName;
                      });
                    }
                  });
                  // User requested to hide this field
                  return const SizedBox.shrink();
                } else {
                  return const SizedBox.shrink();
                }
              }

              if (type == 'medical' || type == 'other') {
                return const SizedBox.shrink();
              }

              return _buildFieldLabelWrapper(
                'TYPE',
                _buildModernDropdown<int>(
                  value: type == 'identity'
                      ? _selectedIdentityDocId
                      : (type == 'belt'
                            ? _selectedBeltDocId
                            : _selectedOtherDocId),
                  options: docs.map((d) => d.id).toList(),
                  getTitle: (id) => docs.firstWhere((d) => d.id == id).name,
                  validator: type == 'identity'
                      ? (v) => v == null ? 'Required' : null
                      : null,
                  onChanged: (val) {
                    if (val == null) return;
                    final int selectedId = val;
                    setState(() {
                      RequiredDocument? foundDoc;
                      for (var d in docs) {
                        if (d.id == selectedId) {
                          foundDoc = d;
                          break;
                        }
                      }

                      if (type == 'identity') {
                        _selectedIdentityDocId = selectedId;
                        if (foundDoc != null) {
                          _selectedIdentityDocName = foundDoc.name;
                          if (foundDoc.name.toLowerCase().contains('aadhar')) {
                            _identityDocNumberController.text =
                                _aadharController.text;
                          } else {
                            _identityDocNumberController.clear();
                          }
                        }
                      } else if (type == 'belt') {
                        _selectedBeltDocId = selectedId;
                        if (foundDoc != null) {
                          _selectedBeltDocName = foundDoc.name;
                        }
                      } else if (type == 'other') {
                        _selectedOtherDocId = selectedId;
                        if (foundDoc != null) {
                          _selectedOtherDocName = foundDoc.name;
                        }
                      }
                    });
                  },
                  hint: 'Select',
                ),
                isRequired: type == 'identity',
              );
            },
          ),
          if (type != 'medical' && type != 'other') const SizedBox(height: 16),
          _buildFieldLabelWrapper(
            'DOCUMENT NUMBER',
            _buildModernTextField(
              type == 'identity'
                  ? _identityDocNumberController
                  : (type == 'belt'
                        ? _beltDocNumberController
                        : (type == 'medical'
                              ? _medicalDocNumberController
                              : _otherDocNumberController)),
              'e.g. ABC1234567',
              validator: type == 'identity'
                  ? (v) => v == null || v.isEmpty ? 'Required' : null
                  : null,
            ),
            isRequired: type == 'identity',
          ),
          const SizedBox(height: 20),
          _buildModernUploadArea(type),
        ],
      ),
    );
  }

  Widget _buildModernUploadArea(String type) {
    bool hasFile = false;
    String? fileName;

    if (type == 'identity') {
      hasFile = _identityDocBytes != null;
      fileName = _identityDocFileName;
    } else if (type == 'belt') {
      hasFile = _beltDocBytes != null;
      fileName = _beltDocFileName;
    } else if (type == 'medical') {
      hasFile = _medicalDocBytes != null;
      fileName = _medicalDocFileName;
    } else if (type == 'other') {
      hasFile = _otherDocBytes != null;
      fileName = _otherDocFileName;
    }

    return Stack(
      children: [
        InkWell(
          onTap: () => _pickDocument(type),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasFile
                    ? AppColors.secondaryAccent
                    : AppColors.deepAccent,
                style: BorderStyle.solid,
                width: hasFile ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.deepAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (hasFile
                                    ? AppColors.secondaryAccent
                                    : AppColors.deepAccent)
                                .withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    hasFile ? Icons.check : Icons.upload_file,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  hasFile ? fileName! : 'UPLOAD IMAGE / PDF',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: hasFile
                        ? AppColors.secondaryAccent
                        : AppColors.deepAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                if (!hasFile) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Max size 2MB',
                    style: TextStyle(
                      color: AppColors.deepAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasFile)
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (type == 'identity') {
                    _identityDocBytes = null;
                    _identityDocFileName = null;
                    _identityDocBase64 = null;
                    _identityDocExtension = null;
                  } else if (type == 'belt') {
                    _beltDocBytes = null;
                    _beltDocFileName = null;
                    _beltDocBase64 = null;
                    _beltDocExtension = null;
                  } else if (type == 'medical') {
                    _medicalDocBytes = null;
                    _medicalDocFileName = null;
                    _medicalDocBase64 = null;
                    _medicalDocExtension = null;
                  } else if (type == 'other') {
                    _otherDocBytes = null;
                    _otherDocFileName = null;
                    _otherDocBase64 = null;
                    _otherDocExtension = null;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.deepAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: AppColors.textPrimary,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernFooter() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        border: Border(
          top: BorderSide(color: AppColors.fieldBorder.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'STEP 0${_currentStep + 1} / 05',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deepAccent,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStepName(_currentStep),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepAccent,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<StudentProvider>(
            builder: (context, provider, child) {
              return Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [AppColors.darkBg, AppColors.deepAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepAccent.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.textPrimary,
                            strokeWidth: 3,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentStep == _totalSteps - 1
                                  ? 'SUBMIT'
                                  : 'CONTINUE',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.arrow_forward,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickDocument(String type) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (file != null) {
      final bytes = await file.readAsBytes();
      final String extension = file.name.split('.').last.toLowerCase();
      final String base64Data = base64Encode(bytes);
      final String contentType = extension == 'pdf'
          ? 'application/pdf'
          : 'image/jpeg';

      setState(() {
        if (type == 'identity') {
          _identityDocBytes = bytes;
          _identityDocFileName = file.name;
          _identityDocBase64 = "data:$contentType;base64,$base64Data";
          _identityDocExtension = extension;
        } else if (type == 'belt') {
          _beltDocBytes = bytes;
          _beltDocFileName = file.name;
          _beltDocBase64 = "data:$contentType;base64,$base64Data";
          _beltDocExtension = extension;
        } else if (type == 'medical') {
          _medicalDocBytes = bytes;
          _medicalDocFileName = file.name;
          _medicalDocBase64 = "data:$contentType;base64,$base64Data";
          _medicalDocExtension = extension;
        } else if (type == 'other') {
          _otherDocBytes = bytes;
          _otherDocFileName = file.name;
          _otherDocBase64 = "data:$contentType;base64,$base64Data";
          _otherDocExtension = extension;
        }
      });
    }
  }
}

class _AadharFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('-');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
