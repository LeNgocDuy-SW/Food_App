import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String pcIpAddress = '192.168.1.102';

  // Biến lưu trữ Root URL máy chủ đang hoạt động tốt nhất (e.g. http://192.168.1.100:8000)
  static String? _workingRootUrl;

  // IP Máy chủ DigitalOcean đã deploy online (Máy chủ tập trung dữ liệu duy nhất)
  static const String serverOnlineUrl = 'http://204.48.17.52';

  // Danh sách địa chỉ Server (Ưu tiên DigitalOcean Cloud tập trung 1 CSDL duy nhất)
  static List<String> get _candidateRootUrls {
    return [
      serverOnlineUrl, // Ưu tiên 1: Máy chủ DigitalOcean Cloud
      'http://$pcIpAddress:8000',
      'http://127.0.0.1:8000',
      'http://10.0.2.2:8000',
    ];
  }

  static Future<String> getWorkingBaseUrl() async {
    final root = await getWorkingRootUrl();
    return '$root/api/v1/auth';
  }

  // Tự động dò tìm địa chỉ máy chủ đang hoạt động
  static Future<String> getWorkingRootUrl() async {
    if (_workingRootUrl != null) return _workingRootUrl!;

    try {
      final futures = _candidateRootUrls.map((root) async {
        try {
          final res = await http
              .get(Uri.parse('$root/'))
              .timeout(const Duration(seconds: 3));
          if (res.statusCode == 200) return root;
        } catch (_) {}
        return null;
      });

      final results = await Future.wait(futures);
      for (final r in results) {
        if (r != null) {
          debugPrint('[AuthService] Máy chủ hoạt động tại: $r');
          _workingRootUrl = r;
          return r;
        }
      }
    } catch (_) {}

    return serverOnlineUrl;
  }

  // Quản lý Token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static String? _cachedUserName;

  static Future<void> saveUserName(String name) async {
    _cachedUserName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_name', name);
  }

  static Future<String?> getUserName() async {
    if (_cachedUserName != null && _cachedUserName!.isNotEmpty) {
      return _cachedUserName;
    }
    final prefs = await SharedPreferences.getInstance();
    _cachedUserName = prefs.getString('current_user_name');
    return _cachedUserName;
  }

  static Future<void> logout() async {
    _cachedUserName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove('current_user_name');
  }

  // Helper thực hiện GET Request thử nghiệm qua các IP dự phòng với timeout 6s
  static Future<http.Response> getApi(
    String apiPath, {
    Map<String, String>? headers,
  }) async {
    final activeRoot = await getWorkingRootUrl();
    final rootsToTry = <String>[activeRoot];
    for (var r in _candidateRootUrls) {
      if (!rootsToTry.contains(r)) rootsToTry.add(r);
    }

    Object? lastError;
    for (final root in rootsToTry) {
      try {
        final uri = Uri.parse('$root$apiPath');
        debugPrint('[AuthService GET] Requesting: $uri');
        final res = await http
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 6));
        _workingRootUrl = root;
        return res;
      } catch (e) {
        lastError = e;
        _workingRootUrl = null;
        debugPrint('[AuthService GET Failed] $root$apiPath -> $e');
      }
    }
    throw lastError ?? Exception('Không thể kết nối đến máy chủ Backend!');
  }

  // Helper thực hiện POST Request thử nghiệm qua các IP dự phòng với timeout 6s
  static Future<http.Response> postApi(
    String apiPath,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final activeRoot = await getWorkingRootUrl();
    final rootsToTry = <String>[activeRoot];
    for (var r in _candidateRootUrls) {
      if (!rootsToTry.contains(r)) rootsToTry.add(r);
    }

    final reqHeaders = <String, String>{'Content-Type': 'application/json'};
    if (headers != null) reqHeaders.addAll(headers);

    Object? lastError;
    for (final root in rootsToTry) {
      try {
        final uri = Uri.parse('$root$apiPath');
        debugPrint('[AuthService POST] Requesting: $uri');
        final res = await http
            .post(uri, headers: reqHeaders, body: jsonEncode(body))
            .timeout(const Duration(seconds: 6));
        _workingRootUrl = root;
        return res;
      } catch (e) {
        lastError = e;
        _workingRootUrl = null;
        debugPrint('[AuthService POST Failed] $root$apiPath -> $e');
      }
    }
    throw lastError ?? Exception('Không thể kết nối đến máy chủ Backend!');
  }

  // Helper thực hiện PUT Request thử nghiệm qua các IP dự phòng với timeout 6s
  static Future<http.Response> putApi(
    String apiPath,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final activeRoot = await getWorkingRootUrl();
    final rootsToTry = <String>[activeRoot];
    for (var r in _candidateRootUrls) {
      if (!rootsToTry.contains(r)) rootsToTry.add(r);
    }

    final reqHeaders = <String, String>{'Content-Type': 'application/json'};
    if (headers != null) reqHeaders.addAll(headers);

    Object? lastError;
    for (final root in rootsToTry) {
      try {
        final uri = Uri.parse('$root$apiPath');
        debugPrint('[AuthService PUT] Requesting: $uri');
        final res = await http
            .put(uri, headers: reqHeaders, body: jsonEncode(body))
            .timeout(const Duration(seconds: 6));
        _workingRootUrl = root;
        return res;
      } catch (e) {
        lastError = e;
        _workingRootUrl = null;
        debugPrint('[AuthService PUT Failed] $root$apiPath -> $e');
      }
    }
    throw lastError ?? Exception('Không thể kết nối đến máy chủ Backend!');
  }

  // 1. Hàm Đăng ký (SignUp) - Đăng ký tài khoản trên máy chủ khả dụng
  static Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final activeRoot = await getWorkingRootUrl();
    final candidateRoots = <String>[activeRoot];
    for (var r in _candidateRootUrls) {
      if (!candidateRoots.contains(r)) candidateRoots.add(r);
    }

    String? lastErrorMsg;
    for (final root in candidateRoots) {
      try {
        final uri = Uri.parse('$root/api/v1/auth/signup');
        debugPrint('[AuthService SignUp] Attempting: $uri');
        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'full_name': fullName,
                'email': email,
                'password': password,
              }),
            )
            .timeout(const Duration(seconds: 5));

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 201 || response.statusCode == 200) {
          _workingRootUrl = root;
          debugPrint('[AuthService SignUp Success] Registered on $root');
          return {'success': true, 'data': responseData};
        } else {
          lastErrorMsg = responseData['detail'] ?? 'Đăng ký thất bại!';
          debugPrint('[AuthService SignUp Failed] $root -> $lastErrorMsg');
        }
      } catch (e) {
        debugPrint('[AuthService SignUp Exception] $root -> $e');
      }
    }

    return {
      'success': false,
      'message':
          lastErrorMsg ??
          'Không thể kết nối đến máy chủ Backend! Vui lòng kiểm tra mạng.',
    };
  }

  // 2. Hàm Đăng nhập (Login) - Tự động tìm tài khoản trên cả Server Local & DigitalOcean Online
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final activeRoot = await getWorkingRootUrl();
    final candidateRoots = <String>[activeRoot];
    for (var r in _candidateRootUrls) {
      if (!candidateRoots.contains(r)) candidateRoots.add(r);
    }

    String? lastErrorMsg;

    for (final root in candidateRoots) {
      try {
        final uri = Uri.parse('$root/api/v1/auth/login');
        debugPrint('[AuthService Login] Requesting login: $uri');
        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': email, 'password': password}),
            )
            .timeout(const Duration(seconds: 5));

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final token = responseData['access_token'];
          if (token != null) {
            await saveToken(token);
          }
          // Chuyển làm việc chính thức sang server xác thực thành công tài khoản này!
          _workingRootUrl = root;
          debugPrint('[AuthService Login Success] Authenticated via $root');
          return {'success': true, 'token': token};
        } else {
          lastErrorMsg =
              responseData['detail'] ?? 'Email hoặc mật khẩu không chính xác!';
          debugPrint('[AuthService Login Failed] $root -> $lastErrorMsg');
        }
      } catch (e) {
        debugPrint('[AuthService Login Exception] $root -> $e');
      }
    }

    return {
      'success': false,
      'message': lastErrorMsg ?? 'Email hoặc mật khẩu không chính xác!',
    };
  }

  // 3. Hàm Lấy thông tin User hiện tại (/me)
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final activeRoot = await getWorkingRootUrl();
      final candidateRoots = <String>[activeRoot];
      for (var r in _candidateRootUrls) {
        if (!candidateRoots.contains(r)) candidateRoots.add(r);
      }

      for (final root in candidateRoots) {
        try {
          final uri = Uri.parse('$root/api/v1/auth/me');
          final response = await http
              .get(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
              )
              .timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            _workingRootUrl = root;
            final responseData = jsonDecode(response.body);
            final name = (responseData['full_name'] as String?)?.trim();
            final username = (responseData['username'] as String?)?.trim();
            final email = (responseData['email'] as String?)?.trim();
            final realName = (name != null && name.isNotEmpty)
                ? name
                : ((username != null && username.isNotEmpty)
                    ? username
                    : (email ?? 'Tài Khoản User'));
            await saveUserName(realName);
            return {'success': true, 'data': responseData};
          }
        } catch (_) {}
      }

      return {'success': false, 'message': 'Phiên đăng nhập đã hết hạn'};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ!'};
    }
  }

  // 4. Hàm Yêu cầu OTP Quên mật khẩu (/forgot-password)
  static Future<Map<String, dynamic>> forgotPassword({
    required String phoneOrEmail,
  }) async {
    try {
      final response = await postApi('/api/v1/auth/forgot-password', {
        'phone_or_email': phoneOrEmail,
      });

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Đã gửi mã OTP!',
          'otp_code': responseData['otp_code'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Không thể gửi mã OTP!',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến máy chủ Backend!',
      };
    }
  }

  // 5. Hàm Xác thực OTP (/verify-otp)
  static Future<Map<String, dynamic>> verifyOtp({
    required String phoneOrEmail,
    required String otpCode,
  }) async {
    try {
      final response = await postApi('/api/v1/auth/verify-otp', {
        'phone_or_email': phoneOrEmail,
        'otp_code': otpCode,
      });

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Xác thực OTP thành công!',
        };
      } else {
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Xác thực OTP thất bại!',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến máy chủ Backend!',
      };
    }
  }

  // 6. Hàm Đổi mật khẩu mới (/reset-password)
  static Future<Map<String, dynamic>> resetPassword({
    required String phoneOrEmail,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      final response = await postApi('/api/v1/auth/reset-password', {
        'phone_or_email': phoneOrEmail,
        'otp_code': otpCode,
        'new_password': newPassword,
      });

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Đổi mật khẩu thành công!',
        };
      } else {
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Đổi mật khẩu thất bại!',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến máy chủ Backend!',
      };
    }
  }

  // 7. Hàm Cập nhật Hồ sơ cá nhân (/api/v1/users/me)
  static Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? email,
  }) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (email != null) body['email'] = email;

      final response = await putApi(
        '/api/v1/users/me',
        body,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Cập nhật hồ sơ thất bại!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ!'};
    }
  }
}
