import 'package:get/get.dart';
import 'package:home_care/Api/Services/auth_repository.dart';
import 'package:home_care/Helper/logger_service.dart';

/// Authentication Guard - Prevents access to protected routes without auth
class AuthGuard extends GetMiddleware {
  final AuthRepository _authRepository = AuthRepository();

  @override
  int? get priority => 0; // Higher priority runs first

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    // List of routes that don't require authentication
    const publicRoutes = [
      '/welcomePage',
      '/loginPage',
      '/enterPhoneNumberPage',
      '/otpPage',
    ];

    // Check if route is public
    if (publicRoutes.contains(route.currentPage?.name)) {
      LoggerService.debug('Accessing public route: ${route.currentPage?.name}');
      return null; // Allow access
    }

    // Check if user is authenticated
    final isLoggedIn = await _authRepository.isLoggedIn();

    if (isLoggedIn) {
      LoggerService.info(
        'User authenticated - allowing access to: ${route.currentPage?.name}',
      );
      return null; // Allow access
    }

    // User not authenticated - redirect to login
    LoggerService.warning(
      'Unauthorized access attempt to: ${route.currentPage?.name}',
    );
    Get.offAllNamed('/loginPage');
    return null;
  }
}

/// Token Refresh Middleware - Refreshes token before API calls
class TokenRefreshMiddleware extends GetMiddleware {
  final AuthRepository _authRepository = AuthRepository();

  // Routes that don't need token refresh
  static const nonProtectedEndpoints = ['login', 'verify', 'register'];

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    // Check if route requires token refresh
    final routeName = route.currentPage?.name ?? '';

    if (nonProtectedEndpoints.any((endpoint) => routeName.contains(endpoint))) {
      return null;
    }

    final token = await _authRepository.getToken();
    if (token == null || token.isEmpty) {
      LoggerService.warning('No valid token found - redirecting to login');
      Get.offAllNamed('/loginPage');
    }

    return null;
  }
}
