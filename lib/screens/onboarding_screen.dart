/// Onboarding screen for Witchy.
/// Multi-step wizard to collect user's cycle settings and preferences.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../providers/app_provider.dart';

/// Multi-step onboarding screen with 3 steps: welcome, cycle info, complete.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;

  int _cycleLength = kDefaultCycleLength;
  int _periodDuration = kDefaultPeriodDuration;

  final List<String> _symptoms = [];
  String? _selectedMood;

  static const List<String> kSymptomOptions = [
    'Cramps',
    'Headache',
    'Bloating',
    'Breast Tenderness',
    'Fatigue',
    'Acne',
    'Cravings',
  ];

  static const List<String> kMoodOptions = [
    'Happy',
    'Sad',
    'Irritable',
    'Anxious',
    'Energetic',
    'Calm',
    'Tired',
  ];

  static const List<String> _stepTitles = [
    'Welcome to Witchy',
    'Tell Us About Your Cycle',
  ];

  static const List<String> _stepDescriptions = [
    'Track your cycle privately and accurately.',
    'Customize your settings for the best predictions.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress indicator.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: index == _currentStep ? 24 : 16,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 48),

              // Step title.
              Text(
                _stepTitles[_currentStep],
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 12),

              // Step description.
              Text(
                _stepDescriptions[_currentStep],
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Step content.
              Expanded(
                child: _buildStepContent(context),
              ),

              const SizedBox(height: 24),

              // Navigation buttons.
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      child: Text(_currentStep == 1 ? 'Save & Continue' : 'Continue'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep(context);
      case 1:
        return _buildCycleInfoStep(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomeStep(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.self_improvement, size: 96, color: Color(0xFFE91E8C)),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCycleInfoStep(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Cycle length selector.
          _buildSettingRow(
            context,
            'Cycle Length',
            _cycleLength.toString(),
            (value) => setState(() => _cycleLength = value),
          ),

          const SizedBox(height: 32),

          // Period duration selector.
          _buildSettingRow(
            context,
            'Period Duration',
            _periodDuration.toString(),
            (value) => setState(() => _periodDuration = value),
          ),

          const SizedBox(height: 32),

          // Symptom selection.
          Text(
            'Common Symptoms (optional)',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kSymptomOptions.map((symptom) {
              final isSelected = _symptoms.contains(symptom);
              return FilterChip(
                label: Text(symptom),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _symptoms.add(symptom);
                    } else {
                      _symptoms.remove(symptom);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Mood selection.
          Text(
            'Typical Mood (optional)',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kMoodOptions.map((mood) {
              final isSelected = _selectedMood == mood;
              return ChoiceChip(
                label: Text(mood),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedMood = selected ? mood : null);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context,
    String label,
    String value,
    ValueChanged<int> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                final newValue = (value.codeUnitAt(0) - 1);
                if (newValue >= 21) onChanged(newValue);
              },
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final newValue = (value.codeUnitAt(0) + 1);
                if (newValue <= 45) onChanged(newValue);
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleNext() async {
    final appProvider = context.read<AppProvider>();

    switch (_currentStep) {
      case 0:
        setState(() => _currentStep++);
        break;

      case 1:
        // Save settings and complete onboarding.
        await appProvider.updateProfile(
          cycleLengthDays: _cycleLength,
          periodDurationDays: _periodDuration,
        );

        // Save last period date (use today as default).
        await appProvider.saveEntries([]);

        // Mark onboarding complete.
        await appProvider.completeOnboarding();

        if (mounted) {
          Navigator.of(context).pop(); // Pop the onboarding route.
        }

        break;

      default:
        break;
    }
  }
}
