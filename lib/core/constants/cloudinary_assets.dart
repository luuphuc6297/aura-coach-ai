abstract final class CloudinaryAssets {
  static const _base = 'https://res.cloudinary.com/dgx0fr20a/image/upload';

  // Aura Orb
  static const auraOrb =
      '$_base/w_120,h_120,c_fill,q_90/v1774779556/aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp';
  static const auraOrbLarge =
      '$_base/w_360,h_360,c_fill,q_90/v1774779556/aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp';

  // AI Chatbot
  static const chatbot =
      '$_base/w_120,h_120,c_fill,q_85/v1774765004/aura-coach-assets/avatars/chat-bot-avatar_tranformed.webp';

  // Navigation
  static const navHome =
      '$_base/w_84,h_84,c_fill,q_85/v1774765585/aura-coach-assets/navigation-bar/home-icon_f164a9.webp';
  static const navSettings =
      '$_base/w_84,h_84,c_fill,q_85/v1774780351/aura-coach-assets/navigation-bar/setting-icon_42d237_cac3a9.webp';

  // Level Icons
  static const levelBeginner =
      '$_base/w_192,h_192,c_fill,q_90/v1774765488/aura-coach-assets/level-icons/beginner-level_8b946e.webp';
  static const levelIntermediate =
      '$_base/w_192,h_192,c_fill,q_90/v1774765510/aura-coach-assets/level-icons/intermediate-level_332f3d.webp';
  static const levelAdvanced =
      '$_base/w_192,h_192,c_fill,q_90/v1774766290/aura-coach-assets/level-icons/advanced-level_75b99f.webp';

  // Mode Icons
  static const modeScenarioCoach =
      '$_base/w_216,h_216,c_fill,q_90/v1774765701/aura-coach-assets/mode-icons/trophy-icon_770c25.webp';
  static const modeStory =
      '$_base/w_216,h_216,c_fill,q_90/v1774779261/aura-coach-assets/mode-icons/national-park-icons_628f11.webp';
  static const modeTranslator =
      '$_base/w_216,h_216,c_fill,q_90/v1774766467/aura-coach-assets/mode-icons/tone-translator_327cd6.webp';
  static const modeVocabHub =
      '$_base/w_216,h_216,c_fill,q_90/v1774779311/aura-coach-assets/mode-icons/ringed-planet-icons_bbcaa8.webp';

  // User Avatars
  static const avatarCat =
      '$_base/w_240,h_240,c_fill,q_90/v1774780151/aura-coach-assets/avatars/cat-avatar_83a6ce_d702ea.webp';
  static const avatarRabbit =
      '$_base/w_240,h_240,c_fill,q_90/v1774766456/aura-coach-assets/avatars/rabbit-avatar_004e97.webp';
  static const avatarPenguin =
      '$_base/w_240,h_240,c_fill,q_90/v1774766444/aura-coach-assets/avatars/penguin-avatar_c3d46f.webp';
  static const avatarFox =
      '$_base/w_240,h_240,c_fill,q_90/v1774780247/aura-coach-assets/avatars/fox-avatar_677f5f.webp';
  static const avatarOwl =
      '$_base/w_240,h_240,c_fill,q_90/v1774765533/aura-coach-assets/avatars/owl-avatar_ddeb3c.webp';
}

class AvatarOption {
  final String id;
  final String label;
  final String url;

  const AvatarOption(
      {required this.id, required this.label, required this.url});
}

const List<AvatarOption> avatarOptions = [
  AvatarOption(id: 'cat', label: 'Cat', url: CloudinaryAssets.avatarCat),
  AvatarOption(
      id: 'rabbit', label: 'Bunny', url: CloudinaryAssets.avatarRabbit),
  AvatarOption(
      id: 'penguin', label: 'Penguin', url: CloudinaryAssets.avatarPenguin),
  AvatarOption(id: 'fox', label: 'Fox', url: CloudinaryAssets.avatarFox),
  AvatarOption(id: 'owl', label: 'Owl', url: CloudinaryAssets.avatarOwl),
];
