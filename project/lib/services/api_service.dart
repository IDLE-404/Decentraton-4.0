import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://formula-eau-une-peninsula.trycloudflare.com",
      connectTimeout: const Duration(seconds: 1000),
      receiveTimeout: const Duration(seconds: 1000),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint("API Request: ${options.method} ${options.uri}");
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint("API Response [${response.statusCode}]: ${response.data}");
        handler.next(response);
      },
      onError: (DioError e, handler) {
        debugPrint("API Error: ${e.message}");
        handler.next(e);
      },
    ));
  }

  /// Отправка 4 фото автомобиля на сервер и получение результата
  Future<Map<String, dynamic>> sendCarPhotos({
    required File frontImage,
    required File leftImage,
    required File rightImage,
    required File rearImage,
  }) async {
    final formData = FormData.fromMap({
      "front_image": await MultipartFile.fromFile(frontImage.path, filename: "front.jpg"),
      "rear_image": await MultipartFile.fromFile(rearImage.path, filename: "rear.jpg"),
      "left_image": await MultipartFile.fromFile(leftImage.path, filename: "left.jpg"),
      "right_image": await MultipartFile.fromFile(rightImage.path, filename: "right.jpg"),
    });

    final response = await _dio.post(
      "/predict",
      data: formData,
      options: Options(headers: {"Content-Type": "multipart/form-data"}),
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception("Ошибка API: ${response.statusCode}");
    }
  }
}
