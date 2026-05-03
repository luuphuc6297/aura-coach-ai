import '../models/grammar_topic.dart';

/// C2 — Proficient. 3 topics for near-native register: formal/literary
/// subjunctive, restrictive/nuanced inversion, and the fixed idiomatic
/// inversions ("Had I known…", "Were it not for…") that appear in
/// polished writing and IELTS Band 8/9 essays.
const List<GrammarTopic> grammarC2 = [
  GrammarTopic(
    id: 'subjunctive_formal',
    title: 'Subjunctive (formal)',
    titleVi: 'Thức giả định (trang trọng)',
    level: CefrLevel.c2,
    category: GrammarCategory.other,
    formula: 'Were S to V… | Should S V… (formal/literary)',
    summary:
        'The formal subjunctive uses inverted "Were S to V…" or "Should S V…" to mark hypothetical or remote conditions without "if". It belongs to legal, academic, and literary register, and conveys a measured, hedged tone characteristic of polished prose.',
    summaryVi:
        'Thức giả định trang trọng dùng đảo ngữ "Were S to V…" hoặc "Should S V…" để diễn đạt điều kiện giả định hoặc xa vời mà không cần "if". Cấu trúc này thuộc văn pháp lý, học thuật và văn chương, mang giọng điệu thận trọng, dè dặt đặc trưng của văn viết được trau chuốt.',
    useCases: [
      'Replace "if" in formal hypothetical conditions.',
      'Hedge proposals in legal contracts and policy papers.',
      'Open IELTS Band 9 essays with sophisticated framing.',
      'Restricted to written register; avoid in casual speech.',
    ],
    useCasesVi: [
      'Thay "if" trong câu điều kiện giả định trang trọng.',
      'Dè dặt khi đề xuất trong hợp đồng pháp lý và văn bản chính sách.',
      'Mở bài luận IELTS band 9 với cách dẫn nhập tinh tế.',
      'Giới hạn ở văn viết; tránh dùng trong nói thường.',
    ],
    examples: [
      GrammarExample(
        en: 'Were the central bank to cut rates, equity markets would likely surge.',
        vi: 'Nếu ngân hàng trung ương cắt giảm lãi suất, thị trường cổ phiếu nhiều khả năng sẽ bứt phá.',
        gloss: 'Were + S + to V (subjunctive)',
      ),
      GrammarExample(
        en: 'Should any discrepancy arise, the auditor must be notified immediately.',
        vi: 'Nếu phát sinh bất kỳ chênh lệch nào, kiểm toán viên phải được thông báo ngay.',
        gloss: 'Should + S + V (formal)',
      ),
      GrammarExample(
        en: 'Were it not for sustained investment, the sector would have collapsed years ago.',
        vi: 'Nếu không có sự đầu tư bền bỉ, ngành này hẳn đã sụp đổ từ nhiều năm trước.',
        gloss: 'Were it not for + NP',
      ),
      GrammarExample(
        en: 'Should the claimant fail to respond within 30 days, the case will be closed.',
        vi: 'Nếu nguyên đơn không phản hồi trong vòng 30 ngày, vụ việc sẽ được khép lại.',
        gloss: 'Should + S + V (legal)',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'If were the bank to cut rates, markets would rise.',
        right: 'Were the bank to cut rates, markets would rise.',
        why:
            'Khi đã đảo "Were" lên đầu để thay "if", không dùng đồng thời "if".',
      ),
      GrammarMistake(
        wrong: 'Should you to need assistance, please contact us.',
        right: 'Should you need assistance, please contact us.',
        why:
            'Sau "Should" đảo ngữ dùng động từ nguyên mẫu trần, không có "to".',
      ),
      GrammarMistake(
        wrong: 'Was it not for the policy, the crisis would have deepened.',
        right: 'Were it not for the policy, the crisis would have deepened.',
        why:
            'Cấu trúc giả định cố định luôn dùng "Were" cho mọi ngôi, không dùng "Was".',
      ),
    ],
    relatedTopicIds: ['subjunctive_intro', 'idiomatic_structures', 'mixed_conditionals'],
  ),
  GrammarTopic(
    id: 'nuanced_inversion',
    title: 'Nuanced Inversion',
    titleVi: 'Đảo ngữ phức',
    level: CefrLevel.c2,
    category: GrammarCategory.linkingInversion,
    formula: 'Only + adv + Aux + S + V (restrictive)',
    summary:
        'Nuanced inversion extends C1 patterns with restrictive adverbials ("Only when…", "Only by…", "No sooner… than", "So + adj… that") and prepositional fronting ("In no way…", "At no point…"). The structure intensifies emphasis and is virtually confined to formal writing or rhetorical speech.',
    summaryVi:
        'Đảo ngữ phức mở rộng các cấu trúc C1 với trạng ngữ hạn định ("Only when…", "Only by…", "No sooner… than", "So + adj… that") và đảo ngữ giới từ ("In no way…", "At no point…"). Cấu trúc này tăng mức độ nhấn mạnh và gần như chỉ xuất hiện trong văn viết trang trọng hoặc diễn ngôn tu từ.',
    useCases: [
      'Convey strict conditionality ("Only when… did…").',
      'Sequence sudden events ("No sooner had… than…").',
      'Reject claims emphatically ("In no way does…").',
      'Almost exclusively written or oratorical register.',
    ],
    useCasesVi: [
      'Diễn đạt điều kiện chặt chẽ ("Only when… did…").',
      'Tường thuật sự kiện liên tiếp đột ngột ("No sooner had… than…").',
      'Bác bỏ luận điểm dứt khoát ("In no way does…").',
      'Gần như chỉ dùng trong văn viết hoặc diễn thuyết.',
    ],
    examples: [
      GrammarExample(
        en: 'Only when the data was independently audited did investors regain confidence.',
        vi: 'Chỉ khi dữ liệu được kiểm toán độc lập, nhà đầu tư mới lấy lại niềm tin.',
        gloss: 'Only when + clause + Aux + S',
      ),
      GrammarExample(
        en: 'No sooner had the report been published than rival firms responded.',
        vi: 'Báo cáo vừa được công bố thì các công ty đối thủ đã phản ứng ngay.',
        gloss: 'No sooner had + S + V3 + than',
      ),
      GrammarExample(
        en: 'In no way does this finding contradict the prevailing consensus.',
        vi: 'Phát hiện này hoàn toàn không mâu thuẫn với đồng thuận hiện hành.',
        gloss: 'In no way + Aux + S + V',
      ),
      GrammarExample(
        en: 'So compelling was the evidence that the defence withdrew its objection.',
        vi: 'Bằng chứng thuyết phục đến mức bên bào chữa đã rút lại phản đối.',
        gloss: 'So + adj + Aux + S + that',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'Only when the audit was complete, investors returned.',
        right: 'Only when the audit was complete did investors return.',
        why:
            '"Only when…" mở đầu kéo theo đảo trợ động từ ở mệnh đề chính, không giữ trật tự thường.',
      ),
      GrammarMistake(
        wrong: 'No sooner the report was released when criticism began.',
        right: 'No sooner had the report been released than criticism began.',
        why:
            '"No sooner" đi với "had + V3" đảo ngữ và liên từ "than", không dùng "when".',
      ),
      GrammarMistake(
        wrong: 'So the evidence was compelling that the case closed.',
        right: 'So compelling was the evidence that the case closed.',
        why:
            'Cấu trúc "So + adj/adv… that" yêu cầu đảo tính từ lên trước "be", không giữ thứ tự thông thường.',
      ),
    ],
    relatedTopicIds: ['inversion', 'cleft_sentences', 'idiomatic_structures'],
  ),
  GrammarTopic(
    id: 'idiomatic_structures',
    title: 'Idiomatic Structures',
    titleVi: 'Cấu trúc thành ngữ',
    level: CefrLevel.c2,
    category: GrammarCategory.other,
    formula: 'Had I known… | Were it not for… | Come what may…',
    summary:
        'Fixed idiomatic structures encode counterfactual or concessive meaning in compact, formulaic shapes ("Had I known…", "Were it not for…", "Be that as it may…", "Come what may…"). They are highly idiomatic, near-native markers and signal polished, literary register.',
    summaryVi:
        'Các cấu trúc thành ngữ cố định mã hoá ý phản thực hoặc nhượng bộ trong các khuôn ngắn gọn ("Had I known…", "Were it not for…", "Be that as it may…", "Come what may…"). Chúng mang tính thành ngữ cao, là dấu hiệu của trình độ gần bản ngữ và văn phong văn chương, được trau chuốt.',
    useCases: [
      'Open counterfactual reflections ("Had I known…").',
      'Hedge conclusions politely ("Be that as it may…").',
      'Express resolute commitment ("Come what may…").',
      'Limited to literary, journalistic, or rhetorical writing.',
    ],
    useCasesVi: [
      'Mở đầu suy ngẫm phản thực ("Had I known…").',
      'Dè dặt khi kết luận ("Be that as it may…").',
      'Thể hiện cam kết kiên định ("Come what may…").',
      'Giới hạn ở văn chương, báo chí hoặc tu từ.',
    ],
    examples: [
      GrammarExample(
        en: 'Had I known the implications, I would have raised concerns sooner.',
        vi: 'Giá tôi biết hệ quả, hẳn tôi đã nêu quan ngại sớm hơn.',
        gloss: 'Had + S + V3 (3rd cond. inverted)',
      ),
      GrammarExample(
        en: 'Were it not for the volunteers, the campaign would have stalled.',
        vi: 'Nếu không có các tình nguyện viên, chiến dịch hẳn đã đình trệ.',
        gloss: 'Were it not for + NP',
      ),
      GrammarExample(
        en: 'Be that as it may, the deadline cannot be extended further.',
        vi: 'Dù vậy đi nữa, thời hạn cũng không thể gia hạn thêm.',
        gloss: 'Be that as it may (concession)',
      ),
      GrammarExample(
        en: 'Come what may, the team is committed to delivering on schedule.',
        vi: 'Dù chuyện gì xảy ra, đội ngũ vẫn cam kết hoàn thành đúng tiến độ.',
        gloss: 'Come what may (resolve)',
      ),
    ],
    commonMistakes: [
      GrammarMistake(
        wrong: 'If I had known the implications, I would raise concerns sooner.',
        right: 'Had I known the implications, I would have raised concerns sooner.',
        why:
            'Cấu trúc đảo ngữ "Had I known" thay cho "If I had known" và phải đi với "would have + V3" để chỉ phản thực quá khứ.',
      ),
      GrammarMistake(
        wrong: 'Was it not for the volunteers, the campaign would fail.',
        right: 'Were it not for the volunteers, the campaign would fail.',
        why:
            'Cấu trúc cố định luôn dùng "Were" bất kể chủ ngữ; không dùng "Was".',
      ),
      GrammarMistake(
        wrong: 'Come what it may, we will deliver on time.',
        right: 'Come what may, we will deliver on time.',
        why:
            '"Come what may" là thành ngữ cố định; không thêm "it" giữa "what" và "may".',
      ),
    ],
    relatedTopicIds: ['subjunctive_formal', 'third_conditional', 'mixed_conditionals'],
  ),
];
