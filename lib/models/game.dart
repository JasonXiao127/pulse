class Game {
  final String id;
  final String title;
  final String exePath;
  final String workingDirectory;
  final String? imagePath; //can be null

  Game({
    required this.id,
    required this.title,
    required this.exePath,
    required this.workingDirectory,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'exePath': exePath,
    'workingDirectory': workingDirectory,
    'imagePath': imagePath,
  };

  factory Game.fromJson(Map<String, dynamic> json) => Game(
    id: json['id'],
    title: json['title'],
    exePath: json['exePath'],
    workingDirectory: json['workingDirectory'],
    imagePath: json['imagePath'],

  );
}