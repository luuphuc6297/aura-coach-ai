import '../models/grammar_topic.dart';

/// C1 — Advanced. 7 topics covering the structures that distinguish
/// proficient writing/speech: inversion, cleft sentences, participle
/// clauses, the introductory subjunctive, ellipsis, and the modal-perfect
/// forms used for hindsight commentary.
const List<GrammarTopic> grammarC1 = [
  GrammarTopic(
    id: 'inversion',
    title: 'Inversion',
    titleVi: 'Đảo ngữ',
    level: CefrLevel.c1,
    category: GrammarCategory.linkingInversion,
    formula: 'Negative-adv + Aux + S + V (e.g. Rarely have I…)',
    summary:
        'Inversion places the auxiliary before the subject after a fronted negative or restrictive adverbial (Rarely, Never, Hardly, Not only, Seldom). It belongs to formal, literary, or rhetorical register; outside that context everyday speech rarely uses it.',
    summaryVi:
        'Đảo ngữ đưa trợ động từ lên trước chủ ngữ sau các trạng từ phủ định hoặc hạn định ở đầu câu (Rarely, Never, Hardly, Not only, Seldom). Cấu trúc này thuộc văn phong trang trọng, học thuật hoặc tu từ; ngoài bối cảnh đó hiếm khi xuất hiện trong giao tiếp thường ngày.',
    useCases: [
      'Open formal essays or speeches with rhetorical emphasis.',
      'Foreground a negative idea ("Not only…, but also…").',
      'Mark sequence in narrative ("Hardly had I… when…").',
      'Mainly written register; spoken use sounds bookish.',
    ],
    useCasesVi: [
      'Mở đầu bài luận hoặc diễn văn trang trọng để nhấn mạnh.',
      'Làm nổi ý phủ định ("Not only…, but also…").',
      'Đánh dấu trình tự trong văn tự sự ("Hardly had I… when…").',
      'Chủ yếu dùng văn viết; nói ra nghe sách vở.',
    ],
    examples: [
      GrammarExample(
        en: 'Rarely have economists witnessed such a sharp contraction in output.',
        vi: 'Hiếm khi các nhà kinh tế chứng kiến sự suy giảm sản lượng mạnh đến vậy.',
        gloss: 'Rarely + Aux + S + V3',
      ),
      GrammarExample(
        en: 'Not only did the policy fail, but it also undermined public trust.',
        vi: 'Chính sách không chỉ thất bại mà còn làm xói mòn niềm tin của công chúng.',
        gloss: 'Not only + Aux + S, but also',
      ),
      GrammarExample(
        en: 'Hardly had the minister finished speaking when journalists raised objections.',
        vi: 'Bộ trưởng vừa dứt lời thì các nhà báo đã lên tiếng phản đối.',
        gloss: 'Hardly had + S + V3 … when',
      ),
      GrammarExample(
        en: 'Under no circumstances should personal data be shared without consent.',
        vi: 'Không vì lý do gì được chia sẻ dữ liệu cá nhân mà chưa có sự đồng ý.',
        gloss: 'Under no circumstances + Aux + S',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'Rarely I have seen such a result.',
        right: 'Rarely have I seen such a result.',
        why:
            'Sau trạng từ phủ định/hạn định ở đầu câu phải đảo trợ động từ lên trước chủ ngữ.',
      ),
      GrammarMistake(
        wrong: 'Hardly I had arrived when the meeting started.',
        right: 'Hardly had I arrived when the meeting started.',
        why:
            'Cấu trúc "Hardly … when" yêu cầu đảo "had" lên trước chủ ngữ ở mệnh đề chính.',
      ),
      GrammarMistake(
        wrong: 'Not only she sings but also dances.',
        right: 'Not only does she sing, but she also dances.',
        why:
            '"Not only" mở đầu cần trợ động từ đảo; mệnh đề sau dùng "but … also" với chủ ngữ và động từ đầy đủ.',
      ),
    ],
    relatedTopicIds: ['nuanced_inversion', 'advanced_linking', 'third_conditional'],
  ),
  GrammarTopic(
    id: 'cleft_sentences',
    title: 'Cleft Sentences',
    titleVi: 'Câu chẻ',
    level: CefrLevel.c1,
    category: GrammarCategory.linkingInversion,
    formula: 'It is X that … | What S V is/was X',
    summary:
        'Cleft sentences split one clause into two to spotlight a single element. "It-clefts" highlight a noun phrase (It was John who called); "Wh-clefts" foreground the action or content (What I need is rest). They are core devices for emphasis and contrast in formal writing.',
    summaryVi:
        'Câu chẻ tách một mệnh đề thành hai phần để làm nổi một thành phần duy nhất. "It-cleft" nhấn cụm danh từ (It was John who called); "Wh-cleft" nhấn hành động hoặc nội dung (What I need is rest). Đây là công cụ nhấn mạnh và đối lập quan trọng trong văn viết trang trọng.',
    useCases: [
      'Highlight one constituent for contrast or correction.',
      'Open a paragraph by foregrounding the key actor.',
      'Reformulate ideas in academic or journalistic prose.',
      'Add rhetorical weight without changing propositional content.',
    ],
    useCasesVi: [
      'Làm nổi một thành phần để đối lập hoặc đính chính.',
      'Mở đoạn bằng cách nhấn nhân tố chính.',
      'Diễn đạt lại ý trong văn học thuật hoặc báo chí.',
      'Tăng sức nặng tu từ mà không đổi nội dung mệnh đề.',
    ],
    examples: [
      GrammarExample(
        en: 'It was the central bank that triggered the rally, not the government.',
        vi: 'Chính ngân hàng trung ương, chứ không phải chính phủ, đã thúc đẩy đợt tăng giá.',
        gloss: 'It is X that…',
      ),
      GrammarExample(
        en: 'What surprised the panel was the candidate\'s clarity under pressure.',
        vi: 'Điều khiến hội đồng bất ngờ là sự minh bạch của ứng viên dưới áp lực.',
        gloss: 'What S V is/was X',
      ),
      GrammarExample(
        en: 'It is in coastal cities that the impact of climate change is most visible.',
        vi: 'Chính tại các thành phố ven biển, tác động của biến đổi khí hậu hiện rõ nhất.',
        gloss: 'It is + adverbial + that',
      ),
      GrammarExample(
        en: 'All she wanted was an honest apology.',
        vi: 'Tất cả những gì cô ấy muốn chỉ là một lời xin lỗi chân thành.',
        gloss: 'All S V is X (cleft variant)',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'It was John who he called me.',
        right: 'It was John who called me.',
        why:
            'Trong "It-cleft", đại từ quan hệ đã đóng vai chủ ngữ; không lặp lại chủ ngữ "he".',
      ),
      GrammarMistake(
        wrong: 'What I need it is some rest.',
        right: 'What I need is some rest.',
        why:
            '"Wh-cleft" lấy mệnh đề "What I need" làm chủ ngữ; không thêm đại từ "it" trước "is".',
      ),
      GrammarMistake(
        wrong: 'It is the report what changed his mind.',
        right: 'It is the report that changed his mind.',
        why:
            '"It-cleft" tiêu chuẩn dùng "that/who", không dùng "what" làm liên từ nối.',
      ),
    ],
    relatedTopicIds: ['inversion', 'relative_clauses_defining', 'advanced_linking'],
  ),
  GrammarTopic(
    id: 'participle_clauses',
    title: 'Participle Clauses',
    titleVi: 'Mệnh đề phân từ',
    level: CefrLevel.c1,
    category: GrammarCategory.clause,
    formula: 'V-ing/V3 + clause (replaces relative or adverbial clause)',
    summary:
        'Participle clauses condense relative or adverbial clauses using V-ing (active), V3 (passive) or "having + V3" (perfect). They are concise and largely written, common in reports, news, and academic prose. The participle subject must match the main-clause subject.',
    summaryVi:
        'Mệnh đề phân từ rút gọn mệnh đề quan hệ hoặc trạng ngữ bằng V-ing (chủ động), V3 (bị động) hoặc "having + V3" (hoàn thành). Cấu trúc này súc tích, chủ yếu trong văn viết, phổ biến trong báo cáo, báo chí và văn học thuật. Chủ ngữ ẩn của phân từ phải trùng với chủ ngữ mệnh đề chính.',
    useCases: [
      'Compress two short clauses into one fluent sentence.',
      'Replace defining relative clauses ("the man standing there").',
      'Express cause, time, or condition in formal writing.',
      'Tighten reported events in journalistic copy.',
    ],
    useCasesVi: [
      'Gộp hai mệnh đề ngắn thành một câu mạch lạc.',
      'Thay mệnh đề quan hệ xác định ("the man standing there").',
      'Diễn đạt nguyên nhân, thời gian, điều kiện trong văn trang trọng.',
      'Cô đọng tường thuật trong văn báo chí.',
    ],
    examples: [
      GrammarExample(
        en: 'Walking through the archive, the historian uncovered a forgotten manuscript.',
        vi: 'Khi đi qua kho lưu trữ, nhà sử học đã phát hiện một bản thảo bị lãng quên.',
        gloss: 'V-ing + clause (time)',
      ),
      GrammarExample(
        en: 'Damaged by years of neglect, the painting required full restoration.',
        vi: 'Bị hư hỏng do nhiều năm bỏ bê, bức tranh cần được phục chế toàn diện.',
        gloss: 'V3 (passive participle)',
      ),
      GrammarExample(
        en: 'Having reviewed the data, the committee revised its recommendation.',
        vi: 'Sau khi xem xét dữ liệu, hội đồng đã sửa lại khuyến nghị của mình.',
        gloss: 'Having + V3 (perfect)',
      ),
      GrammarExample(
        en: 'The candidates shortlisted for the role will be contacted next week.',
        vi: 'Các ứng viên được đưa vào danh sách ngắn sẽ được liên hệ vào tuần sau.',
        gloss: 'V3 reduces relative clause',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'Walking through the park, the rain started to fall.',
        right: 'Walking through the park, I felt the rain start to fall.',
        why:
            'Lỗi phân từ treo (dangling participle): chủ ngữ ẩn của "walking" phải khớp với chủ ngữ chính, không phải "the rain".',
      ),
      GrammarMistake(
        wrong: 'Having finished the report, it was sent to the client.',
        right: 'Having finished the report, she sent it to the client.',
        why:
            '"Having finished" cần một chủ ngữ con người ở mệnh đề chính; không thể đi với "it".',
      ),
      GrammarMistake(
        wrong: 'The book writing in 1920 became a classic.',
        right: 'The book written in 1920 became a classic.',
        why:
            'Hành động bị động phải dùng phân từ V3 ("written"), không dùng V-ing.',
      ),
    ],
    relatedTopicIds: [
      'relative_clauses_defining',
      'relative_clauses_non_defining',
      'advanced_linking',
    ],
  ),
  GrammarTopic(
    id: 'subjunctive_intro',
    title: 'Subjunctive (introductory)',
    titleVi: 'Thức giả định (cơ bản)',
    level: CefrLevel.c1,
    category: GrammarCategory.other,
    formula: 'S + suggest/insist/recommend + that + S + V(base)',
    summary:
        'After verbs and adjectives of demand, suggestion, or necessity (suggest, insist, recommend, demand, essential, vital), British and especially American English use a bare-infinitive verb in the that-clause. The form is invariant for person and tense — no -s, no "to".',
    summaryVi:
        'Sau các động từ và tính từ chỉ yêu cầu, đề xuất, hoặc cần thiết (suggest, insist, recommend, demand, essential, vital), tiếng Anh — đặc biệt Anh-Mỹ — dùng động từ nguyên mẫu không "to" trong mệnh đề "that". Hình thức này không đổi theo ngôi và thời — không thêm -s, không có "to".',
    useCases: [
      'Convey official recommendations in reports or minutes.',
      'Express demands or requirements in legal/academic prose.',
      'Mark formal proposals after "It is essential/vital that…".',
      'Common in American English; British also accepts "should + V".',
    ],
    useCasesVi: [
      'Đưa ra khuyến nghị chính thức trong báo cáo hoặc biên bản.',
      'Diễn đạt yêu cầu trong văn pháp lý/học thuật.',
      'Đánh dấu đề xuất trang trọng sau "It is essential/vital that…".',
      'Phổ biến ở Anh-Mỹ; Anh-Anh cũng chấp nhận "should + V".',
    ],
    examples: [
      GrammarExample(
        en: 'The board recommended that the proposal be reviewed before the next quarter.',
        vi: 'Hội đồng kiến nghị đề xuất phải được xem xét trước quý tới.',
        gloss: 'recommend + that + S + V(base)',
      ),
      GrammarExample(
        en: 'It is essential that every applicant submit two references.',
        vi: 'Mỗi ứng viên nhất thiết phải nộp hai thư giới thiệu.',
        gloss: 'It is essential that + S + V(base)',
      ),
      GrammarExample(
        en: 'The judge insisted that the witness remain in the courtroom.',
        vi: 'Thẩm phán kiên quyết yêu cầu nhân chứng phải ở lại phòng xử.',
        gloss: 'insist that + S + V(base)',
      ),
      GrammarExample(
        en: 'We propose that the deadline be extended by two weeks.',
        vi: 'Chúng tôi đề nghị gia hạn thời hạn thêm hai tuần.',
        gloss: 'propose that + S + be + V3',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'The committee recommended that he submits the report by Friday.',
        right: 'The committee recommended that he submit the report by Friday.',
        why:
            'Sau "recommend that", động từ giữ dạng nguyên mẫu không -s dù chủ ngữ ngôi ba số ít.',
      ),
      GrammarMistake(
        wrong: 'It is essential that the data is verified before publication.',
        right: 'It is essential that the data be verified before publication.',
        why:
            'Cấu trúc giả định dùng "be" nguyên mẫu, không chia "is/are" theo chủ ngữ.',
      ),
      GrammarMistake(
        wrong: 'She insisted that he to leave immediately.',
        right: 'She insisted that he leave immediately.',
        why:
            'Động từ trong mệnh đề giả định dùng nguyên mẫu trần (không "to").',
      ),
    ],
    relatedTopicIds: ['subjunctive_formal', 'wishes_regrets', 'modal_should'],
  ),
  GrammarTopic(
    id: 'ellipsis_substitution',
    title: 'Ellipsis & Substitution',
    titleVi: 'Lược bỏ & Thay thế',
    level: CefrLevel.c1,
    category: GrammarCategory.other,
    formula: 'do / so / not as substitutes for full clauses',
    summary:
        'Ellipsis omits recoverable words; substitution replaces them with pro-forms (do, so, not, one). Both keep prose concise and avoid clumsy repetition. They appear in coordinated clauses, replies, and reported answers — ubiquitous in fluent speech and edited writing.',
    summaryVi:
        'Lược bỏ là việc bỏ những từ có thể suy ra được; thay thế dùng đại từ thay (do, so, not, one). Cả hai giúp câu súc tích và tránh lặp vụng về. Chúng xuất hiện trong mệnh đề ghép, câu trả lời và lời nói gián tiếp — rất phổ biến cả trong giao tiếp lưu loát lẫn văn viết được biên tập.',
    useCases: [
      'Avoid repeating verb phrases ("She can swim and so can I").',
      'Reply concisely with "I think so / I hope not".',
      'Reduce coordinated clauses ("Tom likes coffee; Mary doesn\'t").',
      'Replace nouns with "one/ones" to dodge repetition.',
    ],
    useCasesVi: [
      'Tránh lặp cụm động từ ("She can swim and so can I").',
      'Trả lời gọn bằng "I think so / I hope not".',
      'Rút gọn mệnh đề ghép ("Tom likes coffee; Mary doesn\'t").',
      'Thay danh từ bằng "one/ones" để tránh lặp.',
    ],
    examples: [
      GrammarExample(
        en: 'She can present in three languages, and so can her colleague.',
        vi: 'Cô ấy có thể trình bày bằng ba thứ tiếng, và đồng nghiệp của cô cũng vậy.',
        gloss: 'so + Aux + S (substitution)',
      ),
      GrammarExample(
        en: 'Will the merger close on time? I hope so, but I\'m not certain.',
        vi: 'Liệu vụ sáp nhập có hoàn tất đúng hạn không? Tôi hy vọng vậy, nhưng chưa chắc.',
        gloss: '"so" replaces a clause',
      ),
      GrammarExample(
        en: 'The old printer is slow; the new one prints twice as fast.',
        vi: 'Máy in cũ chậm; cái mới in nhanh gấp đôi.',
        gloss: '"one" replaces noun',
      ),
      GrammarExample(
        en: 'Some economists predicted a recession; others did not.',
        vi: 'Một số nhà kinh tế dự báo suy thoái; số khác thì không.',
        gloss: 'ellipsis after "did"',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'I think yes the project will succeed.',
        right: 'I think so. / I think the project will succeed.',
        why:
            'Trong tiếng Anh, "so" thay cho cả mệnh đề sau động từ tư duy; không dùng "yes" để thay thế.',
      ),
      GrammarMistake(
        wrong: 'She works harder than him does.',
        right: 'She works harder than he does.',
        why:
            'Lược bỏ chỉ giữ trợ động từ; chủ ngữ phải ở dạng chủ cách "he", không dùng "him".',
      ),
      GrammarMistake(
        wrong: 'I don\'t think so it will rain.',
        right: 'I don\'t think it will rain. / I don\'t think so.',
        why:
            '"so" đã thay thế toàn bộ mệnh đề; không thể vừa dùng "so" vừa giữ mệnh đề đầy đủ.',
      ),
    ],
    relatedTopicIds: ['advanced_linking', 'reported_speech_statements', 'modal_can'],
  ),
  GrammarTopic(
    id: 'modal_perfect',
    title: 'Modal Perfect',
    titleVi: 'Modal hoàn thành (would/could/should have done)',
    level: CefrLevel.c1,
    category: GrammarCategory.modal,
    formula: 'S + would/could/should/might + have + V3',
    summary:
        'Modal perfects look back at past possibilities, regrets, deductions, or unrealised actions. "Should have done" expresses retrospective criticism, "could have done" unrealised ability, "might/may have done" past possibility, and "must have done" confident deduction.',
    summaryVi:
        'Modal hoàn thành nhìn lại khả năng, tiếc nuối, suy luận hoặc hành động không xảy ra trong quá khứ. "Should have done" phê phán hồi cố, "could have done" khả năng không thực hiện, "might/may have done" khả năng quá khứ, "must have done" suy luận chắc chắn.',
    useCases: [
      'Critique past decisions ("You should have called").',
      'Speculate about past events ("They must have left").',
      'Talk about regret or missed chances.',
      'Frame counterfactual analysis in essays.',
    ],
    useCasesVi: [
      'Phê bình quyết định trong quá khứ ("You should have called").',
      'Suy đoán về sự việc đã xảy ra ("They must have left").',
      'Nói về tiếc nuối hoặc cơ hội bỏ lỡ.',
      'Lập luận phản thực trong bài luận.',
    ],
    examples: [
      GrammarExample(
        en: 'The committee should have consulted experts before drafting the policy.',
        vi: 'Hội đồng đáng lẽ phải tham vấn chuyên gia trước khi soạn chính sách.',
        gloss: 'should + have + V3 (criticism)',
      ),
      GrammarExample(
        en: 'She must have been exhausted after a fourteen-hour shift.',
        vi: 'Hẳn cô ấy đã kiệt sức sau ca làm mười bốn tiếng.',
        gloss: 'must + have + V3 (deduction)',
      ),
      GrammarExample(
        en: 'We could have prevented the breach with stronger encryption.',
        vi: 'Chúng tôi đã có thể ngăn vụ rò rỉ nếu mã hóa mạnh hơn.',
        gloss: 'could + have + V3 (unrealised)',
      ),
      GrammarExample(
        en: 'They might have missed the announcement during the network outage.',
        vi: 'Có thể họ đã bỏ lỡ thông báo trong lúc mất mạng.',
        gloss: 'might + have + V3 (possibility)',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'You should have went to the meeting.',
        right: 'You should have gone to the meeting.',
        why:
            'Modal hoàn thành dùng phân từ ba (V3) "gone", không dùng quá khứ đơn "went".',
      ),
      GrammarMistake(
        wrong: 'He must has been tired.',
        right: 'He must have been tired.',
        why:
            'Sau modal "must" luôn dùng "have", không chia "has/had" theo chủ ngữ.',
      ),
      GrammarMistake(
        wrong: 'I would have call you, but I lost my phone.',
        right: 'I would have called you, but I lost my phone.',
        why:
            'Sau "would have" cần phân từ ba "called", không phải nguyên mẫu.',
      ),
    ],
    relatedTopicIds: ['third_conditional', 'modals_deduction', 'wishes_regrets'],
  ),
  GrammarTopic(
    id: 'advanced_linking',
    title: 'Advanced Linking',
    titleVi: 'Liên từ nâng cao',
    level: CefrLevel.c1,
    category: GrammarCategory.linkingInversion,
    formula: 'notwithstanding · albeit · given that · inasmuch as',
    summary:
        'Advanced linkers (notwithstanding, albeit, given that, inasmuch as, hence, thereby, whereby) add precision and formality. Each governs a specific structure — clause vs. noun phrase — and signals a particular logical relation: concession, cause, consequence, or qualification.',
    summaryVi:
        'Các liên từ nâng cao (notwithstanding, albeit, given that, inasmuch as, hence, thereby, whereby) tăng độ chính xác và trang trọng. Mỗi từ đi với cấu trúc riêng — mệnh đề hay cụm danh từ — và biểu thị quan hệ logic cụ thể: nhượng bộ, nguyên nhân, kết quả, hay điều kiện hạn định.',
    useCases: [
      'Signal concession concisely ("albeit briefly").',
      'Introduce a premise ("given that demand has fallen").',
      'Mark consequence in formal writing ("hence", "thereby").',
      'Reserved for academic or legal register; avoid in casual speech.',
    ],
    useCasesVi: [
      'Biểu thị nhượng bộ ngắn gọn ("albeit briefly").',
      'Đưa ra tiền đề ("given that demand has fallen").',
      'Đánh dấu kết quả trong văn trang trọng ("hence", "thereby").',
      'Dành cho văn học thuật hoặc pháp lý; tránh trong nói thường.',
    ],
    examples: [
      GrammarExample(
        en: 'Notwithstanding the delay, the project remained within budget.',
        vi: 'Bất chấp sự chậm trễ, dự án vẫn nằm trong ngân sách.',
        gloss: 'notwithstanding + NP',
      ),
      GrammarExample(
        en: 'The trial showed promise, albeit on a small sample.',
        vi: 'Thử nghiệm cho thấy triển vọng, dù chỉ trên mẫu nhỏ.',
        gloss: 'albeit + reduced clause',
      ),
      GrammarExample(
        en: 'Given that inflation persists, the bank may raise rates again.',
        vi: 'Vì lạm phát kéo dài, ngân hàng có thể tăng lãi suất một lần nữa.',
        gloss: 'given that + clause',
      ),
      GrammarExample(
        en: 'The new platform automates onboarding, thereby reducing manual workload.',
        vi: 'Nền tảng mới tự động hóa quy trình tiếp nhận, qua đó giảm khối lượng thủ công.',
        gloss: 'thereby + V-ing',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'Notwithstanding of the delay, we shipped on time.',
        right: 'Notwithstanding the delay, we shipped on time.',
        why:
            '"Notwithstanding" là giới từ; đi trực tiếp với cụm danh từ, không thêm "of".',
      ),
      GrammarMistake(
        wrong: 'The proposal was accepted, albeit it was controversial.',
        right: 'The proposal was accepted, albeit controversial.',
        why:
            '"Albeit" rút gọn mệnh đề; không dùng kèm chủ ngữ + "be" lặp lại.',
      ),
      GrammarMistake(
        wrong: 'Given inflation is persisting, rates may rise.',
        right: 'Given that inflation is persisting, rates may rise.',
        why:
            'Khi nối với mệnh đề có chủ ngữ + động từ, dùng "given that"; "given" trần chỉ đi với cụm danh từ.',
      ),
    ],
    relatedTopicIds: ['linking_concession', 'inversion', 'participle_clauses'],
  ),
];
