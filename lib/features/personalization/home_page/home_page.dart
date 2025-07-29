import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../utils/controller/app_controller.dart';

class HomePage extends StatelessWidget {
  final appController = Get.put(AppController());

   HomePage({super.key});

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
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: SizedBox(
                height: 45,
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
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white38,
                ),
              ),
            ),
          ),

          // Stories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 25, left: 12),
              child: SizedBox(
                height: 95,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFD62976),
                              Color(0xFFEEA863),
                              Color(0xFF9B2282),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          child: const CircleAvatar(
                            radius: 26,
                            backgroundImage: AssetImage('assets/images/profile.jpeg'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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
          ),

          // Chat List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: 10,
                  (context, i) => Column(
                children: [
                  if (i > 0)
                    const Divider(
                      color: Color(0xFF2A2D35),
                      thickness: 0.6,
                      height: 1,
                      indent: 70,
                      endIndent: 16,
                    ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                    horizontalTitleGap: 12,
                    leading: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundImage: AssetImage('assets/images/profile.jpeg'),
                        ),
                        if (i % 2 == 0)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                color: onlineDot,
                                shape: BoxShape.circle,
                                border: Border.all(color: Color(0xFF1A1D25), width: 1),
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
                            'Active 2h ago',
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
                            height: 10,
                            width: 10,
                            margin: const EdgeInsets.only(left: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: unreadBg,
                              borderRadius: BorderRadius.circular(10),
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
                    onTap: () {
                      appController.goTochatPage();
                    },
                  ),
                ],
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
