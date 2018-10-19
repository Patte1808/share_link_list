import 'package:flutter/material.dart';
import 'database/share_provider.dart';

class ContentPreviewCard extends StatelessWidget {
  final Share share;

  ContentPreviewCard(this.share);

  _buildCard() {
    List<Widget> widgets = [];

    if (share.hashtags != null && share.hashtags.length > 0) {
      List<Widget> hashtagLinks = [];
      share.hashtags.forEach((hashtag) {
        hashtagLinks.add(Text("#${hashtag.title}"));
      });

      widgets.add(
        Row(
          children: hashtagLinks,
        ),
      );
    }

    if (share.thumbnailUrl != null) {
      widgets.add(Image.network(
        share.thumbnailUrl,
        width: 50.0,
      ));
    }

    if (share.title != null) {
      widgets.add(Text(share.title));
    }

    if (share.description != null) {
      widgets.add(Text(share.description));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _buildCard(),
        ),
      ),
    );
  }
}
