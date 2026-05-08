class StudentDocument {
  final int docId;
  final String fileName;
  final String contentType;
  final int documentTypeId;
  final String documentTypeName;
  final String documentNumber;
  final String fileExt;

  StudentDocument({
    required this.docId,
    required this.fileName,
    required this.contentType,
    required this.documentTypeId,
    required this.documentTypeName,
    required this.documentNumber,
    required this.fileExt,
  });

  factory StudentDocument.fromJson(Map<String, dynamic> json) {
    return StudentDocument(
      docId: json['doc_id'] ?? 0,
      fileName: json['doc_file_name'] ?? '',
      contentType: json['doc_content_type'] ?? '',
      documentTypeId: json['document_type_id'] ?? 0,
      documentTypeName: json['document_type_name'] ?? '',
      documentNumber: json['document_number'] ?? '',
      fileExt: json['doc_file_ext'] ?? '',
    );
  }
}

class Student {
  final int id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String gender;
  final String dob;
  final int age;
  final String height;
  final String weight;
  final String physicalIndex;
  final String clubAffiliation;
  final String country;
  final String state;
  final String district;
  final String city;
  final String pincode;
  final String address;
  final String aadharNumber;
  final String email;
  final String contactNumber;
  final String studentProfileImage;
  final String fatherName;
  final String motherName;
  final String parentEmail;
  final String emergencyContact;
  final String sopApprovalDate;
  final String createdDate;
  final String uuid;
  final String applicationStatus;
  final List<StudentDocument> documents;

  Student({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.gender,
    required this.dob,
    required this.age,
    required this.height,
    required this.weight,
    required this.physicalIndex,
    required this.clubAffiliation,
    required this.country,
    required this.state,
    required this.district,
    required this.city,
    required this.pincode,
    required this.address,
    required this.aadharNumber,
    required this.email,
    required this.contactNumber,
    required this.studentProfileImage,
    required this.fatherName,
    required this.motherName,
    required this.parentEmail,
    required this.emergencyContact,
    required this.sopApprovalDate,
    required this.createdDate,
    required this.uuid,
    required this.applicationStatus,
    this.documents = const [],
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    var docsList = json['StudentDocuments'] as List? ?? [];
    List<StudentDocument> docs =
        docsList.map((d) => StudentDocument.fromJson(d)).toList();

    return Student(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      age: json['age'] ?? 0,
      height: json['height']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      physicalIndex: json['physical_index']?.toString() ?? '',
      clubAffiliation: json['club_affiliation'] ?? '',
      country: json['country_name'] ?? json['country'] ?? '',
      state: json['state_name'] ?? json['state'] ?? '',
      district: json['district_name'] ?? json['district'] ?? '',
      city: json['city_name'] ?? json['city'] ?? '',
      pincode: json['pincode'] ?? '',
      address: json['address'] ?? '',
      aadharNumber: json['aadhar_number'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      studentProfileImage: (json['student_profile_image'] ?? '').isNotEmpty
          ? '${json['student_profile_image']}?t=${DateTime.now().millisecondsSinceEpoch}'
          : '',
      fatherName: json['father_name'] ?? '',
      motherName: json['mother_name'] ?? '',
      parentEmail: json['parent_email'] ?? '',
      emergencyContact: json['emergency_contact'] ?? '',
      sopApprovalDate: json['SopApprovalDate'] ?? '',
      createdDate: json['createdDate'] ?? '',
      uuid: json['uuid'] ?? '',
      applicationStatus: json['application_status'] ?? '',
      documents: docs,
    );
  }

  String get fullName => '$firstName $lastName';
}
