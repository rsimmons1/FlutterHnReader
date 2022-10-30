import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:math';

class Comment {
  String by;
  int id;
  List<int> kids;
  int parent;
  String text;
  String time;
  int score;
  List<Comment> childComments = [];

  Comment(
      {required this.by,
      required this.id,
      required this.kids,
      required this.parent,
      required this.text,
      required this.time,
      required this.score});

  factory Comment.fromJson(Map<String, dynamic> jsonData) {
    List<int> kids = [];
    if (jsonData["kids"] != null) {
      kids = List<int>.from(jsonData["kids"].map((e) => e));
    }

    return Comment(
        by: jsonData["by"],
        id: jsonData["id"],
        kids: kids,
        parent: jsonData["parent"],
        text: jsonData["text"],
        time: jsonData["time"].toString(),
        score: 0);
  }

  factory Comment.fromAngoliaJson(Map<String, dynamic> jsonData) {
    List<int> kids = [];
    String by = jsonData["author"] ?? '';
    int id = jsonData["id"] ?? '';
    int parent = jsonData["parent_id"] ?? 0;
    String text = jsonData["text"] ?? '';
    String time = jsonData["created_at"] ?? '';
    // int points = jsonData["points"];
    return Comment(
        by: by,
        id: id,
        kids: kids,
        parent: parent,
        text: text,
        time: time,
        score: 0);
  }
}

// Contains HN story post data.
class Story {
  String title;
  int id;
  int postDate;
  String postUser;
  int score;
  String link;
  int? numComments;
  int? storyNum;
  List<Comment> comments;
  List<int> kids;

  Story(
      {required this.title,
      required this.id,
      required this.postDate,
      required this.postUser,
      required this.score,
      required this.link,
      this.numComments = 0,
      this.storyNum = 0,
      this.comments = const [],
      this.kids = const []});

  factory Story.fromJson(Map<String, dynamic> jsonData) {
    List<int> kids = [];
    if (jsonData["kids"] != null) {
      kids = List<int>.from(
          jsonData["kids"]?.map((e) => int.parse(e.toString())).toList());
    }
    return Story(
        id: jsonData["id"] ?? "",
        title: jsonData["title"] ?? "",
        postDate: jsonData["time"] ?? "",
        link: jsonData["url"] ?? "",
        postUser: jsonData["by"] ?? "",
        numComments: jsonData["descendants"] ?? 0,
        score: jsonData["score"] ?? 0,
        kids: kids);
  }
}

// Returns List of top HN story Ids.
Future<List<String>> getTopStoryIds() async {
  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  var response = await http.get(
      Uri.parse("https://hacker-news.firebaseio.com/v0/topstories.json"),
      headers: requestHeaders);
  List<dynamic> body = [];
  List<String> ids = [];
  try {
    body = jsonDecode(response.body);
    ids = body.map((e) => e.toString()).toList();
  } catch (e) {
    print(e.toString());
  }
  return ids;
}

// Makes Get request to get story with corresponding storyId.
Future<Story> getStory(int storyId) async {
  var response = await http.get(
      Uri.parse("https://hacker-news.firebaseio.com/v0/item/$storyId.json"));
  try {
    return Story.fromJson(jsonDecode(response.body));
  } catch (e, stacktrace) {
    print(e);
    print(stacktrace);
  }
  return Story.fromJson(jsonDecode(response.body));
}

// Retrieve stories from HN API, filtered from startDate to endDate if provided.
Future<List<Story>> getStories(
    {int startDate = -1, int endDate = -1, int storyLimit = -1}) async {
  List<Story> stories = [];
  List<String> topStoryIds = await getTopStoryIds();
  for (int i = 0; i < min(topStoryIds.length, 30); i++) {
    int storyId = int.parse(topStoryIds[i]);
    print("Processing story $i of ${topStoryIds.length}");
    Story story = await getStory(storyId);
    story.storyNum = (i + 1);
    stories.add(story);
  }
  return stories;
}

Future<Comment> getComment(int commentId) async {
  var response = await http.get(
      Uri.parse("https://hacker-news.firebaseio.com/v0/item/$commentId.json"));
  try {
    return Comment.fromJson(jsonDecode(response.body));
  } catch (e) {
    print(e);
  }
  return Comment.fromJson(jsonDecode(response.body));
}

Future<void> retrieveComments(List<Story> stories) async {
  for (int i = 0; i < stories.length; i++) {}
  return;
}

void parseComment(Map<String, dynamic> json, Comment parentComment) {
  List<dynamic> childrenJson = List<dynamic>.from(json["children"]);
  for (int i = 0; i < childrenJson.length; i++) {
    Comment newComment = Comment.fromAngoliaJson(childrenJson[i]);
    if (newComment.by == "") {
      continue;
    }
    parentComment.childComments.add(newComment);
    parseComment(childrenJson[i], newComment);
  }
}

Future<List<Comment>> getCommentsFromAngolia(int storyId) async {
  var response =
      await http.get(Uri.parse("https://hn.algolia.com/api/v1/items/$storyId"));
  var body = jsonDecode(response.body);
  List<dynamic> childrenJson = List<dynamic>.from(body["children"]);
  List<Comment> comments = [];
  for (int i = 0; i < childrenJson.length; i++) {
    Comment newComment = Comment.fromAngoliaJson(childrenJson[i]);
    comments.add(newComment);
    parseComment(childrenJson[i], newComment);
    try {} catch (e) {
      print("Error getting comments");
      print(e);
    }
  }

  return comments;
}
