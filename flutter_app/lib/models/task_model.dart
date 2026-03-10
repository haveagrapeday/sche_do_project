class TaskModel {
  final String id;
  final String userId;
  final String subject;
  final String appDate;
  final String appTime;
  final String description;
  final String priority;
  final String status;
  final String category;

  TaskModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.appDate,
    required this.appTime,
    required this.description,
    required this.priority,
    required this.status,
    required this.category,
  });

  // แปลงจาก JSON (ที่ได้จาก PHP) มาเป็น Object ในแอป
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'].toString(), // ใช้ .toString() กันเหนียวเผื่อ API ส่งมาเป็นเลข
      userId: json['user_id'].toString(),
      subject: json['subject'] ?? '',
      appDate: json['app_date'] ?? '',
      appTime: json['app_time'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Low',
      status: json['status'] ?? 'Pending',
      category: json['category'] ?? 'General',
    );
  }

  // แปลงจาก Object ในแอป กลับไปเป็น JSON เพื่อส่งไปบันทึกที่ Database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subject': subject,
      'app_date': appDate,
      'app_time': appTime,
      'description': description,
      'priority': priority,
      'status': status,
      'category': category,
    };
  }
}