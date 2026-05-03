import '../models/grammar_topic.dart';

/// B1 — Intermediate. 11 topics: continuous + perfect tenses, the first
/// conditional, basic passive and reported speech, defining relative
/// clauses, and the gerund-vs-infinitive distinction that trips up most
/// upper-elementary learners.
const List<GrammarTopic> grammarB1 = [
  GrammarTopic(
    id: 'past_continuous',
    title: 'Past Continuous',
    titleVi: 'Quá khứ tiếp diễn',
    level: CefrLevel.b1,
    category: GrammarCategory.tense,
    formula: 'S + was/were + V-ing',
    summary:
        'The Past Continuous describes an action in progress at a specific past moment, or a longer background action interrupted by a shorter Past Simple event.',
    summaryVi:
        'Quá khứ tiếp diễn diễn tả hành động đang xảy ra tại một thời điểm trong quá khứ, hoặc hành động dài bị ngắt bởi một hành động ngắn ở quá khứ đơn.',
    useCases: [
      'Action in progress at a past time: "At 8 p.m. I was studying."',
      'Background interrupted by a Past Simple event with "when".',
      'Two parallel ongoing past actions linked by "while".',
      'Setting the scene at the start of a story or anecdote.',
    ],
    useCasesVi: [
      'Hành động đang diễn ra tại một thời điểm quá khứ: "Lúc 8 giờ tối tôi đang học."',
      'Hành động nền bị ngắt bởi sự kiện quá khứ đơn dùng "when".',
      'Hai hành động cùng diễn ra song song trong quá khứ với "while".',
      'Mô tả bối cảnh mở đầu cho một câu chuyện.',
    ],
    examples: [
      GrammarExample(
        en: 'I was cooking dinner when the lights went out.',
        vi: 'Tôi đang nấu bữa tối thì mất điện.',
        gloss: 'was/were + V-ing + when + V2',
      ),
      GrammarExample(
        en: 'While she was reading, the baby was sleeping.',
        vi: 'Trong khi cô ấy đang đọc sách, em bé đang ngủ.',
        gloss: 'while + V-ing, V-ing (parallel)',
      ),
      GrammarExample(
        en: 'At midnight last night I was driving home.',
        vi: 'Lúc nửa đêm hôm qua tôi đang lái xe về nhà.',
      ),
      GrammarExample(
        en: 'It was raining hard when we arrived at the hotel.',
        vi: 'Trời đang mưa to khi chúng tôi đến khách sạn.',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I was knowing the answer.',
        right: 'I knew the answer.',
        why:
            'Động từ trạng thái (know, like, want…) không dùng ở thì tiếp diễn.',
      ),
      GrammarMistake(
        wrong: 'When she called, I cooked.',
        right: 'When she called, I was cooking.',
        why:
            'Hành động đang dở dang khi bị ngắt phải chia ở quá khứ tiếp diễn.',
      ),
      GrammarMistake(
        wrong: 'They was playing football.',
        right: 'They were playing football.',
        why: 'Chủ ngữ số nhiều (they/we/you) phải dùng "were", không phải "was".',
      ),
    ],
    relatedTopicIds: ['past_simple', 'past_perfect', 'used_to_would'],
  ),
  GrammarTopic(
    id: 'present_perfect',
    title: 'Present Perfect',
    titleVi: 'Hiện tại hoàn thành',
    level: CefrLevel.b1,
    category: GrammarCategory.tense,
    formula: 'S + have/has + V3',
    summary:
        'The Present Perfect links a past action to the present: life experience, recent news, or an unfinished period up to now. The exact past time is unknown or irrelevant.',
    summaryVi:
        'Hiện tại hoàn thành nối quá khứ với hiện tại: kinh nghiệm sống, tin tức vừa xảy ra, hoặc khoảng thời gian chưa kết thúc tới giờ. Thời điểm cụ thể không quan trọng.',
    useCases: [
      'Life experience: "I have been to Japan." (no specific time).',
      'Action just finished with present result: "He has lost his keys."',
      'Unfinished period with "for / since / this week / today".',
      'Contrast with Past Simple: finished time → Past Simple.',
    ],
    useCasesVi: [
      'Kinh nghiệm trong đời: "Tôi đã từng đến Nhật." (không nêu thời điểm).',
      'Hành động vừa kết thúc, còn ảnh hưởng hiện tại: "Anh ấy bị mất chìa khoá."',
      'Khoảng thời gian chưa kết thúc với "for / since / this week / today".',
      'Phân biệt với quá khứ đơn: thời gian xác định → quá khứ đơn.',
    ],
    examples: [
      GrammarExample(
        en: 'I have lived in Hanoi for ten years.',
        vi: 'Tôi đã sống ở Hà Nội được mười năm rồi.',
        gloss: 'have/has + V3 + for + duration',
      ),
      GrammarExample(
        en: 'She has just finished her homework.',
        vi: 'Cô ấy vừa làm xong bài tập về nhà.',
        gloss: 'have/has + just + V3',
      ),
      GrammarExample(
        en: 'Have you ever tried Korean food?',
        vi: 'Bạn đã bao giờ thử món Hàn chưa?',
      ),
      GrammarExample(
        en: 'We haven\'t seen him since Monday.',
        vi: 'Chúng tôi không gặp anh ấy từ thứ Hai đến giờ.',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I have seen him yesterday.',
        right: 'I saw him yesterday.',
        why:
            'Có trạng từ thời gian xác định (yesterday, last week…) thì dùng quá khứ đơn, không dùng hiện tại hoàn thành.',
      ),
      GrammarMistake(
        wrong: 'I have lived here since ten years.',
        right: 'I have lived here for ten years.',
        why: 'Dùng "for" với khoảng thời gian; "since" dùng với mốc thời gian.',
      ),
      GrammarMistake(
        wrong: 'She has went home.',
        right: 'She has gone home.',
        why:
            'Sau "have/has" phải dùng quá khứ phân từ (V3), không dùng quá khứ đơn (V2).',
      ),
    ],
    relatedTopicIds: [
      'past_simple',
      'present_perfect_continuous',
      'past_perfect',
    ],
  ),
  GrammarTopic(
    id: 'present_perfect_continuous',
    title: 'Present Perfect Continuous',
    titleVi: 'Hiện tại hoàn thành tiếp diễn',
    level: CefrLevel.b1,
    category: GrammarCategory.tense,
    formula: 'S + have/has + been + V-ing',
    summary:
        'The Present Perfect Continuous emphasises duration of an action that started in the past and is still in progress, or has just stopped with a visible result.',
    summaryVi:
        'Hiện tại hoàn thành tiếp diễn nhấn mạnh khoảng thời gian của một hành động bắt đầu trong quá khứ và còn tiếp tục, hoặc vừa dừng nhưng để lại kết quả rõ ràng.',
    useCases: [
      'Duration up to now with "for / since / how long".',
      'Action just stopped with a visible result: "I\'m tired — I\'ve been running."',
      'Repeated action over a period: "She\'s been calling all morning."',
      'Contrast with Present Perfect: focus on activity, not completion.',
    ],
    useCasesVi: [
      'Khoảng thời gian kéo dài đến hiện tại với "for / since / how long".',
      'Hành động vừa dừng để lại kết quả thấy được: "Tôi mệt — tôi vừa chạy bộ."',
      'Hành động lặp lại trong một khoảng: "Cô ấy gọi cả sáng nay rồi."',
      'Khác với hiện tại hoàn thành: nhấn mạnh quá trình, không phải kết quả.',
    ],
    examples: [
      GrammarExample(
        en: 'I have been learning English for five years.',
        vi: 'Tôi đã học tiếng Anh được năm năm rồi.',
        gloss: 'have/has + been + V-ing + for',
      ),
      GrammarExample(
        en: 'She\'s been working since 7 a.m. and looks exhausted.',
        vi: 'Cô ấy đã làm việc từ 7 giờ sáng và trông kiệt sức.',
      ),
      GrammarExample(
        en: 'It has been raining all day.',
        vi: 'Trời mưa cả ngày rồi.',
      ),
      GrammarExample(
        en: 'How long have you been waiting?',
        vi: 'Bạn đã đợi bao lâu rồi?',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I have been knowing her for years.',
        right: 'I have known her for years.',
        why:
            'Động từ trạng thái (know, love, own…) không dùng ở dạng tiếp diễn; dùng hiện tại hoàn thành đơn.',
      ),
      GrammarMistake(
        wrong: 'I have been reading three books this week.',
        right: 'I have read three books this week.',
        why:
            'Khi nói về số lượng đã hoàn thành, dùng hiện tại hoàn thành; tiếp diễn dùng cho quá trình kéo dài.',
      ),
      GrammarMistake(
        wrong: 'She has been work here since June.',
        right: 'She has been working here since June.',
        why: 'Sau "been" phải dùng V-ing, không dùng động từ nguyên mẫu.',
      ),
    ],
    relatedTopicIds: [
      'present_perfect',
      'present_continuous',
      'past_perfect_continuous',
    ],
  ),
  GrammarTopic(
    id: 'past_perfect',
    title: 'Past Perfect',
    titleVi: 'Quá khứ hoàn thành',
    level: CefrLevel.b1,
    category: GrammarCategory.tense,
    formula: 'S + had + V3',
    summary:
        'The Past Perfect marks an action completed before another past action or moment. It clarifies the order of events when telling a story in the past.',
    summaryVi:
        'Quá khứ hoàn thành đánh dấu hành động đã xảy ra trước một hành động hoặc thời điểm khác trong quá khứ, giúp làm rõ trình tự các sự kiện.',
    useCases: [
      'Earlier of two past actions: "She had left when I arrived."',
      'After "by the time / before / after / when" linking past events.',
      'Reason for a past state: "He was tired because he had run."',
      'Required back-shift in reported speech of past events.',
    ],
    useCasesVi: [
      'Hành động xảy ra trước trong hai sự kiện quá khứ: "Cô ấy đã đi trước khi tôi đến."',
      'Sau "by the time / before / after / when" để nối hai sự kiện.',
      'Giải thích lý do của trạng thái quá khứ: "Anh ấy mệt vì đã chạy bộ."',
      'Bắt buộc lùi thì trong câu tường thuật khi sự kiện đã ở quá khứ.',
    ],
    examples: [
      GrammarExample(
        en: 'When I arrived, the train had already left.',
        vi: 'Khi tôi đến nơi, tàu đã rời đi rồi.',
        gloss: 'had + V3 (action 1) + V2 (action 2)',
      ),
      GrammarExample(
        en: 'She had finished dinner before he came home.',
        vi: 'Cô ấy đã ăn xong bữa tối trước khi anh ấy về nhà.',
      ),
      GrammarExample(
        en: 'I didn\'t recognise her because she had cut her hair.',
        vi: 'Tôi không nhận ra cô ấy vì cô ấy đã cắt tóc.',
      ),
      GrammarExample(
        en: 'By the time we got there, the film had started.',
        vi: 'Lúc chúng tôi đến nơi thì phim đã bắt đầu rồi.',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'When I arrived, the train left.',
        right: 'When I arrived, the train had left.',
        why:
            'Hành động xảy ra trước phải dùng quá khứ hoàn thành để phân biệt thứ tự thời gian.',
      ),
      GrammarMistake(
        wrong: 'I had saw that film before.',
        right: 'I had seen that film before.',
        why: 'Sau "had" phải dùng quá khứ phân từ (V3), không dùng V2.',
      ),
      GrammarMistake(
        wrong: 'She had left yesterday.',
        right: 'She left yesterday.',
        why:
            'Quá khứ hoàn thành cần một mốc quá khứ khác để so sánh; nếu chỉ có một sự kiện, dùng quá khứ đơn.',
      ),
    ],
    relatedTopicIds: [
      'past_simple',
      'present_perfect',
      'reported_speech_statements',
    ],
  ),
  GrammarTopic(
    id: 'first_conditional',
    title: '1st Conditional',
    titleVi: 'Câu điều kiện loại 1',
    level: CefrLevel.b1,
    category: GrammarCategory.conditional,
    formula: 'If + S + V(present), S + will + V',
    summary:
        'The First Conditional talks about real, possible future situations and their likely results. The "if" clause uses the Present Simple, never "will".',
    summaryVi:
        'Câu điều kiện loại 1 nói về tình huống có thật, có khả năng xảy ra trong tương lai và kết quả của nó. Mệnh đề "if" dùng hiện tại đơn, không dùng "will".',
    useCases: [
      'Real future possibility: "If it rains, we\'ll stay home."',
      'Promises, warnings, threats: "If you touch that, you\'ll burn yourself."',
      'Plans depending on a condition: "If I have time, I\'ll call you."',
      '"Unless" replaces "if not": "Unless you hurry, you\'ll be late."',
    ],
    useCasesVi: [
      'Khả năng có thật trong tương lai: "Nếu trời mưa, chúng tôi sẽ ở nhà."',
      'Lời hứa, cảnh báo, đe doạ: "Nếu chạm vào đó, bạn sẽ bị bỏng."',
      'Kế hoạch phụ thuộc điều kiện: "Nếu có thời gian, tôi sẽ gọi cho bạn."',
      '"Unless" thay cho "if not": "Trừ khi bạn nhanh lên, bạn sẽ trễ."',
    ],
    examples: [
      GrammarExample(
        en: 'If you study hard, you will pass the exam.',
        vi: 'Nếu bạn học chăm, bạn sẽ đỗ kỳ thi.',
        gloss: 'If + V(present), will + V',
      ),
      GrammarExample(
        en: 'I\'ll call you if I finish early.',
        vi: 'Tôi sẽ gọi bạn nếu tôi xong sớm.',
      ),
      GrammarExample(
        en: 'Unless you leave now, you\'ll miss the bus.',
        vi: 'Trừ khi bạn đi ngay, bạn sẽ lỡ chuyến xe buýt.',
      ),
      GrammarExample(
        en: 'If she doesn\'t come, we\'ll start without her.',
        vi: 'Nếu cô ấy không đến, chúng tôi sẽ bắt đầu mà không có cô ấy.',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'If it will rain, we will stay home.',
        right: 'If it rains, we will stay home.',
        why: 'Sau "if" trong điều kiện loại 1 không dùng "will"; dùng hiện tại đơn.',
      ),
      GrammarMistake(
        wrong: 'If I will have time, I call you.',
        right: 'If I have time, I will call you.',
        why:
            'Mệnh đề "if" dùng hiện tại đơn, mệnh đề chính dùng "will" + động từ nguyên mẫu.',
      ),
      GrammarMistake(
        wrong: 'Unless you don\'t hurry, you\'ll be late.',
        right: 'Unless you hurry, you\'ll be late.',
        why:
            '"Unless" đã mang nghĩa phủ định ("if not"), không dùng kèm "don\'t".',
      ),
    ],
    relatedTopicIds: ['future_will', 'present_simple', 'second_conditional'],
  ),
  GrammarTopic(
    id: 'passive_basic',
    title: 'Passive Voice (basic)',
    titleVi: 'Câu bị động (cơ bản)',
    level: CefrLevel.b1,
    category: GrammarCategory.passive,
    formula: 'S + be(present/past) + V3 (+ by O)',
    summary:
        'The passive shifts focus from the doer to the receiver of the action. Use it when the doer is unknown, unimportant, or obvious from context.',
    summaryVi:
        'Câu bị động chuyển sự chú ý từ người thực hiện sang đối tượng chịu tác động của hành động. Dùng khi người thực hiện không rõ, không quan trọng, hoặc đã rõ trong ngữ cảnh.',
    useCases: [
      'Doer unknown or unimportant: "My bike was stolen."',
      'Process or procedure description: "Coffee is grown in Brazil."',
      'News, reports, formal writing: "Three people were injured."',
      'Add "by + agent" only when the doer is relevant.',
    ],
    useCasesVi: [
      'Không rõ hoặc không cần biết người thực hiện: "Xe đạp của tôi bị trộm."',
      'Mô tả quy trình, sự việc khách quan: "Cà phê được trồng ở Brazil."',
      'Tin tức, báo cáo, văn phong trang trọng: "Ba người bị thương."',
      'Chỉ thêm "by + tác nhân" khi người thực hiện thực sự cần thiết.',
    ],
    examples: [
      GrammarExample(
        en: 'English is spoken in many countries.',
        vi: 'Tiếng Anh được nói ở nhiều nước.',
        gloss: 'is/are + V3',
      ),
      GrammarExample(
        en: 'The window was broken last night.',
        vi: 'Cái cửa sổ đã bị vỡ tối qua.',
        gloss: 'was/were + V3',
      ),
      GrammarExample(
        en: 'This song was written by Adele.',
        vi: 'Bài hát này được Adele sáng tác.',
      ),
      GrammarExample(
        en: 'The letters are delivered every morning.',
        vi: 'Thư được giao mỗi sáng.',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'The cake was make by my mum.',
        right: 'The cake was made by my mum.',
        why: 'Sau "be" trong câu bị động phải dùng quá khứ phân từ (V3), không dùng V1.',
      ),
      GrammarMistake(
        wrong: 'The book wrote by him.',
        right: 'The book was written by him.',
        why: 'Câu bị động cần động từ "be" (was/were/is/are) trước V3.',
      ),
      GrammarMistake(
        wrong: 'My phone was stolen by someone.',
        right: 'My phone was stolen.',
        why:
            'Khi tác nhân không xác định ("someone"), không cần thêm cụm "by + agent".',
      ),
    ],
    relatedTopicIds: [
      'past_simple',
      'present_simple',
      'passive_all_tenses',
    ],
  ),
  GrammarTopic(
    id: 'reported_speech_statements',
    title: 'Reported Speech (statements)',
    titleVi: 'Câu tường thuật (câu kể)',
    level: CefrLevel.b1,
    category: GrammarCategory.reported,
    formula: 'S + said (that) + S + V(back-shifted)',
    summary:
        'Reported speech relays what someone said. Verbs usually back-shift one tense into the past, and pronouns plus time/place words shift to fit the new context.',
    summaryVi:
        'Câu tường thuật thuật lại lời người khác nói. Động từ thường lùi một thì về quá khứ; đại từ và từ chỉ thời gian/nơi chốn cũng phải đổi cho phù hợp ngữ cảnh mới.',
    useCases: [
      'Back-shift: present → past, past → past perfect, will → would.',
      'Change pronouns and time words: "today" → "that day", "tomorrow" → "the next day".',
      'No back-shift if the fact is still true or reporting verb is present.',
      '"that" is optional after said/told in informal speech.',
    ],
    useCasesVi: [
      'Lùi thì: hiện tại → quá khứ, quá khứ → quá khứ hoàn thành, will → would.',
      'Đổi đại từ và từ chỉ thời gian: "today" → "that day", "tomorrow" → "the next day".',
      'Không lùi thì khi sự việc còn đúng hoặc động từ tường thuật ở hiện tại.',
      '"that" có thể bỏ sau said/told trong văn nói thân mật.',
    ],
    examples: [
      GrammarExample(
        en: 'She said (that) she was tired.',
        vi: 'Cô ấy nói rằng cô ấy mệt.',
        gloss: 'present "am" → past "was"',
      ),
      GrammarExample(
        en: 'He told me he had finished the report.',
        vi: 'Anh ấy nói với tôi rằng anh ấy đã làm xong báo cáo.',
        gloss: 'present perfect → past perfect',
      ),
      GrammarExample(
        en: 'They said they would call the next day.',
        vi: 'Họ nói họ sẽ gọi vào ngày hôm sau.',
      ),
      GrammarExample(
        en: 'The teacher said the Earth is round.',
        vi: 'Cô giáo nói Trái Đất hình tròn.',
        gloss: 'no back-shift — fact still true',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'She said she is tired.',
        right: 'She said she was tired.',
        why:
            'Khi động từ tường thuật ở quá khứ, mệnh đề được thuật phải lùi một thì.',
      ),
      GrammarMistake(
        wrong: 'He said me he was busy.',
        right: 'He told me he was busy. / He said he was busy.',
        why: '"Said" không đi kèm tân ngữ trực tiếp; "told" mới cần tân ngữ.',
      ),
      GrammarMistake(
        wrong: 'She said she will come tomorrow.',
        right: 'She said she would come the next day.',
        why:
            'Cần đổi "will" thành "would" và "tomorrow" thành "the next day" khi tường thuật.',
      ),
    ],
    relatedTopicIds: [
      'past_perfect',
      'past_simple',
      'reported_speech_questions_commands',
    ],
  ),
  GrammarTopic(
    id: 'relative_clauses_defining',
    title: 'Relative Clauses (defining)',
    titleVi: 'Mệnh đề quan hệ xác định',
    level: CefrLevel.b1,
    category: GrammarCategory.clause,
    formula: 'N + who/which/that + V…',
    summary:
        'Defining relative clauses identify which person or thing we mean and are essential to the sentence. They take no commas, and the relative pronoun can be omitted when it is the object.',
    summaryVi:
        'Mệnh đề quan hệ xác định giúp nhận diện người hoặc vật được nói đến và là phần thiết yếu của câu. Không dùng dấu phẩy, và có thể bỏ đại từ quan hệ khi nó đóng vai tân ngữ.',
    useCases: [
      'who/that for people; which/that for things; whose for possession.',
      'where for places, when for times: "the city where I grew up".',
      'Drop the pronoun if it is the object: "the book (that) I read".',
      'No commas — the clause defines, it doesn\'t add extra info.',
    ],
    useCasesVi: [
      'who/that cho người; which/that cho vật; whose chỉ sự sở hữu.',
      'where cho nơi chốn, when cho thời gian: "thành phố nơi tôi lớn lên".',
      'Có thể bỏ đại từ khi nó là tân ngữ: "the book (that) I read".',
      'Không dùng dấu phẩy — mệnh đề này xác định, không phải bổ sung.',
    ],
    examples: [
      GrammarExample(
        en: 'The man who lives next door is a doctor.',
        vi: 'Người đàn ông sống nhà bên cạnh là bác sĩ.',
        gloss: 'who = subject (people)',
      ),
      GrammarExample(
        en: 'This is the book (that) I bought yesterday.',
        vi: 'Đây là cuốn sách tôi mua hôm qua.',
        gloss: 'that as object — can be omitted',
      ),
      GrammarExample(
        en: 'I met a girl whose brother is famous.',
        vi: 'Tôi gặp một cô gái có anh trai nổi tiếng.',
      ),
      GrammarExample(
        en: 'That\'s the café where we first met.',
        vi: 'Đó là quán cà phê nơi chúng tôi gặp nhau lần đầu.',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'The woman which lives here is kind.',
        right: 'The woman who lives here is kind.',
        why: 'Dùng "who" hoặc "that" cho người, không dùng "which".',
      ),
      GrammarMistake(
        wrong: 'The book who I read was great.',
        right: 'The book which/that I read was great.',
        why: 'Dùng "which" hoặc "that" cho vật, không dùng "who".',
      ),
      GrammarMistake(
        wrong: 'The man, who lives next door, is a doctor.',
        right: 'The man who lives next door is a doctor.',
        why:
            'Mệnh đề quan hệ xác định không dùng dấu phẩy; chỉ mệnh đề không xác định mới có dấu phẩy.',
      ),
    ],
    relatedTopicIds: [
      'relative_clauses_non_defining',
      'subject_pronouns_possessives',
      'object_pronouns',
    ],
  ),
  GrammarTopic(
    id: 'gerund_infinitive',
    title: 'Gerund vs Infinitive',
    titleVi: 'Danh động từ vs Động từ nguyên mẫu',
    level: CefrLevel.b1,
    category: GrammarCategory.other,
    formula: 'V + V-ing | V + to V (verb-dependent)',
    summary:
        'Some verbs are followed by a gerund (V-ing), others by an infinitive (to + V). The choice depends on the main verb, and a few verbs allow both with a change in meaning.',
    summaryVi:
        'Một số động từ theo sau là danh động từ (V-ing), một số khác theo sau là động từ nguyên mẫu (to + V). Sự lựa chọn phụ thuộc vào động từ chính; vài động từ dùng được cả hai với nghĩa khác nhau.',
    useCases: [
      'Gerund after: enjoy, avoid, finish, mind, suggest, keep.',
      'Infinitive after: want, hope, decide, plan, promise, agree.',
      'Both with meaning change: remember/forget/stop/try.',
      'Always V-ing after prepositions: "good at speaking", "before leaving".',
    ],
    useCasesVi: [
      'V-ing sau: enjoy, avoid, finish, mind, suggest, keep.',
      'To + V sau: want, hope, decide, plan, promise, agree.',
      'Cả hai dạng nhưng đổi nghĩa: remember / forget / stop / try.',
      'Luôn dùng V-ing sau giới từ: "good at speaking", "before leaving".',
    ],
    examples: [
      GrammarExample(
        en: 'I enjoy reading novels at weekends.',
        vi: 'Tôi thích đọc tiểu thuyết vào cuối tuần.',
        gloss: 'enjoy + V-ing',
      ),
      GrammarExample(
        en: 'She decided to study abroad next year.',
        vi: 'Cô ấy quyết định đi du học vào năm tới.',
        gloss: 'decide + to + V',
      ),
      GrammarExample(
        en: 'He stopped smoking last year.',
        vi: 'Anh ấy đã bỏ hút thuốc năm ngoái.',
        gloss: 'stop + V-ing = quit doing it',
      ),
      GrammarExample(
        en: 'We stopped to take a photo.',
        vi: 'Chúng tôi dừng lại để chụp ảnh.',
        gloss: 'stop + to V = pause in order to',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I enjoy to read books.',
        right: 'I enjoy reading books.',
        why: 'Sau "enjoy" luôn dùng V-ing, không dùng to + V.',
      ),
      GrammarMistake(
        wrong: 'She wants going home.',
        right: 'She wants to go home.',
        why: 'Sau "want" phải dùng to + V, không dùng V-ing.',
      ),
      GrammarMistake(
        wrong: 'He is good at to cook.',
        right: 'He is good at cooking.',
        why: 'Sau giới từ ("at", "of", "in"…) luôn dùng V-ing.',
      ),
    ],
    relatedTopicIds: ['modal_can', 'modal_should', 'present_continuous'],
  ),
  GrammarTopic(
    id: 'used_to_would',
    title: '"used to" / "would"',
    titleVi: '"used to" / "would" (thói quen quá khứ)',
    level: CefrLevel.b1,
    category: GrammarCategory.other,
    formula:
        'S + used to + V (states + habits) | S + would + V (habits, narrative)',
    summary:
        '"Used to" describes past habits or states that no longer happen. "Would" can replace it for repeated past actions, but not for past states like feelings or possessions.',
    summaryVi:
        '"Used to" diễn tả thói quen hoặc trạng thái trong quá khứ nay không còn. "Would" thay thế được cho hành động lặp lại nhưng không dùng cho trạng thái như cảm xúc hoặc sở hữu.',
    useCases: [
      'Past habit no longer true: "I used to smoke."',
      'Past state (only "used to"): "She used to live in Paris."',
      '"Would" for repeated past actions in storytelling.',
      'Negative/question: "didn\'t use to" / "Did you use to…?"',
    ],
    useCasesVi: [
      'Thói quen quá khứ nay không còn: "Tôi từng hút thuốc."',
      'Trạng thái quá khứ (chỉ dùng "used to"): "Cô ấy từng sống ở Paris."',
      '"Would" cho hành động lặp lại khi kể chuyện quá khứ.',
      'Phủ định/câu hỏi: "didn\'t use to" / "Did you use to…?"',
    ],
    examples: [
      GrammarExample(
        en: 'I used to play football every weekend.',
        vi: 'Tôi từng chơi bóng đá mỗi cuối tuần.',
        gloss: 'used to + V (habit)',
      ),
      GrammarExample(
        en: 'She used to have long hair.',
        vi: 'Cô ấy từng để tóc dài.',
        gloss: 'used to + V (state)',
      ),
      GrammarExample(
        en: 'When we were kids, we would walk to school every day.',
        vi: 'Hồi bé, chúng tôi thường đi bộ đến trường mỗi ngày.',
        gloss: 'would + V (repeated past action)',
      ),
      GrammarExample(
        en: 'Did you use to live in Hue?',
        vi: 'Bạn từng sống ở Huế phải không?',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I used to playing football.',
        right: 'I used to play football.',
        why: 'Sau "used to" phải dùng động từ nguyên mẫu, không dùng V-ing.',
      ),
      GrammarMistake(
        wrong: 'She would have a dog when she was young.',
        right: 'She used to have a dog when she was young.',
        why:
            '"Would" không dùng cho trạng thái hay sở hữu trong quá khứ; chỉ "used to" mới dùng được.',
      ),
      GrammarMistake(
        wrong: 'I didn\'t used to drink coffee.',
        right: 'I didn\'t use to drink coffee.',
        why:
            'Trong câu phủ định/câu hỏi, đã có "did", nên dùng "use to" (không có -d).',
      ),
    ],
    relatedTopicIds: ['past_simple', 'past_continuous', 'adverbs_of_frequency'],
  ),
  GrammarTopic(
    id: 'prepositions_of_time',
    title: 'Prepositions of time',
    titleVi: 'Giới từ chỉ thời gian',
    level: CefrLevel.b1,
    category: GrammarCategory.other,
    formula:
        'in (year/month) · on (day/date) · at (clock time) · for / since',
    summary:
        '"In" goes with longer periods (years, months, parts of the day), "on" with specific days and dates, "at" with clock times. "For" marks duration; "since" marks a starting point.',
    summaryVi:
        '"In" đi với khoảng dài (năm, tháng, buổi trong ngày), "on" đi với ngày và ngày tháng cụ thể, "at" đi với giờ. "For" chỉ khoảng thời gian; "since" chỉ mốc bắt đầu.',
    useCases: [
      'in: years, months, seasons, parts of day ("in the morning").',
      'on: days, dates, specific mornings ("on Monday morning").',
      'at: clock times, night, weekend (BrE), festivals ("at Christmas").',
      'for + duration ("for two hours"); since + start point ("since 2020").',
    ],
    useCasesVi: [
      'in: năm, tháng, mùa, buổi trong ngày ("in the morning").',
      'on: thứ, ngày tháng, sáng/chiều cụ thể ("on Monday morning").',
      'at: giờ, "at night", cuối tuần (Anh-Anh), lễ ("at Christmas").',
      'for + khoảng thời gian ("for two hours"); since + mốc ("since 2020").',
    ],
    examples: [
      GrammarExample(
        en: 'I was born in 1998, in March.',
        vi: 'Tôi sinh năm 1998, vào tháng Ba.',
        gloss: 'in + year/month',
      ),
      GrammarExample(
        en: 'We have a meeting on Monday at 9 a.m.',
        vi: 'Chúng tôi có cuộc họp vào thứ Hai lúc 9 giờ sáng.',
        gloss: 'on + day, at + clock time',
      ),
      GrammarExample(
        en: 'She has lived here for ten years.',
        vi: 'Cô ấy đã sống ở đây được mười năm.',
        gloss: 'for + duration',
      ),
      GrammarExample(
        en: 'I haven\'t seen him since last summer.',
        vi: 'Tôi không gặp anh ấy từ mùa hè năm ngoái.',
        gloss: 'since + start point',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I\'ll see you in Monday.',
        right: 'I\'ll see you on Monday.',
        why: 'Với thứ trong tuần và ngày cụ thể, dùng "on", không dùng "in".',
      ),
      GrammarMistake(
        wrong: 'She has worked here since five years.',
        right: 'She has worked here for five years.',
        why:
            '"Since" đi với mốc thời gian; "for" đi với khoảng thời gian dài bao lâu.',
      ),
      GrammarMistake(
        wrong: 'The meeting starts in 9 a.m.',
        right: 'The meeting starts at 9 a.m.',
        why: 'Với giờ đồng hồ phải dùng "at", không dùng "in".',
      ),
    ],
    relatedTopicIds: [
      'present_perfect',
      'prepositions_of_place',
      'past_simple',
    ],
  ),
];
