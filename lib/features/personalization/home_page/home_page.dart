import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF10131A);
    const appBarColor = bgColor;
    const accentBlue = Color(0xFF0084FF);
    const unreadBg = Color(0xFF0084FF);
    const onlineDot = Color(0xFF4BCB1F);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0.8,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 18.0),
          child: Text(
            'Chat Engine',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
              letterSpacing: 0.3,
              fontFamily: 'Open Sans',
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: SizedBox(
              height: 50,
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  hintText: 'Search',
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 16,
                    fontFamily: 'Open Sans',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white38,
              ),
            ),
          ),

          // Stories
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 12),
            child: SizedBox(
              height: 95,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.2), // Outer gradient border width
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFD62976), // Pink
                            Color(0xFFEEA863), // Orange/Yellow
                            Color(0xFF9B2282), // Purple
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2.6), // Inner white ring
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: CircleAvatar(
                          radius: 30, // Profile image
                          backgroundImage:
                          const AssetImage('assets/images/profile.jpeg'),
                        ),
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


          // Chat List
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: 10,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D25),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundImage:
                        AssetImage('assets/images/profile.jpeg'),
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
                              border: Border.all(
                                  color: const Color(0xFF1A1D25), width: 2),
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
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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
                            fontSize: 14,
                            fontFamily: 'Open Sans',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (i % 3 == 0)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
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
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  horizontalTitleGap: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentBlue,
        onPressed: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
