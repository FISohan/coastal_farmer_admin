import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'providers/auth_provider.dart';
import 'services/dio_client.dart';
import 'services/image_upload_service.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final colorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32), // Deep green
            brightness: Brightness.light,
          );

          return MaterialApp.router(
            title: 'Coastal Farmer Admin',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: colorScheme,
              useMaterial3: true,
              textTheme: GoogleFonts.interTextTheme(),
              appBarTheme: AppBarTheme(
                centerTitle: false,
                elevation: 0,
                scrolledUnderElevation: 1,
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                titleTextStyle: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                isDense: true,
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              dividerTheme: DividerThemeData(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                thickness: 1,
              ),
              snackBarTheme: SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            routerConfig: createAppRouter(authProvider),
          );
        },
      ),
    );
  }
}
