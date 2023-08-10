class DashboardModel {
  late int id;
  late String title;


  DashboardModel({required this.id, required this.title});

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      id: json['id'] as int,
      title: json['title'] as String,
     
    );
  }
}