import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_auth_app/bank_user.dart';
import 'package:secure_auth_app/dashboard_screen.dart';
import 'package:secure_auth_app/main.dart';

void main() {
  testWidgets('app loads welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BrightCareApp());

    expect(find.text('Banking made clearer, safer, faster.'), findsOneWidget);
  });

  testWidgets('dashboard shows transfer actions and navigation sections', (WidgetTester tester) async {
    final user = BankUser(
      firstName: 'Ada',
      lastName: 'Lovelace',
      username: 'ada',
      email: 'ada@example.com',
      phone: '08012345678',
      password: 'securePass1!',
      accountName: 'BrightCare Classic',
      accountNumber: 'BC1234567890',
    );

    await tester.pumpWidget(MaterialApp(home: DashboardScreen(user: user)));

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Send to BrightCare'), findsOneWidget);
    expect(find.text('Send to Other Banks'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('tapping airtime opens a service dialog', (WidgetTester tester) async {
    final user = BankUser(
      firstName: 'Ada',
      lastName: 'Lovelace',
      username: 'ada',
      email: 'ada@example.com',
      phone: '08012345678',
      password: 'securePass1!',
      accountName: 'BrightCare Classic',
      accountNumber: 'BC1234567890',
    );

    await tester.pumpWidget(MaterialApp(home: DashboardScreen(user: user)));
    await tester.ensureVisible(find.text('Airtime'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Airtime'));
    await tester.pumpAndSettle();

    expect(find.text('Airtime Recharge'), findsOneWidget);
  });

  testWidgets('settings tab exposes security controls', (WidgetTester tester) async {
    final user = BankUser(
      firstName: 'Ada',
      lastName: 'Lovelace',
      username: 'ada',
      email: 'ada@example.com',
      phone: '08012345678',
      password: 'securePass1!',
      accountName: 'BrightCare Classic',
      accountNumber: 'BC1234567890',
    );

    await tester.pumpWidget(MaterialApp(home: DashboardScreen(user: user)));
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Change PIN'), findsOneWidget);
    expect(find.text('Fingerprint login'), findsOneWidget);
  });

  testWidgets('new user sees an empty transaction history state', (WidgetTester tester) async {
    final user = BankUser(
      firstName: 'Ada',
      lastName: 'Lovelace',
      username: 'ada',
      email: 'ada@example.com',
      phone: '08012345678',
      password: 'securePass1!',
      accountName: 'BrightCare Classic',
      accountNumber: 'BC1234567890',
    );

    await tester.pumpWidget(MaterialApp(home: DashboardScreen(user: user)));
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('No transactions yet'), findsOneWidget);
  });
}
