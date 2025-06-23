// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// /// Service for handling file uploads to storage
// class StorageService {
//   // For demo purposes, using a mock upload service
//   // In production, replace with your preferred storage service (Firebase Storage, AWS S3, etc.)
//   static const String _uploadEndpoint =
//       'https://olx-api-production.up.railway.app/api/upload';

//   /// Upload multiple images and return their URLs
//   static Future<List<String>> uploadImages(List<File> images) async {
//     List<String> uploadedUrls = [];

//     for (File image in images) {
//       try {
//         String? url = await _uploadSingleImage(image);
//         if (url != null) {
//           uploadedUrls.add(url);
//         }
//       } catch (e) {
//         print('Error uploading image: $e');
//         // For demo purposes, add a mock URL if upload fails
//         uploadedUrls.add(
//           'https://via.placeholder.com/400x400.png?text=Upload+Failed',
//         );
//       }
//     }

//     return uploadedUrls;
//   }

//   /// Upload a single image and return its URL
//   static Future<String?> _uploadSingleImage(File image) async {
//     try {
//       // Create multipart request
//       var request = http.MultipartRequest('POST', Uri.parse(_uploadEndpoint));

//       // Add file to request
//       var fileStream = http.ByteStream(image.openRead());
//       var length = await image.length();
//       var multipartFile = http.MultipartFile(
//         'file',
//         fileStream,
//         length,
//         filename: 'product_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
//       );

//       request.files.add(multipartFile);

//       // Send request
//       var response = await request.send();

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var responseData = await response.stream.bytesToString();
//         var jsonData = json.decode(responseData);

//         // Assuming the API returns the URL in a 'url' field
//         return jsonData['url'] as String?;
//       } else {
//         print('Upload failed with status: ${response.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       print('Error in _uploadSingleImage: $e');
//       return null;
//     }
//   }

//   /// Mock upload for demo purposes - remove in production
//   static Future<List<String>> mockUploadImages(List<File> images) async {
//     // Simulate upload delay
//     await Future.delayed(const Duration(seconds: 2));

//     // Return mock URLs
//     List<String> mockUrls = [];
//     for (int i = 0; i < images.length; i++) {
//       mockUrls.add(
//         'https://picsum.photos/400/400?random=$i&timestamp=${DateTime.now().millisecondsSinceEpoch}',
//       );
//     }

//     return mockUrls;
//   }
// }
