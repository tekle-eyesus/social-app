import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/theme/app_colors.dart';
import 'package:socialapp/widget/signup.dart';

class UserProfileScreen extends StatefulWidget {
  final String userEmail;
  const UserProfileScreen({super.key, required this.userEmail});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.userEmail),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                  clipBehavior: Clip.hardEdge,
                  width: 130,
                  height: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.network(
                    "https://img.freepik.com/premium-photo/cat-city_1001743-985.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 2),
                  // color: Colors.purple,
                  height: 200,
                  width: 220,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tekle",
                            style: TextStyle(
                              fontFamily: 'teko',
                              fontSize: 40,
                            ),
                          ),
                          Text(
                            "Software Engineer",
                            style: TextStyle(
                              fontSize: 22,
                              fontFamily: 'roboto',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Color.fromARGB(255, 183, 172, 133),
                            ),
                            child: Icon(
                              Icons.email,
                              color: Colors.amber,
                              size: 35,
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Color.fromARGB(255, 155, 100, 76),
                            ),
                            child: Icon(
                              Icons.call,
                              color: Colors.red,
                              size: 35,
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color.fromARGB(255, 151, 151, 150),
                            ),
                            child: Icon(
                              Icons.video_call,
                              color: Colors.black,
                              size: 35,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    top: 20,
                  ),
                  child: Text(
                    "About",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontFamily: 'poppins',
                        ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                  "The [overflow] property's behavior is affected by the [softWrap] argument. If the [softWrap] is true or null, the glyph causing overflow, and those that follow, will not be rendered. Otherwise,"),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    top: 20,
                  ),
                  child: Text(
                    "Posts",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontFamily: 'poppins',
                        ),
                  ),
                ),
              ],
            ),
            Container(
              height: 230,
              width: double.infinity,
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
            )
          ],
        ),
      ),
    );
  }
}
