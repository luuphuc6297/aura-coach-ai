import '../models/grammar_topic.dart';

/// A2 — Elementary. 11 topics introducing the past, two future forms,
/// modals (can/must/should), and the article/quantifier system that A1's
/// `a/an/the` started.
const List<GrammarTopic> grammarA2 = [
  GrammarTopic(
    id: 'past_simple',
    title: 'Past Simple',
    titleVi: 'Quá khứ đơn',
    level: CefrLevel.a2,
    category: GrammarCategory.tense,
    formula: 'S + V2(ed/irregular) + O',
    summary:
        'Past Simple talks about finished actions or states at a definite time in the past, often with markers like yesterday, last week, or in 2010.',
    summaryVi:
        'Quá khứ đơn dùng để kể về hành động hoặc trạng thái đã kết thúc tại một thời điểm xác định trong quá khứ, thường đi với "yesterday", "last week", "in 2010".',
    useCases: [
      'Tell a finished story or sequence of events',
      'Talk about past habits with a time marker',
      'Describe states or feelings that ended',
      'Answer "What happened?" questions',
    ],
    useCasesVi: [
      'Kể một câu chuyện hoặc chuỗi sự kiện đã xong',
      'Nói về thói quen trong quá khứ kèm mốc thời gian',
      'Miêu tả trạng thái, cảm xúc đã kết thúc',
      'Trả lời câu hỏi "Chuyện gì đã xảy ra?"',
    ],
    examples: [
      GrammarExample(
        en: 'I watched a great film last night.',
        vi: 'Tối qua tôi xem một bộ phim hay.',
        gloss: 'V2',
      ),
      GrammarExample(
        en: 'She didn\'t go to work yesterday.',
        vi: 'Hôm qua cô ấy không đi làm.',
        gloss: 'didn\'t + V',
      ),
      GrammarExample(
        en: 'Did you call your mum on Sunday?',
        vi: 'Chủ nhật bạn có gọi cho mẹ không?',
        gloss: 'Did + S + V',
      ),
      GrammarExample(
        en: 'We lived in Hanoi for two years.',
        vi: 'Chúng tôi đã sống ở Hà Nội hai năm.',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I didn\'t went to school.',
        right: 'I didn\'t go to school.',
        why: 'Sau "didn\'t" phải dùng động từ nguyên mẫu, không chia quá khứ.',
      ),
      GrammarMistake(
        wrong: 'Where you went last weekend?',
        right: 'Where did you go last weekend?',
        why: 'Câu hỏi quá khứ cần trợ động từ "did" và động từ ở dạng nguyên mẫu.',
      ),
    ],
    relatedTopicIds: ['present_perfect', 'past_continuous', 'used_to_would'],
  ),
  GrammarTopic(
    id: 'future_going_to',
    title: 'Future "going to"',
    titleVi: 'Tương lai "going to"',
    level: CefrLevel.a2,
    category: GrammarCategory.tense,
    formula: 'S + am/is/are + going to + V',
    summary:
        '"Going to" expresses a plan or intention decided before the moment of speaking, and predictions based on present evidence we can see.',
    summaryVi:
        '"Going to" diễn tả kế hoạch hoặc dự định đã quyết định từ trước, và những dự đoán dựa trên dấu hiệu có thể nhìn thấy ở hiện tại.',
    useCases: [
      'Share a plan you already decided',
      'Predict from clear present evidence',
      'Announce intentions for the near future',
      'Talk about scheduled personal goals',
    ],
    useCasesVi: [
      'Chia sẻ kế hoạch đã định trước',
      'Dự đoán dựa vào dấu hiệu hiện tại',
      'Thông báo dự định trong tương lai gần',
      'Nói về mục tiêu cá nhân đã sắp xếp',
    ],
    examples: [
      GrammarExample(
        en: 'I\'m going to study Japanese next year.',
        vi: 'Năm sau tôi sẽ học tiếng Nhật.',
        gloss: 'plan',
      ),
      GrammarExample(
        en: 'Look at those clouds! It\'s going to rain.',
        vi: 'Nhìn mây kìa! Trời sắp mưa rồi.',
        gloss: 'evidence',
      ),
      GrammarExample(
        en: 'We\'re going to move house in June.',
        vi: 'Tháng Sáu chúng tôi sẽ chuyển nhà.',
      ),
      GrammarExample(
        en: 'Are you going to join the gym?',
        vi: 'Bạn có định đăng ký phòng gym không?',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I going to call her tonight.',
        right: 'I\'m going to call her tonight.',
        why: 'Cấu trúc "going to" luôn cần "be" (am/is/are) phía trước.',
      ),
      GrammarMistake(
        wrong: 'She is going to studies abroad.',
        right: 'She is going to study abroad.',
        why: 'Sau "going to" động từ phải ở dạng nguyên mẫu, không chia.',
      ),
    ],
    relatedTopicIds: ['future_will', 'present_continuous', 'future_continuous'],
  ),
  GrammarTopic(
    id: 'future_will',
    title: 'Future "will"',
    titleVi: 'Tương lai "will"',
    level: CefrLevel.a2,
    category: GrammarCategory.tense,
    formula: 'S + will + V',
    summary:
        '"Will" is for decisions made at the moment of speaking, promises, offers, and predictions based on opinion rather than visible evidence.',
    summaryVi:
        '"Will" dùng cho quyết định ngay lúc nói, lời hứa, lời đề nghị, và dự đoán dựa trên suy nghĩ chứ không phải bằng chứng nhìn thấy.',
    useCases: [
      'Make an instant decision while speaking',
      'Offer help or make a promise',
      'Predict the future based on opinion',
      'State general facts about the future',
    ],
    useCasesVi: [
      'Đưa ra quyết định ngay lúc nói',
      'Đề nghị giúp đỡ hoặc đưa ra lời hứa',
      'Dự đoán tương lai dựa trên suy nghĩ',
      'Nêu sự thật chung về tương lai',
    ],
    examples: [
      GrammarExample(
        en: 'I\'ll have the soup, please.',
        vi: 'Cho tôi món súp nhé.',
        gloss: 'instant decision',
      ),
      GrammarExample(
        en: 'Don\'t worry — I\'ll help you with it.',
        vi: 'Đừng lo, tôi sẽ giúp bạn.',
        gloss: 'offer',
      ),
      GrammarExample(
        en: 'I think it will be a great match.',
        vi: 'Tôi nghĩ trận đấu sẽ rất hay.',
        gloss: 'prediction',
      ),
      GrammarExample(
        en: 'She won\'t be late again, I promise.',
        vi: 'Cô ấy sẽ không trễ nữa, tôi hứa đấy.',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I will to call you tomorrow.',
        right: 'I will call you tomorrow.',
        why: 'Sau "will" dùng động từ nguyên mẫu, không có "to".',
      ),
      GrammarMistake(
        wrong: 'He wills come soon.',
        right: 'He will come soon.',
        why: '"Will" là modal nên không thêm "s" với ngôi thứ ba số ít.',
      ),
    ],
    relatedTopicIds: ['future_going_to', 'first_conditional', 'future_perfect'],
  ),
  GrammarTopic(
    id: 'comparatives_superlatives',
    title: 'Comparatives & Superlatives',
    titleVi: 'So sánh hơn & nhất',
    level: CefrLevel.a2,
    category: GrammarCategory.comparison,
    formula: 'ADJ-er than · the ADJ-est | more / most + ADJ',
    summary:
        'Comparatives compare two things; superlatives pick the top one in a group. Short adjectives add -er/-est; longer ones use more/most.',
    summaryVi:
        'So sánh hơn so sánh hai đối tượng; so sánh nhất chọn ra cái đứng đầu trong một nhóm. Tính từ ngắn thêm -er/-est, tính từ dài dùng more/most.',
    useCases: [
      'Compare two people, places, or things',
      'Pick the best or worst in a group',
      'Describe change with "getting + comparative"',
      'Give shopping or travel recommendations',
    ],
    useCasesVi: [
      'So sánh hai người, nơi chốn hoặc vật',
      'Chọn ra cái tốt nhất hoặc tệ nhất trong nhóm',
      'Diễn tả sự thay đổi với "ngày càng..."',
      'Đưa ra gợi ý khi mua sắm hoặc du lịch',
    ],
    examples: [
      GrammarExample(
        en: 'My new phone is faster than the old one.',
        vi: 'Điện thoại mới của tôi nhanh hơn cái cũ.',
        gloss: '-er than',
      ),
      GrammarExample(
        en: 'This is the most expensive cafe in town.',
        vi: 'Đây là quán cà phê đắt nhất phố.',
        gloss: 'the most + ADJ',
      ),
      GrammarExample(
        en: 'The weather is getting colder every day.',
        vi: 'Thời tiết ngày càng lạnh hơn.',
      ),
      GrammarExample(
        en: 'She is the best student in her class.',
        vi: 'Cô ấy là học sinh giỏi nhất lớp.',
        gloss: 'irregular',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'He is more taller than me.',
        right: 'He is taller than me.',
        why: 'Tính từ ngắn chỉ dùng "-er", không kết hợp với "more".',
      ),
      GrammarMistake(
        wrong: 'It is the most good restaurant here.',
        right: 'It is the best restaurant here.',
        why: '"Good" có dạng so sánh bất quy tắc: better/best, không dùng "most good".',
      ),
    ],
    relatedTopicIds: ['adverbs_of_frequency', 'quantifiers'],
  ),
  GrammarTopic(
    id: 'countable_uncountable',
    title: 'Countable / Uncountable',
    titleVi: 'Đếm được / Không đếm được',
    level: CefrLevel.a2,
    category: GrammarCategory.articleQuantifier,
    formula: 'C: a/an + singular, plural form · UC: no plural',
    summary:
        'Countable nouns can be counted and have plural forms; uncountable nouns (water, advice, money) take no plural and no a/an.',
    summaryVi:
        'Danh từ đếm được có thể đếm và có dạng số nhiều; danh từ không đếm được (water, advice, money) không có số nhiều và không dùng a/an.',
    useCases: [
      'Decide if a noun needs "a/an" or not',
      'Choose the correct verb agreement',
      'Order food and drinks correctly',
      'Talk about advice, news, or information',
    ],
    useCasesVi: [
      'Quyết định danh từ có cần "a/an" hay không',
      'Chọn động từ chia số ít hay số nhiều',
      'Gọi đồ ăn, đồ uống đúng cách',
      'Nói về lời khuyên, tin tức, thông tin',
    ],
    examples: [
      GrammarExample(
        en: 'I bought an apple and some bread.',
        vi: 'Tôi mua một quả táo và một ít bánh mì.',
        gloss: 'C + UC',
      ),
      GrammarExample(
        en: 'Can I have a glass of water, please?',
        vi: 'Cho tôi một cốc nước nhé?',
        gloss: 'unit of UC',
      ),
      GrammarExample(
        en: 'She gave me good advice yesterday.',
        vi: 'Hôm qua cô ấy cho tôi lời khuyên hay.',
      ),
      GrammarExample(
        en: 'The news is really surprising today.',
        vi: 'Tin tức hôm nay thực sự bất ngờ.',
        gloss: 'UC + is',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'He gave me an advice.',
        right: 'He gave me some advice.',
        why: '"Advice" là danh từ không đếm được, không dùng "an" hay số nhiều.',
      ),
      GrammarMistake(
        wrong: 'I need many informations.',
        right: 'I need a lot of information.',
        why: '"Information" không đếm được nên không có "s" và không đi với "many".',
      ),
    ],
    relatedTopicIds: ['quantifiers', 'articles', 'plural_nouns'],
  ),
  GrammarTopic(
    id: 'quantifiers',
    title: 'some / any / much / many',
    titleVi: 'Lượng từ some / any / much / many',
    level: CefrLevel.a2,
    category: GrammarCategory.articleQuantifier,
    formula: 'some + UC/C(pl) · any + neg/q · much + UC · many + C(pl)',
    summary:
        'Use "some" in positives and offers, "any" in negatives and questions, "much" with uncountables, and "many" with plural countables.',
    summaryVi:
        'Dùng "some" trong câu khẳng định và lời mời, "any" trong câu phủ định và nghi vấn, "much" với danh từ không đếm được, "many" với danh từ đếm được số nhiều.',
    useCases: [
      'Talk about quantity without exact numbers',
      'Make polite offers and requests',
      'Ask whether something exists or not',
      'Compare amounts in food, money, time',
    ],
    useCasesVi: [
      'Nói về số lượng không cần con số chính xác',
      'Đưa ra lời mời, lời yêu cầu lịch sự',
      'Hỏi xem có thứ gì đó tồn tại hay không',
      'So sánh số lượng đồ ăn, tiền, thời gian',
    ],
    examples: [
      GrammarExample(
        en: 'There are some eggs in the fridge.',
        vi: 'Trong tủ lạnh có vài quả trứng.',
        gloss: 'some + C(pl)',
      ),
      GrammarExample(
        en: 'We don\'t have any sugar left.',
        vi: 'Nhà mình hết đường rồi.',
        gloss: 'any + UC',
      ),
      GrammarExample(
        en: 'How much milk do you want?',
        vi: 'Bạn muốn bao nhiêu sữa?',
        gloss: 'much + UC',
      ),
      GrammarExample(
        en: 'She has many friends in London.',
        vi: 'Cô ấy có nhiều bạn ở London.',
        gloss: 'many + C(pl)',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I don\'t have some money.',
        right: 'I don\'t have any money.',
        why: 'Trong câu phủ định thường dùng "any", không dùng "some".',
      ),
      GrammarMistake(
        wrong: 'There are much cars on the road.',
        right: 'There are many cars on the road.',
        why: '"Cars" là danh từ đếm được số nhiều nên đi với "many", không phải "much".',
      ),
    ],
    relatedTopicIds: ['countable_uncountable', 'articles', 'there_is_are'],
  ),
  GrammarTopic(
    id: 'modal_can',
    title: 'Modal: can / can\'t',
    titleVi: 'Modal can / can\'t',
    level: CefrLevel.a2,
    category: GrammarCategory.modal,
    formula: 'S + can / can\'t + V',
    summary:
        '"Can" expresses ability, possibility, permission, and informal requests. "Can\'t" is the negative for inability or things that aren\'t allowed.',
    summaryVi:
        '"Can" diễn tả khả năng, sự có thể, sự cho phép và lời yêu cầu thân mật. "Can\'t" là dạng phủ định cho việc không thể làm hoặc không được phép.',
    useCases: [
      'Describe a skill or ability you have',
      'Ask for or give informal permission',
      'Make polite requests and offers',
      'Talk about general possibility',
    ],
    useCasesVi: [
      'Miêu tả kỹ năng hoặc khả năng bản thân',
      'Xin hoặc cho phép một cách thân mật',
      'Đưa ra lời yêu cầu, đề nghị lịch sự',
      'Nói về khả năng có thể xảy ra nói chung',
    ],
    examples: [
      GrammarExample(
        en: 'I can speak three languages.',
        vi: 'Tôi nói được ba ngôn ngữ.',
        gloss: 'ability',
      ),
      GrammarExample(
        en: 'Can you pass the salt, please?',
        vi: 'Bạn đưa giúp tôi lọ muối nhé?',
        gloss: 'request',
      ),
      GrammarExample(
        en: 'You can\'t park here on weekdays.',
        vi: 'Ngày thường bạn không được đỗ xe ở đây.',
        gloss: 'no permission',
      ),
      GrammarExample(
        en: 'It can be very cold in December.',
        vi: 'Tháng 12 trời có thể rất lạnh.',
        gloss: 'possibility',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'She cans drive a car.',
        right: 'She can drive a car.',
        why: '"Can" là modal nên không thêm "s" với ngôi thứ ba số ít.',
      ),
      GrammarMistake(
        wrong: 'I can to swim very well.',
        right: 'I can swim very well.',
        why: 'Sau modal "can" dùng động từ nguyên mẫu, không có "to".',
      ),
    ],
    relatedTopicIds: ['modal_must', 'modal_should', 'modals_deduction'],
  ),
  GrammarTopic(
    id: 'modal_must',
    title: 'Modal: must / mustn\'t',
    titleVi: 'Modal must / mustn\'t',
    level: CefrLevel.a2,
    category: GrammarCategory.modal,
    formula: 'S + must / mustn\'t + V',
    summary:
        '"Must" expresses strong obligation or a personal feeling that something is necessary. "Mustn\'t" means it is forbidden — not optional.',
    summaryVi:
        '"Must" diễn tả nghĩa vụ mạnh hoặc cảm nhận cá nhân rằng điều gì đó là cần thiết. "Mustn\'t" mang nghĩa cấm, không phải không cần.',
    useCases: [
      'State a rule or strong personal duty',
      'Warn someone not to do something',
      'Stress a recommendation you feel strongly about',
      'Talk about safety or legal obligations',
    ],
    useCasesVi: [
      'Nêu quy định hoặc nghĩa vụ mạnh của bản thân',
      'Cảnh báo ai đó không được làm điều gì',
      'Nhấn mạnh lời khuyên bạn rất tin tưởng',
      'Nói về quy định an toàn hoặc luật lệ',
    ],
    examples: [
      GrammarExample(
        en: 'You must wear a helmet on the bike.',
        vi: 'Bạn phải đội mũ bảo hiểm khi đi xe máy.',
        gloss: 'obligation',
      ),
      GrammarExample(
        en: 'I must finish this report tonight.',
        vi: 'Tối nay tôi phải làm xong báo cáo này.',
      ),
      GrammarExample(
        en: 'You mustn\'t use your phone in the exam.',
        vi: 'Bạn không được dùng điện thoại trong bài thi.',
        gloss: 'prohibition',
      ),
      GrammarExample(
        en: 'You must try this cake — it\'s amazing!',
        vi: 'Bạn nhất định phải thử bánh này — ngon lắm!',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'You mustn\'t come if you\'re busy.',
        right: 'You don\'t have to come if you\'re busy.',
        why: '"Mustn\'t" mang nghĩa cấm; khi muốn nói "không bắt buộc" phải dùng "don\'t have to".',
      ),
      GrammarMistake(
        wrong: 'He must to study harder.',
        right: 'He must study harder.',
        why: 'Sau modal "must" dùng động từ nguyên mẫu, không có "to".',
      ),
    ],
    relatedTopicIds: ['modal_should', 'modal_can', 'modals_deduction'],
  ),
  GrammarTopic(
    id: 'modal_should',
    title: 'Modal: should / shouldn\'t',
    titleVi: 'Modal should / shouldn\'t',
    level: CefrLevel.a2,
    category: GrammarCategory.modal,
    formula: 'S + should / shouldn\'t + V',
    summary:
        '"Should" gives advice or opinion about the right thing to do. It is softer than "must" — a suggestion, not a strict rule.',
    summaryVi:
        '"Should" dùng để khuyên hoặc nêu ý kiến về việc nên làm. Nó nhẹ hơn "must" — là lời gợi ý chứ không phải bắt buộc.',
    useCases: [
      'Give friendly advice to someone',
      'Ask for advice or recommendations',
      'Express what is right or appropriate',
      'Make polite suggestions in a group',
    ],
    useCasesVi: [
      'Đưa ra lời khuyên thân thiện cho ai đó',
      'Xin lời khuyên hoặc gợi ý',
      'Nêu việc đúng đắn, phù hợp nên làm',
      'Đưa ra đề xuất lịch sự trong nhóm',
    ],
    examples: [
      GrammarExample(
        en: 'You should drink more water.',
        vi: 'Bạn nên uống nhiều nước hơn.',
        gloss: 'advice',
      ),
      GrammarExample(
        en: 'We shouldn\'t stay up too late.',
        vi: 'Chúng ta không nên thức quá khuya.',
      ),
      GrammarExample(
        en: 'Should I call her tonight?',
        vi: 'Tôi có nên gọi cô ấy tối nay không?',
        gloss: 'asking advice',
      ),
      GrammarExample(
        en: 'You should try the new cafe nearby.',
        vi: 'Bạn nên thử quán cà phê mới gần đây.',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'You should to see a doctor.',
        right: 'You should see a doctor.',
        why: 'Sau modal "should" dùng động từ nguyên mẫu, không có "to".',
      ),
      GrammarMistake(
        wrong: 'He shoulds eat more vegetables.',
        right: 'He should eat more vegetables.',
        why: '"Should" là modal nên không thêm "s" với ngôi thứ ba số ít.',
      ),
    ],
    relatedTopicIds: ['modal_must', 'modal_can', 'wishes_regrets'],
  ),
  GrammarTopic(
    id: 'adverbs_of_frequency',
    title: 'Adverbs of frequency',
    titleVi: 'Trạng từ chỉ tần suất',
    level: CefrLevel.a2,
    category: GrammarCategory.other,
    formula: 'always/usually/often/sometimes/rarely/never (before V, after to be)',
    summary:
        'Adverbs of frequency say how often something happens. They go before the main verb but after the verb "be" and after the first auxiliary.',
    summaryVi:
        'Trạng từ tần suất cho biết một việc xảy ra thường xuyên thế nào. Chúng đứng trước động từ thường, nhưng sau động từ "be" và sau trợ động từ đầu tiên.',
    useCases: [
      'Describe daily routines and habits',
      'Compare how often you do things',
      'Answer "How often..?" questions',
      'Talk about typical workplace or study patterns',
    ],
    useCasesVi: [
      'Miêu tả thói quen, lịch sinh hoạt hằng ngày',
      'So sánh tần suất bạn làm các việc',
      'Trả lời câu hỏi "Bao lâu một lần..?"',
      'Nói về thói quen tại nơi làm việc, học tập',
    ],
    examples: [
      GrammarExample(
        en: 'I always have coffee in the morning.',
        vi: 'Sáng nào tôi cũng uống cà phê.',
        gloss: 'before V',
      ),
      GrammarExample(
        en: 'She is usually late on Mondays.',
        vi: 'Cô ấy thường đến trễ vào thứ Hai.',
        gloss: 'after to be',
      ),
      GrammarExample(
        en: 'We rarely eat out during the week.',
        vi: 'Trong tuần chúng tôi hiếm khi ra ngoài ăn.',
      ),
      GrammarExample(
        en: 'He has never been to Japan.',
        vi: 'Anh ấy chưa bao giờ đến Nhật.',
        gloss: 'after auxiliary',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I go always to the gym.',
        right: 'I always go to the gym.',
        why: 'Trạng từ tần suất đứng trước động từ thường, không đứng sau.',
      ),
      GrammarMistake(
        wrong: 'She always is happy.',
        right: 'She is always happy.',
        why: 'Với động từ "be", trạng từ tần suất đứng sau "be".',
      ),
    ],
    relatedTopicIds: ['present_simple', 'present_continuous'],
  ),
  GrammarTopic(
    id: 'object_pronouns',
    title: 'Object pronouns',
    titleVi: 'Đại từ tân ngữ',
    level: CefrLevel.a2,
    category: GrammarCategory.other,
    formula: 'me / you / him / her / it / us / them',
    summary:
        'Object pronouns replace the noun that receives the action. They come after the verb or after a preposition, never as the subject.',
    summaryVi:
        'Đại từ tân ngữ thay cho danh từ nhận hành động. Chúng đứng sau động từ hoặc sau giới từ, không bao giờ làm chủ ngữ.',
    useCases: [
      'Avoid repeating the same noun',
      'Receive an action after a verb',
      'Follow prepositions like with, for, to',
      'Replace people or things in short replies',
    ],
    useCasesVi: [
      'Tránh lặp lại cùng một danh từ',
      'Nhận hành động đứng sau động từ',
      'Đứng sau giới từ như with, for, to',
      'Thay người hoặc vật trong câu trả lời ngắn',
    ],
    examples: [
      GrammarExample(
        en: 'I saw her at the supermarket.',
        vi: 'Tôi gặp cô ấy ở siêu thị.',
        gloss: 'after V',
      ),
      GrammarExample(
        en: 'Can you help me with this?',
        vi: 'Bạn giúp mình việc này được không?',
      ),
      GrammarExample(
        en: 'This gift is for them.',
        vi: 'Món quà này là dành cho họ.',
        gloss: 'after prep',
      ),
      GrammarExample(
        en: 'I called him but he didn\'t answer.',
        vi: 'Tôi gọi anh ấy nhưng anh ấy không nghe máy.',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'He invited I to the party.',
        right: 'He invited me to the party.',
        why: 'Sau động từ phải dùng đại từ tân ngữ "me", không phải đại từ chủ ngữ "I".',
      ),
      GrammarMistake(
        wrong: 'Come with I tomorrow.',
        right: 'Come with me tomorrow.',
        why: 'Sau giới từ luôn dùng đại từ tân ngữ.',
      ),
    ],
    relatedTopicIds: ['subject_pronouns_possessives', 'present_simple'],
  ),
];
