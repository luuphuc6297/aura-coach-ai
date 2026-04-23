// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get authSubtitle =>
      'Huấn luyện viên tiếng Anh AI của bạn.\nHọc tự nhiên, nói tự tin.';

  @override
  String get continueWithGoogle => 'Tiếp tục với Google';

  @override
  String get continueWithApple => 'Tiếp tục với Apple';

  @override
  String get tryAsGuest => 'Dùng thử';

  @override
  String get termsNotice =>
      'Khi tiếp tục, bạn đồng ý với\nĐiều khoản dịch vụ và Chính sách bảo mật';

  @override
  String get onboardingNameTitle => 'Bạn muốn được gọi là gì?';

  @override
  String get onboardingNameSubtitle => 'Chọn tên và avatar của bạn';

  @override
  String get onboardingNameHint => 'Nhập tên của bạn';

  @override
  String get onboardingBuddyLabel => 'CHỌN BẠN ĐỒNG HÀNH';

  @override
  String get onboardingLevelTitle => 'Trình độ tiếng Anh của bạn?';

  @override
  String get onboardingLevelSubtitle =>
      'Chúng tôi sẽ cá nhân hóa bài học cho bạn';

  @override
  String get onboardingGoalsTitle => 'Mục tiêu của bạn là gì?';

  @override
  String get onboardingGoalsSubtitle => 'Chọn tất cả phù hợp';

  @override
  String get onboardingTopicsTitle => 'Chọn sở thích của bạn';

  @override
  String get onboardingTopicsSubtitle =>
      'Chúng tôi sẽ điều chỉnh kịch bản theo sở thích của bạn';

  @override
  String get onboardingTimeTitle => 'Thời gian luyện tập mỗi ngày?';

  @override
  String get onboardingTimeSubtitle => 'Chúng tôi sẽ xây dựng kế hoạch phù hợp';

  @override
  String get addYourOwnTopic => 'Thêm chủ đề của bạn...';

  @override
  String selectedTopicsCount(int count) {
    return 'Đã chọn: $count chủ đề';
  }

  @override
  String get dailyLimitReached =>
      'Đã đạt giới hạn hàng ngày. Nâng cấp để có thêm phiên.';

  @override
  String failedToStart(String error) {
    return 'Không thể bắt đầu: $error';
  }
}
