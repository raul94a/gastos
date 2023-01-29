import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastos/presentation/pages/auth.dart';
import 'package:gastos/presentation/pages/init.dart';
import 'package:gastos/presentation/pages/initial_loading.dart';
import 'package:gastos/presentation/pages/manage_categories_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user!= null) {
                return const InitialLoading();
              }
              
              return const AuthPage();
            });
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
