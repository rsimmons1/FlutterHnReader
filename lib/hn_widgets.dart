import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:hn_reader/hn_api.dart';
import 'package:flutter_html/flutter_html.dart';

class StoryHeadline extends StatelessWidget {
  final Story story;
  const StoryHeadline({super.key, required this.story});

  void openLink(String link) async {
    if (!await launchUrl(
      Uri.parse(link),
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $link';
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle headerTextStyle =
        TextStyle(color: Colors.purple[50], fontSize: 16);
    TextStyle bodyTextStyle =
        TextStyle(color: Colors.purple[200], fontSize: 12);

    return Container(
        color: Colors.transparent,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: ListTile(
                minLeadingWidth: 20,
                leading: Text("${story.storyNum}.", style: headerTextStyle),
                title: Row(children: <Widget>[
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                          child: InkWell(
                              onTap: () async {
                                openLink(story.link);
                              },
                              child: Text(
                                story.title,
                                style: headerTextStyle,
                              ))))
                ]),
                subtitle: Row(children: [
                  Text(
                    "${story.score} points by ${story.postUser} | ",
                    style: bodyTextStyle,
                  ),
                  InkWell(
                    child: Text("${story.numComments} comments",
                        style: bodyTextStyle),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CommentsPage(story: story)),
                      );
                    },
                  )
                ]))));
  }
}

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final Function onPressed;
  final bool expanded;
  const CommentWidget(
      {super.key,
      required this.comment,
      required this.onPressed,
      this.expanded = true});

  @override
  Widget build(BuildContext context) {
    TextStyle titleTextStyle =
        TextStyle(color: Colors.purple[200], fontSize: 12);
    TextStyle bodyTextStyle =
        const TextStyle(color: Color.fromARGB(255, 212, 212, 212));
    return ListTile(
        title: Row(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Text(comment.by, style: titleTextStyle)),
          IconButton(
              icon: Icon(Icons.arrow_downward),
              color: Colors.white,
              onPressed: () {
                onPressed();
              })
        ]),
        subtitle: expanded
            ? Html(
                data: comment.text,
                style: {
                  // p tag with text_size
                  "p": Style(
                      color: bodyTextStyle.color,
                      fontFamily: "Verdana",
                      fontSize: const FontSize(16),
                      padding: const EdgeInsets.all(0),
                      margin: const EdgeInsets.all(0)),
                },
              )
            : Container());
  }
}

class CommentTreeStateful extends StatefulWidget {
  final Comment comment;
  final double depth;
  final double maxDepth;
  const CommentTreeStateful(
      {super.key,
      required this.comment,
      required this.depth,
      this.maxDepth = -1});

  @override
  State<CommentTreeStateful> createState() => CommentTreeState();
}

class CommentTreeState extends State<CommentTreeStateful> {
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    {
      int numCommentsRendered =
          expanded ? widget.comment.childComments.length + 1 : 1;
      return Padding(
        padding: EdgeInsets.fromLTRB(10 * widget.depth, 0, 0, 0),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: numCommentsRendered,
          physics: const ClampingScrollPhysics(),
          itemBuilder: ((context, index) {
            if (index == 0) {
              return CommentWidget(
                  comment: widget.comment,
                  expanded: expanded,
                  onPressed: () {
                    setState(() {
                      expanded = !expanded;
                    });
                  });
            } else {
              return CommentTreeStateful(
                  comment: widget.comment.childComments[index - 1],
                  depth: widget.depth + 1);
            }
          }),
        ),
      );
    }
  }
}

// class CommentTree extends StatelessWidget {
//   final Comment comment;
//   final double depth;
//   const CommentTree({super.key, required this.comment, required this.depth});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(10 * depth, 0, 0, 0),
//       child: ListView.builder(
//         shrinkWrap: true,
//         itemCount: comment.childComments.length + 1,
//         physics: const ClampingScrollPhysics(),
//         itemBuilder: ((context, index) {
//           if (index == 0) {
//             return CommentWidget(comment: comment);
//           } else {
//             return CommentTree(
//                 comment: comment.childComments[index - 1], depth: depth + 1);
//           }
//         }),
//       ),
//     );
//   }
// }

class CommentsPage extends StatelessWidget {
  final Story story;
  const CommentsPage({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    // Future<Comment> comment = getComment(story.kids[0]);
    Future<List<Comment>> loadingComments = getCommentsFromAngolia(story.id);

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          backgroundColor: Colors.purple,
          title: const Text("HN Reader"),
        ),
        body: Center(
            child: Column(children: [
          StoryHeadline(
            story: story,
          ),
          FutureBuilder<List<Comment>>(
              future: loadingComments,
              builder: (context, snapshot) {
                var comments = snapshot.data;
                if (snapshot.hasData) {
                  return Flexible(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: comments!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return CommentTreeStateful(
                                comment: comments[index], depth: 0);
                          }));
                } else {
                  return const SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator());
                }
              })
        ])));
  }
}
