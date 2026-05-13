import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal AI English coach.\nLearn naturally, speak confidently.'**
  String get authSubtitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @tryAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Try as Guest'**
  String get tryAsGuest;

  /// No description provided for @termsNotice.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our\nTerms of Service and Privacy Policy'**
  String get termsNotice;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a name and choose your avatar'**
  String get onboardingNameSubtitle;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get onboardingNameHint;

  /// No description provided for @onboardingBuddyLabel.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE YOUR BUDDY'**
  String get onboardingBuddyLabel;

  /// No description provided for @onboardingLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your English level?'**
  String get onboardingLevelTitle;

  /// No description provided for @onboardingLevelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll personalize lessons just for you'**
  String get onboardingLevelSubtitle;

  /// No description provided for @onboardingGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'What are your goals?'**
  String get onboardingGoalsTitle;

  /// No description provided for @onboardingGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get onboardingGoalsSubtitle;

  /// No description provided for @onboardingTopicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your interests'**
  String get onboardingTopicsTitle;

  /// No description provided for @onboardingTopicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll tailor scenarios to what matters to you'**
  String get onboardingTopicsSubtitle;

  /// No description provided for @onboardingTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'How much time daily?'**
  String get onboardingTimeTitle;

  /// No description provided for @onboardingTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll build the right plan for you'**
  String get onboardingTimeSubtitle;

  /// No description provided for @addYourOwnTopic.
  ///
  /// In en, this message translates to:
  /// **'Add your own topic...'**
  String get addYourOwnTopic;

  /// No description provided for @selectedTopicsCount.
  ///
  /// In en, this message translates to:
  /// **'Selected: {count} topics'**
  String selectedTopicsCount(int count);

  /// No description provided for @dailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached. Upgrade for more sessions.'**
  String get dailyLimitReached;

  /// No description provided for @failedToStart.
  ///
  /// In en, this message translates to:
  /// **'Failed to start: {error}'**
  String failedToStart(String error);

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @profileLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get profileLevelLabel;

  /// No description provided for @profileDailyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get profileDailyGoalLabel;

  /// No description provided for @profilePlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get profilePlanLabel;

  /// No description provided for @profilePlanFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get profilePlanFree;

  /// No description provided for @profilePlanPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get profilePlanPremium;

  /// No description provided for @profileGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get profileGoalsTitle;

  /// No description provided for @profileTopicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get profileTopicsTitle;

  /// No description provided for @profileEditRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditRowLabel;

  /// No description provided for @profileEditRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, avatar, level, daily goal'**
  String get profileEditRowSubtitle;

  /// No description provided for @profileSettingsRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsRowLabel;

  /// No description provided for @profileSettingsRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, notifications, privacy'**
  String get profileSettingsRowSubtitle;

  /// No description provided for @profileUpgradeRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get profileUpgradeRowLabel;

  /// No description provided for @profileUpgradeRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited practice + AI illustrations'**
  String get profileUpgradeRowSubtitle;

  /// No description provided for @profileSignOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOutLabel;

  /// No description provided for @profileSignOutEndSession.
  ///
  /// In en, this message translates to:
  /// **'End your session'**
  String get profileSignOutEndSession;

  /// No description provided for @profileSignOutSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String profileSignOutSignedInAs(String name);

  /// No description provided for @profileSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in anytime.'**
  String get profileSignOutBody;

  /// No description provided for @profileNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Profile not available'**
  String get profileNotAvailable;

  /// No description provided for @profileDailyMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String profileDailyMinutes(int minutes);

  /// No description provided for @profileLevelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get profileLevelBeginner;

  /// No description provided for @profileLevelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get profileLevelIntermediate;

  /// No description provided for @profileLevelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get profileLevelAdvanced;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGroupPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get settingsGroupPractice;

  /// No description provided for @settingsGroupApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsGroupApp;

  /// No description provided for @settingsGroupPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsGroupPrivacy;

  /// No description provided for @settingsRowDailyReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get settingsRowDailyReminders;

  /// No description provided for @settingsRowReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsRowReminderTime;

  /// No description provided for @settingsRowAutoPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Auto-play audio'**
  String get settingsRowAutoPlayAudio;

  /// No description provided for @settingsRowDisplayLanguage.
  ///
  /// In en, this message translates to:
  /// **'Display language'**
  String get settingsRowDisplayLanguage;

  /// No description provided for @settingsRowTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme (Dark mode)'**
  String get settingsRowTheme;

  /// No description provided for @settingsRowDataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & privacy'**
  String get settingsRowDataPrivacy;

  /// No description provided for @settingsRowDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsRowDeleteAccount;

  /// No description provided for @settingsThemePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemePickerTitle;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'Match system'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Display language'**
  String get settingsLanguagePickerTitle;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get settingsLanguageVietnamese;

  /// No description provided for @settingsReminderTimeHelp.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder time'**
  String get settingsReminderTimeHelp;

  /// No description provided for @settingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get settingsDeleteTitle;

  /// No description provided for @settingsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes your profile, conversations, saved words, mind maps, and stats. This action cannot be undone.'**
  String get settingsDeleteBody;

  /// No description provided for @settingsDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get settingsDeleteSuccess;

  /// No description provided for @settingsDeleteRequiresLogin.
  ///
  /// In en, this message translates to:
  /// **'For security, sign in again before deleting your account.'**
  String get settingsDeleteRequiresLogin;

  /// No description provided for @settingsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the account. Please try again later.'**
  String get settingsDeleteFailed;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileSectionBuddy.
  ///
  /// In en, this message translates to:
  /// **'YOUR BUDDY'**
  String get editProfileSectionBuddy;

  /// No description provided for @editProfileSectionName.
  ///
  /// In en, this message translates to:
  /// **'YOUR NAME'**
  String get editProfileSectionName;

  /// No description provided for @editProfileSectionLevel.
  ///
  /// In en, this message translates to:
  /// **'ENGLISH LEVEL'**
  String get editProfileSectionLevel;

  /// No description provided for @editProfileSectionDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'DAILY GOAL'**
  String get editProfileSectionDailyGoal;

  /// No description provided for @editProfileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editProfileSaveButton;

  /// No description provided for @editProfileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty.'**
  String get editProfileNameRequired;

  /// No description provided for @editProfileSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get editProfileSaveSuccess;

  /// No description provided for @editProfileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes. Please try again.'**
  String get editProfileSaveFailed;

  /// No description provided for @editProfileDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get editProfileDiscardTitle;

  /// No description provided for @editProfileDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t saved your edits. If you leave now, your changes will be lost.'**
  String get editProfileDiscardBody;

  /// No description provided for @editProfileDiscardKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get editProfileDiscardKeepEditing;

  /// No description provided for @editProfileDiscardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get editProfileDiscardConfirm;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homePickMode.
  ///
  /// In en, this message translates to:
  /// **'Pick a learning mode'**
  String get homePickMode;

  /// No description provided for @homeStorageFull.
  ///
  /// In en, this message translates to:
  /// **'Storage full. Delete a conversation or upgrade to start a new one.'**
  String get homeStorageFull;

  /// No description provided for @homeStorageUpgradeAction.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get homeStorageUpgradeAction;

  /// No description provided for @homePaywallSnack.
  ///
  /// In en, this message translates to:
  /// **'Paywall coming soon.'**
  String get homePaywallSnack;

  /// No description provided for @homeDailyLimitReachedSessions.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached. Upgrade for more sessions.'**
  String get homeDailyLimitReachedSessions;

  /// No description provided for @homeDailyLimitReachedStories.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached. Upgrade for more stories.'**
  String get homeDailyLimitReachedStories;

  /// No description provided for @modeScenarioTitle.
  ///
  /// In en, this message translates to:
  /// **'Scenario Coach'**
  String get modeScenarioTitle;

  /// No description provided for @modeScenarioDescription.
  ///
  /// In en, this message translates to:
  /// **'Practice real-life situations with AI roleplay. Get instant feedback on grammar, vocabulary & tone.'**
  String get modeScenarioDescription;

  /// No description provided for @modeScenarioBadge.
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get modeScenarioBadge;

  /// No description provided for @modeScenarioCta.
  ///
  /// In en, this message translates to:
  /// **'Start Practice'**
  String get modeScenarioCta;

  /// No description provided for @modeScenarioQuota.
  ///
  /// In en, this message translates to:
  /// **'5 free sessions / day'**
  String get modeScenarioQuota;

  /// No description provided for @modeStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Story Mode'**
  String get modeStoryTitle;

  /// No description provided for @modeStoryBadge.
  ///
  /// In en, this message translates to:
  /// **'INTERACTIVE'**
  String get modeStoryBadge;

  /// No description provided for @modeStoryCta.
  ///
  /// In en, this message translates to:
  /// **'Begin Story'**
  String get modeStoryCta;

  /// No description provided for @modeStoryQuota.
  ///
  /// In en, this message translates to:
  /// **'3 free stories / day'**
  String get modeStoryQuota;

  /// No description provided for @modeToneTitle.
  ///
  /// In en, this message translates to:
  /// **'Tone Translator'**
  String get modeToneTitle;

  /// No description provided for @modeToneDescription.
  ///
  /// In en, this message translates to:
  /// **'Master the art of tone. See how one sentence sounds formal, friendly, casual & neutral.'**
  String get modeToneDescription;

  /// No description provided for @modeToneBadge.
  ///
  /// In en, this message translates to:
  /// **'UNIQUE'**
  String get modeToneBadge;

  /// No description provided for @modeToneCta.
  ///
  /// In en, this message translates to:
  /// **'Translate Now'**
  String get modeToneCta;

  /// No description provided for @modeToneQuota.
  ///
  /// In en, this message translates to:
  /// **'10 free translations / day'**
  String get modeToneQuota;

  /// No description provided for @modeGrammarTitle.
  ///
  /// In en, this message translates to:
  /// **'Grammar Coach'**
  String get modeGrammarTitle;

  /// No description provided for @modeGrammarDescription.
  ///
  /// In en, this message translates to:
  /// **'Master English grammar level by level. Pick a structure, drill it, and track your mastery.'**
  String get modeGrammarDescription;

  /// No description provided for @modeGrammarBadge.
  ///
  /// In en, this message translates to:
  /// **'STRUCTURED'**
  String get modeGrammarBadge;

  /// No description provided for @modeGrammarCta.
  ///
  /// In en, this message translates to:
  /// **'Start drilling'**
  String get modeGrammarCta;

  /// No description provided for @modeGrammarQuota.
  ///
  /// In en, this message translates to:
  /// **'Unlimited practice'**
  String get modeGrammarQuota;

  /// No description provided for @modeVocabTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocab Hub'**
  String get modeVocabTitle;

  /// No description provided for @modeVocabDescription.
  ///
  /// In en, this message translates to:
  /// **'Deep-dive into any word. Get analysis, mind maps, examples & spaced repetition flashcards.'**
  String get modeVocabDescription;

  /// No description provided for @modeVocabBadge.
  ///
  /// In en, this message translates to:
  /// **'BUILD SKILLS'**
  String get modeVocabBadge;

  /// No description provided for @modeVocabCta.
  ///
  /// In en, this message translates to:
  /// **'Explore Words'**
  String get modeVocabCta;

  /// No description provided for @modeVocabQuota.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get modeVocabQuota;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navInsight.
  ///
  /// In en, this message translates to:
  /// **'Insight'**
  String get navInsight;

  /// No description provided for @navAiAgent.
  ///
  /// In en, this message translates to:
  /// **'AI Agent'**
  String get navAiAgent;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread} other{{count} unread}}'**
  String navUnreadCount(int count);

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'My Learning Library'**
  String get libraryTitle;

  /// No description provided for @librarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search saved items'**
  String get librarySearchHint;

  /// No description provided for @libraryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get libraryFilterAll;

  /// No description provided for @libraryFilterVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get libraryFilterVocabulary;

  /// No description provided for @libraryFilterGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get libraryFilterGrammar;

  /// No description provided for @libraryFilterAllPos.
  ///
  /// In en, this message translates to:
  /// **'All POS'**
  String get libraryFilterAllPos;

  /// No description provided for @libraryFilterAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get libraryFilterAllCategories;

  /// No description provided for @libraryItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String libraryItemsCount(int count);

  /// No description provided for @libraryDueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} due'**
  String libraryDueCount(int count);

  /// No description provided for @libraryCategoriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} categories'**
  String libraryCategoriesCount(int count);

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved items yet'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap any word in a conversation, story, or translation to save it here.'**
  String get libraryEmptyBody;

  /// No description provided for @libraryShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get libraryShowMore;

  /// No description provided for @libraryShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get libraryShowLess;

  /// No description provided for @libraryLoadingExplanation.
  ///
  /// In en, this message translates to:
  /// **'Loading explanation...'**
  String get libraryLoadingExplanation;

  /// No description provided for @libraryGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get libraryGenerate;

  /// No description provided for @libraryGeneratePro.
  ///
  /// In en, this message translates to:
  /// **'Generate (Pro)'**
  String get libraryGeneratePro;

  /// No description provided for @libraryProUpsell.
  ///
  /// In en, this message translates to:
  /// **'AI illustrations are part of the Pro plan. Upgrade to unlock.'**
  String get libraryProUpsell;

  /// No description provided for @libraryReviewDueIn.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String libraryReviewDueIn(int days);

  /// No description provided for @libraryReviewDueNow.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get libraryReviewDueNow;

  /// No description provided for @libraryBadgeVocab.
  ///
  /// In en, this message translates to:
  /// **'VOCAB'**
  String get libraryBadgeVocab;

  /// No description provided for @libraryBadgeGrammar.
  ///
  /// In en, this message translates to:
  /// **'GRAMMAR'**
  String get libraryBadgeGrammar;

  /// No description provided for @aiAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Agent'**
  String get aiAgentTitle;

  /// No description provided for @aiAgentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help Center + Ask AI'**
  String get aiAgentSubtitle;

  /// No description provided for @aiAgentCategoryGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get aiAgentCategoryGettingStarted;

  /// No description provided for @aiAgentCategoryFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get aiAgentCategoryFeatures;

  /// No description provided for @aiAgentCategoryAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get aiAgentCategoryAccount;

  /// No description provided for @aiAgentCategorySubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription & Billing'**
  String get aiAgentCategorySubscription;

  /// No description provided for @aiAgentCategoryTroubleshooting.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get aiAgentCategoryTroubleshooting;

  /// No description provided for @aiAgentCategoryContact.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get aiAgentCategoryContact;

  /// No description provided for @aiAgentAskAiCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get aiAgentAskAiCardTitle;

  /// No description provided for @aiAgentAskAiCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get instant answers about how Aura works'**
  String get aiAgentAskAiCardSubtitle;

  /// No description provided for @aiAgentAskAiCardCta.
  ///
  /// In en, this message translates to:
  /// **'Ask now'**
  String get aiAgentAskAiCardCta;

  /// No description provided for @vocabHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocab Hub'**
  String get vocabHubTitle;

  /// No description provided for @vocabHubSectionFreeTools.
  ///
  /// In en, this message translates to:
  /// **'Free tools'**
  String get vocabHubSectionFreeTools;

  /// No description provided for @vocabHubSectionProTools.
  ///
  /// In en, this message translates to:
  /// **'Pro tools'**
  String get vocabHubSectionProTools;

  /// No description provided for @vocabHubCardWordAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Word Analysis'**
  String get vocabHubCardWordAnalysis;

  /// No description provided for @vocabHubCardDescribeWord.
  ///
  /// In en, this message translates to:
  /// **'Describe Word'**
  String get vocabHubCardDescribeWord;

  /// No description provided for @vocabHubCardFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get vocabHubCardFlashcards;

  /// No description provided for @vocabHubCardCompareWords.
  ///
  /// In en, this message translates to:
  /// **'Compare Words'**
  String get vocabHubCardCompareWords;

  /// No description provided for @vocabHubCardLearningLibrary.
  ///
  /// In en, this message translates to:
  /// **'Learning Library'**
  String get vocabHubCardLearningLibrary;

  /// No description provided for @vocabHubCardProgressDashboard.
  ///
  /// In en, this message translates to:
  /// **'Progress Dashboard'**
  String get vocabHubCardProgressDashboard;

  /// No description provided for @vocabHubCardMindMaps.
  ///
  /// In en, this message translates to:
  /// **'Mind Maps'**
  String get vocabHubCardMindMaps;

  /// No description provided for @vocabWordAnalysisHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a word to analyze'**
  String get vocabWordAnalysisHint;

  /// No description provided for @vocabWordAnalyzeCta.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get vocabWordAnalyzeCta;

  /// No description provided for @vocabWordSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved \"{word}\" to your library'**
  String vocabWordSavedSnack(String word);

  /// No description provided for @vocabMindMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Mind Maps'**
  String get vocabMindMapTitle;

  /// No description provided for @vocabMindMapHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a topic, e.g. Travel'**
  String get vocabMindMapHint;

  /// No description provided for @vocabMindMapGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get vocabMindMapGenerate;

  /// No description provided for @vocabMindMapMyMaps.
  ///
  /// In en, this message translates to:
  /// **'My maps'**
  String get vocabMindMapMyMaps;

  /// No description provided for @vocabMindMapUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get vocabMindMapUndo;

  /// No description provided for @vocabMindMapProTitle.
  ///
  /// In en, this message translates to:
  /// **'Mind Map is a Pro feature'**
  String get vocabMindMapProTitle;

  /// No description provided for @vocabMindMapMyMapsTitle.
  ///
  /// In en, this message translates to:
  /// **'My mind maps'**
  String get vocabMindMapMyMapsTitle;

  /// No description provided for @vocabMindMapDeleteSnack.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{topic}\"'**
  String vocabMindMapDeleteSnack(String topic);

  /// No description provided for @vocabMindMapNodesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 node} other{{count} nodes}}'**
  String vocabMindMapNodesCount(int count);

  /// No description provided for @vocabMindMapDepth.
  ///
  /// In en, this message translates to:
  /// **'depth {value}'**
  String vocabMindMapDepth(int value);

  /// No description provided for @vocabMindMapFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'from Library'**
  String get vocabMindMapFromLibrary;

  /// No description provided for @vocabMindMapNodeRemovedSnack.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{label}\" from library'**
  String vocabMindMapNodeRemovedSnack(String label);

  /// No description provided for @vocabMindMapNodeAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Added \"{word}\" under this node'**
  String vocabMindMapNodeAddedSnack(String word);

  /// No description provided for @vocabMindMapNodeDeletedSnack.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{label}\"'**
  String vocabMindMapNodeDeletedSnack(String label);

  /// No description provided for @vocabMindMapExpandViaAi.
  ///
  /// In en, this message translates to:
  /// **'Expand via AI'**
  String get vocabMindMapExpandViaAi;

  /// No description provided for @vocabMindMapAddWord.
  ///
  /// In en, this message translates to:
  /// **'+ Add word'**
  String get vocabMindMapAddWord;

  /// No description provided for @vocabMindMapSaveToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Save to library'**
  String get vocabMindMapSaveToLibrary;

  /// No description provided for @vocabMindMapAddWordHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. boarding pass'**
  String get vocabMindMapAddWordHint;

  /// No description provided for @vocabMindMapMindMapCta.
  ///
  /// In en, this message translates to:
  /// **'Mind Map 🧠'**
  String get vocabMindMapMindMapCta;

  /// No description provided for @vocabFlashcardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get vocabFlashcardsTitle;

  /// No description provided for @vocabFlashcardsPracticeCta.
  ///
  /// In en, this message translates to:
  /// **'Practice 10 cards'**
  String get vocabFlashcardsPracticeCta;

  /// No description provided for @vocabFlashcardsStudyMoreCta.
  ///
  /// In en, this message translates to:
  /// **'Study 10 more'**
  String get vocabFlashcardsStudyMoreCta;

  /// No description provided for @vocabFlashcardsAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Added {count} {topic} cards to your library'**
  String vocabFlashcardsAddedSnack(int count, String topic);

  /// No description provided for @vocabFlashcardsAlreadyHaveSnack.
  ///
  /// In en, this message translates to:
  /// **'All {topic} picks are already in your library'**
  String vocabFlashcardsAlreadyHaveSnack(String topic);

  /// No description provided for @vocabFlashcardsRatingHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get vocabFlashcardsRatingHard;

  /// No description provided for @vocabFlashcardsRatingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get vocabFlashcardsRatingGood;

  /// No description provided for @vocabFlashcardsRatingEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get vocabFlashcardsRatingEasy;

  /// No description provided for @vocabCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare Words'**
  String get vocabCompareTitle;

  /// No description provided for @vocabCompareTryAPair.
  ///
  /// In en, this message translates to:
  /// **'Try a pair'**
  String get vocabCompareTryAPair;

  /// No description provided for @vocabCompareWordA.
  ///
  /// In en, this message translates to:
  /// **'WORD A'**
  String get vocabCompareWordA;

  /// No description provided for @vocabCompareWordB.
  ///
  /// In en, this message translates to:
  /// **'WORD B'**
  String get vocabCompareWordB;

  /// No description provided for @vocabCompareKeyDifference.
  ///
  /// In en, this message translates to:
  /// **'Key difference'**
  String get vocabCompareKeyDifference;

  /// No description provided for @vocabCompareWhenToUse.
  ///
  /// In en, this message translates to:
  /// **'Use \"{word}\" when'**
  String vocabCompareWhenToUse(String word);

  /// No description provided for @vocabCompareSectionDefinition.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get vocabCompareSectionDefinition;

  /// No description provided for @vocabCompareSectionExample.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get vocabCompareSectionExample;

  /// No description provided for @vocabCompareSectionCollocations.
  ///
  /// In en, this message translates to:
  /// **'Collocations'**
  String get vocabCompareSectionCollocations;

  /// No description provided for @vocabDescribeTitle.
  ///
  /// In en, this message translates to:
  /// **'Describe Word'**
  String get vocabDescribeTitle;

  /// No description provided for @vocabDescribeHint.
  ///
  /// In en, this message translates to:
  /// **'VD: cảm giác buồn nhẹ khi nhớ chuyện cũ'**
  String get vocabDescribeHint;

  /// No description provided for @vocabAnalysisExamples.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get vocabAnalysisExamples;

  /// No description provided for @vocabAnalysisExamplePositive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get vocabAnalysisExamplePositive;

  /// No description provided for @vocabAnalysisExampleNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get vocabAnalysisExampleNeutral;

  /// No description provided for @vocabAnalysisExampleNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get vocabAnalysisExampleNegative;

  /// No description provided for @vocabAnalysisCollocations.
  ///
  /// In en, this message translates to:
  /// **'Collocations'**
  String get vocabAnalysisCollocations;

  /// No description provided for @vocabAnalysisWordFamily.
  ///
  /// In en, this message translates to:
  /// **'Word family'**
  String get vocabAnalysisWordFamily;

  /// No description provided for @vocabAnalysisSynonyms.
  ///
  /// In en, this message translates to:
  /// **'Synonyms'**
  String get vocabAnalysisSynonyms;

  /// No description provided for @vocabAnalysisAntonyms.
  ///
  /// In en, this message translates to:
  /// **'Antonyms'**
  String get vocabAnalysisAntonyms;

  /// No description provided for @vocabProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress Dashboard'**
  String get vocabProgressTitle;

  /// No description provided for @vocabProgressSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get vocabProgressSaved;

  /// No description provided for @vocabProgressDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get vocabProgressDueToday;

  /// No description provided for @vocabProgressMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get vocabProgressMastered;

  /// No description provided for @vocabProgressByPos.
  ///
  /// In en, this message translates to:
  /// **'By part of speech'**
  String get vocabProgressByPos;

  /// No description provided for @vocabProgressKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get vocabProgressKeepGoing;

  /// No description provided for @vocabProgressLegendMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered · {count}'**
  String vocabProgressLegendMastered(int count);

  /// No description provided for @vocabProgressLegendLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning · {count}'**
  String vocabProgressLegendLearning(int count);

  /// No description provided for @vocabProgressLegendNew.
  ///
  /// In en, this message translates to:
  /// **'New · {count}'**
  String vocabProgressLegendNew(int count);

  /// No description provided for @vocabProgressEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved words yet'**
  String get vocabProgressEmptyTitle;

  /// No description provided for @vocabProgressEmptyAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze a word'**
  String get vocabProgressEmptyAnalyze;

  /// No description provided for @vocabLearningLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Library'**
  String get vocabLearningLibraryTitle;

  /// No description provided for @vocabHubCardWordAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation, 3 examples, synonyms & antonyms'**
  String get vocabHubCardWordAnalysisDesc;

  /// No description provided for @vocabHubCardDescribeWordDesc.
  ///
  /// In en, this message translates to:
  /// **'Describe in Vietnamese → get the English word'**
  String get vocabHubCardDescribeWordDesc;

  /// No description provided for @vocabHubCardFlashcardsDesc.
  ///
  /// In en, this message translates to:
  /// **'SM-2 spaced repetition — review at the perfect time'**
  String get vocabHubCardFlashcardsDesc;

  /// No description provided for @vocabHubCardCompareWordsDesc.
  ///
  /// In en, this message translates to:
  /// **'Side-by-side nuance: \"affect\" vs \"effect\"'**
  String get vocabHubCardCompareWordsDesc;

  /// No description provided for @vocabHubCardLearningLibraryDesc.
  ///
  /// In en, this message translates to:
  /// **'All saved words from every mode in one place'**
  String get vocabHubCardLearningLibraryDesc;

  /// No description provided for @vocabHubCardProgressDashboardDesc.
  ///
  /// In en, this message translates to:
  /// **'Track total, due reviews & mastered at a glance'**
  String get vocabHubCardProgressDashboardDesc;

  /// No description provided for @vocabHubCardMindMapsDesc.
  ///
  /// In en, this message translates to:
  /// **'Visual word relationships — synonyms, antonyms & related'**
  String get vocabHubCardMindMapsDesc;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSectionNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationsSectionNew;

  /// No description provided for @notificationsSectionEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notificationsSectionEarlier;

  /// No description provided for @notificationsRemovedSnack.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{title}\"'**
  String notificationsRemovedSnack(String title);

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders, streak nudges, and review prompts will show up here.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpTitle;

  /// No description provided for @helpSectionQuickGuides.
  ///
  /// In en, this message translates to:
  /// **'Quick guides'**
  String get helpSectionQuickGuides;

  /// No description provided for @helpSectionFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get helpSectionFaq;

  /// No description provided for @helpSectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get helpSectionContact;

  /// No description provided for @helpAskAuraTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask Aura'**
  String get helpAskAuraTitle;

  /// No description provided for @helpAskAuraSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about how to use the app — Aura answers right away in your language.'**
  String get helpAskAuraSubtitle;

  /// No description provided for @helpAskAuraStartChat.
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get helpAskAuraStartChat;

  /// No description provided for @helpContactEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get helpContactEmailLabel;

  /// No description provided for @helpContactHotlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Hotline'**
  String get helpContactHotlineLabel;

  /// No description provided for @helpContactCopyEmailToast.
  ///
  /// In en, this message translates to:
  /// **'Copied email to clipboard'**
  String get helpContactCopyEmailToast;

  /// No description provided for @helpContactCopyHotlineToast.
  ///
  /// In en, this message translates to:
  /// **'Copied hotline to clipboard'**
  String get helpContactCopyHotlineToast;

  /// No description provided for @helpFeedbackButton.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get helpFeedbackButton;

  /// No description provided for @helpFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Send us feedback'**
  String get helpFeedbackTitle;

  /// No description provided for @helpFeedbackBody.
  ///
  /// In en, this message translates to:
  /// **'Bug, idea, or just a thought — drop it below. We read every one.'**
  String get helpFeedbackBody;

  /// No description provided for @helpFeedbackHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get helpFeedbackHint;

  /// No description provided for @helpFeedbackSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get helpFeedbackSendButton;

  /// No description provided for @helpFeedbackThanksToast.
  ///
  /// In en, this message translates to:
  /// **'Thanks! We\'ll review your feedback shortly.'**
  String get helpFeedbackThanksToast;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insight'**
  String get insightsTitle;

  /// No description provided for @insightsTabLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get insightsTabLibrary;

  /// No description provided for @insightsTabStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get insightsTabStats;

  /// No description provided for @conversationHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversation History'**
  String get conversationHistoryTitle;

  /// No description provided for @conversationHistoryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get conversationHistoryFilterAll;

  /// No description provided for @conversationHistoryFilterScenario.
  ///
  /// In en, this message translates to:
  /// **'Scenario'**
  String get conversationHistoryFilterScenario;

  /// No description provided for @conversationHistoryFilterStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get conversationHistoryFilterStory;

  /// No description provided for @conversationHistoryFilterTranslator.
  ///
  /// In en, this message translates to:
  /// **'Translator'**
  String get conversationHistoryFilterTranslator;

  /// No description provided for @conversationHistoryRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename conversation'**
  String get conversationHistoryRenameTitle;

  /// No description provided for @conversationHistoryRenameHint.
  ///
  /// In en, this message translates to:
  /// **'Conversation title'**
  String get conversationHistoryRenameHint;

  /// No description provided for @conversationHistoryRenameFailed.
  ///
  /// In en, this message translates to:
  /// **'Rename failed. Please try again.'**
  String get conversationHistoryRenameFailed;

  /// No description provided for @conversationHistoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation?'**
  String get conversationHistoryDeleteTitle;

  /// No description provided for @conversationHistoryDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This conversation will be permanently removed from your history.'**
  String get conversationHistoryDeleteBody;

  /// No description provided for @conversationHistoryDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed. Please try again.'**
  String get conversationHistoryDeleteFailed;

  /// No description provided for @conversationHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversation history yet'**
  String get conversationHistoryEmptyTitle;

  /// No description provided for @conversationHistoryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Start a roleplay scenario to see your history here'**
  String get conversationHistoryEmptyBody;

  /// No description provided for @conversationHistoryStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get conversationHistoryStatusCompleted;

  /// No description provided for @conversationHistoryStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get conversationHistoryStatusInProgress;

  /// No description provided for @conversationHistoryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get conversationHistoryDateLabel;

  /// No description provided for @conversationHistoryDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get conversationHistoryDurationLabel;

  /// No description provided for @conversationHistoryTurnsLabel.
  ///
  /// In en, this message translates to:
  /// **'Turns'**
  String get conversationHistoryTurnsLabel;

  /// No description provided for @conversationHistoryScoreBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Score Breakdown'**
  String get conversationHistoryScoreBreakdownTitle;

  /// No description provided for @conversationHistoryScoreOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get conversationHistoryScoreOverall;

  /// No description provided for @conversationHistoryScoreGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get conversationHistoryScoreGrammar;

  /// No description provided for @conversationHistoryScoreVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get conversationHistoryScoreVocabulary;

  /// No description provided for @conversationHistoryScoreFluency.
  ///
  /// In en, this message translates to:
  /// **'Fluency'**
  String get conversationHistoryScoreFluency;

  /// No description provided for @conversationHistoryReplayComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Tap to replay coming soon'**
  String get conversationHistoryReplayComingSoon;

  /// No description provided for @conversationHistoryYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get conversationHistoryYesterday;

  /// No description provided for @conversationHistoryUnknownTopic.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get conversationHistoryUnknownTopic;

  /// No description provided for @conversationHistoryFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Roleplay'**
  String get conversationHistoryFallbackTitle;

  /// No description provided for @conversationHistoryMoreMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get conversationHistoryMoreMenuTooltip;

  /// No description provided for @conversationHistoryRenameAction.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get conversationHistoryRenameAction;

  /// No description provided for @conversationHistoryDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get conversationHistoryDeleteAction;

  /// No description provided for @conversationHistoryModeVocab.
  ///
  /// In en, this message translates to:
  /// **'Vocab'**
  String get conversationHistoryModeVocab;

  /// No description provided for @conversationHistoryModeSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get conversationHistoryModeSession;

  /// No description provided for @conversationHistoryRelativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get conversationHistoryRelativeJustNow;

  /// No description provided for @conversationHistoryRelativeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String conversationHistoryRelativeMinutesAgo(int minutes);

  /// No description provided for @conversationHistoryRelativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String conversationHistoryRelativeHoursAgo(int hours);

  /// No description provided for @conversationHistoryRelativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String conversationHistoryRelativeDaysAgo(int days);

  /// No description provided for @storageQuotaCapTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage full — delete or upgrade to start new'**
  String get storageQuotaCapTitle;

  /// No description provided for @storageQuotaWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage almost full'**
  String get storageQuotaWarningTitle;

  /// No description provided for @storageQuotaUsage.
  ///
  /// In en, this message translates to:
  /// **'{used}/{cap} conversations used.'**
  String storageQuotaUsage(int used, int cap);

  /// No description provided for @storageQuotaManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get storageQuotaManage;

  /// No description provided for @storageQuotaUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get storageQuotaUpgrade;

  /// No description provided for @storageQuotaModeScenario.
  ///
  /// In en, this message translates to:
  /// **'Scenario'**
  String get storageQuotaModeScenario;

  /// No description provided for @storageQuotaModeStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get storageQuotaModeStory;

  /// No description provided for @scenarioAppBarMeta.
  ///
  /// In en, this message translates to:
  /// **'{emoji} {category} · {level} · Scenario #{index}'**
  String scenarioAppBarMeta(
      String emoji, String category, String level, int index);

  /// No description provided for @scenarioLoadingPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your scenario...'**
  String get scenarioLoadingPreparing;

  /// No description provided for @scenarioErrorNoScenarioLoaded.
  ///
  /// In en, this message translates to:
  /// **'No scenario loaded'**
  String get scenarioErrorNoScenarioLoaded;

  /// No description provided for @scenarioErrorBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get scenarioErrorBackToHome;

  /// No description provided for @scenarioEndSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'End this session?'**
  String get scenarioEndSessionTitle;

  /// No description provided for @scenarioEndSessionBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll grade your conversation and add it to your history.'**
  String get scenarioEndSessionBody;

  /// No description provided for @scenarioEndSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get scenarioEndSessionConfirm;

  /// No description provided for @scenarioEndSessionKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get scenarioEndSessionKeepGoing;

  /// No description provided for @endSessionDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'End this session?'**
  String get endSessionDefaultTitle;

  /// No description provided for @endSessionContinueLabel.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get endSessionContinueLabel;

  /// No description provided for @endSessionEndReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'End & review'**
  String get endSessionEndReviewLabel;

  /// No description provided for @endSessionStatTurns.
  ///
  /// In en, this message translates to:
  /// **'Turns'**
  String get endSessionStatTurns;

  /// No description provided for @endSessionStatAvgScore.
  ///
  /// In en, this message translates to:
  /// **'Avg score'**
  String get endSessionStatAvgScore;

  /// No description provided for @endSessionStatDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get endSessionStatDuration;

  /// No description provided for @endSessionBestLine.
  ///
  /// In en, this message translates to:
  /// **'Best line: \"{preview}\"'**
  String endSessionBestLine(String preview);

  /// No description provided for @endSessionScenarioQuotaRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remaining}/{limit} sessions left today'**
  String endSessionScenarioQuotaRemaining(int remaining, int limit);

  /// No description provided for @endSessionStoryQuotaRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remaining}/{limit} stories left today'**
  String endSessionStoryQuotaRemaining(int remaining, int limit);

  /// No description provided for @storyEndSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'End this story?'**
  String get storyEndSessionTitle;

  /// No description provided for @chatSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved: {item}'**
  String chatSavedSnack(String item);

  /// No description provided for @grammarHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Grammar Coach'**
  String get grammarHubTitle;

  /// No description provided for @grammarHubMasteredCounter.
  ///
  /// In en, this message translates to:
  /// **'{mastered}/{total} mastered'**
  String grammarHubMasteredCounter(int mastered, int total);

  /// No description provided for @grammarHubHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Master grammar by level'**
  String get grammarHubHeroTitle;

  /// No description provided for @grammarHubHeroTagline.
  ///
  /// In en, this message translates to:
  /// **'Pick a structure, drill it, track mastery'**
  String get grammarHubHeroTagline;

  /// No description provided for @grammarHubSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search topics'**
  String get grammarHubSearchHint;

  /// No description provided for @grammarHubFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get grammarHubFilterAll;

  /// No description provided for @grammarHubCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get grammarHubCategoryAll;

  /// No description provided for @grammarHubCategoryTense.
  ///
  /// In en, this message translates to:
  /// **'Tense'**
  String get grammarHubCategoryTense;

  /// No description provided for @grammarHubCategoryModal.
  ///
  /// In en, this message translates to:
  /// **'Modal'**
  String get grammarHubCategoryModal;

  /// No description provided for @grammarHubCategoryConditional.
  ///
  /// In en, this message translates to:
  /// **'Conditional'**
  String get grammarHubCategoryConditional;

  /// No description provided for @grammarHubCategoryPassive.
  ///
  /// In en, this message translates to:
  /// **'Passive'**
  String get grammarHubCategoryPassive;

  /// No description provided for @grammarHubCategoryReported.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get grammarHubCategoryReported;

  /// No description provided for @grammarHubCategoryClause.
  ///
  /// In en, this message translates to:
  /// **'Clause'**
  String get grammarHubCategoryClause;

  /// No description provided for @grammarHubCategoryComparison.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get grammarHubCategoryComparison;

  /// No description provided for @grammarHubCategoryLinkingInversion.
  ///
  /// In en, this message translates to:
  /// **'Linking & Inversion'**
  String get grammarHubCategoryLinkingInversion;

  /// No description provided for @grammarHubCategoryArticleQuantifier.
  ///
  /// In en, this message translates to:
  /// **'Articles & Quantifiers'**
  String get grammarHubCategoryArticleQuantifier;

  /// No description provided for @grammarHubCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get grammarHubCategoryOther;

  /// No description provided for @grammarHubMasteryNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get grammarHubMasteryNotStarted;

  /// No description provided for @grammarHubMasteryLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get grammarHubMasteryLearning;

  /// No description provided for @grammarHubMasteryMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get grammarHubMasteryMastered;

  /// No description provided for @grammarHubTopicMetaNew.
  ///
  /// In en, this message translates to:
  /// **'Tap to learn the formula'**
  String get grammarHubTopicMetaNew;

  /// No description provided for @grammarHubTopicMetaProgress.
  ///
  /// In en, this message translates to:
  /// **'{attempts} attempts · {accuracy}% accuracy'**
  String grammarHubTopicMetaProgress(int attempts, int accuracy);

  /// No description provided for @grammarHubEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No topics match this filter'**
  String get grammarHubEmptyTitle;

  /// No description provided for @grammarHubEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try clearing the level or category filter.'**
  String get grammarHubEmptyBody;

  /// No description provided for @grammarTopicNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Topic not found'**
  String get grammarTopicNotFoundTitle;

  /// No description provided for @grammarTopicNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The grammar topic you\'re looking for is no longer in the catalog.'**
  String get grammarTopicNotFoundBody;

  /// No description provided for @grammarTopicSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get grammarTopicSummaryTitle;

  /// No description provided for @grammarTopicWhenToUseTitle.
  ///
  /// In en, this message translates to:
  /// **'When to use'**
  String get grammarTopicWhenToUseTitle;

  /// No description provided for @grammarTopicExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get grammarTopicExamplesTitle;

  /// No description provided for @grammarTopicMistakesTitle.
  ///
  /// In en, this message translates to:
  /// **'Common mistakes'**
  String get grammarTopicMistakesTitle;

  /// No description provided for @grammarTopicRelatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Related topics'**
  String get grammarTopicRelatedTitle;

  /// No description provided for @grammarTopicListenA11y.
  ///
  /// In en, this message translates to:
  /// **'Play example audio'**
  String get grammarTopicListenA11y;

  /// No description provided for @grammarTopicNoContentBody.
  ///
  /// In en, this message translates to:
  /// **'Detailed content for this topic is coming soon.'**
  String get grammarTopicNoContentBody;

  /// No description provided for @grammarStartPracticeCta.
  ///
  /// In en, this message translates to:
  /// **'Start practice'**
  String get grammarStartPracticeCta;

  /// No description provided for @grammarPracticePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your practice mode'**
  String get grammarPracticePickerTitle;

  /// No description provided for @grammarPracticePickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each mode focuses on a different skill. You can switch between sessions.'**
  String get grammarPracticePickerSubtitle;

  /// No description provided for @grammarPracticeModeTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get grammarPracticeModeTranslate;

  /// No description provided for @grammarPracticeModeTranslateSub.
  ///
  /// In en, this message translates to:
  /// **'EN ↔ VI sentence translation using this structure.'**
  String get grammarPracticeModeTranslateSub;

  /// No description provided for @grammarPracticeModeFillBlank.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank'**
  String get grammarPracticeModeFillBlank;

  /// No description provided for @grammarPracticeModeFillBlankSub.
  ///
  /// In en, this message translates to:
  /// **'Pick or type the correct form to complete a sentence.'**
  String get grammarPracticeModeFillBlankSub;

  /// No description provided for @grammarPracticeModeTransform.
  ///
  /// In en, this message translates to:
  /// **'Transform'**
  String get grammarPracticeModeTransform;

  /// No description provided for @grammarPracticeModeTransformSub.
  ///
  /// In en, this message translates to:
  /// **'Rewrite an English sentence into the correct tense from a Vietnamese hint.'**
  String get grammarPracticeModeTransformSub;

  /// No description provided for @grammarPracticeAttemptsLabel.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get grammarPracticeAttemptsLabel;

  /// No description provided for @grammarPracticeAccuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get grammarPracticeAccuracyLabel;

  /// No description provided for @grammarPracticeStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get grammarPracticeStreakLabel;

  /// No description provided for @grammarPracticeModeTagTranslateEnVi.
  ///
  /// In en, this message translates to:
  /// **'TRANSLATE · EN → VI'**
  String get grammarPracticeModeTagTranslateEnVi;

  /// No description provided for @grammarPracticeModeTagTranslateViEn.
  ///
  /// In en, this message translates to:
  /// **'TRANSLATE · VI → EN'**
  String get grammarPracticeModeTagTranslateViEn;

  /// No description provided for @grammarPracticeModeTagFillBlank.
  ///
  /// In en, this message translates to:
  /// **'FILL IN THE BLANK'**
  String get grammarPracticeModeTagFillBlank;

  /// No description provided for @grammarPracticeModeTagTransform.
  ///
  /// In en, this message translates to:
  /// **'TRANSFORM'**
  String get grammarPracticeModeTagTransform;

  /// No description provided for @grammarPracticeHintLabel.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get grammarPracticeHintLabel;

  /// No description provided for @grammarPracticeInputHintTranslate.
  ///
  /// In en, this message translates to:
  /// **'Type your translation…'**
  String get grammarPracticeInputHintTranslate;

  /// No description provided for @grammarPracticeInputHintFillBlank.
  ///
  /// In en, this message translates to:
  /// **'Type the missing word(s)…'**
  String get grammarPracticeInputHintFillBlank;

  /// No description provided for @grammarPracticeInputHintTransform.
  ///
  /// In en, this message translates to:
  /// **'Rewrite the sentence using the target structure…'**
  String get grammarPracticeInputHintTransform;

  /// No description provided for @grammarPracticeCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get grammarPracticeCheck;

  /// No description provided for @grammarPracticeNext.
  ///
  /// In en, this message translates to:
  /// **'Next →'**
  String get grammarPracticeNext;

  /// No description provided for @grammarPracticeEndSession.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get grammarPracticeEndSession;

  /// No description provided for @grammarPracticeEndConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'End this session?'**
  String get grammarPracticeEndConfirmTitle;

  /// No description provided for @grammarPracticeEndConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Your attempts will be saved and you\'ll see the summary.'**
  String get grammarPracticeEndConfirmBody;

  /// No description provided for @grammarPracticeEndKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get grammarPracticeEndKeepGoing;

  /// No description provided for @grammarPracticeEndConfirm.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get grammarPracticeEndConfirm;

  /// No description provided for @grammarPracticeResultCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get grammarPracticeResultCorrect;

  /// No description provided for @grammarPracticeResultIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Not quite'**
  String get grammarPracticeResultIncorrect;

  /// No description provided for @grammarPracticeResultYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get grammarPracticeResultYourAnswer;

  /// No description provided for @grammarPracticeResultAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get grammarPracticeResultAccepted;

  /// No description provided for @grammarPracticeResultCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get grammarPracticeResultCorrectAnswer;

  /// No description provided for @grammarPracticeResultFullSentence.
  ///
  /// In en, this message translates to:
  /// **'Full sentence'**
  String get grammarPracticeResultFullSentence;

  /// No description provided for @grammarPracticeResultExtraExample.
  ///
  /// In en, this message translates to:
  /// **'Same pattern'**
  String get grammarPracticeResultExtraExample;

  /// No description provided for @grammarPracticeSaveToLibrary.
  ///
  /// In en, this message translates to:
  /// **'⭐ Save to Library'**
  String get grammarPracticeSaveToLibrary;

  /// No description provided for @grammarPracticeSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved to Library'**
  String get grammarPracticeSavedSnack;

  /// No description provided for @grammarPracticeGenerating.
  ///
  /// In en, this message translates to:
  /// **'Building your next exercise…'**
  String get grammarPracticeGenerating;

  /// No description provided for @grammarPracticeError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t generate exercise'**
  String get grammarPracticeError;

  /// No description provided for @grammarPracticeRetry.
  ///
  /// In en, this message translates to:
  /// **'Try another'**
  String get grammarPracticeRetry;

  /// No description provided for @grammarSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Session summary'**
  String get grammarSummaryTitle;

  /// No description provided for @grammarSummaryHeadlineMastered.
  ///
  /// In en, this message translates to:
  /// **'Great work! You mastered this round.'**
  String get grammarSummaryHeadlineMastered;

  /// No description provided for @grammarSummaryHeadlineProgress.
  ///
  /// In en, this message translates to:
  /// **'Solid progress — keep practicing.'**
  String get grammarSummaryHeadlineProgress;

  /// No description provided for @grammarSummaryHeadlineRough.
  ///
  /// In en, this message translates to:
  /// **'Tough round. Review and retry.'**
  String get grammarSummaryHeadlineRough;

  /// No description provided for @grammarSummaryHeadlineEmpty.
  ///
  /// In en, this message translates to:
  /// **'Session ended without any attempts.'**
  String get grammarSummaryHeadlineEmpty;

  /// No description provided for @grammarSummaryStatAttempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get grammarSummaryStatAttempts;

  /// No description provided for @grammarSummaryStatAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get grammarSummaryStatAccuracy;

  /// No description provided for @grammarSummaryStatDuration.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get grammarSummaryStatDuration;

  /// No description provided for @grammarSummaryStatMastery.
  ///
  /// In en, this message translates to:
  /// **'Mastery'**
  String get grammarSummaryStatMastery;

  /// No description provided for @grammarSummaryMasteryDelta.
  ///
  /// In en, this message translates to:
  /// **'{sign}{value}%'**
  String grammarSummaryMasteryDelta(String sign, String value);

  /// No description provided for @grammarSummaryDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String grammarSummaryDurationMinutes(int minutes, int seconds);

  /// No description provided for @grammarSummaryDurationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String grammarSummaryDurationSeconds(int seconds);

  /// No description provided for @grammarSummaryMistakesTitle.
  ///
  /// In en, this message translates to:
  /// **'What to revisit'**
  String get grammarSummaryMistakesTitle;

  /// No description provided for @grammarSummaryMistakesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No mistakes this round — nicely done.'**
  String get grammarSummaryMistakesEmpty;

  /// No description provided for @grammarSummaryMistakeYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get grammarSummaryMistakeYou;

  /// No description provided for @grammarSummaryMistakeCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get grammarSummaryMistakeCorrect;

  /// No description provided for @grammarSummarySaveAllMistakes.
  ///
  /// In en, this message translates to:
  /// **'Save mistakes to Library'**
  String get grammarSummarySaveAllMistakes;

  /// No description provided for @grammarSummarySaveAllSnack.
  ///
  /// In en, this message translates to:
  /// **'{count} mistake(s) saved to Library'**
  String grammarSummarySaveAllSnack(int count);

  /// No description provided for @grammarSummaryPracticeAgain.
  ///
  /// In en, this message translates to:
  /// **'Practice again'**
  String get grammarSummaryPracticeAgain;

  /// No description provided for @grammarSummaryBackToTopic.
  ///
  /// In en, this message translates to:
  /// **'Back to topic'**
  String get grammarSummaryBackToTopic;

  /// No description provided for @grammarSummaryBackToHub.
  ///
  /// In en, this message translates to:
  /// **'Back to all topics'**
  String get grammarSummaryBackToHub;

  /// No description provided for @assessmentGrammarBreakdownHeader.
  ///
  /// In en, this message translates to:
  /// **'GRAMMAR BREAKDOWN'**
  String get assessmentGrammarBreakdownHeader;

  /// No description provided for @assessmentGrammarBreakdownYourSentence.
  ///
  /// In en, this message translates to:
  /// **'YOUR SENTENCE'**
  String get assessmentGrammarBreakdownYourSentence;

  /// No description provided for @assessmentGrammarBreakdownYourSentenceCorrect.
  ///
  /// In en, this message translates to:
  /// **'YOUR SENTENCE — Correct'**
  String get assessmentGrammarBreakdownYourSentenceCorrect;

  /// No description provided for @assessmentGrammarBreakdownCorrectSentence.
  ///
  /// In en, this message translates to:
  /// **'STANDARD SENTENCE'**
  String get assessmentGrammarBreakdownCorrectSentence;

  /// No description provided for @assessmentGrammarBreakdownComponents.
  ///
  /// In en, this message translates to:
  /// **'SENTENCE COMPONENTS'**
  String get assessmentGrammarBreakdownComponents;

  /// No description provided for @assessmentGrammarBreakdownAuxiliaries.
  ///
  /// In en, this message translates to:
  /// **'AUXILIARIES'**
  String get assessmentGrammarBreakdownAuxiliaries;

  /// No description provided for @assessmentGrammarBreakdownPatternPrefix.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get assessmentGrammarBreakdownPatternPrefix;

  /// No description provided for @sessionPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'SESSION'**
  String get sessionPanelTitle;

  /// No description provided for @sessionPanelCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{scenario} other{scenarios}}'**
  String sessionPanelCount(int count);

  /// No description provided for @sessionPanelAvg.
  ///
  /// In en, this message translates to:
  /// **'Avg ⭐ {avg}'**
  String sessionPanelAvg(String avg);

  /// No description provided for @sessionPanelFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get sessionPanelFilterAll;

  /// No description provided for @sessionPanelFilterExcellent.
  ///
  /// In en, this message translates to:
  /// **'⭐ 9+'**
  String get sessionPanelFilterExcellent;

  /// No description provided for @sessionPanelFilterGood.
  ///
  /// In en, this message translates to:
  /// **'⭐ 7-8'**
  String get sessionPanelFilterGood;

  /// No description provided for @sessionPanelFilterNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'⭐ <7'**
  String get sessionPanelFilterNeedsWork;

  /// No description provided for @sessionPanelEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No scenarios yet'**
  String get sessionPanelEmptyTitle;

  /// No description provided for @sessionPanelEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Complete a scenario to see it here.'**
  String get sessionPanelEmptyBody;

  /// No description provided for @sessionPanelFilterEmpty.
  ///
  /// In en, this message translates to:
  /// **'No scenarios match this filter.'**
  String get sessionPanelFilterEmpty;

  /// No description provided for @sessionPanelActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get sessionPanelActiveLabel;

  /// No description provided for @sessionPanelTimeNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get sessionPanelTimeNow;

  /// No description provided for @sessionPanelTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String sessionPanelTimeMinutes(int minutes);

  /// No description provided for @sessionPanelTimeHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String sessionPanelTimeHours(int hours);

  /// No description provided for @sessionPanelTimeYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get sessionPanelTimeYesterday;

  /// No description provided for @sessionPanelTimeOlder.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String sessionPanelTimeOlder(int days);

  /// No description provided for @sessionPanelEndSessionCta.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get sessionPanelEndSessionCta;

  /// No description provided for @sessionPanelEndConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'End this session?'**
  String get sessionPanelEndConfirmTitle;

  /// No description provided for @sessionPanelEndConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll go back to the home screen. You can start a new session anytime.'**
  String get sessionPanelEndConfirmBody;

  /// No description provided for @sessionPanelEndConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get sessionPanelEndConfirmAction;

  /// No description provided for @sessionPanelEndConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep practicing'**
  String get sessionPanelEndConfirmCancel;

  /// No description provided for @replayTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay #{order}'**
  String replayTitle(int order);

  /// No description provided for @replayBannerText.
  ///
  /// In en, this message translates to:
  /// **'Replay mode — read only'**
  String get replayBannerText;

  /// No description provided for @replayLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading replay…'**
  String get replayLoading;

  /// No description provided for @replayLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load this scenario'**
  String get replayLoadErrorTitle;

  /// No description provided for @replayLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'The conversation may have been deleted or your connection dropped. Try again from the session panel.'**
  String get replayLoadErrorBody;

  /// No description provided for @replayLoadErrorBack.
  ///
  /// In en, this message translates to:
  /// **'Back to session'**
  String get replayLoadErrorBack;

  /// No description provided for @replayBranchSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'BRANCH FROM THIS SCENARIO'**
  String get replayBranchSectionTitle;

  /// No description provided for @replayBranchSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a difficulty to start a new scenario in this session. The replayed one stays unchanged.'**
  String get replayBranchSectionSubtitle;

  /// No description provided for @replayBranchEasier.
  ///
  /// In en, this message translates to:
  /// **'Easier'**
  String get replayBranchEasier;

  /// No description provided for @replayBranchSame.
  ///
  /// In en, this message translates to:
  /// **'Same'**
  String get replayBranchSame;

  /// No description provided for @replayBranchHarder.
  ///
  /// In en, this message translates to:
  /// **'Harder'**
  String get replayBranchHarder;

  /// No description provided for @scenarioEmptyNoSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a practice session'**
  String get scenarioEmptyNoSessionTitle;

  /// No description provided for @scenarioEmptyNoSessionBody.
  ///
  /// In en, this message translates to:
  /// **'Translate scenarios, get AI feedback, and review every past attempt. A session keeps your scenarios grouped so you can branch from any one.'**
  String get scenarioEmptyNoSessionBody;

  /// No description provided for @scenarioEmptyNoSessionCta.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get scenarioEmptyNoSessionCta;

  /// No description provided for @scenarioEmptyHasSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session in progress'**
  String get scenarioEmptyHasSessionTitle;

  /// No description provided for @scenarioEmptyHasSessionBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You\'ve completed 1 scenario in this session.} other{You\'ve completed {count} scenarios in this session.}} Continue with a fresh scenario or end the session.'**
  String scenarioEmptyHasSessionBody(int count);

  /// No description provided for @scenarioEmptyHasSessionContinueCta.
  ///
  /// In en, this message translates to:
  /// **'Continue practice'**
  String get scenarioEmptyHasSessionContinueCta;

  /// No description provided for @scenarioEmptyHasSessionEndCta.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get scenarioEmptyHasSessionEndCta;

  /// No description provided for @scenarioEmptyBackToHomeCta.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get scenarioEmptyBackToHomeCta;

  /// No description provided for @assessmentDifficultyTitle.
  ///
  /// In en, this message translates to:
  /// **'NEXT SCENARIO DIFFICULTY'**
  String get assessmentDifficultyTitle;

  /// No description provided for @assessmentDifficultyEasier.
  ///
  /// In en, this message translates to:
  /// **'Easier'**
  String get assessmentDifficultyEasier;

  /// No description provided for @assessmentDifficultySame.
  ///
  /// In en, this message translates to:
  /// **'Same'**
  String get assessmentDifficultySame;

  /// No description provided for @assessmentDifficultyHarder.
  ///
  /// In en, this message translates to:
  /// **'Harder'**
  String get assessmentDifficultyHarder;

  /// No description provided for @assessmentDifficultyLoading.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get assessmentDifficultyLoading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
