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

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonDone => 'Done';

  @override
  String get profileLevelLabel => 'Level';

  @override
  String get profileDailyGoalLabel => 'Daily Goal';

  @override
  String get profilePlanLabel => 'Plan';

  @override
  String get profilePlanFree => 'Free';

  @override
  String get profilePlanPremium => 'Premium';

  @override
  String get profileGoalsTitle => 'Goals';

  @override
  String get profileTopicsTitle => 'Topics';

  @override
  String get profileEditRowLabel => 'Edit profile';

  @override
  String get profileEditRowSubtitle => 'Name, avatar, level, daily goal';

  @override
  String get profileSettingsRowLabel => 'Settings';

  @override
  String get profileSettingsRowSubtitle => 'Language, notifications, privacy';

  @override
  String get profileUpgradeRowLabel => 'Upgrade to Premium';

  @override
  String get profileUpgradeRowSubtitle =>
      'Unlimited practice + AI illustrations';

  @override
  String get profileSignOutLabel => 'Sign out';

  @override
  String get profileSignOutEndSession => 'End your session';

  @override
  String profileSignOutSignedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get profileSignOutTitle => 'Sign out?';

  @override
  String get profileSignOutBody => 'You can sign back in anytime.';

  @override
  String get profileNotAvailable => 'Profile not available';

  @override
  String profileDailyMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get profileLevelBeginner => 'Beginner';

  @override
  String get profileLevelIntermediate => 'Intermediate';

  @override
  String get profileLevelAdvanced => 'Advanced';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGroupPractice => 'Practice';

  @override
  String get settingsGroupApp => 'App';

  @override
  String get settingsGroupPrivacy => 'Privacy';

  @override
  String get settingsRowDailyReminders => 'Daily reminders';

  @override
  String get settingsRowReminderTime => 'Reminder time';

  @override
  String get settingsRowAutoPlayAudio => 'Auto-play audio';

  @override
  String get settingsRowDisplayLanguage => 'Display language';

  @override
  String get settingsRowTheme => 'Theme (Dark mode)';

  @override
  String get settingsRowDataPrivacy => 'Data & privacy';

  @override
  String get settingsRowDeleteAccount => 'Delete account';

  @override
  String get settingsThemePickerTitle => 'Theme';

  @override
  String get settingsThemeSystem => 'Match system';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguagePickerTitle => 'Display language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageVietnamese => 'Tiếng Việt';

  @override
  String get settingsReminderTimeHelp => 'Daily reminder time';

  @override
  String get settingsDeleteTitle => 'Delete account?';

  @override
  String get settingsDeleteBody =>
      'This permanently removes your profile, conversations, saved words, mind maps, and stats. This action cannot be undone.';

  @override
  String get settingsDeleteSuccess => 'Account deleted.';

  @override
  String get settingsDeleteRequiresLogin =>
      'For security, sign in again before deleting your account.';

  @override
  String get settingsDeleteFailed =>
      'Could not delete the account. Please try again later.';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editProfileSectionBuddy => 'YOUR BUDDY';

  @override
  String get editProfileSectionName => 'YOUR NAME';

  @override
  String get editProfileSectionLevel => 'ENGLISH LEVEL';

  @override
  String get editProfileSectionDailyGoal => 'DAILY GOAL';

  @override
  String get editProfileSaveButton => 'Save changes';

  @override
  String get editProfileNameRequired => 'Name cannot be empty.';

  @override
  String get editProfileSaveSuccess => 'Profile updated.';

  @override
  String get editProfileSaveFailed =>
      'Could not save changes. Please try again.';

  @override
  String get editProfileDiscardTitle => 'Discard changes?';

  @override
  String get editProfileDiscardBody =>
      'You haven\'t saved your edits. If you leave now, your changes will be lost.';

  @override
  String get editProfileDiscardKeepEditing => 'Keep editing';

  @override
  String get editProfileDiscardConfirm => 'Discard';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get homePickMode => 'Pick a learning mode';

  @override
  String get homeStorageFull =>
      'Storage full. Delete a conversation or upgrade to start a new one.';

  @override
  String get homeStorageUpgradeAction => 'Upgrade';

  @override
  String get homePaywallSnack => 'Paywall coming soon.';

  @override
  String get homeDailyLimitReachedSessions =>
      'Daily limit reached. Upgrade for more sessions.';

  @override
  String get homeDailyLimitReachedStories =>
      'Daily limit reached. Upgrade for more stories.';

  @override
  String get modeScenarioTitle => 'Scenario Coach';

  @override
  String get modeScenarioDescription =>
      'Practice real-life situations with AI roleplay. Get instant feedback on grammar, vocabulary & tone.';

  @override
  String get modeScenarioBadge => 'MOST POPULAR';

  @override
  String get modeScenarioCta => 'Start Practice';

  @override
  String get modeScenarioQuota => '5 free sessions / day';

  @override
  String get modeStoryTitle => 'Story Mode';

  @override
  String get modeStoryBadge => 'INTERACTIVE';

  @override
  String get modeStoryCta => 'Begin Story';

  @override
  String get modeStoryQuota => '3 free stories / day';

  @override
  String get modeToneTitle => 'Tone Translator';

  @override
  String get modeToneDescription =>
      'Master the art of tone. See how one sentence sounds formal, friendly, casual & neutral.';

  @override
  String get modeToneBadge => 'UNIQUE';

  @override
  String get modeToneCta => 'Translate Now';

  @override
  String get modeToneQuota => '10 free translations / day';

  @override
  String get modeGrammarTitle => 'Grammar Coach';

  @override
  String get modeGrammarDescription =>
      'Master English grammar level by level. Pick a structure, drill it, and track your mastery.';

  @override
  String get modeGrammarBadge => 'STRUCTURED';

  @override
  String get modeGrammarCta => 'Start drilling';

  @override
  String get modeGrammarQuota => 'Unlimited practice';

  @override
  String get modeVocabTitle => 'Vocab Hub';

  @override
  String get modeVocabDescription =>
      'Deep-dive into any word. Get analysis, mind maps, examples & spaced repetition flashcards.';

  @override
  String get modeVocabBadge => 'BUILD SKILLS';

  @override
  String get modeVocabCta => 'Explore Words';

  @override
  String get modeVocabQuota => 'Unlimited';

  @override
  String get navHome => 'Home';

  @override
  String get navInsight => 'Insight';

  @override
  String get navAiAgent => 'AI Agent';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String navUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread',
      one: '1 unread',
    );
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'My Learning Library';

  @override
  String get librarySearchHint => 'Search saved items';

  @override
  String get libraryFilterAll => 'All';

  @override
  String get libraryFilterVocabulary => 'Vocabulary';

  @override
  String get libraryFilterGrammar => 'Grammar';

  @override
  String get libraryFilterAllPos => 'All POS';

  @override
  String get libraryFilterAllCategories => 'All Categories';

  @override
  String libraryItemsCount(int count) {
    return '$count items';
  }

  @override
  String libraryDueCount(int count) {
    return '$count due';
  }

  @override
  String libraryCategoriesCount(int count) {
    return '$count categories';
  }

  @override
  String get libraryEmptyTitle => 'No saved items yet';

  @override
  String get libraryEmptyBody =>
      'Tap any word in a conversation, story, or translation to save it here.';

  @override
  String get libraryShowMore => 'Show more';

  @override
  String get libraryShowLess => 'Show less';

  @override
  String get libraryLoadingExplanation => 'Loading explanation...';

  @override
  String get libraryGenerate => 'Generate';

  @override
  String get libraryGeneratePro => 'Generate (Pro)';

  @override
  String get libraryProUpsell =>
      'AI illustrations are part of the Pro plan. Upgrade to unlock.';

  @override
  String libraryReviewDueIn(int days) {
    return '${days}d';
  }

  @override
  String get libraryReviewDueNow => 'Due';

  @override
  String get libraryBadgeVocab => 'VOCAB';

  @override
  String get libraryBadgeGrammar => 'GRAMMAR';

  @override
  String get aiAgentTitle => 'AI Agent';

  @override
  String get aiAgentSubtitle => 'Help Center + Ask AI';

  @override
  String get aiAgentCategoryGettingStarted => 'Getting Started';

  @override
  String get aiAgentCategoryFeatures => 'Features';

  @override
  String get aiAgentCategoryAccount => 'Account';

  @override
  String get aiAgentCategorySubscription => 'Subscription & Billing';

  @override
  String get aiAgentCategoryTroubleshooting => 'Troubleshooting';

  @override
  String get aiAgentCategoryContact => 'Contact Support';

  @override
  String get aiAgentAskAiCardTitle => 'Ask AI';

  @override
  String get aiAgentAskAiCardSubtitle =>
      'Get instant answers about how Aura works';

  @override
  String get aiAgentAskAiCardCta => 'Ask now';

  @override
  String get vocabHubTitle => 'Vocab Hub';

  @override
  String get vocabHubSectionFreeTools => 'Free tools';

  @override
  String get vocabHubSectionProTools => 'Pro tools';

  @override
  String get vocabHubCardWordAnalysis => 'Word Analysis';

  @override
  String get vocabHubCardDescribeWord => 'Describe Word';

  @override
  String get vocabHubCardFlashcards => 'Flashcards';

  @override
  String get vocabHubCardCompareWords => 'Compare Words';

  @override
  String get vocabHubCardLearningLibrary => 'Learning Library';

  @override
  String get vocabHubCardProgressDashboard => 'Progress Dashboard';

  @override
  String get vocabHubCardMindMaps => 'Mind Maps';

  @override
  String get vocabWordAnalysisHint => 'Enter a word to analyze';

  @override
  String get vocabWordAnalyzeCta => 'Analyze';

  @override
  String vocabWordSavedSnack(String word) {
    return 'Saved \"$word\" to your library';
  }

  @override
  String get vocabMindMapTitle => 'Mind Maps';

  @override
  String get vocabMindMapHint => 'Enter a topic, e.g. Travel';

  @override
  String get vocabMindMapGenerate => 'Generate';

  @override
  String get vocabMindMapMyMaps => 'My maps';

  @override
  String get vocabMindMapUndo => 'Undo';

  @override
  String get vocabMindMapProTitle => 'Mind Map is a Pro feature';

  @override
  String get vocabMindMapMyMapsTitle => 'My mind maps';

  @override
  String vocabMindMapDeleteSnack(String topic) {
    return 'Deleted \"$topic\"';
  }

  @override
  String vocabMindMapNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nodes',
      one: '1 node',
    );
    return '$_temp0';
  }

  @override
  String vocabMindMapDepth(int value) {
    return 'depth $value';
  }

  @override
  String get vocabMindMapFromLibrary => 'from Library';

  @override
  String vocabMindMapNodeRemovedSnack(String label) {
    return 'Removed \"$label\" from library';
  }

  @override
  String vocabMindMapNodeAddedSnack(String word) {
    return 'Added \"$word\" under this node';
  }

  @override
  String vocabMindMapNodeDeletedSnack(String label) {
    return 'Deleted \"$label\"';
  }

  @override
  String get vocabMindMapExpandViaAi => 'Expand via AI';

  @override
  String get vocabMindMapAddWord => '+ Add word';

  @override
  String get vocabMindMapSaveToLibrary => 'Save to library';

  @override
  String get vocabMindMapAddWordHint => 'e.g. boarding pass';

  @override
  String get vocabMindMapMindMapCta => 'Mind Map 🧠';

  @override
  String get vocabFlashcardsTitle => 'Flashcards';

  @override
  String get vocabFlashcardsPracticeCta => 'Practice 10 cards';

  @override
  String get vocabFlashcardsStudyMoreCta => 'Study 10 more';

  @override
  String vocabFlashcardsAddedSnack(int count, String topic) {
    return 'Added $count $topic cards to your library';
  }

  @override
  String vocabFlashcardsAlreadyHaveSnack(String topic) {
    return 'All $topic picks are already in your library';
  }

  @override
  String get vocabFlashcardsRatingHard => 'Hard';

  @override
  String get vocabFlashcardsRatingGood => 'Good';

  @override
  String get vocabFlashcardsRatingEasy => 'Easy';

  @override
  String get vocabCompareTitle => 'Compare Words';

  @override
  String get vocabCompareTryAPair => 'Try a pair';

  @override
  String get vocabCompareWordA => 'WORD A';

  @override
  String get vocabCompareWordB => 'WORD B';

  @override
  String get vocabCompareKeyDifference => 'Key difference';

  @override
  String vocabCompareWhenToUse(String word) {
    return 'Use \"$word\" when';
  }

  @override
  String get vocabCompareSectionDefinition => 'Definition';

  @override
  String get vocabCompareSectionExample => 'Example';

  @override
  String get vocabCompareSectionCollocations => 'Collocations';

  @override
  String get vocabDescribeTitle => 'Describe Word';

  @override
  String get vocabDescribeHint => 'VD: cảm giác buồn nhẹ khi nhớ chuyện cũ';

  @override
  String get vocabAnalysisExamples => 'Examples';

  @override
  String get vocabAnalysisExamplePositive => 'Positive';

  @override
  String get vocabAnalysisExampleNeutral => 'Neutral';

  @override
  String get vocabAnalysisExampleNegative => 'Negative';

  @override
  String get vocabAnalysisCollocations => 'Collocations';

  @override
  String get vocabAnalysisWordFamily => 'Word family';

  @override
  String get vocabAnalysisSynonyms => 'Synonyms';

  @override
  String get vocabAnalysisAntonyms => 'Antonyms';

  @override
  String get vocabProgressTitle => 'Progress Dashboard';

  @override
  String get vocabProgressSaved => 'Saved';

  @override
  String get vocabProgressDueToday => 'Due today';

  @override
  String get vocabProgressMastered => 'Mastered';

  @override
  String get vocabProgressByPos => 'By part of speech';

  @override
  String get vocabProgressKeepGoing => 'Keep going';

  @override
  String vocabProgressLegendMastered(int count) {
    return 'Mastered · $count';
  }

  @override
  String vocabProgressLegendLearning(int count) {
    return 'Learning · $count';
  }

  @override
  String vocabProgressLegendNew(int count) {
    return 'New · $count';
  }

  @override
  String get vocabProgressEmptyTitle => 'No saved words yet';

  @override
  String get vocabProgressEmptyAnalyze => 'Analyze a word';

  @override
  String get vocabLearningLibraryTitle => 'Learning Library';

  @override
  String get vocabHubCardWordAnalysisDesc =>
      'Pronunciation, 3 examples, synonyms & antonyms';

  @override
  String get vocabHubCardDescribeWordDesc =>
      'Describe in Vietnamese → get the English word';

  @override
  String get vocabHubCardFlashcardsDesc =>
      'SM-2 spaced repetition — review at the perfect time';

  @override
  String get vocabHubCardCompareWordsDesc =>
      'Side-by-side nuance: \"affect\" vs \"effect\"';

  @override
  String get vocabHubCardLearningLibraryDesc =>
      'All saved words from every mode in one place';

  @override
  String get vocabHubCardProgressDashboardDesc =>
      'Track total, due reviews & mastered at a glance';

  @override
  String get vocabHubCardMindMapsDesc =>
      'Visual word relationships — synonyms, antonyms & related';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSectionNew => 'New';

  @override
  String get notificationsSectionEarlier => 'Earlier';

  @override
  String notificationsRemovedSnack(String title) {
    return 'Removed \"$title\"';
  }

  @override
  String get notificationsEmptyTitle => 'You\'re all caught up';

  @override
  String get notificationsEmptyBody =>
      'Reminders, streak nudges, and review prompts will show up here.';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get helpTitle => 'Help & support';

  @override
  String get helpSectionQuickGuides => 'Quick guides';

  @override
  String get helpSectionFaq => 'FAQ';

  @override
  String get helpSectionContact => 'Contact';

  @override
  String get helpAskAuraTitle => 'Ask Aura';

  @override
  String get helpAskAuraSubtitle =>
      'Ask anything about how to use the app — Aura answers right away in your language.';

  @override
  String get helpAskAuraStartChat => 'Start chat';

  @override
  String get helpContactEmailLabel => 'Email';

  @override
  String get helpContactHotlineLabel => 'Hotline';

  @override
  String get helpContactCopyEmailToast => 'Copied email to clipboard';

  @override
  String get helpContactCopyHotlineToast => 'Copied hotline to clipboard';

  @override
  String get helpFeedbackButton => 'Send feedback';

  @override
  String get helpFeedbackTitle => 'Send us feedback';

  @override
  String get helpFeedbackBody =>
      'Bug, idea, or just a thought — drop it below. We read every one.';

  @override
  String get helpFeedbackHint => 'What\'s on your mind?';

  @override
  String get helpFeedbackSendButton => 'Send';

  @override
  String get helpFeedbackThanksToast =>
      'Thanks! We\'ll review your feedback shortly.';

  @override
  String get insightsTitle => 'Insight';

  @override
  String get insightsTabLibrary => 'Library';

  @override
  String get insightsTabStats => 'Stats';

  @override
  String get conversationHistoryTitle => 'Conversation History';

  @override
  String get conversationHistoryFilterAll => 'All';

  @override
  String get conversationHistoryFilterScenario => 'Scenario';

  @override
  String get conversationHistoryFilterStory => 'Story';

  @override
  String get conversationHistoryFilterTranslator => 'Translator';

  @override
  String get conversationHistoryRenameTitle => 'Rename conversation';

  @override
  String get conversationHistoryRenameHint => 'Conversation title';

  @override
  String get conversationHistoryRenameFailed =>
      'Rename failed. Please try again.';

  @override
  String get conversationHistoryDeleteTitle => 'Delete conversation?';

  @override
  String get conversationHistoryDeleteBody =>
      'This conversation will be permanently removed from your history.';

  @override
  String get conversationHistoryDeleteFailed =>
      'Delete failed. Please try again.';

  @override
  String get conversationHistoryEmptyTitle => 'No conversation history yet';

  @override
  String get conversationHistoryEmptyBody =>
      'Start a roleplay scenario to see your history here';

  @override
  String get conversationHistoryStatusCompleted => 'Completed';

  @override
  String get conversationHistoryStatusInProgress => 'In Progress';

  @override
  String get conversationHistoryDateLabel => 'Date';

  @override
  String get conversationHistoryDurationLabel => 'Duration';

  @override
  String get conversationHistoryTurnsLabel => 'Turns';

  @override
  String get conversationHistoryScoreBreakdownTitle => 'Score Breakdown';

  @override
  String get conversationHistoryScoreOverall => 'Overall';

  @override
  String get conversationHistoryScoreGrammar => 'Grammar';

  @override
  String get conversationHistoryScoreVocabulary => 'Vocabulary';

  @override
  String get conversationHistoryScoreFluency => 'Fluency';

  @override
  String get conversationHistoryReplayComingSoon => 'Tap to replay coming soon';

  @override
  String get conversationHistoryYesterday => 'Yesterday';

  @override
  String get conversationHistoryUnknownTopic => 'Unknown';

  @override
  String get conversationHistoryFallbackTitle => 'Roleplay';

  @override
  String get conversationHistoryMoreMenuTooltip => 'More';

  @override
  String get conversationHistoryRenameAction => 'Rename';

  @override
  String get conversationHistoryDeleteAction => 'Delete';

  @override
  String get conversationHistoryModeVocab => 'Vocab';

  @override
  String get conversationHistoryModeSession => 'Session';

  @override
  String get conversationHistoryRelativeJustNow => 'just now';

  @override
  String conversationHistoryRelativeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String conversationHistoryRelativeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String conversationHistoryRelativeDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get storageQuotaCapTitle =>
      'Storage full — delete or upgrade to start new';

  @override
  String get storageQuotaWarningTitle => 'Storage almost full';

  @override
  String storageQuotaUsage(int used, int cap) {
    return '$used/$cap conversations used.';
  }

  @override
  String get storageQuotaManage => 'Manage';

  @override
  String get storageQuotaUpgrade => 'Upgrade';

  @override
  String get storageQuotaModeScenario => 'Scenario';

  @override
  String get storageQuotaModeStory => 'Story';

  @override
  String scenarioAppBarMeta(
      String emoji, String category, String level, int index) {
    return '$emoji $category · $level · Scenario #$index';
  }

  @override
  String get scenarioLoadingPreparing => 'Preparing your scenario...';

  @override
  String get scenarioErrorNoScenarioLoaded => 'No scenario loaded';

  @override
  String get scenarioErrorBackToHome => 'Back to Home';

  @override
  String get scenarioEndSessionTitle => 'End this session?';

  @override
  String get scenarioEndSessionBody =>
      'We\'ll grade your conversation and add it to your history.';

  @override
  String get scenarioEndSessionConfirm => 'End session';

  @override
  String get scenarioEndSessionKeepGoing => 'Keep going';

  @override
  String get endSessionDefaultTitle => 'End this session?';

  @override
  String get endSessionContinueLabel => 'Keep going';

  @override
  String get endSessionEndReviewLabel => 'End & review';

  @override
  String get endSessionStatTurns => 'Turns';

  @override
  String get endSessionStatAvgScore => 'Avg score';

  @override
  String get endSessionStatDuration => 'Duration';

  @override
  String endSessionBestLine(String preview) {
    return 'Best line: \"$preview\"';
  }

  @override
  String endSessionScenarioQuotaRemaining(int remaining, int limit) {
    return '$remaining/$limit sessions left today';
  }

  @override
  String endSessionStoryQuotaRemaining(int remaining, int limit) {
    return '$remaining/$limit stories left today';
  }

  @override
  String get storyEndSessionTitle => 'End this story?';

  @override
  String chatSavedSnack(String item) {
    return 'Saved: $item';
  }

  @override
  String get grammarHubTitle => 'Grammar Coach';

  @override
  String grammarHubMasteredCounter(int mastered, int total) {
    return '$mastered/$total mastered';
  }

  @override
  String get grammarHubHeroTitle => 'Master grammar by level';

  @override
  String get grammarHubHeroTagline =>
      'Pick a structure, drill it, track mastery';

  @override
  String get grammarHubSearchHint => 'Search topics';

  @override
  String get grammarHubFilterAll => 'All';

  @override
  String get grammarHubCategoryAll => 'All';

  @override
  String get grammarHubCategoryTense => 'Tense';

  @override
  String get grammarHubCategoryModal => 'Modal';

  @override
  String get grammarHubCategoryConditional => 'Conditional';

  @override
  String get grammarHubCategoryPassive => 'Passive';

  @override
  String get grammarHubCategoryReported => 'Reported';

  @override
  String get grammarHubCategoryClause => 'Clause';

  @override
  String get grammarHubCategoryComparison => 'Comparison';

  @override
  String get grammarHubCategoryLinkingInversion => 'Linking & Inversion';

  @override
  String get grammarHubCategoryArticleQuantifier => 'Articles & Quantifiers';

  @override
  String get grammarHubCategoryOther => 'Other';

  @override
  String get grammarHubMasteryNotStarted => 'Not started';

  @override
  String get grammarHubMasteryLearning => 'Learning';

  @override
  String get grammarHubMasteryMastered => 'Mastered';

  @override
  String get grammarHubTopicMetaNew => 'Tap to learn the formula';

  @override
  String grammarHubTopicMetaProgress(int attempts, int accuracy) {
    return '$attempts attempts · $accuracy% accuracy';
  }

  @override
  String get grammarHubEmptyTitle => 'No topics match this filter';

  @override
  String get grammarHubEmptyBody =>
      'Try clearing the level or category filter.';

  @override
  String get grammarTopicNotFoundTitle => 'Topic not found';

  @override
  String get grammarTopicNotFoundBody =>
      'The grammar topic you\'re looking for is no longer in the catalog.';

  @override
  String get grammarTopicSummaryTitle => 'Summary';

  @override
  String get grammarTopicWhenToUseTitle => 'When to use';

  @override
  String get grammarTopicExamplesTitle => 'Examples';

  @override
  String get grammarTopicMistakesTitle => 'Common mistakes';

  @override
  String get grammarTopicRelatedTitle => 'Related topics';

  @override
  String get grammarTopicListenA11y => 'Play example audio';

  @override
  String get grammarTopicNoContentBody =>
      'Detailed content for this topic is coming soon.';

  @override
  String get grammarStartPracticeCta => 'Start practice';

  @override
  String get grammarPracticePickerTitle => 'Pick your practice mode';

  @override
  String get grammarPracticePickerSubtitle =>
      'Each mode focuses on a different skill. You can switch between sessions.';

  @override
  String get grammarPracticeModeTranslate => 'Translate';

  @override
  String get grammarPracticeModeTranslateSub =>
      'EN ↔ VI sentence translation using this structure.';

  @override
  String get grammarPracticeModeFillBlank => 'Fill in the blank';

  @override
  String get grammarPracticeModeFillBlankSub =>
      'Pick or type the correct form to complete a sentence.';

  @override
  String get grammarPracticeModeTransform => 'Transform';

  @override
  String get grammarPracticeModeTransformSub =>
      'Rewrite an English sentence into the correct tense from a Vietnamese hint.';

  @override
  String get grammarPracticeAttemptsLabel => 'Attempts';

  @override
  String get grammarPracticeAccuracyLabel => 'Accuracy';

  @override
  String get grammarPracticeStreakLabel => 'Streak';

  @override
  String get grammarPracticeModeTagTranslateEnVi => 'TRANSLATE · EN → VI';

  @override
  String get grammarPracticeModeTagTranslateViEn => 'TRANSLATE · VI → EN';

  @override
  String get grammarPracticeModeTagFillBlank => 'FILL IN THE BLANK';

  @override
  String get grammarPracticeModeTagTransform => 'TRANSFORM';

  @override
  String get grammarPracticeHintLabel => 'Hint';

  @override
  String get grammarPracticeInputHintTranslate => 'Type your translation…';

  @override
  String get grammarPracticeInputHintFillBlank => 'Type the missing word(s)…';

  @override
  String get grammarPracticeInputHintTransform =>
      'Rewrite the sentence using the target structure…';

  @override
  String get grammarPracticeCheck => 'Check';

  @override
  String get grammarPracticeNext => 'Next →';

  @override
  String get grammarPracticeEndSession => 'End session';

  @override
  String get grammarPracticeEndConfirmTitle => 'End this session?';

  @override
  String get grammarPracticeEndConfirmBody =>
      'Your attempts will be saved and you\'ll see the summary.';

  @override
  String get grammarPracticeEndKeepGoing => 'Keep going';

  @override
  String get grammarPracticeEndConfirm => 'End';

  @override
  String get grammarPracticeResultCorrect => 'Correct!';

  @override
  String get grammarPracticeResultIncorrect => 'Not quite';

  @override
  String get grammarPracticeResultYourAnswer => 'Your answer';

  @override
  String get grammarPracticeResultAccepted => 'Accepted';

  @override
  String get grammarPracticeResultCorrectAnswer => 'Correct answer';

  @override
  String get grammarPracticeResultFullSentence => 'Full sentence';

  @override
  String get grammarPracticeResultExtraExample => 'Same pattern';

  @override
  String get grammarPracticeSaveToLibrary => '⭐ Save to Library';

  @override
  String get grammarPracticeSavedSnack => 'Saved to Library';

  @override
  String get grammarPracticeGenerating => 'Building your next exercise…';

  @override
  String get grammarPracticeError => 'Couldn\'t generate exercise';

  @override
  String get grammarPracticeRetry => 'Try another';

  @override
  String get grammarSummaryTitle => 'Session summary';

  @override
  String get grammarSummaryHeadlineMastered =>
      'Great work! You mastered this round.';

  @override
  String get grammarSummaryHeadlineProgress =>
      'Solid progress — keep practicing.';

  @override
  String get grammarSummaryHeadlineRough => 'Tough round. Review and retry.';

  @override
  String get grammarSummaryHeadlineEmpty =>
      'Session ended without any attempts.';

  @override
  String get grammarSummaryStatAttempts => 'Attempts';

  @override
  String get grammarSummaryStatAccuracy => 'Accuracy';

  @override
  String get grammarSummaryStatDuration => 'Time';

  @override
  String get grammarSummaryStatMastery => 'Mastery';

  @override
  String grammarSummaryMasteryDelta(String sign, String value) {
    return '$sign$value%';
  }

  @override
  String grammarSummaryDurationMinutes(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String grammarSummaryDurationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get grammarSummaryMistakesTitle => 'What to revisit';

  @override
  String get grammarSummaryMistakesEmpty =>
      'No mistakes this round — nicely done.';

  @override
  String get grammarSummaryMistakeYou => 'You';

  @override
  String get grammarSummaryMistakeCorrect => 'Correct';

  @override
  String get grammarSummarySaveAllMistakes => 'Save mistakes to Library';

  @override
  String grammarSummarySaveAllSnack(int count) {
    return '$count mistake(s) saved to Library';
  }

  @override
  String get grammarSummaryPracticeAgain => 'Practice again';

  @override
  String get grammarSummaryBackToTopic => 'Back to topic';

  @override
  String get grammarSummaryBackToHub => 'Back to all topics';

  @override
  String get assessmentGrammarBreakdownHeader => 'GRAMMAR BREAKDOWN';

  @override
  String get assessmentGrammarBreakdownYourSentence => 'YOUR SENTENCE';

  @override
  String get assessmentGrammarBreakdownYourSentenceCorrect =>
      'YOUR SENTENCE — Correct';

  @override
  String get assessmentGrammarBreakdownCorrectSentence => 'STANDARD SENTENCE';

  @override
  String get assessmentGrammarBreakdownComponents => 'SENTENCE COMPONENTS';

  @override
  String get assessmentGrammarBreakdownAuxiliaries => 'AUXILIARIES';

  @override
  String get assessmentGrammarBreakdownPatternPrefix => 'Pattern';

  @override
  String get sessionPanelTitle => 'SESSION';

  @override
  String sessionPanelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'scenarios',
      one: 'scenario',
    );
    return '$count $_temp0';
  }

  @override
  String sessionPanelAvg(String avg) {
    return 'Avg ⭐ $avg';
  }

  @override
  String get sessionPanelFilterAll => 'All';

  @override
  String get sessionPanelFilterExcellent => '⭐ 9+';

  @override
  String get sessionPanelFilterGood => '⭐ 7-8';

  @override
  String get sessionPanelFilterNeedsWork => '⭐ <7';

  @override
  String get sessionPanelEmptyTitle => 'No scenarios yet';

  @override
  String get sessionPanelEmptyBody => 'Complete a scenario to see it here.';

  @override
  String get sessionPanelFilterEmpty => 'No scenarios match this filter.';

  @override
  String get sessionPanelActiveLabel => 'Active';

  @override
  String get sessionPanelTimeNow => 'now';

  @override
  String sessionPanelTimeMinutes(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String sessionPanelTimeHours(int hours) {
    return '${hours}h ago';
  }

  @override
  String get sessionPanelTimeYesterday => 'yesterday';

  @override
  String sessionPanelTimeOlder(int days) {
    return '${days}d ago';
  }

  @override
  String get sessionPanelEndSessionCta => 'End session';

  @override
  String get sessionPanelEndConfirmTitle => 'End this session?';

  @override
  String get sessionPanelEndConfirmBody =>
      'You\'ll go back to the home screen. You can start a new session anytime.';

  @override
  String get sessionPanelEndConfirmAction => 'End session';

  @override
  String get sessionPanelEndConfirmCancel => 'Keep practicing';

  @override
  String replayTitle(int order) {
    return 'Replay #$order';
  }

  @override
  String get replayBannerText => 'Replay mode — read only';

  @override
  String get replayLoading => 'Loading replay…';

  @override
  String get replayLoadErrorTitle => 'Could not load this scenario';

  @override
  String get replayLoadErrorBody =>
      'The conversation may have been deleted or your connection dropped. Try again from the session panel.';

  @override
  String get replayLoadErrorBack => 'Back to session';

  @override
  String get replayBranchSectionTitle => 'BRANCH FROM THIS SCENARIO';

  @override
  String get replayBranchSectionSubtitle =>
      'Pick a difficulty to start a new scenario in this session. The replayed one stays unchanged.';

  @override
  String get replayBranchEasier => 'Easier';

  @override
  String get replayBranchSame => 'Same';

  @override
  String get replayBranchHarder => 'Harder';

  @override
  String get scenarioEmptyNoSessionTitle => 'Start a practice session';

  @override
  String get scenarioEmptyNoSessionBody =>
      'Translate scenarios, get AI feedback, and review every past attempt. A session keeps your scenarios grouped so you can branch from any one.';

  @override
  String get scenarioEmptyNoSessionCta => 'Start session';

  @override
  String get scenarioEmptyHasSessionTitle => 'Session in progress';

  @override
  String scenarioEmptyHasSessionBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You\'ve completed $count scenarios in this session.',
      one: 'You\'ve completed 1 scenario in this session.',
    );
    return '$_temp0 Continue with a fresh scenario or end the session.';
  }

  @override
  String get scenarioEmptyHasSessionContinueCta => 'Continue practice';

  @override
  String get scenarioEmptyHasSessionEndCta => 'End session';

  @override
  String get scenarioEmptyBackToHomeCta => 'Back to home';

  @override
  String get assessmentDifficultyTitle => 'NEXT SCENARIO DIFFICULTY';

  @override
  String get assessmentDifficultyEasier => 'Easier';

  @override
  String get assessmentDifficultySame => 'Same';

  @override
  String get assessmentDifficultyHarder => 'Harder';

  @override
  String get assessmentDifficultyLoading => 'Generating…';
}
