import 'package:flutter/material.dart';
import '../../../app/theme.dart';

/// Test widget untuk verify theme
class ThemeTestScreen extends StatelessWidget {
  const ThemeTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display styles
            Text('Display Large', style: Theme.of(context).textTheme.displayLarge),
            Text('Display Medium', style: Theme.of(context).textTheme.displayMedium),
            Text('Display Small', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            
            // Headline styles
            Text('Headline Large', style: Theme.of(context).textTheme.headlineLarge),
            Text('Headline Medium', style: Theme.of(context).textTheme.headlineMedium),
            Text('Headline Small', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            
            // Title styles
            Text('Title Large', style: Theme.of(context).textTheme.titleLarge),
            Text('Title Medium', style: Theme.of(context).textTheme.titleMedium),
            Text('Title Small', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            
            // Body styles
            Text('Body Large', style: Theme.of(context).textTheme.bodyLarge),
            Text('Body Medium', style: Theme.of(context).textTheme.bodyMedium),
            Text('Body Small', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            
            // Color palette
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorBox(color: AppTheme.primaryBlue, label: 'Primary Blue'),
                _ColorBox(color: AppTheme.primaryGreen, label: 'Primary Green'),
                _ColorBox(color: AppTheme.primaryYellow, label: 'Primary Yellow'),
                _ColorBox(color: AppTheme.successColor, label: 'Success'),
                _ColorBox(color: AppTheme.errorColor, label: 'Error'),
                _ColorBox(color: AppTheme.warningColor, label: 'Warning'),
                _ColorBox(color: AppTheme.infoColor, label: 'Info'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Buttons
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated Button'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('Text Button'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorBox({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
