// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// class StorageServices {
//   final picker = ImagePicker();

//   Future<void> pickImage(
//     BuildContext context,
//     Function(XFile pickedFile, String imageUrl) onUploaded,
//   ) async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile == null) return;

//     final imageUrl = await uploadImageToCloudinary(File(pickedFile.path));
//     if (imageUrl != null) {
//       onUploaded(pickedFile, imageUrl); // ✅ send both file and imageUrl back
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to upload image')),
//       );
//     }
//   }

//   Future<String?> uploadImageToCloudinary(File file) async {
//     const cloudName = 'dy1heev9z';
//     const uploadPreset = 'flutter_unsigned';

//     final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');

//     final request = http.MultipartRequest('POST', uri)
//       ..fields['upload_preset'] = uploadPreset
//       ..files.add(await http.MultipartFile.fromPath('file', file.path));

//     final response = await request.send();

//     final resStr = await response.stream.bytesToString();
//     if (response.statusCode == 200) {
//       final data = json.decode(resStr);
//       return data['secure_url'];
//     } else {
//       print('❌ Cloudinary upload failed: ${response.statusCode}');
//       print('❌ Error body: $resStr');
//       return null;
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class StorageServices {
  final picker = ImagePicker();

  Future<void> pickImage(
    BuildContext context,
    Function(XFile pickedFile, String imageUrl) onUploaded,
  ) async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final imageUrl = await uploadImageToCloudinary(File(pickedFile.path));

      if (imageUrl != null) {
        //save it in this callback Function
        onUploaded(pickedFile, imageUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      // Hide loading indicator if showing
      if (Navigator.canPop(context)) Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String?> uploadImageToCloudinary(File file) async {
    const cloudName = 'dy1heev9z';
    const uploadPreset = 'images';

    try {
      // Validate file exists and is readable
      if (!await file.exists()) {
        print('❌ File does not exist: ${file.path}');
        return null;
      }

      print('📁 Uploading file: ${file.path}');

      // Create URI - using the same pattern as working code
      var uri =
          Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      // Create MultipartRequest - using the same pattern as working code
      var request = http.MultipartRequest("POST", uri);

      // Read file as bytes (like the working code)
      var fileBytes = await file.readAsBytes();

      // Create MultipartFile from bytes (like the working code)
      var multipartFile = http.MultipartFile.fromBytes(
        'file', // The form field name for the file
        fileBytes,
        filename:
            file.path.split("/").last, // The file name to send in the request
      );

      // Add the file part to the request
      request.files.add(multipartFile);

      // Add required fields
      request.fields['upload_preset'] = uploadPreset;
      request.fields['resource_type'] = 'image'; // Specify it's an image

      print('🚀 Sending request to Cloudinary...');

      // Send the request and await the response
      var response = await request.send();

      // Get the response as text
      var responseBody = await response.stream.bytesToString();

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: $responseBody');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        String? secureUrl = jsonResponse['secure_url'];

        if (secureUrl != null) {
          print('✅ Upload successful: $secureUrl');
          return secureUrl;
        } else {
          print('❌ No secure_url in response');
          return null;
        }
      } else {
        print('❌ Upload failed with status: ${response.statusCode}');
        print('❌ Response body: $responseBody');
        return null;
      }
    } catch (e) {
      print('❌ Exception during upload: $e');
      return null;
    }
  }

  // Alternative method using file path directly (like the working example)
  Future<String?> uploadImageToCloudinaryAlternative(String filePath) async {
    const cloudName = 'dy1heev9z';
    const uploadPreset = 'images';

    try {
      File file = File(filePath);

      if (!await file.exists()) {
        print('❌ File does not exist: $filePath');
        return null;
      }

      print('📁 Uploading file: $filePath');

      // Exactly like the working code structure
      var uri =
          Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      var request = http.MultipartRequest("POST", uri);

      // Read the file content as bytes
      var fileBytes = await file.readAsBytes();

      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: file.path.split("/").last,
      );

      // Add the file part to the request
      request.files.add(multipartFile);

      request.fields['upload_preset'] = uploadPreset;
      request.fields['resource_type'] = "image";

      // Send the request and await the response
      var response = await request.send();

      // Get the response as text
      var responseBody = await response.stream.bytesToString();

      // Print the response
      print('Response: $responseBody');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        return jsonResponse["secure_url"];
      } else {
        print("Upload failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print('❌ Exception during upload: $e');
      return null;
    }
  }

  // Test method to verify connectivity
  Future<bool> testConnectivity() async {
    try {
      print('🌐 Testing connectivity to Cloudinary...');
      var response = await http.get(
        Uri.parse('https://cloudinary.com'),
        headers: {'User-Agent': 'Flutter App'},
      ).timeout(const Duration(seconds: 10));

      print('🌐 Connectivity test status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connectivity test failed: $e');
      return false;
    }
  }
}
