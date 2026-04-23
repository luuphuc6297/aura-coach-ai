// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authSubtitle =>
      'Your personal AI English coach.\nLearn naturally, speak confidently.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get tryAsGuest => 'Try as Guest';

  @override
  String get termsNotice =>
      'By continuing you agree to our\nTerms of Service and Privacy Policy';

  @override
  String get onboardingNameTitle => 'What should we call you?';

  @override
  String get onboardingNameSubtitle => 'Pick a name and choose your avatar';

  @override
  String get onboardingNameHint => 'Enter your name';

  @override
  String get onboardingBuddyLabel => 'CHOOSE YOUR BUDDY';

  @override
  String get onboardingLevelTitle => 'What\'s your English level?';

  @override
  String get onboardingLevelSubtitle =>
      'We\'ll personalize lessons just for you';

  @override
  String get onboardingGoalsTitle => 'What are your goals?';

  @override
  String get onboardingGoalsSubtitle => 'Select all that apply';

  @override
  String get onboardingTopicsTitle => 'Pick your interests';

  @override
  String get onboardingTopicsSubtitle =>
      'We\'ll tailor scenarios to what matters to you';

  @override
  String get onboardingTimeTitle => 'How much time daily?';

  @override
  String get onboardingTimeSubtitle => 'We\'ll build the right plan for you';

  @override
  String get addYourOwnTopic => 'Add your own topic...';

  @override
  String selectedTopicsCount(int count) {
    return 'Selected: $count topics';
  }

  @override
  String get dailyLimitReached =>
      'Daily limit reached. Upgrade for more sessions.';

  @override
  String failedToStart(String error) {
    return 'Failed to start: $error';
  }
}
