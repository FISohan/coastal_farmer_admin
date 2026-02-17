import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'providers/auth_provider.dart';
import 'services/dio_client.dart';
import 'services/image_upload_service.dart';
import 'providers/product_provider.dart';

void main() {
  runApp(const CoastalFarmerAdminApp());
}

class CoastalFarmerAdminApp extends StatelessWidget {
  const CoastalFarmerAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => DioClient()),
        ProxyProvider<DioClient, ImageUploadService>(
          update: (_, dioClient, __) => ImageUploadService(dioClient),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkLoginStatus(),
        ),
        ChangeNotifierProxyProvider2<
          DioClient,
          ImageUploadService,
          ProductProvider
        >(
          create: (context) => ProductProvider(
            context.read<DioClient>(),
            context.read<ImageUploadService>(),
          ),
          update: (_, dioClient, imageUploadService, previous) =>
              previous ?? ProductProvider(dioClient, imageUploadService),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'Coastal Farmer Admin',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              useMaterial3: true,
            ),
            routerConfig: createAppRouter(authProvider),
          );
        },
      ),
    );
  }
}
