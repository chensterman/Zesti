// Group class for the app
//  Useful to hold unpackaged requests from the database
class ZestiGroup {
  final String gid;
  final String groupName;
  final String funFact;
  final List<dynamic> groupPhotos;

  ZestiGroup(
      {required this.gid,
      required this.groupName,
      required this.funFact,
      required this.groupPhotos});
}
