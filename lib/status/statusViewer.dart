import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class StoryViewScreen extends StatelessWidget {
  final List<String> imageUrls;

  const StoryViewScreen({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoryView(
        storyItems: imageUrls
            .map((url) => StoryItem.pageImage(
          url: url,
          controller: StoryController(),
        ))
            .toList(),
        repeat: true, // Set to true if you want the stories to repeat
        controller: StoryController(), // Use a shared controller to control all stories
        inline: true,
        onComplete: () => Navigator.pop(context),
        indicatorHeight: IndicatorHeight.small,// Display progress indicator inline
      ),
    );
  }
}
