import 'dart:convert';
import 'dart:io';

import 'package:chat_engine/utils/controller/app_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ChatInputBar extends StatefulWidget {
  final String receiverId;
  final Map<String, dynamic>? replyMessage;
  final VoidCallback? onClearReply;

  const ChatInputBar({super.key, required this.receiverId, this.replyMessage, this.onClearReply});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final appController = Get.find<AppController>();

  File? _selectedImage;
  bool _isUploading = false;

  // Replace these with your Cloudinary credentials
  final String cloudName = 'dqqj1ge7h';
  final String uploadPreset = 'chat_app_unsigned';

  Future<void> _uploadFile(File file, {bool isImage = false}) async {
    try {
      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final data = json.decode(resStr);
        final imageUrl = data['secure_url'];

        debugPrint('✅ Uploaded to Cloudinary: $imageUrl');

        appController.sendMessage(
          receiverId: widget.receiverId,
          messageText: imageUrl,
          type: isImage ? 'image' : 'file',
        );
      } else {
        debugPrint('❌ Cloudinary upload failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    appController.sendMessage(
      receiverId: widget.receiverId,
      messageText: text,
      replyTo: widget.replyMessage, // ✅ Include reply message
    );

    _controller.clear();

    // ✅ Clear reply UI
    if (widget.onClearReply != null) {
      widget.onClearReply!();
    }
  }


  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any);
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      await _uploadFile(file);
    }
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery);

    if (pickedImage == null) return;

    final File file = File(pickedImage.path);

    if (!file.existsSync()) {
      debugPrint('❌ Picked file does not exist');
      return;
    }

    setState(() {
      _selectedImage = file;
      _isUploading = true;
    });

    await _uploadFile(file, isImage: true);

    setState(() {
      _isUploading = false;
      _selectedImage = null;
    });
  }

  void _openCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      File file = File(photo.path);
      if (file.existsSync()) {
        setState(() {
          _selectedImage = file;
          _isUploading = true;
        });

        await _uploadFile(file, isImage: true);

        setState(() {
          _isUploading = false;
          _selectedImage = null;
        });
      }
    }
  }

  String? _replyingToName;

  @override
  void didUpdateWidget(covariant ChatInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.replyMessage != null) {
      _loadReplyUserName(widget.replyMessage!['senderId']);
    }
  }

  Future<void> _loadReplyUserName(String senderId) async {
    if (senderId == FirebaseAuth.instance.currentUser!.uid) {
      setState(() {
        _replyingToName = 'yourself';
      });
      return;
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(senderId).get();
    if (userDoc.exists) {
      setState(() {
        _replyingToName = userDoc.data()?['name'] ?? 'Unknown';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedImage != null)
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (_isUploading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 4,
                    ),
                  ),
                ),
              Positioned(
                top: 2,
                right: 2,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _isUploading = false;
                    });
                  },
                ),
              ),
            ],
          ),

        // ✅ REPLY MESSAGE UI START
        if (widget.replyMessage != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Replying to ${_replyingToName ?? '...'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.replyMessage!['content'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onClearReply,
                  icon: const Icon(Icons.close, color: Colors.white),
                )
              ],
            ),
          ),
        // ✅ REPLY MESSAGE UI END

        // ✅ Existing Input Bar Below (unchanged)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: Colors.black,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.grey),
                        onPressed: _openCamera,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                                Icons.attach_file, color: Colors.grey),
                            onPressed: _pickFile,
                          ),
                          IconButton(
                            icon: const Icon(Icons.image, color: Colors.grey),
                            onPressed: _pickImage,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}