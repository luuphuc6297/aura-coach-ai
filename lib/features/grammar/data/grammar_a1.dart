import '../models/grammar_topic.dart';

/// A1 — Beginner. 10 topics covering core sentence structure and the two
/// foundational tenses every learner needs first.
const List<GrammarTopic> grammarA1 = [
  GrammarTopic(
    id: 'to_be',
    title: 'Verb "to be"',
    titleVi: 'Động từ "to be"',
    level: CefrLevel.a1,
    category: GrammarCategory.tense,
    formula: 'S + am/is/are + complement',
    summary:
        'The verb "to be" links a subject to a name, job, feeling, place, or description. It changes form: I am, you/we/they are, he/she/it is.',
    summaryVi:
        'Động từ "to be" dùng để nối chủ ngữ với tên, nghề nghiệp, cảm xúc, nơi chốn hoặc mô tả. Chia ba dạng: am, is, are.',
    useCases: [
      'Introducing yourself or other people',
      'Giving age, nationality or job',
      'Describing how someone or something is',
      'Saying where someone or something is',
    ],
    useCasesVi: [
      'Giới thiệu bản thân hoặc người khác',
      'Nói tuổi, quốc tịch hoặc nghề nghiệp',
      'Miêu tả người hoặc vật như thế nào',
      'Nói ai đó hoặc vật gì đang ở đâu',
    ],
    examples: [
      GrammarExample(
        en: 'I am a student at Hanoi University.',
        vi: 'Tôi là sinh viên Đại học Hà Nội.',
        gloss: 'am',
      ),
      GrammarExample(
        en: 'She is really tired this morning.',
        vi: 'Sáng nay cô ấy mệt thật sự.',
        gloss: 'is',
      ),
      GrammarExample(
        en: 'We are at the coffee shop now.',
        vi: 'Bọn mình đang ở quán cà phê.',
        gloss: 'are',
      ),
      GrammarExample(
        en: 'They are not Vietnamese; they are Thai.',
        vi: 'Họ không phải người Việt, họ là người Thái.',
        gloss: 'are not',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'He are my brother.',
        right: 'He is my brother.',
        why: 'Chủ ngữ số ít ngôi thứ ba (he/she/it) phải dùng "is", không dùng "are".',
      ),
      GrammarMistake(
        wrong: 'I very happy today.',
        right: 'I am very happy today.',
        why: 'Câu tiếng Anh luôn cần động từ; với tính từ "happy" phải có "am/is/are".',
      ),
    ],
    relatedTopicIds: [
      'subject_pronouns_possessives',
      'present_simple',
      'there_is_are',
    ],
  ),
  GrammarTopic(
    id: 'subject_pronouns_possessives',
    title: 'Subject pronouns + possessives',
    titleVi: 'Đại từ chủ ngữ + Sở hữu',
    level: CefrLevel.a1,
    category: GrammarCategory.other,
    formula: 'I/you/he/she/it/we/they → my/your/his/her/its/our/their',
    summary:
        'Subject pronouns replace a noun as the doer of the action. Possessive adjectives (my, your, his...) come before a noun to show who owns it.',
    summaryVi:
        'Đại từ chủ ngữ thay cho danh từ làm chủ ngữ. Tính từ sở hữu (my, your, his...) đứng trước danh từ để chỉ ai sở hữu vật đó.',
    useCases: [
      'Avoiding repetition of a person\'s name',
      'Saying which person does an action',
      'Showing ownership of an object',
      'Talking about family and belongings',
    ],
    useCasesVi: [
      'Tránh nhắc lại tên người nhiều lần',
      'Nói rõ ai là người thực hiện hành động',
      'Chỉ ra ai sở hữu một vật',
      'Nói về gia đình và đồ vật của mình',
    ],
    examples: [
      GrammarExample(
        en: 'My sister loves her new phone.',
        vi: 'Chị tôi rất thích chiếc điện thoại mới của chị ấy.',
        gloss: 'my / her',
      ),
      GrammarExample(
        en: 'We bring our laptops to class.',
        vi: 'Bọn mình mang laptop đến lớp.',
        gloss: 'we / our',
      ),
      GrammarExample(
        en: 'He forgot his umbrella at the cafe.',
        vi: 'Anh ấy bỏ quên ô ở quán cà phê.',
        gloss: 'he / his',
      ),
      GrammarExample(
        en: 'They are talking about their trip.',
        vi: 'Họ đang nói về chuyến đi của họ.',
        gloss: 'they / their',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'She love she mother.',
        right: 'She loves her mother.',
        why: 'Trước danh từ phải dùng tính từ sở hữu "her", không dùng đại từ chủ ngữ "she".',
      ),
      GrammarMistake(
        wrong: 'This is me book.',
        right: 'This is my book.',
        why: '"Me" là đại từ tân ngữ; để chỉ sở hữu trước danh từ phải dùng "my".',
      ),
    ],
    relatedTopicIds: ['to_be', 'object_pronouns', 'present_simple'],
  ),
  GrammarTopic(
    id: 'articles',
    title: 'Articles a / an / the',
    titleVi: 'Mạo từ a / an / the',
    level: CefrLevel.a1,
    category: GrammarCategory.articleQuantifier,
    formula: 'a/an + singular noun · the + specific noun',
    summary:
        'Use a/an when a singular noun is mentioned for the first time or is one of many. Use the when both speaker and listener know exactly which one.',
    summaryVi:
        'Dùng a/an khi nhắc đến một danh từ số ít lần đầu hoặc bất kỳ. Dùng the khi cả người nói và người nghe đều biết rõ vật nào.',
    useCases: [
      'Mentioning a thing for the first time',
      'Talking about jobs and nationalities',
      'Pointing to one specific known item',
      'Naming unique things like the sun',
    ],
    useCasesVi: [
      'Nhắc đến vật gì đó lần đầu tiên',
      'Nói về nghề nghiệp và quốc tịch',
      'Chỉ một vật cụ thể mà cả hai đều biết',
      'Gọi tên những vật duy nhất như mặt trời',
    ],
    examples: [
      GrammarExample(
        en: 'I bought a book and an apple.',
        vi: 'Tôi mua một quyển sách và một quả táo.',
        gloss: 'a / an',
      ),
      GrammarExample(
        en: 'The book on the table is mine.',
        vi: 'Quyển sách trên bàn là của tôi.',
        gloss: 'the (specific)',
      ),
      GrammarExample(
        en: 'My dad is an engineer.',
        vi: 'Bố tôi là kỹ sư.',
        gloss: 'an + job',
      ),
      GrammarExample(
        en: 'The sun rises in the east.',
        vi: 'Mặt trời mọc ở hướng đông.',
        gloss: 'the (unique)',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'She is a engineer.',
        right: 'She is an engineer.',
        why: 'Trước danh từ bắt đầu bằng nguyên âm (a, e, i, o, u) phải dùng "an".',
      ),
      GrammarMistake(
        wrong: 'Can you close door, please?',
        right: 'Can you close the door, please?',
        why: 'Cánh cửa cụ thể mà cả hai đều biết, nên phải có mạo từ xác định "the".',
      ),
    ],
    relatedTopicIds: ['plural_nouns', 'countable_uncountable', 'there_is_are'],
  ),
  GrammarTopic(
    id: 'plural_nouns',
    title: 'Plural nouns',
    titleVi: 'Danh từ số nhiều',
    level: CefrLevel.a1,
    category: GrammarCategory.other,
    formula: 'noun + s/es (regular) | irregular forms',
    summary:
        'Most English nouns add -s for plural; nouns ending in -s, -sh, -ch, -x, -o add -es. A small group is irregular: man/men, child/children, foot/feet.',
    summaryVi:
        'Phần lớn danh từ thêm -s ở số nhiều; danh từ kết thúc bằng -s, -sh, -ch, -x, -o thêm -es. Một số dạng bất quy tắc: man/men, child/children.',
    useCases: [
      'Counting two or more of something',
      'Talking about groups of people or things',
      'Listing items you have or want',
      'Describing things in general',
    ],
    useCasesVi: [
      'Đếm hai vật trở lên',
      'Nói về một nhóm người hoặc vật',
      'Liệt kê những thứ mình có hoặc muốn',
      'Miêu tả sự vật nói chung',
    ],
    examples: [
      GrammarExample(
        en: 'I have two cats and three dogs.',
        vi: 'Tôi có hai con mèo và ba con chó.',
        gloss: '+s',
      ),
      GrammarExample(
        en: 'She washes the dishes after dinner.',
        vi: 'Cô ấy rửa bát sau bữa tối.',
        gloss: '+es',
      ),
      GrammarExample(
        en: 'The children are playing in the park.',
        vi: 'Bọn trẻ đang chơi ngoài công viên.',
        gloss: 'irregular',
      ),
      GrammarExample(
        en: 'My feet hurt after the long walk.',
        vi: 'Chân tôi đau sau khi đi bộ dài.',
        gloss: 'foot → feet',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I have three childs.',
        right: 'I have three children.',
        why: '"Child" là danh từ bất quy tắc; số nhiều là "children", không thêm -s.',
      ),
      GrammarMistake(
        wrong: 'There are many bus at the station.',
        right: 'There are many buses at the station.',
        why: 'Danh từ kết thúc bằng -s phải thêm "-es" để tạo số nhiều.',
      ),
    ],
    relatedTopicIds: ['articles', 'countable_uncountable', 'there_is_are'],
  ),
  GrammarTopic(
    id: 'present_simple',
    title: 'Present Simple',
    titleVi: 'Hiện tại đơn',
    level: CefrLevel.a1,
    category: GrammarCategory.tense,
    formula: 'S + V(s/es) + O',
    summary:
        'Present simple talks about habits, routines, facts, and things that are generally true. Add -s/-es to the verb when the subject is he, she, or it.',
    summaryVi:
        'Hiện tại đơn dùng cho thói quen, lịch sinh hoạt, sự thật và những điều luôn đúng. Với chủ ngữ he/she/it phải thêm -s/-es vào động từ.',
    useCases: [
      'Describing daily routines and habits',
      'Stating facts and general truths',
      'Talking about likes and dislikes',
      'Giving timetables and schedules',
    ],
    useCasesVi: [
      'Mô tả thói quen và lịch sinh hoạt hằng ngày',
      'Nêu sự thật và điều luôn đúng',
      'Nói về sở thích và điều không thích',
      'Trình bày lịch trình, thời gian biểu',
    ],
    examples: [
      GrammarExample(
        en: 'I drink coffee every morning.',
        vi: 'Sáng nào tôi cũng uống cà phê.',
        gloss: 'V',
      ),
      GrammarExample(
        en: 'She works at a small bookshop.',
        vi: 'Cô ấy làm việc ở một tiệm sách nhỏ.',
        gloss: 'V+s',
      ),
      GrammarExample(
        en: 'My brother does not eat meat.',
        vi: 'Anh trai tôi không ăn thịt.',
        gloss: 'does not + V',
      ),
      GrammarExample(
        en: 'The train leaves at seven sharp.',
        vi: 'Tàu khởi hành đúng bảy giờ.',
        gloss: 'schedule',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'He go to school by bus.',
        right: 'He goes to school by bus.',
        why: 'Chủ ngữ "he" cần động từ thêm -es: "goes".',
      ),
      GrammarMistake(
        wrong: 'She don\'t like coffee.',
        right: 'She doesn\'t like coffee.',
        why: 'Với he/she/it phải dùng "doesn\'t", không dùng "don\'t".',
      ),
    ],
    relatedTopicIds: [
      'present_continuous',
      'adverbs_of_frequency',
      'to_be',
    ],
  ),
  GrammarTopic(
    id: 'present_continuous',
    title: 'Present Continuous',
    titleVi: 'Hiện tại tiếp diễn',
    level: CefrLevel.a1,
    category: GrammarCategory.tense,
    formula: 'S + am/is/are + V-ing + O',
    summary:
        'Present continuous describes actions happening right now or around this period. It also covers temporary situations and fixed plans for the near future.',
    summaryVi:
        'Hiện tại tiếp diễn diễn tả hành động đang xảy ra ngay lúc này hoặc trong giai đoạn này. Cũng dùng cho việc tạm thời và kế hoạch sắp tới.',
    useCases: [
      'Describing what is happening now',
      'Talking about temporary current situations',
      'Mentioning fixed plans for tonight or tomorrow',
      'Showing changing or developing trends',
    ],
    useCasesVi: [
      'Miêu tả việc đang diễn ra ngay lúc này',
      'Nói về hoàn cảnh tạm thời hiện tại',
      'Nêu kế hoạch chắc chắn tối nay hoặc ngày mai',
      'Diễn tả xu hướng đang thay đổi',
    ],
    examples: [
      GrammarExample(
        en: 'I am studying for my English test.',
        vi: 'Tôi đang ôn cho bài kiểm tra tiếng Anh.',
        gloss: 'am + V-ing',
      ),
      GrammarExample(
        en: 'It is raining heavily outside.',
        vi: 'Bên ngoài đang mưa to.',
        gloss: 'is + V-ing',
      ),
      GrammarExample(
        en: 'We are meeting Lan at eight tonight.',
        vi: 'Tối nay tám giờ bọn mình gặp Lan.',
        gloss: 'fixed plan',
      ),
      GrammarExample(
        en: 'My English is getting better every week.',
        vi: 'Tiếng Anh của tôi tiến bộ mỗi tuần.',
        gloss: 'changing',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I am study English now.',
        right: 'I am studying English now.',
        why: 'Sau am/is/are phải là động từ thêm -ing, không phải động từ nguyên thể.',
      ),
      GrammarMistake(
        wrong: 'She is wanting a new phone.',
        right: 'She wants a new phone.',
        why: 'Động từ trạng thái như "want, like, know" thường không dùng dạng tiếp diễn.',
      ),
    ],
    relatedTopicIds: ['present_simple', 'to_be', 'past_continuous'],
  ),
  GrammarTopic(
    id: 'imperatives',
    title: 'Imperatives',
    titleVi: 'Câu mệnh lệnh',
    level: CefrLevel.a1,
    category: GrammarCategory.other,
    formula: '(Don\'t) + V + O',
    summary:
        'Imperatives give instructions, orders, advice, or invitations. Start with the base verb; use "Don\'t" before the verb for the negative form.',
    summaryVi:
        'Câu mệnh lệnh dùng để ra lệnh, hướng dẫn, khuyên hoặc mời. Bắt đầu bằng động từ nguyên thể; thêm "Don\'t" phía trước nếu phủ định.',
    useCases: [
      'Giving directions or simple instructions',
      'Telling someone to stop or start',
      'Offering polite invitations or advice',
      'Writing recipes and how-to steps',
    ],
    useCasesVi: [
      'Chỉ đường hoặc hướng dẫn đơn giản',
      'Yêu cầu ai đó dừng lại hoặc bắt đầu',
      'Mời mọc hoặc khuyên bảo lịch sự',
      'Viết công thức nấu ăn, các bước hướng dẫn',
    ],
    examples: [
      GrammarExample(
        en: 'Turn left at the next traffic light.',
        vi: 'Rẽ trái ở đèn giao thông tiếp theo.',
        gloss: 'V',
      ),
      GrammarExample(
        en: 'Please sit down and have some tea.',
        vi: 'Mời bạn ngồi xuống và dùng chút trà.',
        gloss: 'polite',
      ),
      GrammarExample(
        en: 'Don\'t touch the stove; it\'s hot.',
        vi: 'Đừng chạm vào bếp, nó đang nóng.',
        gloss: 'Don\'t + V',
      ),
      GrammarExample(
        en: 'Open the file and click "Save".',
        vi: 'Mở tệp ra và nhấn "Lưu".',
        gloss: 'instruction',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'You sit down, please.',
        right: 'Please sit down.',
        why: 'Câu mệnh lệnh không cần chủ ngữ "you"; bắt đầu thẳng bằng động từ.',
      ),
      GrammarMistake(
        wrong: 'No open the window.',
        right: 'Don\'t open the window.',
        why: 'Phủ định mệnh lệnh phải dùng "Don\'t" + động từ, không dùng "No".',
      ),
    ],
    relatedTopicIds: ['present_simple', 'modal_should', 'modal_must'],
  ),
  GrammarTopic(
    id: 'prepositions_of_place',
    title: 'Prepositions of place',
    titleVi: 'Giới từ chỉ nơi chốn',
    level: CefrLevel.a1,
    category: GrammarCategory.other,
    formula: 'in / on / at + place',
    summary:
        'In, on, and at locate things in space. Use in for enclosed areas, on for surfaces, and at for specific points or addresses.',
    summaryVi:
        'In, on, at dùng để chỉ vị trí. In cho không gian bao quanh, on cho mặt phẳng, at cho một điểm hoặc địa chỉ cụ thể.',
    useCases: [
      'Saying where someone or something is',
      'Giving an address or meeting point',
      'Describing items in a room or photo',
      'Asking and answering "Where?" questions',
    ],
    useCasesVi: [
      'Nói ai đó hoặc vật gì đang ở đâu',
      'Cho địa chỉ hoặc điểm hẹn',
      'Mô tả đồ vật trong phòng hoặc trên ảnh',
      'Hỏi và trả lời câu hỏi "Ở đâu?"',
    ],
    examples: [
      GrammarExample(
        en: 'My keys are in the top drawer.',
        vi: 'Chìa khoá của tôi ở trong ngăn kéo trên cùng.',
        gloss: 'in',
      ),
      GrammarExample(
        en: 'The cat is sleeping on the sofa.',
        vi: 'Con mèo đang ngủ trên ghế sô pha.',
        gloss: 'on',
      ),
      GrammarExample(
        en: 'I will meet you at the bus stop.',
        vi: 'Tôi sẽ gặp bạn ở trạm xe buýt.',
        gloss: 'at',
      ),
      GrammarExample(
        en: 'There is a bakery next to my house.',
        vi: 'Có một tiệm bánh ngay cạnh nhà tôi.',
        gloss: 'next to',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'She lives in 25 Hang Bai Street.',
        right: 'She lives at 25 Hang Bai Street.',
        why: 'Với địa chỉ cụ thể có số nhà phải dùng "at", không dùng "in".',
      ),
      GrammarMistake(
        wrong: 'The book is in the table.',
        right: 'The book is on the table.',
        why: 'Sách nằm trên mặt bàn (bề mặt) nên dùng "on", không dùng "in".',
      ),
    ],
    relatedTopicIds: ['there_is_are', 'prepositions_of_time', 'to_be'],
  ),
  GrammarTopic(
    id: 'there_is_are',
    title: 'There is / There are',
    titleVi: 'There is / There are',
    level: CefrLevel.a1,
    category: GrammarCategory.other,
    formula: 'There is + singular noun · There are + plural noun',
    summary:
        'There is/are introduces the existence of something in a place. Use "is" with a singular or uncountable noun and "are" with a plural noun.',
    summaryVi:
        'There is/are dùng để giới thiệu sự tồn tại của vật ở một nơi. Dùng "is" với danh từ số ít hoặc không đếm được, "are" với danh từ số nhiều.',
    useCases: [
      'Describing what is in a room or place',
      'Listing people, things, or events',
      'Talking about quantities and numbers',
      'Saying what exists nearby',
    ],
    useCasesVi: [
      'Miêu tả những gì có trong phòng hoặc một nơi',
      'Liệt kê người, vật hoặc sự kiện',
      'Nói về số lượng',
      'Nói về thứ gì đó tồn tại ở gần đây',
    ],
    examples: [
      GrammarExample(
        en: 'There is a cafe on the corner.',
        vi: 'Có một quán cà phê ở góc đường.',
        gloss: 'is + singular',
      ),
      GrammarExample(
        en: 'There are four people in my family.',
        vi: 'Gia đình tôi có bốn người.',
        gloss: 'are + plural',
      ),
      GrammarExample(
        en: 'Is there any milk in the fridge?',
        vi: 'Trong tủ lạnh còn sữa không?',
        gloss: 'question',
      ),
      GrammarExample(
        en: 'There aren\'t any tickets left for tonight.',
        vi: 'Không còn vé nào cho tối nay.',
        gloss: 'aren\'t any',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'There are a book on my desk.',
        right: 'There is a book on my desk.',
        why: '"A book" là danh từ số ít nên phải dùng "There is".',
      ),
      GrammarMistake(
        wrong: 'It has many people in the park.',
        right: 'There are many people in the park.',
        why: 'Tiếng Anh dùng "There is/are" để nói có gì đó tồn tại, không dùng "It has".',
      ),
    ],
    relatedTopicIds: ['to_be', 'prepositions_of_place', 'quantifiers'],
  ),
  GrammarTopic(
    id: 'question_words',
    title: 'Question words',
    titleVi: 'Từ để hỏi (Wh-words)',
    level: CefrLevel.a1,
    category: GrammarCategory.other,
    formula: 'Wh- + auxiliary + S + V?',
    summary:
        'Wh-words like what, where, when, who, why, and how open questions that ask for information rather than yes/no. They start the sentence before the auxiliary verb.',
    summaryVi:
        'Các từ để hỏi như what, where, when, who, why, how dùng cho câu hỏi cần thông tin chứ không phải có/không. Chúng đứng đầu câu, trước trợ động từ.',
    useCases: [
      'Asking for information about people or things',
      'Finding out a place, time, or reason',
      'Starting small talk with new people',
      'Checking details in a conversation',
    ],
    useCasesVi: [
      'Hỏi thông tin về người hoặc vật',
      'Tìm hiểu nơi chốn, thời gian hoặc lý do',
      'Bắt chuyện làm quen',
      'Kiểm tra thông tin trong khi trò chuyện',
    ],
    examples: [
      GrammarExample(
        en: 'Where do you live in Hanoi?',
        vi: 'Bạn sống ở đâu tại Hà Nội?',
        gloss: 'Where + do',
      ),
      GrammarExample(
        en: 'What is your favourite food?',
        vi: 'Món ăn yêu thích của bạn là gì?',
        gloss: 'What + is',
      ),
      GrammarExample(
        en: 'Why are you learning English?',
        vi: 'Vì sao bạn học tiếng Anh?',
        gloss: 'Why + are',
      ),
      GrammarExample(
        en: 'How does she go to work?',
        vi: 'Cô ấy đi làm bằng cách nào?',
        gloss: 'How + does',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'Where you live?',
        right: 'Where do you live?',
        why: 'Câu hỏi với động từ thường cần trợ động từ "do/does" sau từ để hỏi.',
      ),
      GrammarMistake(
        wrong: 'What you are doing?',
        right: 'What are you doing?',
        why: 'Trong câu hỏi, trợ động từ "are" phải đứng trước chủ ngữ.',
      ),
    ],
    relatedTopicIds: ['present_simple', 'to_be', 'present_continuous'],
  ),
];
