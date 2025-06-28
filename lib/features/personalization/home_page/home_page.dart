import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Messenger dark mode colors
    const bgColor = Color(0xFF10131A);
    // Use the same color for both background and app bar
    const appBarColor = bgColor;
    const accentBlue = Color(0xFF0084FF);
    const unreadBg = Color(0xFF0084FF);
    const onlineDot = Color(0xFF4BCB1F);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0.5,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 18.0),
          child: Text(
            'Chat Engine',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.2,
              fontFamily: 'Open Sans',
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Simple, smooth, responsive search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.09),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 16, fontFamily: 'Open Sans'),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Open Sans'),
                cursorColor: Colors.white54,
              ),
            ),
          ),
          // Stories row
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 8),
            child: SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, i) => Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [accentBlue, Colors.purpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundImage: const AssetImage('assets/images/profile.jpeg'),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      i == 0 ? 'You' : 'User $i',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Open Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Chat list
          Expanded(
            child: ListView.separated(
              itemCount: 10,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (context, i) => Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: appBarColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: const AssetImage('assets/images/profile.jpeg'),
                      ),
                      if (i % 2 == 0)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: onlineDot,
                              shape: BoxShape.circle,
                              border: Border.all(color: appBarColor, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Contact ${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            fontFamily: 'Open Sans',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '12:${i}0',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontFamily: 'Open Sans',
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Last message preview goes here...',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 15,
                            fontFamily: 'Open Sans',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (i % 3 == 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: unreadBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Open Sans',
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {},
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  horizontalTitleGap: 12,
                  minVerticalPadding: 0,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentBlue,
        onPressed: () {},
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}