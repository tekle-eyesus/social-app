import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostShimmerLoading extends StatelessWidget {
  const PostShimmerLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 67),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Skeleton(height: 45, width: 45, isCircle: true),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(height: 14, width: 120),
                        SizedBox(height: 6),
                        Skeleton(height: 10, width: 80),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),

                Skeleton(height: 14, width: double.infinity),
                SizedBox(height: 8),
                Skeleton(height: 14, width: double.infinity),
                SizedBox(height: 8),
                Skeleton(height: 14, width: 200), // Short last line

                SizedBox(height: 15),

                Skeleton(height: 200, width: double.infinity),

                SizedBox(height: 15),

                //  Footer (Action Buttons)
                Row(
                  children: const [
                    Skeleton(height: 20, width: 20, isCircle: true),
                    SizedBox(width: 40),
                    Skeleton(height: 20, width: 20, isCircle: true),
                    Spacer(),
                    Skeleton(height: 20, width: 20, isCircle: true),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Helper Widget for cleaner code ---
class Skeleton extends StatelessWidget {
  final double height;
  final double width;
  final bool isCircle;

  const Skeleton({
    Key? key,
    required this.height,
    required this.width,
    this.isCircle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius:
            isCircle ? BorderRadius.circular(height) : BorderRadius.circular(4),
      ),
    );
  }
}
