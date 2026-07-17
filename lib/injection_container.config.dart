// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'features/cart/data/cart_manager.dart' as _i617;
import 'features/chat/data/driver_chat_manager.dart' as _i548;
import 'features/food_catalog/data/favorite_manager.dart' as _i88;
import 'features/order/data/order_manager.dart' as _i909;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i617.CartManager>(() => _i617.CartManager());
    gh.lazySingleton<_i548.DriverChatManager>(() => _i548.DriverChatManager());
    gh.lazySingleton<_i88.FavoriteManager>(() => _i88.FavoriteManager());
    gh.lazySingleton<_i909.OrderManager>(() => _i909.OrderManager());
    return this;
  }
}
