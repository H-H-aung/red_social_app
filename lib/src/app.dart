library;

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

part 'api/account_api.dart';
part 'api/api_client.dart';
part 'api/api_config.dart';
part 'api/auth_api.dart';
part 'api/catalog_api.dart';
part 'api/orders_api.dart';
part 'api/tickets_api.dart';
part 'api/wallet_api.dart';
part 'components/nav.dart';
part 'models/order_model.dart';
part 'models/service_model.dart';
part 'models/ticket_model.dart';
part 'models/user_model.dart';
part 'models/wallet_model.dart';
part 'screens/account_screen.dart';
part 'screens/game/free_fire.dart';
part 'screens/game/game.dart';
part 'screens/game/game_order_form.dart';
part 'screens/game/honor_of_kings.dart';
part 'screens/game/mobile_legends.dart';
part 'screens/game/pubg.dart';
part 'screens/help_support_screen.dart';
part 'screens/home_screen.dart';
part 'screens/login_screen.dart';
part 'screens/notification_screen.dart';
part 'screens/orders/order_detail_screen.dart';
part 'screens/orders_screen.dart';
part 'screens/premium/premium_order_form.dart';
part 'screens/premium/premium.dart';
part 'screens/profile_detail_screen.dart';
part 'screens/refund_screen.dart';
part 'screens/social/social_order_form.dart';
part 'screens/social/social.dart';
part 'screens/splash_screen.dart';
part 'screens/tickets_screen.dart';
part 'screens/wallet_screen.dart';
part 'widgets/home_widgets.dart';
part 'widgets/inputs.dart';
part 'widgets/layout.dart';
part 'widgets/order_widgets.dart';
part 'widgets/profile_widgets.dart';
part 'widgets/service_widgets.dart';
part 'widgets/ticket_widgets.dart';
part 'widgets/wallet_widgets.dart';
part 'theme/decorations.dart';
part 'utils/time_format.dart';

class RedSiteSocialApp extends StatelessWidget {
  const RedSiteSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Social',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE71F32),
          brightness: Brightness.dark,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const OrdersPage(),
      const WalletPage(),
      HomePage(onOpenOrders: () => setState(() => _selectedIndex = 0)),
      const TicketActionPage(),
      const AccountPage(),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: _AppBottomNav(
        selectedIndex: _selectedIndex,
        onChanged: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
