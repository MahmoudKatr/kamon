class ActiveEmployeesModel {
  final int employeeId;
  final String employeeName;
  final String employeeDateHired;
  final String employeeStatus;
  final String employeeBranch;
  final String employeeSection;
  final String employeePosition;

  ActiveEmployeesModel({
    required this.employeeId,
    required this.employeeName,
    required this.employeeDateHired,
    required this.employeeStatus,
    required this.employeeBranch,
    required this.employeeSection,
    required this.employeePosition,
  });

  factory ActiveEmployeesModel.fromJson(Map<String, dynamic> jsonData) {
    return ActiveEmployeesModel(
      employeeId: jsonData['employee_id'] as int? ??
          0, // Cast and provide a default int value
      employeeName: jsonData['employee_name'] as String? ??
          '', // Cast and provide a default String value
      employeeDateHired: jsonData['employee_date_hired'] as String? ?? '',
      employeeStatus: jsonData['employee_status'] as String? ?? '',
      employeeBranch: jsonData['employee_branch'] as String? ?? '',
      employeeSection: jsonData['empolyee_section'] as String? ??
          '', // Corrected the key typo
      employeePosition: jsonData['employee_position'] as String? ?? '',
    );
  }
}
