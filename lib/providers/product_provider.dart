import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../services/dio_client.dart';
import '../services/image_upload_service.dart';

class ProductProvider extends ChangeNotifier {
  final DioClient _dioClient;
  final ImageUploadService _imageUploadService;

  List<Product> _products = [];
  bool _isLoading = false;

  ProductProvider(this._dioClient, this._imageUploadService);

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dioClient.dio.get('/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _products = data.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product product, XFile? imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      String imageUrl = product.image;

      // Upload image if provided
      if (imageFile != null) {
        final uploadedUrl = await _imageUploadService.uploadImage(imageFile);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          // Image upload failed
          print('Image upload failed');
          return false;
        }
      }

      // Create product with image URL
      final newProduct = Product(
        name: product.name,
        description: product.description,
        price: product.price,
        category: product.category,
        stock: product.stock,
        unit: product.unit,
        image: imageUrl,
        discount: product.discount,
        originalPrice: product.originalPrice,
        isPublic: product.isPublic,
      );

      final response = await _dioClient.dio.post(
        '/products',
        data: newProduct.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final createdProduct = Product.fromJson(response.data);
        _products.add(createdProduct);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
