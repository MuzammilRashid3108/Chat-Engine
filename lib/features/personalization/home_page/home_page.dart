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
            onPressed: () {
              appController.signOutUser();
            },
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
          SliverToBoxAdapter(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: appController.getAllUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No users found",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final users = snapshot.data!;
                final currentUserId = appController.auth.currentUser?.uid;

                return ListView.separated(
                  padding: const EdgeInsets.only(top: 12),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: Color(0xFF2A2D35),
                    thickness: 0.6,
                    height: 1,
                    indent: 70,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, i) {
                    final user = users[i];
                    if (user['uid'] == currentUserId) return const SizedBox(); // Skip current user

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                      horizontalTitleGap: 12,
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(user['photoUrl'] ?? ''),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                color: Color(0xFF4BCB1F), // onlineDot
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
                              user['name'] ?? 'No Name',
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
                            'Online',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        user['email'] ?? '',
                        style: const TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      onTap: () {
                        appController.goTochatPage(user['uid']);
                      },
                    );
                  },
                );
              },
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
