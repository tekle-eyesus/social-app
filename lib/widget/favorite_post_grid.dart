import 'package:flutter/material.dart';
import 'package:socialapp/widget/full_screen_image.dart';

class FavoriteGridView extends StatelessWidget {
  const FavoriteGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey.shade300,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Placeholder image logic
              InkWell(
                onTap: () {
                  // full screen image view ( for now)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return FullScreenImage(
                        tag: "$index",
                        imageFile: "https://picsum.photos/500?random=$index",
                      );
                    }),
                  );
                },
                // random images from picsum for demo purposes
                child: Image.network(
                  "https://picsum.photos/200?random=$index",
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, color: Colors.white),
                  ),
                ),
              ),
              // Overlay icon
              const Align(
                alignment: Alignment.center,
                child: Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 30),
              )
            ],
          ),
        );
      },
    );
  }
}
