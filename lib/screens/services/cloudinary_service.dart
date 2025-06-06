import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';

class CloudinaryService {
  // Cloudinary credentials
  static const String _cloudName = 'dzq6pdlda';
  static const String _apiKey = '894334133175213';
  static const String _apiSecret = 'PtPgs7tfQoxyZYb3s0mSdiG08a0';

  // Thư mục mặc định trong Cloudinary
  static const String _defaultFolder = "media_library";

  final cloudinary = CloudinaryPublic(
    _cloudName,
    'ml_default', // Sử dụng ml_default upload preset
    cache: false,
  );

  // Lấy danh sách thư mục từ Cloudinary
  Future<List<String>> getFolders() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/folders'),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_apiKey:$_apiSecret'))}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final folders = data['folders'] as List;
        return folders.map((folder) => folder['path'] as String).toList();
      } else {
        print(
          'Error fetching folders: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error in getFolders: $e');
      return [];
    }
  }

  // Lấy danh sách ảnh từ một thư mục cụ thể
  Future<List<String>> getImagesFromFolder(String folder) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.cloudinary.com/v1_1/$_cloudName/image/list?prefix=$folder/',
        ),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_apiKey:$_apiSecret'))}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final resources = data['resources'] as List;
        return resources
            .map((resource) => resource['secure_url'] as String)
            .toList();
      } else {
        print(
          'Error fetching images from folder: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error in getImagesFromFolder: $e');
      return [];
    }
  }

  // Upload ảnh lên Cloudinary và lưu vào AnhHoaDon với transformation
  Future<String?> uploadImageAndSave(File imageFile, int maGiaoDich) async {
    try {
      // Upload lên Cloudinary với transformation
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: _defaultFolder,
        ),
      );

      // Áp dụng transformation cho URL
      String transformedUrl =
          '${response.secureUrl}/w_1000,c_scale,q_auto,f_auto';
      print('Upload to Cloudinary successful: $transformedUrl');

      // Lưu URL vào AnhHoaDon
      final anhHoaDonResponse = await http.post(
        Uri.parse('https://10.0.2.2:7283/api/AnhHoaDon'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'maGiaoDich': maGiaoDich,
          'duongDanAnh': transformedUrl,
        }),
      );

      if (anhHoaDonResponse.statusCode == 200) {
        print('Save to AnhHoaDon successful');
        return transformedUrl;
      } else {
        print(
          'Error saving to AnhHoaDon: ${anhHoaDonResponse.statusCode} - ${anhHoaDonResponse.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error in uploadImageAndSave: $e');
      return null;
    }
  }

  // Upload ảnh lên Cloudinary với transformation
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Kiểm tra kích thước file
      final fileSize = await imageFile.length();
      print('File size: ${fileSize / 1024 / 1024}MB');

      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw Exception('File size exceeds 10MB limit');
      }

      // Kiểm tra file tồn tại
      if (!await imageFile.exists()) {
        throw Exception('File does not exist');
      }

      print('Uploading to Cloudinary...');
      print('Cloud name: $_cloudName');
      print('Folder: $_defaultFolder');
      print('File path: ${imageFile.path}');

      // Upload với cấu hình đầy đủ
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'media_library', // Sử dụng tên thư mục trực tiếp
          resourceType: CloudinaryResourceType.Image,
          tags: ['flutter_app'],
          context: {
            'alt': 'Uploaded from Flutter app',
            'caption': 'Image uploaded from Flutter app',
          },
        ),
      );

      print('Cloudinary upload response: ${response.secureUrl}');

      if (response.secureUrl != null) {
        // Áp dụng transformation cho URL
        final transformedUrl =
            '${response.secureUrl}/w_1000,c_scale,q_auto,f_auto';
        print('Transformed URL: $transformedUrl');
        return transformedUrl;
      }
      return null;
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      print('Source stack:');
      print(e.toString());

      if (e is DioError) {
        print('DioError details:');
        print('Type: ${e.type}');
        print('Message: ${e.message}');
        print('Response: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
      }

      rethrow;
    }
  }

  // Lấy danh sách ảnh từ Media Library
  Future<List<String>> getMediaLibraryImages() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.cloudinary.com/v1_1/$_cloudName/resources/image/upload?prefix=$_defaultFolder/',
        ),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_apiKey:$_apiSecret'))}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final resources = data['resources'] as List;
        return resources.map((resource) {
          // Áp dụng transformation cho mỗi URL
          String baseUrl = resource['secure_url'] as String;
          return '$baseUrl/w_1000,c_scale,q_auto,f_auto';
        }).toList();
      } else {
        print(
          'Error fetching media library images: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error in getMediaLibraryImages: $e');
      return [];
    }
  }

  // Chọn ảnh từ thư viện
  Future<File?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Request permission and pick image
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image == null) {
        print('No image selected');
        return null;
      }

      // Convert XFile to File
      final File imageFile = File(image.path);

      // Verify file exists
      if (!await imageFile.exists()) {
        print('Image file does not exist');
        return null;
      }

      return imageFile;
    } catch (e) {
      print('Error picking image: $e');
      // Show error to user
      if (e is PlatformException) {
        print('Platform error: ${e.message}');
        print('Error code: ${e.code}');
        print('Error details: ${e.details}');
      }
      return null;
    }
  }

  // Chụp ảnh mới bằng camera
  Future<File?> takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (photo == null) {
        print('No photo taken');
        return null;
      }

      return File(photo.path);
    } catch (e) {
      print('Error taking photo: $e');
      if (e is PlatformException) {
        print('Platform error: ${e.message}');
        print('Error code: ${e.code}');
        print('Error details: ${e.details}');
      }
      return null;
    }
  }
}

class CloudinaryImageGallery extends StatefulWidget {
  final String folder;
  final CloudinaryService cloudinaryService;

  const CloudinaryImageGallery({
    Key? key,
    required this.folder,
    required this.cloudinaryService,
  }) : super(key: key);

  @override
  State<CloudinaryImageGallery> createState() => _CloudinaryImageGalleryState();
}

class _CloudinaryImageGalleryState extends State<CloudinaryImageGallery> {
  List<String> _images = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final images = await widget.cloudinaryService.getImagesFromFolder(
        widget.folder,
      );
      if (!mounted) return;

      setState(() {
        _images = images;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load images: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadImages, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_images.isEmpty) {
      return const Center(child: Text('No images found in this folder'));
    }

    return RefreshIndicator(
      onRefresh: _loadImages,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => Scaffold(
                        appBar: AppBar(title: const Text('Image Preview')),
                        body: Center(
                          child: Image.network(
                            _images[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Text('Failed to load image'),
                              );
                            },
                          ),
                        ),
                      ),
                ),
              );
            },
            child: Hero(
              tag: _images[index],
              child: Image.network(
                _images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.error)),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}