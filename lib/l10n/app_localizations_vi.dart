// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get authSubtitle =>
      'Huấn luyện viên tiếng Anh AI cá nhân của bạn.\nHọc tự nhiên, nói tự tin.';

  @override
  String get continueWithGoogle => 'Tiếp tục với Google';

  @override
  String get continueWithApple => 'Tiếp tục với Apple';

  @override
  String get tryAsGuest => 'Dùng thử';

  @override
  String get termsNotice =>
      'Bằng việc tiếp tục, bạn đồng ý với\nĐiều khoản Dịch vụ và Chính sách Bảo mật';

  @override
  String get onboardingNameTitle => 'Bạn muốn được gọi là gì?';

  @override
  String get onboardingNameSubtitle => 'Chọn tên và avatar của bạn';

  @override
  String get onboardingNameHint => 'Nhập tên của bạn';

  @override
  String get onboardingBuddyLabel => 'CHỌN BUDDY';

  @override
  String get onboardingLevelTitle => 'Trình độ tiếng Anh của bạn?';

  @override
  String get onboardingLevelSubtitle =>
      'Chúng tôi sẽ cá nhân hóa bài học cho bạn';

  @override
  String get onboardingGoalsTitle => 'Mục tiêu của bạn là gì?';

  @override
  String get onboardingGoalsSubtitle => 'Chọn tất cả mục tiêu phù hợp';

  @override
  String get onboardingTopicsTitle => 'Chọn chủ đề bạn quan tâm';

  @override
  String get onboardingTopicsSubtitle =>
      'Chúng tôi sẽ điều chỉnh tình huống theo sở thích của bạn';

  @override
  String get onboardingTimeTitle => 'Bạn dành bao nhiêu thời gian mỗi ngày?';

  @override
  String get onboardingTimeSubtitle =>
      'Chúng tôi sẽ xây dựng kế hoạch phù hợp cho bạn';

  @override
  String get addYourOwnTopic => 'Thêm chủ đề của riêng bạn...';

  @override
  String selectedTopicsCount(int count) {
    return 'Đã chọn: $count chủ đề';
  }

  @override
  String get dailyLimitReached =>
      'Đã đạt giới hạn hôm nay. Nâng cấp để có thêm phiên luyện tập.';

  @override
  String failedToStart(String error) {
    return 'Không khởi động được: $error';
  }

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonCancel => 'Huỷ';

  @override
  String get commonDelete => 'Xoá';

  @override
  String get commonContinue => 'Tiếp tục';

  @override
  String get commonNext => 'Tiếp';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonDone => 'Xong';

  @override
  String get profileLevelLabel => 'Trình độ';

  @override
  String get profileDailyGoalLabel => 'Mục tiêu hằng ngày';

  @override
  String get profilePlanLabel => 'Gói';

  @override
  String get profilePlanFree => 'Miễn phí';

  @override
  String get profilePlanPremium => 'Premium';

  @override
  String get profileGoalsTitle => 'Mục tiêu';

  @override
  String get profileTopicsTitle => 'Chủ đề';

  @override
  String get profileEditRowLabel => 'Chỉnh sửa hồ sơ';

  @override
  String get profileEditRowSubtitle =>
      'Tên, avatar, trình độ, mục tiêu hằng ngày';

  @override
  String get profileSettingsRowLabel => 'Cài đặt';

  @override
  String get profileSettingsRowSubtitle =>
      'Ngôn ngữ, thông báo, quyền riêng tư';

  @override
  String get profileUpgradeRowLabel => 'Nâng cấp Premium';

  @override
  String get profileUpgradeRowSubtitle =>
      'Luyện tập không giới hạn + minh hoạ AI';

  @override
  String get profileSignOutLabel => 'Đăng xuất';

  @override
  String get profileSignOutEndSession => 'Kết thúc phiên';

  @override
  String profileSignOutSignedInAs(String name) {
    return 'Đang đăng nhập với $name';
  }

  @override
  String get profileSignOutTitle => 'Đăng xuất?';

  @override
  String get profileSignOutBody => 'Bạn có thể đăng nhập lại bất cứ lúc nào.';

  @override
  String get profileNotAvailable => 'Không tải được hồ sơ';

  @override
  String profileDailyMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String get profileLevelBeginner => 'Mới bắt đầu';

  @override
  String get profileLevelIntermediate => 'Trung cấp';

  @override
  String get profileLevelAdvanced => 'Nâng cao';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsGroupPractice => 'Luyện tập';

  @override
  String get settingsGroupApp => 'Ứng dụng';

  @override
  String get settingsGroupPrivacy => 'Quyền riêng tư';

  @override
  String get settingsRowDailyReminders => 'Nhắc nhở hằng ngày';

  @override
  String get settingsRowReminderTime => 'Giờ nhắc';

  @override
  String get settingsRowAutoPlayAudio => 'Tự động phát âm thanh';

  @override
  String get settingsRowDisplayLanguage => 'Ngôn ngữ hiển thị';

  @override
  String get settingsRowTheme => 'Giao diện (Chế độ tối)';

  @override
  String get settingsRowDataPrivacy => 'Dữ liệu & quyền riêng tư';

  @override
  String get settingsRowDeleteAccount => 'Xoá tài khoản';

  @override
  String get settingsThemePickerTitle => 'Giao diện';

  @override
  String get settingsThemeSystem => 'Theo hệ thống';

  @override
  String get settingsThemeLight => 'Sáng';

  @override
  String get settingsThemeDark => 'Tối';

  @override
  String get settingsLanguagePickerTitle => 'Ngôn ngữ hiển thị';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageVietnamese => 'Tiếng Việt';

  @override
  String get settingsReminderTimeHelp => 'Giờ nhắc nhở hằng ngày';

  @override
  String get settingsDeleteTitle => 'Xoá tài khoản?';

  @override
  String get settingsDeleteBody =>
      'Thao tác này sẽ xoá vĩnh viễn hồ sơ, hội thoại, từ đã lưu, mind map và thống kê của bạn. Không thể hoàn tác.';

  @override
  String get settingsDeleteSuccess => 'Đã xoá tài khoản.';

  @override
  String get settingsDeleteRequiresLogin =>
      'Vì lý do bảo mật, hãy đăng nhập lại trước khi xoá tài khoản.';

  @override
  String get settingsDeleteFailed =>
      'Không thể xoá tài khoản. Vui lòng thử lại sau.';

  @override
  String get editProfileTitle => 'Chỉnh sửa hồ sơ';

  @override
  String get editProfileSectionBuddy => 'BUDDY CỦA BẠN';

  @override
  String get editProfileSectionName => 'TÊN CỦA BẠN';

  @override
  String get editProfileSectionLevel => 'TRÌNH ĐỘ TIẾNG ANH';

  @override
  String get editProfileSectionDailyGoal => 'MỤC TIÊU HẰNG NGÀY';

  @override
  String get editProfileSaveButton => 'Lưu thay đổi';

  @override
  String get editProfileNameRequired => 'Tên không được bỏ trống.';

  @override
  String get editProfileSaveSuccess => 'Đã cập nhật hồ sơ.';

  @override
  String get editProfileSaveFailed =>
      'Không thể lưu thay đổi. Vui lòng thử lại.';

  @override
  String get editProfileDiscardTitle => 'Bỏ thay đổi?';

  @override
  String get editProfileDiscardBody =>
      'Bạn chưa lưu chỉnh sửa. Nếu rời đi, mọi thay đổi sẽ mất.';

  @override
  String get editProfileDiscardKeepEditing => 'Tiếp tục chỉnh sửa';

  @override
  String get editProfileDiscardConfirm => 'Bỏ thay đổi';

  @override
  String homeGreeting(String name) {
    return 'Xin chào, $name';
  }

  @override
  String get homePickMode => 'Chọn chế độ luyện tập';

  @override
  String get homeStorageFull =>
      'Đã hết dung lượng. Hãy xoá hội thoại cũ hoặc nâng cấp để bắt đầu phiên mới.';

  @override
  String get homeStorageUpgradeAction => 'Nâng cấp';

  @override
  String get homePaywallSnack => 'Tính năng nâng cấp sắp ra mắt.';

  @override
  String get homeDailyLimitReachedSessions =>
      'Đã đạt giới hạn hôm nay. Nâng cấp để có thêm phiên luyện tập.';

  @override
  String get homeDailyLimitReachedStories =>
      'Đã đạt giới hạn hôm nay. Nâng cấp để có thêm câu chuyện.';

  @override
  String get modeScenarioTitle => 'Scenario Coach';

  @override
  String get modeScenarioDescription =>
      'Luyện tình huống thực tế qua roleplay AI. Nhận góp ý tức thì về ngữ pháp, từ vựng và sắc thái.';

  @override
  String get modeScenarioBadge => 'PHỔ BIẾN NHẤT';

  @override
  String get modeScenarioCta => 'Bắt đầu luyện tập';

  @override
  String get modeScenarioQuota => '5 phiên miễn phí / ngày';

  @override
  String get modeStoryTitle => 'Story Mode';

  @override
  String get modeStoryBadge => 'TƯƠNG TÁC';

  @override
  String get modeStoryCta => 'Bắt đầu câu chuyện';

  @override
  String get modeStoryQuota => '3 câu chuyện miễn phí / ngày';

  @override
  String get modeToneTitle => 'Tone Translator';

  @override
  String get modeToneDescription =>
      'Làm chủ sắc thái. Xem cùng một câu sẽ trang trọng, thân thiện, suồng sã hay trung lập như thế nào.';

  @override
  String get modeToneBadge => 'ĐỘC ĐÁO';

  @override
  String get modeToneCta => 'Dịch ngay';

  @override
  String get modeToneQuota => '10 lần dịch miễn phí / ngày';

  @override
  String get modeGrammarTitle => 'Grammar Coach';

  @override
  String get modeGrammarDescription =>
      'Nắm chắc ngữ pháp tiếng Anh theo từng cấp độ. Chọn cấu trúc, luyện sâu, theo dõi mức nắm vững.';

  @override
  String get modeGrammarBadge => 'CÓ HỆ THỐNG';

  @override
  String get modeGrammarCta => 'Bắt đầu luyện';

  @override
  String get modeGrammarQuota => 'Luyện không giới hạn';

  @override
  String get modeVocabTitle => 'Vocab Hub';

  @override
  String get modeVocabDescription =>
      'Khám phá sâu mọi từ vựng. Phân tích, mind map, ví dụ và thẻ ôn theo lịch lặp lại.';

  @override
  String get modeVocabBadge => 'RÈN KỸ NĂNG';

  @override
  String get modeVocabCta => 'Khám phá từ';

  @override
  String get modeVocabQuota => 'Không giới hạn';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navInsight => 'Thống kê';

  @override
  String get navAiAgent => 'AI Agent';

  @override
  String get navAlerts => 'Thông báo';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String navUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chưa đọc',
    );
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'Thư viện học tập';

  @override
  String get librarySearchHint => 'Tìm trong các mục đã lưu';

  @override
  String get libraryFilterAll => 'Tất cả';

  @override
  String get libraryFilterVocabulary => 'Từ vựng';

  @override
  String get libraryFilterGrammar => 'Ngữ pháp';

  @override
  String get libraryFilterAllPos => 'Tất cả từ loại';

  @override
  String get libraryFilterAllCategories => 'Tất cả chủ đề';

  @override
  String libraryItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mục',
    );
    return '$_temp0';
  }

  @override
  String libraryDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count đến hạn',
    );
    return '$_temp0';
  }

  @override
  String libraryCategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chủ đề',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmptyTitle => 'Chưa có mục nào được lưu';

  @override
  String get libraryEmptyBody =>
      'Chạm vào bất kỳ từ nào trong hội thoại, câu chuyện hay bản dịch để lưu vào đây.';

  @override
  String get libraryShowMore => 'Xem thêm';

  @override
  String get libraryShowLess => 'Thu gọn';

  @override
  String get libraryLoadingExplanation => 'Đang tải giải thích...';

  @override
  String get libraryGenerate => 'Tạo';

  @override
  String get libraryGeneratePro => 'Tạo (Pro)';

  @override
  String get libraryProUpsell =>
      'Minh hoạ AI thuộc gói Pro. Hãy nâng cấp để mở khoá.';

  @override
  String libraryReviewDueIn(int days) {
    return '$days ngày';
  }

  @override
  String get libraryReviewDueNow => 'Đến hạn';

  @override
  String get libraryBadgeVocab => 'TỪ VỰNG';

  @override
  String get libraryBadgeGrammar => 'NGỮ PHÁP';

  @override
  String get aiAgentTitle => 'AI Agent';

  @override
  String get aiAgentSubtitle => 'Trung tâm trợ giúp + Hỏi AI';

  @override
  String get aiAgentCategoryGettingStarted => 'Bắt đầu';

  @override
  String get aiAgentCategoryFeatures => 'Tính năng';

  @override
  String get aiAgentCategoryAccount => 'Tài khoản';

  @override
  String get aiAgentCategorySubscription => 'Gói & Thanh toán';

  @override
  String get aiAgentCategoryTroubleshooting => 'Khắc phục sự cố';

  @override
  String get aiAgentCategoryContact => 'Liên hệ hỗ trợ';

  @override
  String get aiAgentAskAiCardTitle => 'Hỏi AI';

  @override
  String get aiAgentAskAiCardSubtitle =>
      'Nhận câu trả lời tức thì về cách dùng Aura';

  @override
  String get aiAgentAskAiCardCta => 'Hỏi ngay';

  @override
  String get vocabHubTitle => 'Vocab Hub';

  @override
  String get vocabHubSectionFreeTools => 'Công cụ miễn phí';

  @override
  String get vocabHubSectionProTools => 'Công cụ Pro';

  @override
  String get vocabHubCardWordAnalysis => 'Phân tích từ';

  @override
  String get vocabHubCardDescribeWord => 'Mô tả từ';

  @override
  String get vocabHubCardFlashcards => 'Flashcards';

  @override
  String get vocabHubCardCompareWords => 'So sánh từ';

  @override
  String get vocabHubCardLearningLibrary => 'Thư viện học tập';

  @override
  String get vocabHubCardProgressDashboard => 'Tiến độ';

  @override
  String get vocabHubCardMindMaps => 'Mind Map';

  @override
  String get vocabWordAnalysisHint => 'Nhập từ cần phân tích';

  @override
  String get vocabWordAnalyzeCta => 'Phân tích';

  @override
  String vocabWordSavedSnack(String word) {
    return 'Đã lưu \"$word\" vào thư viện';
  }

  @override
  String get vocabMindMapTitle => 'Mind Map';

  @override
  String get vocabMindMapHint => 'Nhập chủ đề, ví dụ: Du lịch';

  @override
  String get vocabMindMapGenerate => 'Tạo';

  @override
  String get vocabMindMapMyMaps => 'Mind map của tôi';

  @override
  String get vocabMindMapUndo => 'Hoàn tác';

  @override
  String get vocabMindMapProTitle => 'Mind Map là tính năng Pro';

  @override
  String get vocabMindMapMyMapsTitle => 'Mind map của tôi';

  @override
  String vocabMindMapDeleteSnack(String topic) {
    return 'Đã xoá \"$topic\"';
  }

  @override
  String vocabMindMapNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count node',
    );
    return '$_temp0';
  }

  @override
  String vocabMindMapDepth(int value) {
    return 'độ sâu $value';
  }

  @override
  String get vocabMindMapFromLibrary => 'từ thư viện';

  @override
  String vocabMindMapNodeRemovedSnack(String label) {
    return 'Đã gỡ \"$label\" khỏi thư viện';
  }

  @override
  String vocabMindMapNodeAddedSnack(String word) {
    return 'Đã thêm \"$word\" vào node này';
  }

  @override
  String vocabMindMapNodeDeletedSnack(String label) {
    return 'Đã xoá \"$label\"';
  }

  @override
  String get vocabMindMapExpandViaAi => 'Mở rộng bằng AI';

  @override
  String get vocabMindMapAddWord => '+ Thêm từ';

  @override
  String get vocabMindMapSaveToLibrary => 'Lưu vào thư viện';

  @override
  String get vocabMindMapAddWordHint => 'ví dụ: thẻ lên máy bay';

  @override
  String get vocabMindMapMindMapCta => 'Mind Map 🧠';

  @override
  String get vocabFlashcardsTitle => 'Flashcards';

  @override
  String get vocabFlashcardsPracticeCta => 'Luyện 10 thẻ';

  @override
  String get vocabFlashcardsStudyMoreCta => 'Học thêm 10 thẻ';

  @override
  String vocabFlashcardsAddedSnack(int count, String topic) {
    return 'Đã thêm $count thẻ $topic vào thư viện';
  }

  @override
  String vocabFlashcardsAlreadyHaveSnack(String topic) {
    return 'Tất cả thẻ $topic đã có trong thư viện';
  }

  @override
  String get vocabFlashcardsRatingHard => 'Khó';

  @override
  String get vocabFlashcardsRatingGood => 'Bình thường';

  @override
  String get vocabFlashcardsRatingEasy => 'Dễ';

  @override
  String get vocabCompareTitle => 'So sánh từ';

  @override
  String get vocabCompareTryAPair => 'Thử một cặp';

  @override
  String get vocabCompareWordA => 'TỪ A';

  @override
  String get vocabCompareWordB => 'TỪ B';

  @override
  String get vocabCompareKeyDifference => 'Khác biệt chính';

  @override
  String vocabCompareWhenToUse(String word) {
    return 'Dùng \"$word\" khi';
  }

  @override
  String get vocabCompareSectionDefinition => 'Định nghĩa';

  @override
  String get vocabCompareSectionExample => 'Ví dụ';

  @override
  String get vocabCompareSectionCollocations => 'Cụm thường đi kèm';

  @override
  String get vocabDescribeTitle => 'Mô tả từ';

  @override
  String get vocabDescribeHint => 'VD: cảm giác buồn nhẹ khi nhớ chuyện cũ';

  @override
  String get vocabAnalysisExamples => 'Ví dụ';

  @override
  String get vocabAnalysisExamplePositive => 'Tích cực';

  @override
  String get vocabAnalysisExampleNeutral => 'Trung tính';

  @override
  String get vocabAnalysisExampleNegative => 'Tiêu cực';

  @override
  String get vocabAnalysisCollocations => 'Cụm thường đi kèm';

  @override
  String get vocabAnalysisWordFamily => 'Họ từ';

  @override
  String get vocabAnalysisSynonyms => 'Từ đồng nghĩa';

  @override
  String get vocabAnalysisAntonyms => 'Từ trái nghĩa';

  @override
  String get vocabProgressTitle => 'Tiến độ';

  @override
  String get vocabProgressSaved => 'Đã lưu';

  @override
  String get vocabProgressDueToday => 'Hôm nay đến hạn';

  @override
  String get vocabProgressMastered => 'Thành thạo';

  @override
  String get vocabProgressByPos => 'Theo từ loại';

  @override
  String get vocabProgressKeepGoing => 'Tiếp tục cố gắng';

  @override
  String vocabProgressLegendMastered(int count) {
    return 'Thành thạo · $count';
  }

  @override
  String vocabProgressLegendLearning(int count) {
    return 'Đang học · $count';
  }

  @override
  String vocabProgressLegendNew(int count) {
    return 'Mới · $count';
  }

  @override
  String get vocabProgressEmptyTitle => 'Chưa có từ nào được lưu';

  @override
  String get vocabProgressEmptyAnalyze => 'Phân tích một từ';

  @override
  String get vocabLearningLibraryTitle => 'Thư viện học tập';

  @override
  String get vocabHubCardWordAnalysisDesc =>
      'Phát âm, 3 ví dụ, từ đồng nghĩa & trái nghĩa';

  @override
  String get vocabHubCardDescribeWordDesc =>
      'Mô tả bằng tiếng Việt → nhận từ tiếng Anh';

  @override
  String get vocabHubCardFlashcardsDesc =>
      'Lịch lặp lại SM-2 — ôn đúng thời điểm vàng';

  @override
  String get vocabHubCardCompareWordsDesc =>
      'So sánh sắc thái cạnh nhau: \"affect\" vs \"effect\"';

  @override
  String get vocabHubCardLearningLibraryDesc =>
      'Mọi từ đã lưu từ mọi chế độ tại một nơi';

  @override
  String get vocabHubCardProgressDashboardDesc =>
      'Theo dõi tổng số, từ đến hạn & thành thạo trong nháy mắt';

  @override
  String get vocabHubCardMindMapsDesc =>
      'Bản đồ trực quan — đồng nghĩa, trái nghĩa & liên quan';

  @override
  String get notificationsTitle => 'Thông báo';

  @override
  String get notificationsSectionNew => 'Mới';

  @override
  String get notificationsSectionEarlier => 'Trước đó';

  @override
  String notificationsRemovedSnack(String title) {
    return 'Đã xoá \"$title\"';
  }

  @override
  String get notificationsEmptyTitle => 'Bạn đã xem hết';

  @override
  String get notificationsEmptyBody =>
      'Lời nhắc, gợi ý chuỗi và nhắc ôn tập sẽ xuất hiện ở đây.';

  @override
  String get notificationsMarkAllRead => 'Đánh dấu đã đọc tất cả';

  @override
  String get helpTitle => 'Trợ giúp & hỗ trợ';

  @override
  String get helpSectionQuickGuides => 'Hướng dẫn nhanh';

  @override
  String get helpSectionFaq => 'Câu hỏi thường gặp';

  @override
  String get helpSectionContact => 'Liên hệ';

  @override
  String get helpAskAuraTitle => 'Hỏi Aura';

  @override
  String get helpAskAuraSubtitle =>
      'Hỏi bất kỳ điều gì về cách dùng app — Aura sẽ trả lời ngay bằng tiếng Việt.';

  @override
  String get helpAskAuraStartChat => 'Bắt đầu chat';

  @override
  String get helpContactEmailLabel => 'Email';

  @override
  String get helpContactHotlineLabel => 'Hotline';

  @override
  String get helpContactCopyEmailToast => 'Đã sao chép email';

  @override
  String get helpContactCopyHotlineToast => 'Đã sao chép hotline';

  @override
  String get helpFeedbackButton => 'Gửi phản hồi';

  @override
  String get helpFeedbackTitle => 'Gửi phản hồi cho chúng tôi';

  @override
  String get helpFeedbackBody =>
      'Lỗi, ý tưởng, hay chỉ là suy nghĩ — viết bên dưới. Chúng tôi đọc tất cả.';

  @override
  String get helpFeedbackHint => 'Bạn đang nghĩ gì?';

  @override
  String get helpFeedbackSendButton => 'Gửi';

  @override
  String get helpFeedbackThanksToast =>
      'Cảm ơn bạn! Chúng tôi sẽ xem phản hồi sớm nhất có thể.';

  @override
  String get insightsTitle => 'Thống kê';

  @override
  String get insightsTabLibrary => 'Thư viện';

  @override
  String get insightsTabStats => 'Số liệu';

  @override
  String get conversationHistoryTitle => 'Lịch sử hội thoại';

  @override
  String get conversationHistoryFilterAll => 'Tất cả';

  @override
  String get conversationHistoryFilterScenario => 'Tình huống';

  @override
  String get conversationHistoryFilterStory => 'Truyện';

  @override
  String get conversationHistoryFilterTranslator => 'Dịch';

  @override
  String get conversationHistoryRenameTitle => 'Đổi tên hội thoại';

  @override
  String get conversationHistoryRenameHint => 'Tên hội thoại';

  @override
  String get conversationHistoryRenameFailed =>
      'Đổi tên thất bại. Vui lòng thử lại.';

  @override
  String get conversationHistoryDeleteTitle => 'Xoá hội thoại?';

  @override
  String get conversationHistoryDeleteBody =>
      'Hội thoại này sẽ bị xoá vĩnh viễn khỏi lịch sử của bạn.';

  @override
  String get conversationHistoryDeleteFailed =>
      'Xoá thất bại. Vui lòng thử lại.';

  @override
  String get conversationHistoryEmptyTitle => 'Chưa có lịch sử hội thoại';

  @override
  String get conversationHistoryEmptyBody =>
      'Bắt đầu một tình huống nhập vai để xem lịch sử ở đây';

  @override
  String get conversationHistoryStatusCompleted => 'Đã hoàn thành';

  @override
  String get conversationHistoryStatusInProgress => 'Đang thực hiện';

  @override
  String get conversationHistoryDateLabel => 'Ngày';

  @override
  String get conversationHistoryDurationLabel => 'Thời lượng';

  @override
  String get conversationHistoryTurnsLabel => 'Lượt';

  @override
  String get conversationHistoryScoreBreakdownTitle => 'Chi tiết điểm';

  @override
  String get conversationHistoryScoreOverall => 'Tổng';

  @override
  String get conversationHistoryScoreGrammar => 'Ngữ pháp';

  @override
  String get conversationHistoryScoreVocabulary => 'Từ vựng';

  @override
  String get conversationHistoryScoreFluency => 'Lưu loát';

  @override
  String get conversationHistoryReplayComingSoon => 'Phát lại sẽ ra mắt sớm';

  @override
  String get conversationHistoryYesterday => 'Hôm qua';

  @override
  String get conversationHistoryUnknownTopic => 'Không rõ';

  @override
  String get conversationHistoryFallbackTitle => 'Nhập vai';

  @override
  String get conversationHistoryMoreMenuTooltip => 'Thêm';

  @override
  String get conversationHistoryRenameAction => 'Đổi tên';

  @override
  String get conversationHistoryDeleteAction => 'Xoá';

  @override
  String get conversationHistoryModeVocab => 'Từ vựng';

  @override
  String get conversationHistoryModeSession => 'Phiên';

  @override
  String get conversationHistoryRelativeJustNow => 'vừa xong';

  @override
  String conversationHistoryRelativeMinutesAgo(int minutes) {
    return '$minutes phút trước';
  }

  @override
  String conversationHistoryRelativeHoursAgo(int hours) {
    return '$hours giờ trước';
  }

  @override
  String conversationHistoryRelativeDaysAgo(int days) {
    return '$days ngày trước';
  }

  @override
  String get storageQuotaCapTitle =>
      'Bộ nhớ đầy — xoá bớt hoặc nâng cấp để bắt đầu mới';

  @override
  String get storageQuotaWarningTitle => 'Bộ nhớ gần đầy';

  @override
  String storageQuotaUsage(int used, int cap) {
    return 'Đã dùng $used/$cap hội thoại.';
  }

  @override
  String get storageQuotaManage => 'Quản lý';

  @override
  String get storageQuotaUpgrade => 'Nâng cấp';

  @override
  String get storageQuotaModeScenario => 'Tình huống';

  @override
  String get storageQuotaModeStory => 'Truyện';

  @override
  String scenarioAppBarMeta(
      String emoji, String category, String level, int index) {
    return '$emoji $category · $level · Tình huống #$index';
  }

  @override
  String get scenarioLoadingPreparing => 'Đang chuẩn bị tình huống...';

  @override
  String get scenarioErrorNoScenarioLoaded => 'Chưa có tình huống nào được tải';

  @override
  String get scenarioErrorBackToHome => 'Về Trang chủ';

  @override
  String get scenarioEndSessionTitle => 'Kết thúc phiên này?';

  @override
  String get scenarioEndSessionBody =>
      'Chúng tôi sẽ chấm điểm hội thoại và lưu vào lịch sử của bạn.';

  @override
  String get scenarioEndSessionConfirm => 'Kết thúc';

  @override
  String get scenarioEndSessionKeepGoing => 'Tiếp tục';

  @override
  String get endSessionDefaultTitle => 'Kết thúc phiên này?';

  @override
  String get endSessionContinueLabel => 'Tiếp tục';

  @override
  String get endSessionEndReviewLabel => 'Kết thúc & xem lại';

  @override
  String get endSessionStatTurns => 'Lượt';

  @override
  String get endSessionStatAvgScore => 'Điểm TB';

  @override
  String get endSessionStatDuration => 'Thời lượng';

  @override
  String endSessionBestLine(String preview) {
    return 'Câu hay nhất: \"$preview\"';
  }

  @override
  String endSessionScenarioQuotaRemaining(int remaining, int limit) {
    return 'Còn $remaining/$limit phiên hôm nay';
  }

  @override
  String endSessionStoryQuotaRemaining(int remaining, int limit) {
    return 'Còn $remaining/$limit truyện hôm nay';
  }

  @override
  String get storyEndSessionTitle => 'Kết thúc truyện này?';

  @override
  String chatSavedSnack(String item) {
    return 'Đã lưu: $item';
  }

  @override
  String get grammarHubTitle => 'Grammar Coach';

  @override
  String grammarHubMasteredCounter(int mastered, int total) {
    return 'Đã thuộc $mastered/$total';
  }

  @override
  String get grammarHubHeroTitle => 'Làm chủ ngữ pháp theo trình độ';

  @override
  String get grammarHubHeroTagline =>
      'Chọn cấu trúc · luyện tập · theo dõi tiến độ';

  @override
  String get grammarHubSearchHint => 'Tìm chủ đề';

  @override
  String get grammarHubFilterAll => 'Tất cả';

  @override
  String get grammarHubCategoryAll => 'Tất cả';

  @override
  String get grammarHubCategoryTense => 'Thì';

  @override
  String get grammarHubCategoryModal => 'Modal';

  @override
  String get grammarHubCategoryConditional => 'Câu điều kiện';

  @override
  String get grammarHubCategoryPassive => 'Bị động';

  @override
  String get grammarHubCategoryReported => 'Tường thuật';

  @override
  String get grammarHubCategoryClause => 'Mệnh đề';

  @override
  String get grammarHubCategoryComparison => 'So sánh';

  @override
  String get grammarHubCategoryLinkingInversion => 'Liên từ & Đảo ngữ';

  @override
  String get grammarHubCategoryArticleQuantifier => 'Mạo từ & Lượng từ';

  @override
  String get grammarHubCategoryOther => 'Khác';

  @override
  String get grammarHubMasteryNotStarted => 'Chưa bắt đầu';

  @override
  String get grammarHubMasteryLearning => 'Đang học';

  @override
  String get grammarHubMasteryMastered => 'Đã thuộc';

  @override
  String get grammarHubTopicMetaNew => 'Chạm để xem công thức';

  @override
  String grammarHubTopicMetaProgress(int attempts, int accuracy) {
    return '$attempts lượt · độ chính xác $accuracy%';
  }

  @override
  String get grammarHubEmptyTitle => 'Không có chủ đề nào khớp bộ lọc';

  @override
  String get grammarHubEmptyBody => 'Thử bỏ bộ lọc trình độ hoặc danh mục.';

  @override
  String get grammarTopicNotFoundTitle => 'Không tìm thấy chủ đề';

  @override
  String get grammarTopicNotFoundBody =>
      'Chủ đề ngữ pháp bạn tìm không còn trong danh sách.';

  @override
  String get grammarTopicSummaryTitle => 'Tóm tắt';

  @override
  String get grammarTopicWhenToUseTitle => 'Khi nào dùng';

  @override
  String get grammarTopicExamplesTitle => 'Ví dụ';

  @override
  String get grammarTopicMistakesTitle => 'Lỗi thường gặp';

  @override
  String get grammarTopicRelatedTitle => 'Chủ đề liên quan';

  @override
  String get grammarTopicListenA11y => 'Phát âm thanh ví dụ';

  @override
  String get grammarTopicNoContentBody => 'Nội dung chi tiết sẽ sớm có mặt.';

  @override
  String get grammarStartPracticeCta => 'Bắt đầu luyện tập';

  @override
  String get grammarPracticePickerTitle => 'Chọn cách luyện tập';

  @override
  String get grammarPracticePickerSubtitle =>
      'Mỗi cách tập trung một kỹ năng khác nhau. Có thể đổi giữa các phiên.';

  @override
  String get grammarPracticeModeTranslate => 'Dịch câu';

  @override
  String get grammarPracticeModeTranslateSub =>
      'Dịch câu EN ↔ VI dùng cấu trúc này.';

  @override
  String get grammarPracticeModeFillBlank => 'Điền vào chỗ trống';

  @override
  String get grammarPracticeModeFillBlankSub =>
      'Chọn hoặc nhập dạng đúng để hoàn thành câu.';

  @override
  String get grammarPracticeModeTransform => 'Chuyển đổi câu';

  @override
  String get grammarPracticeModeTransformSub =>
      'Viết lại câu tiếng Anh đúng thì dựa trên gợi ý tiếng Việt.';

  @override
  String get grammarPracticeAttemptsLabel => 'Lượt';

  @override
  String get grammarPracticeAccuracyLabel => 'Chính xác';

  @override
  String get grammarPracticeStreakLabel => 'Chuỗi';

  @override
  String get grammarPracticeModeTagTranslateEnVi => 'DỊCH · EN → VI';

  @override
  String get grammarPracticeModeTagTranslateViEn => 'DỊCH · VI → EN';

  @override
  String get grammarPracticeModeTagFillBlank => 'ĐIỀN VÀO CHỖ TRỐNG';

  @override
  String get grammarPracticeModeTagTransform => 'CHUYỂN ĐỔI CÂU';

  @override
  String get grammarPracticeHintLabel => 'Gợi ý';

  @override
  String get grammarPracticeInputHintTranslate => 'Nhập bản dịch của bạn…';

  @override
  String get grammarPracticeInputHintFillBlank => 'Nhập từ còn thiếu…';

  @override
  String get grammarPracticeInputHintTransform =>
      'Viết lại câu dùng cấu trúc mục tiêu…';

  @override
  String get grammarPracticeCheck => 'Kiểm tra';

  @override
  String get grammarPracticeNext => 'Tiếp theo →';

  @override
  String get grammarPracticeEndSession => 'Kết thúc phiên';

  @override
  String get grammarPracticeEndConfirmTitle => 'Kết thúc phiên này?';

  @override
  String get grammarPracticeEndConfirmBody =>
      'Các lượt làm bài sẽ được lưu và bạn sẽ thấy bản tổng kết.';

  @override
  String get grammarPracticeEndKeepGoing => 'Tiếp tục';

  @override
  String get grammarPracticeEndConfirm => 'Kết thúc';

  @override
  String get grammarPracticeResultCorrect => 'Chính xác!';

  @override
  String get grammarPracticeResultIncorrect => 'Chưa đúng';

  @override
  String get grammarPracticeResultYourAnswer => 'Câu của bạn';

  @override
  String get grammarPracticeResultAccepted => 'Đáp án được chấp nhận';

  @override
  String get grammarPracticeResultCorrectAnswer => 'Đáp án đúng';

  @override
  String get grammarPracticeResultFullSentence => 'Câu hoàn chỉnh';

  @override
  String get grammarPracticeResultExtraExample => 'Ví dụ cùng mẫu';

  @override
  String get grammarPracticeSaveToLibrary => '⭐ Lưu vào Thư viện';

  @override
  String get grammarPracticeSavedSnack => 'Đã lưu vào Thư viện';

  @override
  String get grammarPracticeGenerating => 'Đang tạo bài tập tiếp theo…';

  @override
  String get grammarPracticeError => 'Không tạo được bài tập';

  @override
  String get grammarPracticeRetry => 'Thử bài khác';

  @override
  String get grammarSummaryTitle => 'Tổng kết phiên';

  @override
  String get grammarSummaryHeadlineMastered =>
      'Tuyệt vời! Bạn đã nắm chắc vòng này.';

  @override
  String get grammarSummaryHeadlineProgress => 'Tiến bộ tốt — luyện tiếp nào.';

  @override
  String get grammarSummaryHeadlineRough =>
      'Vòng này khá khó. Xem lại và thử lại nhé.';

  @override
  String get grammarSummaryHeadlineEmpty =>
      'Phiên kết thúc mà chưa có bài nào.';

  @override
  String get grammarSummaryStatAttempts => 'Số bài';

  @override
  String get grammarSummaryStatAccuracy => 'Độ chính xác';

  @override
  String get grammarSummaryStatDuration => 'Thời gian';

  @override
  String get grammarSummaryStatMastery => 'Mức nắm vững';

  @override
  String grammarSummaryMasteryDelta(String sign, String value) {
    return '$sign$value%';
  }

  @override
  String grammarSummaryDurationMinutes(int minutes, int seconds) {
    return '$minutes phút $seconds giây';
  }

  @override
  String grammarSummaryDurationSeconds(int seconds) {
    return '$seconds giây';
  }

  @override
  String get grammarSummaryMistakesTitle => 'Cần xem lại';

  @override
  String get grammarSummaryMistakesEmpty =>
      'Không có lỗi nào trong vòng này — quá đỉnh.';

  @override
  String get grammarSummaryMistakeYou => 'Bạn';

  @override
  String get grammarSummaryMistakeCorrect => 'Đúng';

  @override
  String get grammarSummarySaveAllMistakes => 'Lưu lỗi vào Thư viện';

  @override
  String grammarSummarySaveAllSnack(int count) {
    return 'Đã lưu $count lỗi vào Thư viện';
  }

  @override
  String get grammarSummaryPracticeAgain => 'Luyện tiếp';

  @override
  String get grammarSummaryBackToTopic => 'Về chủ đề';

  @override
  String get grammarSummaryBackToHub => 'Tất cả chủ đề';
}
