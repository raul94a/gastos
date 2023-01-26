import 'package:flutter/material.dart';
import 'package:gastos/presentation/pages/init.dart';
import 'package:gastos/presentation/pages/initial_loading.dart';
import 'package:gastos/presentation/pages/settings.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const InitialLoading();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'init',
          builder: (BuildContext context, GoRouterState state) {
            return const Init();
          },
        ),
        GoRoute(
          path: 'categories',
          builder: (context, state) {
            return const ManageCategoriesPage();
          },
        )
      ],
    ),
  ],
);
