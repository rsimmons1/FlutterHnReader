import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:math';

// Contains HN story post data.
class Story {
  String title;
  int id;
  int postDate;
  String postUser;
  int score;
  String link;
  int? numComments;

  Story(
      {required this.title,
      required this.id,
      required this.postDate,
      required this.postUser,
      required this.score,
      required this.link,
      this.numComments = 0});

  factory Story.fromJson(Map<String, dynamic> jsonData){
    return Story(
      id: jsonData["id"],
      title: jsonData["title"],
      postDate: jsonData["time"],
      link: jsonData["url"],
      postUser: jsonData["by"],
      numComments: jsonData["descendants"],
      score: jsonData["score"],      
      );

  }
}

Future<List<String>> getTopStoryIds() async{
   Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
  var response =  await http.get(
    Uri.parse("https://hacker-news.firebaseio.com/v0/topstories.json"), headers: requestHeaders);
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

Future<Story> getStory(int storyId) async{
  var response = await http.get(Uri.parse("https://hacker-news.firebaseio.com/v0/item/$storyId.json"));
  return Story.fromJson(jsonDecode(response.body));
}

// Retrieve stories from HN API, filtered from startDate to endDate if provided.
Future<List<Story>> getStories({int startDate = -1, int endDate = -1, int storyLimit = -1}) async{
  List<Story> stories = [];
  List<String> topStoryIds = await getTopStoryIds();
  for(int i = 0; i < min(topStoryIds.length, 30); i++){
    int storyId = int.parse(topStoryIds[i]);
    print("Processing story $i of ${topStoryIds.length}");
    Story story = await getStory(storyId);
    stories.add(story);
  }
  return stories;
}
