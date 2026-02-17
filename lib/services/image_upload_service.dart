import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart'; // Add this import
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart'; // Add this import if needed or use basic check

import 'dio_client.dart';

class ImageUploadService {
  final DioClient _dioClient;

  ImageUploadService(this._dioClient);

  Future<String?> uploadImage(XFile imageFile) async {
    try {
      String fileName = imageFile.name;
      String? mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

      final bytes = await imageFile.readAsBytes();

      FormData formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      // Replace with your actual upload endpoint
      final response = await _dioClient.dio.post('/upload', data: formData);

      if (response.statusCode == 200) {
        // Assuming API returns { "url": "..." }
        return response.data['url'];
      }
      return null;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }
}
