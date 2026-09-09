import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctalk/features/image_analysis/widgets/confidence_badge.dart';
import 'package:doctalk/features/image_analysis/widgets/severity_badge.dart';
import 'package:doctalk/features/image_analysis/widgets/emergency_banner.dart';

void main() {
  group('Image Analysis Widget Tests', () {
    testWidgets('ConfidenceBadge renders confidence text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(confidence: 'Medium'),
          ),
        ),
      );

      expect(find.text('Confidence: Medium'), findsOneWidget);
    });

    testWidgets('SeverityBadge renders severity text and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeverityBadge(severity: 'Emergency'),
          ),
        ),
      );

      expect(find.text('🚨 EMERGENCY'), findsOneWidget);
    });

    testWidgets('EmergencyBanner renders urgent alert', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmergencyBanner(animate: false),
          ),
        ),
      );

      expect(find.text('⚠️ EMERGENCY'), findsOneWidget);
      expect(find.text('Seek immediate medical attention'), findsOneWidget);
    });
  });
}
