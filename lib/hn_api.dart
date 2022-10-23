
class Story {
  String title;
  String id;
  int rating;
  int postDate;

  Story({required this.title, required this.id, 
    required this.rating, required this.postDate});
}

List<Story> getStories(int startDate, int endDate){
  List<Story> stories = [];
  stories.add(Story(title: "Test 1", id: "1234", 
    rating: 100, postDate: 100000));
  stories.add(Story(title: "Test 2", id: "5678", 
    rating: 200, postDate: 100000));
  return stories;
}