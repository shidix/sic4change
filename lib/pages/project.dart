class SProject {
  final String name;
  final String description;

  SProject(this.name, this.description);

  SProject.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'];

  Map<String, String> toJson() => {
        'name': name,
        'description': description,
      };
}
