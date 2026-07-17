import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import all pages/widgets
import 'package:food_app/features/welcome/presentation/pages/welcome_page.dart';
import 'package:food_app/features/auth/presentation/pages/login_page.dart';
import 'package:food_app/features/auth/presentation/pages/signup_page.dart';
import 'package:food_app/features/auth/presentation/pages/forgot_page.dart';
import 'package:food_app/features/auth/presentation/pages/confirm_password_page.dart';
import 'package:food_app/features/auth/presentation/pages/change_password.dart';
import 'package:food_app/features/food_catalog/presentation/widgets/taskbar_widget.dart';
import 'package:food_app/features/food_catalog/presentation/pages/food_detail_page.dart';
import 'package:food_app/features/cart/presentation/pages/cart_page.dart';
import 'package:food_app/features/order/presentation/pages/checkout_page.dart';
import 'package:food_app/features/order/presentation/pages/payment_success_page.dart';
import 'package:food_app/features/order/presentation/pages/order_tracking_page.dart';
import 'package:food_app/features/order/presentation/pages/order_history_page.dart';
import 'package:food_app/features/order/presentation/pages/order_detail_page.dart';
import 'package:food_app/features/profile/presentation/pages/settings_page.dart';
import 'package:food_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:food_app/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:food_app/features/chat/presentation/pages/driver_chat_detail_page.dart';
import 'package:food_app/features/chat/presentation/pages/notification_page.dart';
import 'package:food_app/features/order/data/order_manager.dart';

// Custom transition page that matches the existing slide + fade transition
CustomTransitionPage<T> buildPageWithTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutCubic;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

class AppRouter {
  // Routes Paths
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgot = '/forgot';
  static const String confirmPassword = '/confirm-password';
  static const String changePassword = '/change-password';
  static const String taskbar = '/taskbar';
  static const String foodDetail = '/food-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String paymentSuccess = '/payment-success';
  static const String orderTracking = '/order-tracking';
  static const String orderHistory = '/order-history';
  static const String orderDetail = '/order-detail';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';
  static const String chatDetail = '/chat-detail';
  static const String driverChatDetail = '/driver-chat-detail';
  static const String notifications = '/notifications';

  static final GoRouter router = GoRouter(
    initialLocation: welcome,
    routes: [
      GoRoute(
        path: welcome,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const WelcomePage(),
        ),
      ),
      GoRoute(
        path: login,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: signup,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const SignupPage(),
        ),
      ),
      GoRoute(
        path: forgot,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ForgotPage(),
        ),
      ),
      GoRoute(
        path: confirmPassword,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ConfirmPassWordPage(),
        ),
      ),
      GoRoute(
        path: changePassword,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ChangePasswordPage(),
        ),
      ),
      GoRoute(
        path: taskbar,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const TaskBarWidget(),
        ),
      ),
      GoRoute(
        path: foodDetail,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: FoodDetailPage(
              title: args['title'] as String,
              image: args['image'] as String,
              price: args['price'] as String,
              rating: args['rating'] as String,
              prepTime: args['prepTime'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: cart,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const CartPage(),
        ),
      ),
      GoRoute(
        path: checkout,
        pageBuilder: (context, state) {
          final initialVoucher = state.extra as Voucher?;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: CheckoutPage(initialVoucher: initialVoucher),
          );
        },
      ),
      GoRoute(
        path: paymentSuccess,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: PaymentSuccessPage(
              totalPrice: args['totalPrice'] as int,
              paymentMethod: args['paymentMethod'] as String,
              orderId: args['orderId'] as String,
            ),
          );
        },
      ),
      GoRoute(
        path: orderTracking,
        pageBuilder: (context, state) {
          final order = state.extra as OrderHistoryItem;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: OrderTrackingPage(order: order),
          );
        },
      ),
      GoRoute(
        path: orderHistory,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const OrderHistoryPage(),
        ),
      ),
      GoRoute(
        path: orderDetail,
        pageBuilder: (context, state) {
          final order = state.extra as OrderHistoryItem;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: OrderDetailPage(order: order),
          );
        },
      ),
      GoRoute(
        path: settings,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: editProfile,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const EditProfilePage(),
        ),
      ),
      GoRoute(
        path: chatDetail,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ChatDetailPage(),
        ),
      ),
      GoRoute(
        path: driverChatDetail,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const DriverChatDetailPage(),
        ),
      ),
      GoRoute(
        path: notifications,
        pageBuilder: (context, state) {
          final showBackButton = state.extra as bool? ?? true;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: NotificationPage(showBackButton: showBackButton),
          );
        },
      ),
    ],
  );
}