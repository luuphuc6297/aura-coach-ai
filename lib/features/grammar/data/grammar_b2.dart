import '../models/grammar_topic.dart';

/// B2 — Upper-Intermediate. 13 topics extending tense system to all
/// perfect/continuous combinations, all three conditionals + mixed,
/// passive/reported in every form, and the causative + concession
/// constructions that mark a learner moving toward C-level fluency.
const List<GrammarTopic> grammarB2 = [
  GrammarTopic(
    id: 'past_perfect_continuous',
    title: 'Past Perfect Continuous',
    titleVi: 'Quá khứ hoàn thành tiếp diễn',
    level: CefrLevel.b2,
    category: GrammarCategory.tense,
    formula: 'S + had been + V-ing',
    summary:
        'Past Perfect Continuous describes an action that had been in progress up to a point in the past, often explaining a result or visible state at that moment. It stresses duration rather than completion.',
    summaryVi:
        'Thì quá khứ hoàn thành tiếp diễn diễn tả hành động đã diễn ra liên tục đến một thời điểm trong quá khứ, thường giải thích nguyên nhân của một kết quả nhìn thấy được. Nó nhấn mạnh quá trình, không phải sự hoàn tất.',
    useCases: [
      'Explain why something looked a certain way in the past.',
      'Emphasise duration of an activity before another past event.',
      'Describe repeated actions leading up to a past moment.',
      'Distinguish from Past Perfect: focus on process, not result.',
    ],
    useCasesVi: [
      'Giải thích lý do cho một trạng thái nhìn thấy trong quá khứ.',
      'Nhấn mạnh thời gian một hoạt động đã kéo dài trước sự kiện khác.',
      'Mô tả hành động lặp lại liên tục dẫn tới một mốc quá khứ.',
      'Phân biệt với Quá khứ hoàn thành: nhấn quá trình, không phải kết quả.',
    ],
    examples: [
      GrammarExample(
        en: 'Her eyes were red because she had been crying.',
        vi: 'Mắt cô ấy đỏ vì cô ấy đã khóc một lúc lâu rồi.',
        gloss: 'had been + V-ing',
      ),
      GrammarExample(
        en: 'They had been arguing for an hour before the manager stepped in.',
        vi: 'Họ đã cãi nhau cả tiếng đồng hồ trước khi quản lý vào can.',
        gloss: 'had been + V-ing',
      ),
      GrammarExample(
        en: 'I was tired because I had been working since 6 a.m.',
        vi: 'Tôi mệt vì đã làm việc liên tục từ 6 giờ sáng.',
        gloss: 'had been + V-ing',
      ),
      GrammarExample(
        en: 'He had been living in Hanoi for ten years when he moved abroad.',
        vi: 'Anh ấy đã sống ở Hà Nội mười năm khi chuyển ra nước ngoài.',
        gloss: 'had been + V-ing',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'She was been studying all night.',
        right: 'She had been studying all night.',
        why: 'Trợ động từ phải là "had been", không phải "was been".',
      ),
      GrammarMistake(
        wrong: 'I had been knowing him for years.',
        right: 'I had known him for years.',
        why: 'Động từ trạng thái như "know" không dùng dạng tiếp diễn.',
      ),
      GrammarMistake(
        wrong: 'They had been finished the report before lunch.',
        right: 'They had finished the report before lunch.',
        why: 'Khi nhấn kết quả hoàn tất, dùng Past Perfect, không phải tiếp diễn.',
      ),
    ],
    relatedTopicIds: [
      'past_perfect',
      'present_perfect_continuous',
      'past_continuous',
    ],
  ),
  GrammarTopic(
    id: 'future_continuous',
    title: 'Future Continuous',
    titleVi: 'Tương lai tiếp diễn',
    level: CefrLevel.b2,
    category: GrammarCategory.tense,
    formula: 'S + will be + V-ing',
    summary:
        'Future Continuous describes an action that will be in progress at a specific time in the future. It is also used for polite enquiries and to talk about expected, scheduled future activities.',
    summaryVi:
        'Tương lai tiếp diễn diễn tả hành động đang xảy ra tại một thời điểm cụ thể trong tương lai. Nó cũng dùng để hỏi lịch sự hoặc nói về những việc đã được dự kiến sẽ diễn ra.',
    useCases: [
      'Action in progress at a specific future moment.',
      'Polite enquiries about someone\'s plans.',
      'Predict what is naturally expected to happen.',
      'Parallel future actions happening at the same time.',
    ],
    useCasesVi: [
      'Hành động đang diễn ra ở một thời điểm tương lai cụ thể.',
      'Hỏi lịch sự về kế hoạch của ai đó.',
      'Dự đoán điều gì đó tự nhiên sẽ xảy ra.',
      'Diễn tả các hành động song song ở tương lai.',
    ],
    examples: [
      GrammarExample(
        en: 'This time tomorrow, I will be flying to Singapore.',
        vi: 'Giờ này ngày mai, tôi sẽ đang bay đến Singapore.',
        gloss: 'will be + V-ing',
      ),
      GrammarExample(
        en: 'Will you be using the meeting room at three?',
        vi: 'Ba giờ bạn có dùng phòng họp không?',
        gloss: 'will be + V-ing',
      ),
      GrammarExample(
        en: 'Don\'t call at eight; we will be having dinner.',
        vi: 'Đừng gọi lúc tám giờ; chúng tôi sẽ đang ăn tối.',
        gloss: 'will be + V-ing',
      ),
      GrammarExample(
        en: 'The team will be reviewing the proposal all afternoon.',
        vi: 'Cả buổi chiều nhóm sẽ đang xem xét đề xuất.',
        gloss: 'will be + V-ing',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I will being working at 9 tomorrow.',
        right: 'I will be working at 9 tomorrow.',
        why: 'Sau "will" phải là động từ nguyên thể "be", không phải "being".',
      ),
      GrammarMistake(
        wrong: 'At this time next week she will be knowing the result.',
        right: 'At this time next week she will know the result.',
        why: 'Động từ trạng thái "know" không dùng ở dạng tiếp diễn.',
      ),
    ],
    relatedTopicIds: [
      'future_will',
      'future_perfect',
      'present_continuous',
    ],
  ),
  GrammarTopic(
    id: 'future_perfect',
    title: 'Future Perfect',
    titleVi: 'Tương lai hoàn thành',
    level: CefrLevel.b2,
    category: GrammarCategory.tense,
    formula: 'S + will have + V3',
    summary:
        'Future Perfect refers to an action that will be completed before a specific point in the future. It is typically signalled by time markers like "by", "by then", or "by the time".',
    summaryVi:
        'Tương lai hoàn thành diễn tả hành động sẽ hoàn tất trước một mốc thời gian cụ thể trong tương lai. Thì này thường đi với "by", "by then" hoặc "by the time".',
    useCases: [
      'Actions completed before a future deadline.',
      'Estimating duration that will have passed by a future point.',
      'Talking about achievements expected by a date.',
      'Often paired with "by + time" or "by the time + clause".',
    ],
    useCasesVi: [
      'Hành động hoàn tất trước một thời hạn ở tương lai.',
      'Ước lượng khoảng thời gian sẽ đã trôi qua tới một mốc tương lai.',
      'Nói về thành tựu dự kiến đạt được trước một ngày.',
      'Thường đi với "by + thời gian" hoặc "by the time + mệnh đề".',
    ],
    examples: [
      GrammarExample(
        en: 'By next June, I will have graduated from university.',
        vi: 'Đến tháng Sáu năm sau, tôi sẽ đã tốt nghiệp đại học.',
        gloss: 'will have + V3',
      ),
      GrammarExample(
        en: 'They will have launched the product by the end of Q3.',
        vi: 'Họ sẽ ra mắt sản phẩm trước khi kết thúc quý ba.',
        gloss: 'will have + V3',
      ),
      GrammarExample(
        en: 'By the time you arrive, the meeting will have started.',
        vi: 'Khi bạn tới, cuộc họp đã bắt đầu rồi.',
        gloss: 'will have + V3',
      ),
      GrammarExample(
        en: 'In May, we will have lived here for ten years.',
        vi: 'Đến tháng Năm, chúng tôi sẽ đã sống ở đây mười năm.',
        gloss: 'will have + V3',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'By 2030, technology will change everything.',
        right: 'By 2030, technology will have changed everything.',
        why: 'Với "by + thời gian tương lai", phải dùng tương lai hoàn thành.',
      ),
      GrammarMistake(
        wrong: 'She will has finished the project by Friday.',
        right: 'She will have finished the project by Friday.',
        why: 'Sau "will" luôn là "have", không chia theo chủ ngữ.',
      ),
      GrammarMistake(
        wrong: 'By the time he comes, I will have went home.',
        right: 'By the time he comes, I will have gone home.',
        why: 'Sau "have" phải là phân từ quá khứ (V3), không phải dạng V2.',
      ),
    ],
    relatedTopicIds: [
      'future_continuous',
      'present_perfect',
      'past_perfect',
    ],
  ),
  GrammarTopic(
    id: 'second_conditional',
    title: '2nd Conditional',
    titleVi: 'Câu điều kiện loại 2',
    level: CefrLevel.b2,
    category: GrammarCategory.conditional,
    formula: 'If + S + V(past), S + would + V',
    summary:
        'The 2nd Conditional talks about unreal or hypothetical situations in the present or future. The past form in the if-clause signals unreality, not past time, and "were" is preferred for all subjects in formal English.',
    summaryVi:
        'Câu điều kiện loại 2 diễn tả tình huống không có thật hoặc giả định ở hiện tại hay tương lai. Động từ chia ở quá khứ trong mệnh đề "if" báo hiệu sự không có thật, không phải thời gian quá khứ, và "were" được dùng cho mọi chủ ngữ trong văn phong trang trọng.',
    useCases: [
      'Imagining present situations that are not real.',
      'Giving polite advice with "If I were you, I would…".',
      'Talking about unlikely future possibilities.',
      'Daydreaming or hypothesising about preferences.',
    ],
    useCasesVi: [
      'Tưởng tượng tình huống không có thật ở hiện tại.',
      'Khuyên lịch sự với cấu trúc "If I were you, I would…".',
      'Nói về khả năng tương lai khó xảy ra.',
      'Mơ mộng hoặc đưa ra giả định về sở thích.',
    ],
    examples: [
      GrammarExample(
        en: 'If I had more time, I would learn another language.',
        vi: 'Nếu có nhiều thời gian hơn, tôi sẽ học thêm một ngôn ngữ.',
        gloss: 'V(past) … would + V',
      ),
      GrammarExample(
        en: 'If I were you, I would take the job offer.',
        vi: 'Nếu tôi là bạn, tôi sẽ nhận lời mời làm việc.',
        gloss: 'were … would + V',
      ),
      GrammarExample(
        en: 'She would travel more if she earned a higher salary.',
        vi: 'Cô ấy sẽ đi du lịch nhiều hơn nếu lương cao hơn.',
        gloss: 'would + V … V(past)',
      ),
      GrammarExample(
        en: 'What would you do if you won the lottery?',
        vi: 'Bạn sẽ làm gì nếu trúng xổ số?',
        gloss: 'would + V … V(past)',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'If I would have more money, I would buy a house.',
        right: 'If I had more money, I would buy a house.',
        why: 'Mệnh đề "if" loại 2 dùng quá khứ đơn, không dùng "would".',
      ),
      GrammarMistake(
        wrong: 'If she was here, she would help us.',
        right: 'If she were here, she would help us.',
        why: 'Trong văn phong chuẩn, dùng "were" cho mọi chủ ngữ ở câu giả định.',
      ),
      GrammarMistake(
        wrong: 'If I won the lottery, I will buy a car.',
        right: 'If I won the lottery, I would buy a car.',
        why: 'Mệnh đề chính câu loại 2 dùng "would + V", không dùng "will".',
      ),
    ],
    relatedTopicIds: [
      'first_conditional',
      'third_conditional',
      'wishes_regrets',
    ],
  ),
  GrammarTopic(
    id: 'third_conditional',
    title: '3rd Conditional',
    titleVi: 'Câu điều kiện loại 3',
    level: CefrLevel.b2,
    category: GrammarCategory.conditional,
    formula: 'If + S + had + V3, S + would have + V3',
    summary:
        'The 3rd Conditional describes imagined past situations and their unreal past results. Because the event did not happen, this structure often expresses regret, criticism, or relief about choices already made.',
    summaryVi:
        'Câu điều kiện loại 3 diễn tả tình huống giả định trong quá khứ và kết quả không có thật của nó. Vì sự việc đã không xảy ra, cấu trúc này thường thể hiện sự nuối tiếc, trách móc hoặc nhẹ nhõm về những lựa chọn đã rồi.',
    useCases: [
      'Express regret about a past action or inaction.',
      'Criticise or evaluate a past decision in hindsight.',
      'Imagine alternative outcomes for a finished event.',
      'Show relief that a bad outcome was avoided.',
    ],
    useCasesVi: [
      'Thể hiện sự nuối tiếc về việc đã hoặc chưa làm trong quá khứ.',
      'Phê bình, đánh giá một quyết định đã rồi.',
      'Tưởng tượng kết cục khác cho sự việc đã kết thúc.',
      'Thể hiện sự nhẹ nhõm vì đã tránh được điều xấu.',
    ],
    examples: [
      GrammarExample(
        en: 'If I had studied harder, I would have passed the exam.',
        vi: 'Nếu tôi đã học chăm hơn, tôi đã đậu kỳ thi.',
        gloss: 'had + V3 … would have + V3',
      ),
      GrammarExample(
        en: 'She would have caught the train if she had left earlier.',
        vi: 'Cô ấy đã kịp tàu nếu rời đi sớm hơn.',
        gloss: 'would have + V3 … had + V3',
      ),
      GrammarExample(
        en: 'If we had taken a taxi, we wouldn\'t have got wet.',
        vi: 'Nếu chúng ta bắt taxi, đã không bị ướt rồi.',
        gloss: 'had + V3 … wouldn\'t have + V3',
      ),
      GrammarExample(
        en: 'They would have signed the deal if the price had been lower.',
        vi: 'Họ đã ký hợp đồng nếu giá thấp hơn.',
        gloss: 'would have + V3 … had + V3',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'If I would have known, I would have called you.',
        right: 'If I had known, I would have called you.',
        why: 'Mệnh đề "if" loại 3 dùng "had + V3", không dùng "would have".',
      ),
      GrammarMistake(
        wrong: 'If she had asked, I would help her.',
        right: 'If she had asked, I would have helped her.',
        why: 'Mệnh đề chính loại 3 phải là "would have + V3" để diễn tả quá khứ không có thật.',
      ),
      GrammarMistake(
        wrong: 'If they had arrived earlier, they would have saw the show.',
        right: 'If they had arrived earlier, they would have seen the show.',
        why: 'Sau "have" phải là phân từ quá khứ "seen", không phải "saw".',
      ),
    ],
    relatedTopicIds: [
      'second_conditional',
      'mixed_conditionals',
      'wishes_regrets',
    ],
  ),
  GrammarTopic(
    id: 'mixed_conditionals',
    title: 'Mixed Conditionals',
    titleVi: 'Câu điều kiện hỗn hợp',
    level: CefrLevel.b2,
    category: GrammarCategory.conditional,
    formula:
        'If + S + had + V3, S + would + V (now) | If + S + V(past), S + would have + V3 (then)',
    summary:
        'Mixed conditionals link a hypothetical past condition to a present result, or a permanent present condition to a hypothetical past result. They are common when reflecting on how earlier choices still shape current life.',
    summaryVi:
        'Câu điều kiện hỗn hợp nối một điều kiện giả định trong quá khứ với kết quả ở hiện tại, hoặc một đặc điểm có thật ở hiện tại với một kết quả giả định trong quá khứ. Chúng thường xuất hiện khi nhìn lại cách những lựa chọn trước đây vẫn ảnh hưởng đến cuộc sống bây giờ.',
    useCases: [
      'Past condition causing a present consequence.',
      'Present trait or state causing a different past outcome.',
      'Reflecting on how decisions still affect today.',
      'Useful in personal storytelling and analysis.',
    ],
    useCasesVi: [
      'Điều kiện quá khứ gây ra hậu quả ở hiện tại.',
      'Đặc điểm hiện tại dẫn tới kết cục quá khứ khác đi.',
      'Suy ngẫm về việc quyết định cũ vẫn ảnh hưởng hôm nay.',
      'Hữu ích khi kể chuyện cá nhân và phân tích.',
    ],
    examples: [
      GrammarExample(
        en: 'If I had taken that job, I would be living in Tokyo now.',
        vi: 'Nếu tôi đã nhận việc đó, giờ tôi đang sống ở Tokyo.',
        gloss: 'had + V3 … would + V',
      ),
      GrammarExample(
        en: 'If she were more careful, she wouldn\'t have lost her wallet.',
        vi: 'Nếu cô ấy cẩn thận hơn, đã không mất ví.',
        gloss: 'V(past) … wouldn\'t have + V3',
      ),
      GrammarExample(
        en: 'If we had saved money, we wouldn\'t be struggling today.',
        vi: 'Nếu chúng ta đã tiết kiệm, hôm nay đã không vất vả.',
        gloss: 'had + V3 … wouldn\'t be + V-ing',
      ),
      GrammarExample(
        en: 'If he weren\'t so shy, he would have spoken up earlier.',
        vi: 'Nếu anh ấy không nhút nhát, đã lên tiếng sớm hơn rồi.',
        gloss: 'V(past) … would have + V3',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'If I had studied medicine, I would have been a doctor now.',
        right: 'If I had studied medicine, I would be a doctor now.',
        why: 'Kết quả ở hiện tại dùng "would + V", không dùng "would have + V3".',
      ),
      GrammarMistake(
        wrong: 'If she was taller, she would have made the team.',
        right: 'If she were taller, she would have made the team.',
        why: 'Đặc điểm chung hiện tại dùng "were" trong câu giả định trang trọng.',
      ),
    ],
    relatedTopicIds: [
      'second_conditional',
      'third_conditional',
      'wishes_regrets',
    ],
  ),
  GrammarTopic(
    id: 'passive_all_tenses',
    title: 'Passive (all tenses)',
    titleVi: 'Câu bị động (tất cả các thì)',
    level: CefrLevel.b2,
    category: GrammarCategory.passive,
    formula: '[any tense of be] + V3 (+ by O)',
    summary:
        'At B2, the passive extends across every tense and modal: continuous, perfect, future, and modal forms. The auxiliary "be" carries the tense while the main verb stays in past participle, foregrounding the action or its receiver.',
    summaryVi:
        'Ở trình độ B2, câu bị động được mở rộng sang mọi thì và động từ khuyết thiếu: tiếp diễn, hoàn thành, tương lai và modal. Trợ động từ "be" mang thì còn động từ chính giữ ở phân từ quá khứ, qua đó nhấn mạnh hành động hoặc đối tượng bị tác động.',
    useCases: [
      'News and reports where the doer is unknown or irrelevant.',
      'Academic and formal writing about processes and findings.',
      'Modal passive for rules, recommendations, possibilities.',
      'Continuous and perfect passive for ongoing or completed events.',
    ],
    useCasesVi: [
      'Tin tức và báo cáo khi không cần biết ai làm.',
      'Văn phong học thuật/trang trọng về quy trình và kết quả.',
      'Bị động với modal để diễn đạt quy tắc, đề xuất, khả năng.',
      'Bị động tiếp diễn/hoàn thành cho việc đang xảy ra hoặc đã xong.',
    ],
    examples: [
      GrammarExample(
        en: 'The new policy is being reviewed by the board this week.',
        vi: 'Chính sách mới đang được hội đồng xem xét trong tuần này.',
        gloss: 'is being + V3',
      ),
      GrammarExample(
        en: 'The report has been submitted to the client.',
        vi: 'Báo cáo đã được nộp cho khách hàng.',
        gloss: 'has been + V3',
      ),
      GrammarExample(
        en: 'All applicants will be contacted by Friday.',
        vi: 'Tất cả ứng viên sẽ được liên hệ trước thứ Sáu.',
        gloss: 'will be + V3',
      ),
      GrammarExample(
        en: 'Helmets must be worn at all times on site.',
        vi: 'Mũ bảo hộ phải được đội mọi lúc tại công trường.',
        gloss: 'must be + V3',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'The book is being wrote by a famous author.',
        right: 'The book is being written by a famous author.',
        why: 'Phân từ quá khứ của "write" là "written", không phải "wrote".',
      ),
      GrammarMistake(
        wrong: 'The email has sent yesterday.',
        right: 'The email was sent yesterday.',
        why: 'Bị động cần "be" hợp với thì; quá khứ đơn dùng "was/were + V3".',
      ),
      GrammarMistake(
        wrong: 'This problem must solve immediately.',
        right: 'This problem must be solved immediately.',
        why: 'Sau modal, bị động cần "be + V3", không bỏ "be".',
      ),
    ],
    relatedTopicIds: [
      'passive_basic',
      'modals_deduction',
      'reported_speech_questions_commands',
    ],
  ),
  GrammarTopic(
    id: 'reported_speech_questions_commands',
    title: 'Reported Speech (questions/commands)',
    titleVi: 'Câu tường thuật (câu hỏi & mệnh lệnh)',
    level: CefrLevel.b2,
    category: GrammarCategory.reported,
    formula: 'S + asked + (if/wh-) + S + V | S + told + O + (not) to V',
    summary:
        'Reported questions use statement word order with no auxiliary "do", introduced by "if/whether" for yes-no or a wh-word for open questions. Commands and requests use "told/asked + object + (not) to + verb", and tenses back-shift as in reported statements.',
    summaryVi:
        'Câu hỏi tường thuật dùng trật tự câu khẳng định, không có trợ động từ "do", mở đầu bằng "if/whether" cho câu yes-no hoặc từ để hỏi cho câu mở. Mệnh lệnh và yêu cầu dùng "told/asked + tân ngữ + (not) to + V", và các thì lùi như trong câu tường thuật bình thường.',
    useCases: [
      'Reporting yes-no and wh- questions in conversation.',
      'Conveying instructions, orders or polite requests.',
      'Summarising interviews, meetings or customer calls.',
      'Writing minutes and indirect dialogue in stories.',
    ],
    useCasesVi: [
      'Tường thuật câu hỏi yes-no và câu hỏi với từ để hỏi.',
      'Truyền đạt chỉ dẫn, mệnh lệnh hoặc yêu cầu lịch sự.',
      'Tóm tắt phỏng vấn, cuộc họp hoặc cuộc gọi khách hàng.',
      'Ghi biên bản, viết hội thoại gián tiếp trong truyện.',
    ],
    examples: [
      GrammarExample(
        en: 'She asked if I was free on Monday.',
        vi: 'Cô ấy hỏi tôi có rảnh thứ Hai không.',
        gloss: 'asked if + S + V',
      ),
      GrammarExample(
        en: 'He asked where I had left my laptop.',
        vi: 'Anh ấy hỏi tôi đã để laptop ở đâu.',
        gloss: 'asked + wh- + S + V (back-shift)',
      ),
      GrammarExample(
        en: 'The teacher told us to hand in the essays by Friday.',
        vi: 'Giáo viên bảo chúng tôi nộp bài luận trước thứ Sáu.',
        gloss: 'told + O + to V',
      ),
      GrammarExample(
        en: 'The guard asked us not to take photos inside.',
        vi: 'Bảo vệ yêu cầu chúng tôi không chụp ảnh bên trong.',
        gloss: 'asked + O + not to V',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'She asked me where do I live.',
        right: 'She asked me where I lived.',
        why: 'Câu hỏi gián tiếp dùng trật tự khẳng định và không có trợ động từ "do".',
      ),
      GrammarMistake(
        wrong: 'He asked if I will join the meeting.',
        right: 'He asked if I would join the meeting.',
        why: 'Khi động từ tường thuật ở quá khứ, "will" lùi thành "would".',
      ),
      GrammarMistake(
        wrong: 'The manager told me don\'t be late again.',
        right: 'The manager told me not to be late again.',
        why: 'Cấu trúc mệnh lệnh tường thuật là "told + O + (not) to V".',
      ),
    ],
    relatedTopicIds: [
      'reported_speech_statements',
      'passive_all_tenses',
      'gerund_infinitive',
    ],
  ),
  GrammarTopic(
    id: 'wishes_regrets',
    title: 'Wishes & Regrets',
    titleVi: 'Câu ước & nuối tiếc',
    level: CefrLevel.b2,
    category: GrammarCategory.other,
    formula: 'I wish + S + V(past) | had + V3 | would + V',
    summary:
        '"Wish" + past tense expresses unreal regret about the present, "wish" + past perfect expresses regret about the past, and "wish" + would describes annoyance at someone\'s repeated behaviour. "If only" works the same way with stronger emotion.',
    summaryVi:
        '"Wish" + quá khứ đơn thể hiện sự nuối tiếc không có thật ở hiện tại, "wish" + quá khứ hoàn thành thể hiện nuối tiếc trong quá khứ, còn "wish" + would diễn tả sự khó chịu vì hành vi lặp lại của người khác. "If only" mang ý tương tự nhưng cảm xúc mạnh hơn.',
    useCases: [
      'Regret about a present situation you cannot change.',
      'Regret about a past action or missed chance.',
      'Complaining about another person\'s habit with "wish + would".',
      'Add emotional emphasis with "If only…".',
    ],
    useCasesVi: [
      'Nuối tiếc tình huống hiện tại không thể đổi.',
      'Nuối tiếc hành động đã rồi hoặc cơ hội đã mất.',
      'Phàn nàn thói quen của người khác với "wish + would".',
      'Nhấn mạnh cảm xúc bằng "If only…".',
    ],
    examples: [
      GrammarExample(
        en: 'I wish I lived closer to the office.',
        vi: 'Tôi ước mình sống gần văn phòng hơn.',
        gloss: 'wish + V(past)',
      ),
      GrammarExample(
        en: 'She wishes she had accepted the offer last year.',
        vi: 'Cô ấy ước đã nhận lời đề nghị năm ngoái.',
        gloss: 'wish + had + V3',
      ),
      GrammarExample(
        en: 'I wish you wouldn\'t interrupt me during meetings.',
        vi: 'Tôi mong bạn đừng ngắt lời tôi trong cuộc họp.',
        gloss: 'wish + would + V',
      ),
      GrammarExample(
        en: 'If only I had saved more money when I was younger.',
        vi: 'Giá mà hồi trẻ tôi đã tiết kiệm nhiều hơn.',
        gloss: 'If only + had + V3',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I wish I have more free time.',
        right: 'I wish I had more free time.',
        why: 'Sau "wish" cho hiện tại không có thật, dùng quá khứ đơn.',
      ),
      GrammarMistake(
        wrong: 'I wish I would be taller.',
        right: 'I wish I were taller.',
        why: '"Wish + would" dùng cho hành động/người khác, không dùng cho đặc điểm bản thân.',
      ),
      GrammarMistake(
        wrong: 'She wishes she didn\'t fail the test yesterday.',
        right: 'She wishes she hadn\'t failed the test yesterday.',
        why: 'Nuối tiếc về quá khứ phải dùng "wish + had/hadn\'t + V3".',
      ),
    ],
    relatedTopicIds: [
      'second_conditional',
      'third_conditional',
      'mixed_conditionals',
    ],
  ),
  GrammarTopic(
    id: 'modals_deduction',
    title: 'Modals of Deduction',
    titleVi: 'Modal suy đoán',
    level: CefrLevel.b2,
    category: GrammarCategory.modal,
    formula: 'S + must / might / can\'t + (have +) V3',
    summary:
        'Modals of deduction express how certain we are about something based on evidence. "Must" shows strong belief, "might/may/could" show possibility, and "can\'t" shows strong disbelief. Add "have + V3" to deduce about the past.',
    summaryVi:
        'Modal suy đoán thể hiện mức độ chắc chắn của người nói dựa trên bằng chứng. "Must" thể hiện sự tin chắc, "might/may/could" diễn tả khả năng, còn "can\'t" thể hiện sự tin chắc điều gì đó không đúng. Thêm "have + V3" để suy đoán về quá khứ.',
    useCases: [
      'Strong logical conclusion with "must (have)".',
      'Tentative possibility with "might / may / could (have)".',
      'Impossibility or strong disbelief with "can\'t (have)".',
      'Inferring causes from observed evidence.',
    ],
    useCasesVi: [
      'Kết luận chắc chắn với "must (have)".',
      'Khả năng dè dặt với "might / may / could (have)".',
      'Bất khả thi hoặc nghi ngờ mạnh với "can\'t (have)".',
      'Suy luận nguyên nhân từ bằng chứng quan sát được.',
    ],
    examples: [
      GrammarExample(
        en: 'The lights are on; she must be home.',
        vi: 'Đèn đang bật; chắc chắn cô ấy đang ở nhà.',
        gloss: 'must + V (now)',
      ),
      GrammarExample(
        en: 'He didn\'t answer; he might have been in a meeting.',
        vi: 'Anh ấy không bắt máy; có thể anh ấy đang họp lúc đó.',
        gloss: 'might have + V3 (past)',
      ),
      GrammarExample(
        en: 'She can\'t be tired; she just woke up.',
        vi: 'Cô ấy không thể mệt; mới ngủ dậy mà.',
        gloss: 'can\'t + V (now)',
      ),
      GrammarExample(
        en: 'They can\'t have left already; their bags are still here.',
        vi: 'Họ không thể đã đi rồi; túi vẫn còn ở đây.',
        gloss: 'can\'t have + V3 (past)',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'He mustn\'t be the manager; he\'s too young.',
        right: 'He can\'t be the manager; he\'s too young.',
        why: '"Mustn\'t" nghĩa là cấm; phủ định suy đoán dùng "can\'t".',
      ),
      GrammarMistake(
        wrong: 'She must forgot her keys at home.',
        right: 'She must have forgotten her keys at home.',
        why: 'Suy đoán quá khứ phải dùng "must have + V3".',
      ),
      GrammarMistake(
        wrong: 'They might to be at the airport now.',
        right: 'They might be at the airport now.',
        why: 'Sau modal là động từ nguyên thể, không có "to".',
      ),
    ],
    relatedTopicIds: [
      'modal_must',
      'modal_perfect',
      'passive_all_tenses',
    ],
  ),
  GrammarTopic(
    id: 'relative_clauses_non_defining',
    title: 'Relative Clauses (non-defining)',
    titleVi: 'Mệnh đề quan hệ không xác định',
    level: CefrLevel.b2,
    category: GrammarCategory.clause,
    formula: 'N , who/which + V , …',
    summary:
        'Non-defining relative clauses add extra information about a noun that is already identified. They are set off by commas, the relative pronoun cannot be omitted, and "that" cannot be used in this type of clause.',
    summaryVi:
        'Mệnh đề quan hệ không xác định bổ sung thông tin thêm về một danh từ đã được xác định rõ. Chúng được tách bằng dấu phẩy, không được lược bỏ đại từ quan hệ và không được dùng "that" trong loại mệnh đề này.',
    useCases: [
      'Add background detail without changing meaning.',
      'Common in news writing and biographies.',
      'Always set off by commas in writing, pauses in speech.',
      'Use "which" to comment on a whole previous clause.',
    ],
    useCasesVi: [
      'Thêm chi tiết phụ mà không thay đổi nghĩa chính.',
      'Phổ biến trong tin tức và tiểu sử.',
      'Luôn tách bằng dấu phẩy khi viết, ngắt hơi khi nói.',
      'Dùng "which" để bình luận về cả mệnh đề trước.',
    ],
    examples: [
      GrammarExample(
        en: 'My manager, who joined last year, is leading the project.',
        vi: 'Quản lý của tôi, người mới vào năm ngoái, đang dẫn dắt dự án.',
        gloss: ', who + V ,',
      ),
      GrammarExample(
        en: 'Hanoi, which is over a thousand years old, attracts many tourists.',
        vi: 'Hà Nội, vốn hơn nghìn năm tuổi, thu hút rất nhiều du khách.',
        gloss: ', which + V ,',
      ),
      GrammarExample(
        en: 'The CEO announced a pay rise, which surprised everyone.',
        vi: 'Giám đốc thông báo tăng lương, điều khiến mọi người bất ngờ.',
        gloss: ', which (refers to the whole clause)',
      ),
      GrammarExample(
        en: 'My laptop, whose battery is failing, needs replacing soon.',
        vi: 'Laptop của tôi, vốn đang hỏng pin, sắp cần thay rồi.',
        gloss: ', whose + N ,',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'My brother that lives in Da Nang is a doctor.',
        right: 'My brother, who lives in Da Nang, is a doctor.',
        why: 'Khi danh từ đã xác định, dùng dấu phẩy và "who/which", không dùng "that".',
      ),
      GrammarMistake(
        wrong: 'Paris which is the capital of France is beautiful.',
        right: 'Paris, which is the capital of France, is beautiful.',
        why: 'Mệnh đề không xác định bắt buộc phải có dấu phẩy ở hai đầu.',
      ),
      GrammarMistake(
        wrong: 'My phone, I bought last month, is already broken.',
        right: 'My phone, which I bought last month, is already broken.',
        why: 'Trong mệnh đề không xác định, không được lược bỏ đại từ quan hệ.',
      ),
    ],
    relatedTopicIds: [
      'relative_clauses_defining',
      'participle_clauses',
      'linking_concession',
    ],
  ),
  GrammarTopic(
    id: 'causative',
    title: 'Causative: have / get something done',
    titleVi: 'Câu nhờ vả (have/get something done)',
    level: CefrLevel.b2,
    category: GrammarCategory.other,
    formula: 'S + have/get + O + V3',
    summary:
        'The causative "have/get + object + past participle" describes arranging for someone else to do something for you. "Get" is more informal than "have", and the doer is usually omitted unless it is important.',
    summaryVi:
        'Cấu trúc nhờ vả "have/get + tân ngữ + phân từ quá khứ" diễn tả việc thu xếp để người khác làm hộ mình. "Get" mang sắc thái thân mật hơn "have", và người thực hiện thường được lược bỏ trừ khi cần nhấn mạnh.',
    useCases: [
      'Services arranged at a salon, garage, or office.',
      'Distinguish from doing the action yourself.',
      'Talk about repairs, deliveries, alterations.',
      'Negative experiences: "I had my bag stolen."',
    ],
    useCasesVi: [
      'Dịch vụ thực hiện tại tiệm, garage hoặc văn phòng.',
      'Phân biệt với việc tự mình làm hành động đó.',
      'Nói về sửa chữa, giao hàng, chỉnh sửa.',
      'Trải nghiệm tiêu cực: "I had my bag stolen."',
    ],
    examples: [
      GrammarExample(
        en: 'I had my hair cut yesterday.',
        vi: 'Hôm qua tôi đi cắt tóc.',
        gloss: 'had + O + V3',
      ),
      GrammarExample(
        en: 'We are getting our car repaired this weekend.',
        vi: 'Cuối tuần này chúng tôi mang xe đi sửa.',
        gloss: 'get + O + V3 (continuous)',
      ),
      GrammarExample(
        en: 'She had her passport stolen on the train.',
        vi: 'Cô ấy bị mất hộ chiếu trên tàu.',
        gloss: 'had + O + V3 (negative experience)',
      ),
      GrammarExample(
        en: 'You should get your eyes tested every year.',
        vi: 'Bạn nên đi kiểm tra mắt mỗi năm.',
        gloss: 'get + O + V3 (modal)',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I had cut my hair yesterday.',
        right: 'I had my hair cut yesterday.',
        why: 'Trật tự đúng là "have + tân ngữ + V3"; sai trật tự sẽ thành nghĩa tự làm.',
      ),
      GrammarMistake(
        wrong: 'She got repaired her phone.',
        right: 'She got her phone repaired.',
        why: 'Tân ngữ phải đứng giữa "get" và phân từ quá khứ.',
      ),
      GrammarMistake(
        wrong: 'I will have my car to wash tomorrow.',
        right: 'I will have my car washed tomorrow.',
        why: 'Sau tân ngữ phải là phân từ quá khứ "washed", không phải "to V".',
      ),
    ],
    relatedTopicIds: [
      'passive_all_tenses',
      'passive_basic',
      'modal_should',
    ],
  ),
  GrammarTopic(
    id: 'linking_concession',
    title: 'although / despite / however',
    titleVi: 'Liên từ nhượng bộ (although / despite / however)',
    level: CefrLevel.b2,
    category: GrammarCategory.linkingInversion,
    formula: 'Although + clause | Despite + N/V-ing | … , however , …',
    summary:
        'These linkers introduce contrast between two ideas. "Although/though/even though" join two clauses, "despite/in spite of" take a noun or "-ing" form, and "however" is an adverb that links separate sentences with commas.',
    summaryVi:
        'Các liên từ này dùng để diễn tả sự tương phản giữa hai ý. "Although/though/even though" nối hai mệnh đề, "despite/in spite of" đi với danh từ hoặc "-ing", còn "however" là trạng từ nối hai câu riêng và đi kèm dấu phẩy.',
    useCases: [
      'Concede a point before stating a contrast.',
      'Vary written style by switching between structures.',
      'Use "however" to start a new sentence formally.',
      'Add emphasis with "even though" stronger than "although".',
    ],
    useCasesVi: [
      'Thừa nhận một ý trước khi nêu ý tương phản.',
      'Đa dạng văn phong bằng cách đổi cấu trúc.',
      'Dùng "however" để mở câu mới trang trọng.',
      'Nhấn mạnh hơn bằng "even though" so với "although".',
    ],
    examples: [
      GrammarExample(
        en: 'Although the team was tired, they finished the project on time.',
        vi: 'Mặc dù nhóm đã mệt, họ vẫn hoàn thành dự án đúng hạn.',
        gloss: 'Although + clause',
      ),
      GrammarExample(
        en: 'Despite the heavy rain, the match continued.',
        vi: 'Bất chấp cơn mưa lớn, trận đấu vẫn tiếp tục.',
        gloss: 'Despite + N',
      ),
      GrammarExample(
        en: 'In spite of feeling unwell, she joined the meeting.',
        vi: 'Dù không khỏe, cô ấy vẫn tham gia cuộc họp.',
        gloss: 'In spite of + V-ing',
      ),
      GrammarExample(
        en: 'The product is popular. However, the price is too high.',
        vi: 'Sản phẩm rất được ưa chuộng. Tuy nhiên, giá lại quá cao.',
        gloss: '. However, + clause',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'Despite he was tired, he kept working.',
        right: 'Although he was tired, he kept working.',
        why: '"Despite" đi với danh từ/V-ing; "although" mới đi với mệnh đề.',
      ),
      GrammarMistake(
        wrong: 'Although the bad weather, we went out.',
        right: 'Despite the bad weather, we went out.',
        why: '"Although" cần một mệnh đề đầy đủ; với danh từ phải dùng "despite".',
      ),
      GrammarMistake(
        wrong: 'He was tired, however he finished the report.',
        right: 'He was tired; however, he finished the report.',
        why: '"However" cần dấu chấm phẩy hoặc dấu chấm trước, và dấu phẩy sau.',
      ),
    ],
    relatedTopicIds: [
      'relative_clauses_non_defining',
      'advanced_linking',
      'gerund_infinitive',
    ],
  ),
];
