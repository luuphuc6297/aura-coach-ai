import { useState } from "react";

// ═══════════════════════════════════════════════════════════════════
// AURA COACH MOBILE — High-Fidelity Wireframes v5.3
// Clay Design System · Warm Paper Cutout Aesthetic
// Fonts: Fredoka 800 ROND 80 (logo), Nunito (headings), Inter (body)
// Icons: Clay 3D (Cloudinary) + Fluent Emojis (topics) + Lucide (UI)
// Assets: See aura-coach-mobile-asset-registry.md
// ═══════════════════════════════════════════════════════════════════

// ═══ DESIGN TOKENS — Clay Design System ═══
const C = {
  // Surface Colors
  cream: "#FFF8F0",
  clayWhite: "#FEFCF9",
  clayBeige: "#F5EDE3",
  clayBorder: "#E8DFD3",
  clayShadow: "#D4C9BB",
  // Text
  warmDark: "#2D3047",
  warmMuted: "#6B6D7B",
  warmLight: "#9B9DAB",
  white: "#FFFFFF",
  // Accent Colors
  tealClay: "#7ECEC5",
  purpleClay: "#A78BCA",
  goldClay: "#E8C77B",
  // Semantic Colors
  success: "#7BC6A0",
  warning: "#E8C77B",
  error: "#D98A8A",
  info: "#7ECEC5",
  // Shadows
  shadowClay: "3px 3px 0px #D4C9BB",
  shadowClayHover: "5px 5px 0px #D4C9BB",
  shadowClayPressed: "1px 1px 0px #D4C9BB",
  shadowSoft: "0 4px 12px rgba(45,48,71,0.06)",
  shadowCard: "0 2px 8px rgba(45,48,71,0.04)",
  // Radii
  sm: 8, md: 12, lg: 20, xl: 28, full: 9999,
  // Fonts
  fontBody: "'Inter', sans-serif",
  fontHeading: "'Nunito', sans-serif",
  fontLogo: "'Fredoka', sans-serif",
  // Tone colors (matching web app)
  formalColor: "#6366F1",
  neutralColor: "#7BC6A0",
  friendlyColor: "#E8C77B",
  casualColor: "#D98A8A",
};

// Opacity helpers
const alpha = (hex, a) => {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r},${g},${b},${a})`;
};

// ═══ CLOUDINARY Clay 3D Icons (Production) — from asset_registry.md ═══
const CLOUD = {
  base: "https://res.cloudinary.com/dgx0fr20a/image/upload",
  // Mode card icons (clay 3D, 216px @3x)
  modeScenarioCoach: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_216,h_216,c_fill,q_90/v1774765701/aura-coach-assets/mode-icons/trophy-icon_770c25.webp",
  modeStory: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_216,h_216,c_fill,q_90/v1774779261/aura-coach-assets/mode-icons/national-park-icons_628f11.webp",
  modeTranslator: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_216,h_216,c_fill,q_90/v1774766467/aura-coach-assets/mode-icons/tone-translator_327cd6.webp",
  modeVocabHub: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_216,h_216,c_fill,q_90/v1774779311/aura-coach-assets/mode-icons/ringed-planet-icons_bbcaa8.webp",
  // Logo / Mascot
  auraOrb: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_120,h_120,c_fill,q_90/v1774779556/aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp",
  auraOrbLarge: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_360,h_360,c_fill,q_90/v1774779556/aura-coach-assets/aura-orbs-icons_1ff981_b7df4e.webp",
  chatbot: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_120,h_120,c_fill,q_85/v1774765004/aura-coach-assets/avatars/chat-bot-avatar_tranformed.webp",
  // Navigation bar icons (clay 3D, 84px @3x)
  navHome: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_84,h_84,c_fill,q_85/v1774765585/aura-coach-assets/navigation-bar/home-icon_f164a9.webp",
  navSettings: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_84,h_84,c_fill,q_85/v1774780351/aura-coach-assets/navigation-bar/setting-icon_42d237_cac3a9.webp",
  // Level icons (clay 3D, 192px @3x)
  levelBeginner: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_192,h_192,c_fill,q_90/v1774765488/aura-coach-assets/level-icons/beginner-level_8b946e.webp",
  levelIntermediate: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_192,h_192,c_fill,q_90/v1774765510/aura-coach-assets/level-icons/intermediate-level_332f3d.webp",
  levelAdvanced: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_192,h_192,c_fill,q_90/v1774766290/aura-coach-assets/level-icons/advanced-level_75b99f.webp",
  // User avatars (clay 3D animals, 240px @3x)
  avatarCat: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_240,h_240,c_fill,q_90/v1774780151/aura-coach-assets/avatars/cat-avatar_83a6ce_d702ea.webp",
  avatarRabbit: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_240,h_240,c_fill,q_90/v1774766456/aura-coach-assets/avatars/rabbit-avatar_004e97.webp",
  avatarPenguin: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_240,h_240,c_fill,q_90/v1774766444/aura-coach-assets/avatars/penguin-avatar_c3d46f.webp",
  avatarFox: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_240,h_240,c_fill,q_90/v1774780247/aura-coach-assets/avatars/fox-avatar_677f5f.webp",
  avatarOwl: "https://res.cloudinary.com/dgx0fr20a/image/upload/w_240,h_240,c_fill,q_90/v1774765533/aura-coach-assets/avatars/owl-avatar_ddeb3c.webp",
};

// ═══ Fluent Emojis (topics + fallback mode icons) ═══
const E = {
  trophy: CLOUD.modeScenarioCoach,
  nationalPark: CLOUD.modeStory,
  sparkles: CLOUD.modeTranslator,
  ringedPlanet: CLOUD.modeVocabHub,
  highVoltage: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Travel%20and%20places/High%20Voltage.png",
  studioMic: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Studio%20Microphone.png",
  globe: CLOUD.auraOrb,
  airplane: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Travel%20and%20places/Airplane.png",
  briefcase: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Briefcase.png",
  clinkingGlasses: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Food/Clinking%20Glasses.png",
  house: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Travel%20and%20places/House.png",
  laptop: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Laptop.png",
  steamingBowl: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Food/Steaming%20Bowl.png",
  hospital: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Travel%20and%20places/Hospital.png",
  shoppingBags: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Shopping%20Bags.png",
  clapperBoard: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Clapper%20Board.png",
  soccerBall: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Activities/Soccer%20Ball.png",
  gradCap: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Graduation%20Cap.png",
  herb: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Animals/Herb.png",
  moneyBag: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Money%20Bag.png",
  redHeart: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Smilies/Red%20Heart.png",
  balanceScale: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Balance%20Scale.png",
  key: "https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Key.png",
};

// ═══ Clay 3D Animal Avatars (Cloudinary) — replaces DiceBear ═══
const CLAY_AVATARS = [
  { id: "cat", label: "Cat", url: CLOUD.avatarCat },
  { id: "rabbit", label: "Bunny", url: CLOUD.avatarRabbit },
  { id: "penguin", label: "Penguin", url: CLOUD.avatarPenguin },
  { id: "fox", label: "Fox", url: CLOUD.avatarFox },
  { id: "owl", label: "Owl", url: CLOUD.avatarOwl },
];
const avatarUrl = (name, i) => CLAY_AVATARS[i % CLAY_AVATARS.length].url;

// ═══════════════════════════════════════════════════════════════════
// SHARED UI COMPONENTS — Clay Design System
// ═══════════════════════════════════════════════════════════════════

const Phone = ({ children, label, tall }) => (
  <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 8 }}>
    <div style={{ width: 320, height: tall ? 780 : 640, background: C.cream, borderRadius: 32, border: `2px solid ${C.clayBorder}`, overflow: "hidden", position: "relative", boxShadow: C.shadowSoft, display: "flex", flexDirection: "column" }}>
      <div style={{ height: 36, display: "flex", alignItems: "center", justifyContent: "space-between", padding: "0 20px", fontSize: 11, color: C.warmMuted, flexShrink: 0 }}>
        <span>9:41</span>
        <div style={{ display: "flex", gap: 4, alignItems: "center" }}><span>●●●●</span><span>WiFi</span><span>100%</span></div>
      </div>
      <div style={{ flex: 1, display: "flex", flexDirection: "column", overflow: "hidden" }}>{children}</div>
      <div style={{ height: 20, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
        <div style={{ width: 120, height: 4, background: C.clayBorder, borderRadius: 2 }} />
      </div>
    </div>
    {label && <div style={{ fontSize: 12, color: C.tealClay, fontWeight: 600, letterSpacing: 0.5, textTransform: "uppercase", background: alpha(C.tealClay, 0.1), padding: "4px 12px", borderRadius: C.full, fontFamily: C.fontBody }}>{label}</div>}
  </div>
);

const AppBar = ({ title, subtitle, leading, actions, color, tabs }) => (
  <div style={{ flexShrink: 0, background: C.cream }}>
    <div style={{ height: 48, display: "flex", alignItems: "center", padding: "0 8px", gap: 8, borderBottom: tabs ? "none" : `2px solid ${C.clayBorder}` }}>
      {leading && <div style={{ width: 36, height: 36, display: "flex", alignItems: "center", justifyContent: "center", color: C.warmDark, fontSize: 16, borderRadius: C.md, cursor: "pointer" }}>{leading}</div>}
      <div style={{ flex: 1 }}><div style={{ fontSize: 16, fontWeight: 600, color: color || C.warmDark, fontFamily: C.fontHeading }}>{title}</div>{subtitle && <div style={{ fontSize: 11, color: C.warmMuted, marginTop: -2, fontFamily: C.fontBody }}>{subtitle}</div>}</div>
      {actions && <div style={{ display: "flex", gap: 4 }}>{actions}</div>}
    </div>
    {tabs && <div style={{ display: "flex", gap: 0, borderBottom: `2px solid ${C.clayBorder}`, overflowX: "auto", padding: "0 8px" }}>{tabs.map((t, i) => <div key={i} style={{ padding: "8px 10px", fontSize: 11, fontWeight: t.active ? 700 : 400, color: t.active ? C.tealClay : C.warmLight, borderBottom: t.active ? `2px solid ${C.tealClay}` : "2px solid transparent", whiteSpace: "nowrap", fontFamily: C.fontBody, textTransform: "uppercase", letterSpacing: 0.5 }}>{t.label}</div>)}</div>}
  </div>
);

const IconBtn = ({ icon, color }) => <div style={{ width: 36, height: 36, display: "flex", alignItems: "center", justifyContent: "center", color: color || C.warmMuted, fontSize: 14, borderRadius: C.md, cursor: "pointer" }}>{icon}</div>;

const ClayCard = ({ children, style, borderColor, interactive }) => <div style={{ background: C.clayWhite, border: `2px solid ${borderColor || C.clayBorder}`, borderRadius: C.lg, padding: 16, boxShadow: C.shadowCard, transition: "all 250ms cubic-bezier(0.34, 1.56, 0.64, 1)", cursor: interactive ? "pointer" : "default", ...style }}>{children}</div>;

const Badge = ({ text, color, bg, border }) => <span style={{ fontSize: 11, fontWeight: 700, color, background: bg, padding: "4px 12px", borderRadius: C.full, textTransform: "uppercase", letterSpacing: "0.05em", fontFamily: C.fontBody, border: border || "none" }}>{text}</span>;

const Btn = ({ text, bg, color, outline, full, small, icon, shadow }) => <div style={{ display: "inline-flex", alignItems: "center", justifyContent: "center", gap: 6, padding: small ? "8px 16px" : "12px 24px", borderRadius: C.lg, background: outline ? "transparent" : bg || C.tealClay, border: outline ? `2px solid ${outline}` : "none", color: color || C.white, fontSize: small ? 14 : 16, fontWeight: 700, width: full ? "100%" : "auto", textAlign: "center", boxSizing: "border-box", fontFamily: C.fontBody, boxShadow: shadow || (outline ? "none" : C.shadowClay), cursor: "pointer" }}>{icon && <span>{icon}</span>}{text}</div>;

const Chip = ({ text, active, color }) => <span style={{ fontSize: 14, fontWeight: active ? 700 : 500, padding: "8px 16px", borderRadius: C.full, background: active ? (color || C.tealClay) : C.clayBeige, color: active ? C.white : C.warmMuted, border: active ? "none" : `1.5px solid ${C.clayBorder}`, fontFamily: C.fontBody }}>{text}</span>;

const Input = ({ placeholder, icon, lines }) => <div style={{ display: "flex", alignItems: icon ? "center" : "flex-start", gap: 8, background: C.clayBeige, border: `2px solid ${C.clayBorder}`, borderRadius: lines ? C.md : C.full, padding: lines ? "14px 18px" : "14px 18px", fontFamily: C.fontBody }}>{icon && <span style={{ color: C.warmLight, fontSize: 14 }}>{icon}</span>}<span style={{ color: C.warmLight, fontSize: 16, flex: 1 }}>{placeholder}</span></div>;

const ProgressBar = ({ value, color, label, count }) => <div style={{ marginBottom: 8 }}><div style={{ display: "flex", justifyContent: "space-between", fontSize: 12, marginBottom: 4, fontFamily: C.fontBody }}><span style={{ color: C.warmMuted }}>{label}</span><span style={{ color: color || C.tealClay, fontWeight: 600 }}>{count}</span></div><div style={{ height: 6, background: C.clayBeige, borderRadius: C.full }}><div style={{ width: `${value}%`, height: "100%", background: color || C.tealClay, borderRadius: C.full }} /></div></div>;

const FlowArrow = ({ label }) => <div style={{ display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "0 4px" }}><div style={{ fontSize: 9, color: C.goldClay, fontWeight: 700, marginBottom: 2, textAlign: "center", maxWidth: 60, fontFamily: C.fontBody }}>{label}</div><div style={{ color: C.goldClay, fontSize: 20 }}>→</div></div>;

const SectionTitle = ({ title, subtitle }) => <div style={{ margin: "40px 0 20px", textAlign: "center" }}><h2 style={{ color: C.warmDark, fontSize: 22, fontWeight: 700, margin: 0, fontFamily: C.fontHeading }}>{title}</h2>{subtitle && <p style={{ color: C.warmMuted, fontSize: 13, margin: "4px 0 0", fontFamily: C.fontBody }}>{subtitle}</p>}</div>;

const Img3D = ({ src, size = 48, alt="" }) => <img src={src} alt={alt} style={{ width: size, height: size, objectFit: "contain", filter: "drop-shadow(0 2px 4px rgba(45,48,71,0.1))" }} />;

// ═══ Bottom Navigation Bar — 3 tabs with Clay 3D icons (Cloudinary) ═══
const BottomNav = ({ active = "home" }) => (
  <div style={{ flexShrink: 0, background: C.clayWhite, borderTop: `2px solid ${C.clayBorder}`, display: "flex", justifyContent: "space-around", alignItems: "center", padding: "6px 0 2px", height: 56 }}>
    {[
      { id: "home", icon: CLOUD.navHome, label: "Home", route: "/home" },
      { id: "user", icon: null, label: "User", route: "/user", emoji: "👤" },
      { id: "setting", icon: CLOUD.navSettings, label: "Setting", route: "/setting" },
    ].map((tab) => (
      <div key={tab.id} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 2, cursor: "pointer", minWidth: 64, padding: "4px 0" }}>
        {tab.icon
          ? <img src={tab.icon} alt={tab.label} style={{ width: 22, height: 22, objectFit: "contain", opacity: active === tab.id ? 1 : 0.5, transform: active === tab.id ? "scale(1.15)" : "none", transition: "all 200ms ease" }} />
          : <div style={{ fontSize: 18, opacity: active === tab.id ? 1 : 0.5, transform: active === tab.id ? "scale(1.15)" : "none", transition: "all 200ms ease" }}>{tab.emoji}</div>
        }
        <span style={{ fontSize: 10, fontWeight: active === tab.id ? 700 : 500, color: active === tab.id ? C.tealClay : C.warmLight, fontFamily: C.fontBody, letterSpacing: "0.02em" }}>{tab.label}</span>
        {active === tab.id && <div style={{ width: 20, height: 3, borderRadius: 2, background: C.tealClay, marginTop: 1 }} />}
      </div>
    ))}
  </div>
);

// Logo — Fredoka 800 + ROND 80
const AuraLogo = ({ size = 24 }) => (
  <div style={{ fontSize: size, fontWeight: 800, fontFamily: C.fontLogo, fontVariationSettings: '"ROND" 80', letterSpacing: "0.04em", display: "flex", alignItems: "center", lineHeight: 1.2 }}>
    <span style={{ color: C.tealClay }}>AURA C</span>
    <img src={E.globe} alt="O" style={{ width: size * 0.85, height: size * 0.85, margin: "0 1px" }} />
    <span style={{ color: C.tealClay }}>ACH</span>
    <span style={{ color: C.warmDark, marginLeft: 2 }}>.AI</span>
  </div>
);

// Radar Chart SVG — clay palette
const RadarChart = ({ scores = { accuracy: 7, naturalness: 8, complexity: 6 } }) => {
  const cx = 65, cy = 60, r = 45;
  const axes = [{ label: "Accuracy", angle: -90, value: scores.accuracy }, { label: "Naturalness", angle: 30, value: scores.naturalness }, { label: "Complexity", angle: 150, value: scores.complexity }];
  const toXY = (angle, dist) => ({ x: cx + dist * Math.cos((angle * Math.PI) / 180), y: cy + dist * Math.sin((angle * Math.PI) / 180) });
  const gridLevels = [0.25, 0.5, 0.75, 1];
  const polygon = axes.map((a) => { const p = toXY(a.angle, (a.value / 10) * r); return `${p.x},${p.y}`; }).join(" ");
  return (
    <svg width="130" height="130" viewBox="0 0 130 130">
      {gridLevels.map((lvl, i) => <polygon key={i} points={axes.map((a) => { const p = toXY(a.angle, r * lvl); return `${p.x},${p.y}`; }).join(" ")} fill="none" stroke={C.clayBorder} strokeWidth="0.5" />)}
      {axes.map((a, i) => { const p = toXY(a.angle, r); return <line key={i} x1={cx} y1={cy} x2={p.x} y2={p.y} stroke={C.clayBorder} strokeWidth="0.5" />; })}
      <polygon points={polygon} fill={alpha(C.tealClay, 0.3)} stroke={C.tealClay} strokeWidth="2" />
      {axes.map((a, i) => { const p = toXY(a.angle, r + 14); return <text key={i} x={p.x} y={p.y} textAnchor="middle" fill={C.warmMuted} fontSize="8" dominantBaseline="middle">{a.label}</text>; })}
    </svg>
  );
};

// ═══ Shared Assessment Card (used by BOTH Roleplay & Story) ═══
const AssessmentCard = ({ mode = "roleplay", accentColor }) => (
  <ClayCard borderColor={alpha(accentColor, 0.3)} style={{ padding: 0, overflow: "hidden" }}>
    {/* SECTION 1: HEADER */}
    <div style={{ padding: "14px 16px", borderBottom: `2px solid ${C.clayBorder}` }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 8 }}>
        <div style={{ width: 44, height: 44, borderRadius: C.md, background: alpha(C.success, 0.1), border: `2px solid ${alpha(C.success, 0.3)}`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 18, fontWeight: 800, color: C.success, fontFamily: C.fontBody }}>{mode === "story" ? "9" : "8"}</div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 14, fontWeight: 700, color: C.warmDark, fontFamily: C.fontHeading }}>Assessment</div>
          <div style={{ display: "flex", gap: 4, marginTop: 2 }}>
            <Badge text="EXCELLENT" color={C.success} bg={alpha(C.success, 0.1)} border={`1.5px solid ${alpha(C.success, 0.3)}`} />
            <Badge text={mode === "story" ? "NATURAL & POLITE" : "FRIENDLY AND APOLOGETIC"} color={C.warmMuted} bg={C.clayBeige} border={`1.5px solid ${C.clayBorder}`} />
          </div>
        </div>
      </div>
      <div style={{ fontSize: 12, color: C.warmMuted, lineHeight: 1.5, marginBottom: 10, fontFamily: C.fontBody }}>
        {mode === "story"
          ? "Your response is natural and contextually appropriate. Good vocabulary choice and correct tense usage throughout."
          : "Your translation is grammatically correct and fits the context well. It captures the essence of the Vietnamese source, though it lacks the 'offer to fix' part."}
      </div>
      <div style={{ background: alpha(C.warning, 0.1), border: `1.5px solid ${alpha(C.warning, 0.3)}`, borderRadius: C.md, padding: "10px 12px" }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 4 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 4 }}><span>⚠️</span><span style={{ fontSize: 11, fontWeight: 700, color: "#9A7B3D", textTransform: "uppercase", fontFamily: C.fontBody, letterSpacing: "0.05em" }}>Better Way to Say It</span></div>
          <span style={{ fontSize: 12, color: C.warmLight }}>🔖</span>
        </div>
        <div style={{ fontSize: 12, color: C.warmDark, lineHeight: 1.5, fontFamily: C.fontBody }}>
          {mode === "story"
            ? <>Here you go — everything's in order. <span style={{ color: C.tealClay, fontWeight: 600 }}>Is the flight running on schedule?</span></>
            : <>Oh gosh! I'm so sorry – I wasn't paying attention and I accidentally spilled some coffee on your report. <span style={{ color: C.tealClay, fontWeight: 600 }}>Let me reprint it for you right away.</span></>}
        </div>
      </div>
    </div>

    {/* SECTION 2: DETAILED METRICS */}
    <div style={{ padding: "12px 16px", borderBottom: `2px solid ${C.clayBorder}` }}>
      <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 8 }}><span>📊</span><span style={{ fontSize: 11, fontWeight: 700, color: C.warmDark, textTransform: "uppercase", letterSpacing: "0.08em", fontFamily: C.fontBody }}>Detailed Metrics</span></div>
      <div style={{ display: "flex", gap: 8 }}>
        <div style={{ background: C.clayBeige, border: `1.5px solid ${C.clayBorder}`, borderRadius: C.md, padding: 4, flex: "0 0 auto" }}><RadarChart /></div>
        <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: 6 }}>
          <div style={{ background: alpha(C.formalColor, 0.1), border: `1.5px solid ${alpha(C.formalColor, 0.3)}`, borderRadius: C.md, padding: 8 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 4, marginBottom: 4 }}><span style={{ fontSize: 10 }}>✏️</span><span style={{ fontSize: 10, fontWeight: 700, color: C.formalColor, textTransform: "uppercase", fontFamily: C.fontBody }}>Grammar</span></div>
            <div style={{ fontSize: 10, color: C.warmMuted, lineHeight: 1.4, fontFamily: C.fontBody }}>
              {mode === "story" ? "Good use of present tense. Direct question form is appropriate." : "Solid structure. Good use of past continuous 'wasn't paying attention'. Dash needs space."}
            </div>
          </div>
          <div style={{ background: alpha(C.purpleClay, 0.1), border: `1.5px solid ${alpha(C.purpleClay, 0.3)}`, borderRadius: C.md, padding: 8 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 4, marginBottom: 4 }}><span style={{ fontSize: 10 }}>📖</span><span style={{ fontSize: 10, fontWeight: 700, color: C.purpleClay, textTransform: "uppercase", fontFamily: C.fontBody }}>Vocabulary</span></div>
            <div style={{ fontSize: 10, color: C.warmMuted, lineHeight: 1.4, fontFamily: C.fontBody }}>
              {mode === "story" ? "'Here you go' is natural. 'On time' is clear and appropriate." : "'Spilled' is precise. 'Oh gosh' is natural. 'some coffee' sounds more native."}
            </div>
          </div>
        </div>
      </div>
    </div>

    {/* SECTION 3: TONE VARIATIONS */}
    <div style={{ padding: "12px 16px", borderBottom: `2px solid ${C.clayBorder}` }}>
      <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 8 }}><span>🎭</span><span style={{ fontSize: 11, fontWeight: 700, color: C.warmDark, textTransform: "uppercase", letterSpacing: "0.08em", fontFamily: C.fontBody }}>Tone Variations</span></div>
      <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
        {[
          { tone: "FORMAL", icon: "🏛️", color: C.formalColor, text: mode === "story" ? '"Here is my boarding pass and passport. Could you kindly confirm whether the flight is departing on schedule?"' : '"I sincerely apologize for my carelessness; I have inadvertently spilled coffee on your report."' },
          { tone: "NEUTRAL", icon: "💬", color: C.neutralColor, text: mode === "story" ? '"Here you go. Is the flight on time?"' : '"Oh gosh, I\'m so sorry! I wasn\'t looking where I was going and spilled coffee on your report."', active: true },
          { tone: "FRIENDLY", icon: "😊", color: C.friendlyColor, text: mode === "story" ? '"Sure thing, here you go! By the way, are we all good on timing?"' : '"Oh no! I\'m so sorry—I was being so clumsy and got coffee all over your report!"' },
          { tone: "CASUAL", icon: "☕", color: C.casualColor, text: mode === "story" ? '"Yeah, here. Are we still leaving on time or what?"' : '"Oops, my bad! I totally spaced out and spilled my drink on your papers."' },
        ].map((t, i) => (
          <div key={i} style={{ background: alpha(t.color, 0.1), border: `1.5px solid ${alpha(t.color, 0.3)}`, borderRadius: C.md, padding: "10px 12px", outline: t.active ? `2px solid ${alpha(t.color, 0.5)}` : "none", outlineOffset: -1 }}>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 4 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 4 }}><span style={{ fontSize: 11 }}>{t.icon}</span><span style={{ fontSize: 11, fontWeight: 700, color: t.color, textTransform: "uppercase", fontFamily: C.fontBody, letterSpacing: "0.05em" }}>{t.tone}</span></div>
              <div style={{ display: "flex", gap: 6 }}><span style={{ fontSize: 11, color: C.warmLight }}>🔖</span><span style={{ fontSize: 11, color: C.warmLight }}>🔊</span></div>
            </div>
            <div style={{ fontSize: 11, color: C.warmDark, lineHeight: 1.5, fontFamily: C.fontBody }}>{t.text}</div>
          </div>
        ))}
      </div>
    </div>

    {/* SECTION 4: FOOTER — mode-specific buttons */}
    <div style={{ padding: "12px 16px" }}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 6, padding: "8px 0", borderBottom: `2px solid ${C.clayBorder}`, marginBottom: 10 }}><span>🎬</span><span style={{ fontSize: 12, color: C.warmMuted, fontWeight: 500, fontFamily: C.fontBody }}>Visualize Native Context</span></div>
      {mode === "story" ? (
        <div style={{ display: "flex", gap: 8 }}>
          <div style={{ flex: 1 }}><Btn text="▶ Continue Story" bg={C.purpleClay} color={C.white} full small shadow={`3px 3px 0px ${alpha(C.purpleClay, 0.4)}`} /></div>
          <div style={{ flex: 1 }}><Btn text="End & New Story" outline={C.clayBorder} color={C.warmMuted} full small /></div>
        </div>
      ) : (
        <div style={{ display: "flex", gap: 6 }}>
          {[{ label: "📉 Easier", color: C.success }, { label: "🔄 New One", color: C.tealClay }, { label: "📈 Harder", color: C.error }].map((b, i) => (
            <div key={i} style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", gap: 4, padding: "10px 0", background: alpha(b.color, 0.1), border: `1.5px solid ${alpha(b.color, 0.3)}`, borderRadius: C.md, fontSize: 11, color: b.color, fontWeight: 700, fontFamily: C.fontBody }}>{b.label}</div>
          ))}
        </div>
      )}
    </div>
  </ClayCard>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 1: SPLASH
// ═══════════════════════════════════════════════════════════════════
const SplashScreen = () => (
  <Phone label="/ (splash)">
    <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", background: C.cream }}>
      <img src={CLOUD.auraOrbLarge} alt="Aura Coach" style={{ width: 96, height: 96, marginBottom: 16 }} />
      <AuraLogo size={28} />
      <div style={{ marginTop: 24, width: 28, height: 28, border: `3px solid ${C.tealClay}`, borderTop: "3px solid transparent", borderRadius: "50%" }} />
      <style>{`@import url('https://fonts.googleapis.com/css2?family=Fredoka:wght@600;700;800&family=Nunito:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap');`}</style>
    </div>
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 2: AUTH
// ═══════════════════════════════════════════════════════════════════
const AuthScreen = () => (
  <Phone label="/auth">
    <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: 32, gap: 16, background: C.cream }}>
      <AuraLogo size={26} />
      <div style={{ fontSize: 14, color: C.warmMuted, marginBottom: 24, fontFamily: C.fontBody }}>Your AI English Coach</div>
      <Btn text="Continue with Google" bg={C.tealClay} color={C.white} full icon="G" />
      <div style={{ height: 4 }} />
      <Btn text="Continue with Apple" bg={C.warmDark} color={C.white} full icon="" />
      <div style={{ height: 4 }} />
      <Btn text="Try as Guest" outline={C.tealClay} color={C.tealClay} full icon="👤" />
    </div>
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 3: ONBOARDING — Step 1: Name + Level + Avatar
// ═══════════════════════════════════════════════════════════════════
const OnboardingStep1 = () => (
  <Phone label="/onboarding (step 1)" tall>
    <div style={{ flex: 1, padding: 20, display: "flex", flexDirection: "column", gap: 16, overflow: "auto", background: C.cream }}>
      <div style={{ fontSize: 28, fontWeight: 700, color: C.warmDark, fontFamily: C.fontHeading }}>Welcome! 👋</div>
      <div style={{ fontSize: 14, color: C.warmMuted, fontFamily: C.fontBody }}>Let's set up your profile</div>

      {/* Name */}
      <div>
        <div style={{ fontSize: 11, fontWeight: 700, color: C.warmLight, marginBottom: 6, textTransform: "uppercase", letterSpacing: "0.08em", fontFamily: C.fontBody }}>YOUR NAME</div>
        <Input placeholder="Enter your name" />
      </div>

      {/* Avatar Picker — 5 Clay 3D Animal Avatars (Cloudinary) */}
      <div>
        <div style={{ fontSize: 11, fontWeight: 700, color: C.warmLight, marginBottom: 6, textTransform: "uppercase", letterSpacing: "0.08em", fontFamily: C.fontBody }}>CHOOSE YOUR AVATAR</div>
        <div style={{ display: "flex", flexWrap: "wrap", gap: 8, justifyContent: "center" }}>
          {CLAY_AVATARS.map((avatar, i) => (
            <div key={avatar.id} style={{ width: 52, height: 52, borderRadius: C.full, border: i === 0 ? `2.5px solid ${C.tealClay}` : `1.5px solid ${C.clayBorder}`, overflow: "hidden", transform: i === 0 ? "scale(1.1)" : "none", boxShadow: i === 0 ? C.shadowClay : "none" }}>
              <img src={avatar.url} alt={avatar.label} style={{ width: "100%", height: "100%", borderRadius: C.full, objectFit: "cover" }} />
            </div>
          ))}
        </div>
      </div>

      {/* English Level — FULL WIDTH, 3 rows */}
      <div>
        <div style={{ fontSize: 11, fontWeight: 700, color: C.warmLight, marginBottom: 6, textTransform: "uppercase", letterSpacing: "0.08em", fontFamily: C.fontBody }}>YOUR ENGLISH LEVEL</div>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {[
            { id: "A1/A2", label: "Beginner", desc: "Basic phrases & simple sentences", sel: false, color: C.success, icon: CLOUD.levelBeginner },
            { id: "B1/B2", label: "Intermediate", desc: "Everyday conversations & complex topics", sel: true, color: C.warning, icon: CLOUD.levelIntermediate },
            { id: "C1/C2", label: "Advanced", desc: "Complex discussions & near-native fluency", sel: false, color: C.error, icon: CLOUD.levelAdvanced },
          ].map((lv, i) => (
            <ClayCard key={i} borderColor={lv.sel ? C.tealClay : C.clayBorder} style={{ padding: 12, background: lv.sel ? alpha(C.tealClay, 0.1) : C.clayWhite, display: "flex", alignItems: "center", gap: 12, boxShadow: lv.sel ? C.shadowClay : C.shadowCard }}>
              <img src={lv.icon} alt={lv.label} style={{ width: 40, height: 40, borderRadius: C.md, objectFit: "cover" }} />
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 600, color: lv.sel ? C.tealClay : C.warmDark, fontFamily: C.fontBody }}>{lv.label} <span style={{ fontSize: 11, fontWeight: 800, color: lv.sel ? C.tealClay : C.warmLight }}>{lv.id}</span></div>
                <div style={{ fontSize: 11, color: C.warmMuted, fontFamily: C.fontBody }}>{lv.desc}</div>
              </div>
              {lv.sel && <div style={{ color: C.tealClay, fontSize: 14, fontWeight: 700 }}>✓</div>}
            </ClayCard>
          ))}
        </div>
      </div>

      {/* Buttons — same size */}
      <div style={{ marginTop: "auto", display: "flex", gap: 12 }}>
        <div style={{ flex: 1 }}><Btn text="← Back" outline={C.clayBorder} color={C.warmMuted} full /></div>
        <div style={{ flex: 1 }}><Btn text="Next →" bg={C.tealClay} color={C.white} full /></div>
      </div>
    </div>
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 4: ONBOARDING — Step 2: Choose Topics + Custom Topic
// ═══════════════════════════════════════════════════════════════════
const OnboardingStep2 = () => (
  <Phone label="/onboarding (step 2)" tall>
    <div style={{ flex: 1, padding: 20, display: "flex", flexDirection: "column", gap: 14, overflow: "auto", background: C.cream }}>
      <div style={{ fontSize: 28, fontWeight: 700, color: C.warmDark, fontFamily: C.fontHeading }}>Choose your topics</div>
      <div style={{ fontSize: 14, color: C.warmMuted, fontFamily: C.fontBody }}>Select topics you'd like to practice</div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8, flex: 1 }}>
        {[
          { emoji: E.airplane, name: "Travel", sel: true },
          { emoji: E.briefcase, name: "Business", sel: true },
          { emoji: E.steamingBowl, name: "Food", sel: false },
          { emoji: E.hospital, name: "Healthcare", sel: false },
          { emoji: E.gradCap, name: "Education", sel: true },
          { emoji: E.laptop, name: "Technology", sel: false },
          { emoji: E.house, name: "Daily Life", sel: false },
          { emoji: E.clapperBoard, name: "Entertainment", sel: false },
        ].map((t, i) => (
          <ClayCard key={i} borderColor={t.sel ? C.tealClay : C.clayBorder} style={{ padding: 10, display: "flex", flexDirection: "column", alignItems: "center", gap: 4, background: t.sel ? alpha(C.tealClay, 0.1) : C.clayWhite, boxShadow: t.sel ? C.shadowClay : C.shadowCard }} interactive>
            <div style={{ width: 48, height: 48, borderRadius: C.md, background: alpha(C.tealClay, 0.15), display: "flex", alignItems: "center", justifyContent: "center" }}><Img3D src={t.emoji} size={32} /></div>
            <span style={{ fontSize: 12, fontWeight: 600, color: t.sel ? C.tealClay : C.warmDark, fontFamily: C.fontBody }}>{t.name}</span>
          </ClayCard>
        ))}
      </div>

      {/* Custom Topic Input */}
      <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
        <div style={{ flex: 1, display: "flex", alignItems: "center", gap: 8, background: C.clayBeige, border: `2px solid ${C.clayBorder}`, borderRadius: C.full, padding: "10px 18px" }}>
          <span style={{ color: C.warmLight, fontSize: 12 }}>✨</span>
          <span style={{ color: C.warmLight, fontSize: 14, flex: 1, fontFamily: C.fontBody }}>Add your own topic (e.g. Pets, Family)...</span>
        </div>
        <div style={{ width: 40, height: 40, borderRadius: C.md, background: alpha(C.tealClay, 0.15), border: `2px solid ${alpha(C.tealClay, 0.3)}`, display: "flex", alignItems: "center", justifyContent: "center", color: C.tealClay, fontSize: 18, fontWeight: 700, cursor: "pointer" }}>+</div>
      </div>

      {/* Buttons — same size */}
      <div style={{ display: "flex", gap: 12 }}>
        <div style={{ flex: 1 }}><Btn text="← Back" outline={C.clayBorder} color={C.warmMuted} full /></div>
        <div style={{ flex: 1 }}><Btn text="Let's go! 🚀" bg={C.tealClay} color={C.white} full /></div>
      </div>
    </div>
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 5: HOME (Mode Selection)
// ═══════════════════════════════════════════════════════════════════
const HomeScreen = () => (
  <Phone label="/home">
    <div style={{ flex: 1, padding: 16, display: "flex", flexDirection: "column", gap: 14, background: C.cream, overflow: "auto" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <AuraLogo size={18} />
        <div style={{ width: 40, height: 40, borderRadius: C.full, overflow: "hidden", border: `2px solid ${C.tealClay}`, boxShadow: C.shadowClay }}>
          <img src={avatarUrl("Molly", 3)} alt="" style={{ width: "100%", height: "100%" }} />
        </div>
      </div>
      <div style={{ fontSize: 22, fontWeight: 700, color: C.warmDark, fontFamily: C.fontHeading }}>Welcome back, Luu</div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, flex: 1 }}>
        {[
          { emoji: E.trophy, title: "Scenario Coach", sub: "Practice real-life situations", color: C.tealClay, route: "/chat/roleplay" },
          { emoji: E.nationalPark, title: "Story Mode", sub: "Learn through stories", color: C.purpleClay, route: "/chat/story/select" },
          { emoji: E.sparkles, title: "Tone Translator", sub: "Master tone & register", color: C.goldClay, route: "/chat/translator" },
          { emoji: E.ringedPlanet, title: "Vocab Hub", sub: "Build your word power", color: C.purpleClay, route: "/vocab-hub" },
        ].map((m, i) => (
          <ClayCard key={i} style={{ display: "flex", flexDirection: "column", gap: 8, padding: 14 }} interactive>
            <div style={{ width: 56, height: 56, borderRadius: C.md, background: alpha(m.color, 0.15), display: "flex", alignItems: "center", justifyContent: "center" }}>
              <Img3D src={m.emoji} size={40} />
            </div>
            <div style={{ fontSize: 14, fontWeight: 700, color: C.warmDark, fontFamily: C.fontBody }}>{m.title}</div>
            <div style={{ fontSize: 12, color: C.warmMuted, lineHeight: 1.3, fontFamily: C.fontBody }}>{m.sub}</div>
            <div style={{ fontSize: 9, color: m.color, marginTop: "auto", fontFamily: C.fontBody }}>→ {m.route}</div>
          </ClayCard>
        ))}
      </div>
    </div>
    <BottomNav active="home" />
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 6: CHAT ROLEPLAY — Sticky Context + Full Assessment
// ═══════════════════════════════════════════════════════════════════
const ChatRoleplay = () => (
  <Phone label="/chat/roleplay" tall>
    <AppBar title="Scenario Coach" color={C.tealClay} leading="←" actions={<><IconBtn icon="🔊" /><IconBtn icon="📚" /></>} />

    {/* STICKY CONTEXT HEADER */}
    <div style={{ flexShrink: 0, background: C.clayWhite, borderBottom: `2px solid ${C.clayBorder}`, padding: "12px 14px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 6 }}>
        <Badge text="Translate to English" color={C.tealClay} bg={alpha(C.tealClay, 0.1)} border={`1.5px solid ${alpha(C.tealClay, 0.3)}`} />
        <div style={{ display: "flex", gap: 6 }}>
          <div style={{ fontSize: 10, color: C.warmMuted, background: C.clayBeige, padding: "3px 8px", borderRadius: C.full, border: `1.5px solid ${C.clayBorder}`, fontFamily: C.fontBody }}>🔄 EN↔VN</div>
          <div style={{ fontSize: 10, color: C.goldClay, background: alpha(C.goldClay, 0.1), padding: "3px 8px", borderRadius: C.full, border: `1.5px solid ${alpha(C.goldClay, 0.3)}`, fontFamily: C.fontBody, fontWeight: 600 }}>💡 Hints</div>
        </div>
      </div>
      <div style={{ fontSize: 15, fontWeight: 700, color: C.warmDark, lineHeight: 1.4, fontFamily: C.fontBody }}>"Xin lỗi, tôi không để ý và vô tình làm đổ cà phê lên báo cáo của bạn."</div>
      <div style={{ fontSize: 11, color: C.warmMuted, marginTop: 4, display: "flex", alignItems: "center", gap: 4, fontFamily: C.fontBody }}>
        <span style={{ color: C.goldClay }}>📍</span> Situation: Office, apologizing to a colleague
      </div>
    </div>

    {/* CHAT MESSAGES */}
    <div style={{ flex: 1, padding: "10px 12px", overflow: "auto", display: "flex", flexDirection: "column", gap: 8, background: C.cream }}>
      {/* User Message */}
      <div style={{ display: "flex", justifyContent: "flex-end" }}>
        <div style={{ maxWidth: "80%" }}>
          <div style={{ background: C.tealClay, borderRadius: `${C.xl}px ${C.xl}px 4px ${C.xl}px`, padding: "16px 18px", fontSize: 13, color: C.white, lineHeight: 1.5, fontFamily: C.fontBody, boxShadow: `3px 3px 0px ${alpha(C.tealClay, 0.3)}` }}>
            Oh gosh! I'm so sorry - I <span style={{ borderBottom: `2px solid ${C.goldClay}`, paddingBottom: 1 }}>wasn't paying attention</span> and I accidentally spilled some coffee on your report.
          </div>
          <div style={{ display: "flex", justifyContent: "flex-end", marginTop: 4 }}><span style={{ fontSize: 10, color: C.warmMuted, background: C.clayBeige, padding: "3px 8px", borderRadius: C.full, fontFamily: C.fontBody }}>🔊 Listen</span></div>
        </div>
      </div>

      {/* Save to Dictionary tooltip */}
      <div style={{ display: "flex", justifyContent: "flex-end", marginTop: -4 }}>
        <div style={{ background: C.clayWhite, border: `2px solid ${alpha(C.tealClay, 0.3)}`, borderRadius: C.md, padding: "6px 10px", display: "flex", alignItems: "center", gap: 6, maxWidth: 220, boxShadow: C.shadowClay }}>
          <span style={{ fontSize: 10 }}>📖</span>
          <span style={{ fontSize: 10, color: C.warmDark, fontWeight: 500, fontFamily: C.fontBody }}>"wasn't paying attention"</span>
          <span style={{ fontSize: 10, color: C.tealClay, fontWeight: 700, fontFamily: C.fontBody }}>Save</span>
        </div>
      </div>
      <div style={{ fontSize: 9, color: C.warmLight, textAlign: "right", fontStyle: "italic", fontFamily: C.fontBody }}>↑ Long-press text → Save to Dictionary</div>

      {/* ══ FULL ASSESSMENT CARD — 4 SECTIONS ══ */}
      <AssessmentCard mode="roleplay" accentColor={C.tealClay} />
    </div>

    {/* BOTTOM: New Conversation + Next Scenario + Input */}
    <div style={{ flexShrink: 0, borderTop: `2px solid ${C.clayBorder}`, background: C.clayWhite }}>
      <div style={{ display: "flex", gap: 8, padding: "8px 12px" }}>
        <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", gap: 4, padding: "8px 0", background: C.clayBeige, border: `1.5px solid ${C.clayBorder}`, borderRadius: C.md, fontSize: 11, color: C.warmMuted, fontFamily: C.fontBody, fontWeight: 600 }}>💬 New Conversation</div>
        <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", gap: 4, padding: "8px 0", background: alpha(C.tealClay, 0.1), border: `1.5px solid ${alpha(C.tealClay, 0.3)}`, borderRadius: C.md, fontSize: 11, color: C.tealClay, fontWeight: 700, fontFamily: C.fontBody }}>⏭️ Next Scenario</div>
      </div>
      <div style={{ padding: "0 12px 8px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, background: C.clayWhite, border: `2px solid ${C.clayBorder}`, borderRadius: C.full, padding: "6px 6px 6px 18px" }}>
          <span style={{ flex: 1, fontSize: 14, color: C.warmLight, fontFamily: C.fontBody }}>Type your translation...</span>
          <div style={{ width: 32, height: 32, borderRadius: C.full, background: alpha(C.error, 0.1), display: "flex", alignItems: "center", justifyContent: "center", fontSize: 12 }}>🎤</div>
          <div style={{ width: 40, height: 40, borderRadius: C.full, background: C.tealClay, display: "flex", alignItems: "center", justifyContent: "center", color: C.white, fontSize: 14 }}>➤</div>
        </div>
      </div>
    </div>
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 7: CHAT (Story Mode) — FULL Assessment (same as Roleplay)
// ═══════════════════════════════════════════════════════════════════
const ChatStory = () => (
  <Phone label="/chat/story" tall>
    <AppBar title="Story Mode" subtitle="At the Airport" color={C.purpleClay} leading="←" actions={<><IconBtn icon="ℹ️" /><IconBtn icon="🔊" /></>} />
    <div style={{ flex: 1, padding: "10px 12px", overflow: "auto", display: "flex", flexDirection: "column", gap: 8, background: C.cream }}>
      {/* AI message — Narrator */}
      <div style={{ maxWidth: "85%" }}>
        <div style={{ background: C.clayWhite, border: `1.5px solid ${C.clayBorder}`, borderLeft: `4px solid ${C.purpleClay}`, borderRadius: `4px ${C.xl}px ${C.xl}px ${C.xl}px`, padding: "16px 18px", fontSize: 13, color: C.warmDark, lineHeight: 1.5, fontFamily: C.fontBody, boxShadow: C.shadowCard }}>
          <div style={{ fontSize: 11, color: C.purpleClay, fontWeight: 700, marginBottom: 4, fontFamily: C.fontBody, textTransform: "uppercase", letterSpacing: "0.05em" }}>🎭 Narrator</div>
          You arrive at the international terminal. A friendly gate agent waves you over...
        </div>
      </div>
      {/* AI message — Character */}
      <div style={{ maxWidth: "85%" }}>
        <div style={{ background: C.clayWhite, border: `1.5px solid ${C.clayBorder}`, borderLeft: `4px solid ${C.tealClay}`, borderRadius: `4px ${C.xl}px ${C.xl}px ${C.xl}px`, padding: "16px 18px", fontSize: 13, color: C.warmDark, lineHeight: 1.5, fontFamily: C.fontBody, boxShadow: C.shadowCard }}>
          <div style={{ fontSize: 11, color: C.tealClay, fontWeight: 700, marginBottom: 4, fontFamily: C.fontBody, textTransform: "uppercase", letterSpacing: "0.05em" }}>👤 Gate Agent</div>
          "Good morning! May I see your boarding pass and passport, please?"
          <div style={{ marginTop: 6 }}><span style={{ fontSize: 10, color: C.warmMuted, background: C.clayBeige, padding: "3px 8px", borderRadius: C.full, fontFamily: C.fontBody }}>🔊 Listen</span></div>
        </div>
      </div>
      {/* User message */}
      <div style={{ display: "flex", justifyContent: "flex-end" }}>
        <div style={{ maxWidth: "80%" }}>
          <div style={{ background: C.tealClay, borderRadius: `${C.xl}px ${C.xl}px 4px ${C.xl}px`, padding: "16px 18px", fontSize: 13, color: C.white, fontFamily: C.fontBody, boxShadow: `3px 3px 0px ${alpha(C.tealClay, 0.3)}` }}>Here you go. Is the flight on time?</div>
          <div style={{ display: "flex", justifyContent: "flex-end", marginTop: 4 }}><span style={{ fontSize: 10, color: C.warmMuted, background: C.clayBeige, padding: "3px 8px", borderRadius: C.full, fontFamily: C.fontBody }}>🔊 Listen</span></div>
        </div>
      </div>

      {/* ══ FULL ASSESSMENT CARD — 4 SECTIONS (same structure as Roleplay) ══ */}
      <AssessmentCard mode="story" accentColor={C.purpleClay} />
    </div>

    {/* BOTTOM: Input */}
    <div style={{ padding: "8px 12px", borderTop: `2px solid ${C.clayBorder}`, flexShrink: 0, background: C.clayWhite }}>
      <div style={{ display: "flex", alignItems: "center", gap: 8, background: C.clayWhite, border: `2px solid ${C.clayBorder}`, borderRadius: C.full, padding: "6px 6px 6px 18px" }}>
        <span style={{ flex: 1, fontSize: 14, color: C.warmLight, fontFamily: C.fontBody }}>What do you say?</span>
        <div style={{ width: 32, height: 32, borderRadius: C.full, background: alpha(C.error, 0.1), display: "flex", alignItems: "center", justifyContent: "center", fontSize: 12 }}>🎤</div>
        <div style={{ width: 40, height: 40, borderRadius: C.full, background: C.purpleClay, display: "flex", alignItems: "center", justifyContent: "center", color: C.white, fontSize: 14 }}>➤</div>
      </div>
    </div>
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 8: CHAT (Tone Translator) with Listen + Save on each tone
// ═══════════════════════════════════════════════════════════════════
const ChatTranslator = () => (
  <Phone label="/chat/translator">
    <AppBar title="Tone Translator" color={C.goldClay} leading="←" actions={<IconBtn icon="🔊" />} />
    <div style={{ flex: 1, padding: "10px 12px", overflow: "auto", display: "flex", flexDirection: "column", gap: 8, background: C.cream }}>
      <div style={{ display: "flex", justifyContent: "flex-end" }}>
        <div style={{ background: C.tealClay, borderRadius: `${C.xl}px ${C.xl}px 4px ${C.xl}px`, padding: "16px 18px", fontSize: 13, color: C.white, maxWidth: "80%", fontFamily: C.fontBody, boxShadow: `3px 3px 0px ${alpha(C.tealClay, 0.3)}` }}>I need to tell my boss I can't come to work tomorrow</div>
      </div>
      <ClayCard style={{ padding: 14 }}>
        <div style={{ fontSize: 12, color: C.warmLight, fontStyle: "italic", marginBottom: 10, fontFamily: C.fontBody }}>Original: "I need to tell my boss I can't come to work tomorrow"</div>
        {[
          { tone: "FORMAL", icon: "🏛️", color: C.formalColor, text: '"I would like to inform you that I will be unable to attend work tomorrow."' },
          { tone: "FRIENDLY", icon: "😊", color: C.neutralColor, text: '"Hey! Just wanted to let you know I won\'t be able to make it tomorrow."' },
          { tone: "INFORMAL", icon: "☕", color: C.friendlyColor, text: '"Can\'t come in tomorrow — something came up. Hope that\'s okay!"' },
          { tone: "CASUAL", icon: "💬", color: C.casualColor, text: '"Yo, heads up — not gonna be in tomorrow."' },
        ].map((t, i) => (
          <div key={i} style={{ background: alpha(t.color, 0.1), border: `1.5px solid ${alpha(t.color, 0.3)}`, borderRadius: C.md, padding: "10px 12px", marginBottom: 6 }}>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 4 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 4 }}><span style={{ fontSize: 12 }}>{t.icon}</span><span style={{ fontSize: 11, fontWeight: 700, color: t.color, fontFamily: C.fontBody, letterSpacing: "0.05em" }}>{t.tone}</span></div>
              <div style={{ display: "flex", gap: 8 }}><span style={{ fontSize: 11, color: C.warmLight }}>🔖</span><span style={{ fontSize: 11, color: C.warmLight }}>🔊</span></div>
            </div>
            <div style={{ fontSize: 12, color: C.warmDark, lineHeight: 1.5, fontFamily: C.fontBody }}>{t.text}</div>
          </div>
        ))}
        <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 6, padding: "8px 0", borderTop: `2px solid ${C.clayBorder}`, marginTop: 4 }}><span>🎬</span><span style={{ fontSize: 12, color: C.warmMuted, fontFamily: C.fontBody }}>Visualize Native Context</span></div>
      </ClayCard>
    </div>
    <div style={{ flexShrink: 0, borderTop: `2px solid ${C.clayBorder}`, background: C.clayWhite }}>
      <div style={{ display: "flex", gap: 8, padding: "8px 12px" }}>
        <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", padding: "8px 0", background: C.clayBeige, border: `1.5px solid ${C.clayBorder}`, borderRadius: C.md, fontSize: 11, color: C.warmMuted, fontFamily: C.fontBody, fontWeight: 600 }}>💬 New Conversation</div>
      </div>
      <div style={{ padding: "0 12px 8px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, background: C.clayWhite, border: `2px solid ${C.clayBorder}`, borderRadius: C.full, padding: "6px 6px 6px 18px" }}>
          <span style={{ flex: 1, fontSize: 14, color: C.warmLight, fontFamily: C.fontBody }}>Enter a phrase to translate...</span>
          <div style={{ width: 40, height: 40, borderRadius: C.full, background: C.goldClay, display: "flex", alignItems: "center", justifyContent: "center", color: C.white, fontSize: 14 }}>➤</div>
        </div>
      </div>
    </div>
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 9: MY LEARNING LIBRARY (Saved Items — FULL feature)
// ═══════════════════════════════════════════════════════════════════
const MyLearningLibrary = () => (
  <Phone label="/my-library" tall>
    <AppBar title="My Learning Library" color={C.tealClay} leading="←" />
    <div style={{ flex: 1, padding: "10px 12px", overflow: "auto", display: "flex", flexDirection: "column", gap: 10, background: C.cream }}>
      <div style={{ display: "flex", gap: 8 }}><div style={{ flex: 1 }}><Input placeholder="Search saved words..." icon="🔍" /></div></div>
      <div style={{ display: "flex", gap: 6, overflow: "auto" }}><Chip text="All" active /><Chip text="Grammar" color={C.error} /><Chip text="Vocab" color={C.purpleClay} /><Chip text="Noun" /><Chip text="Verb" /><Chip text="Adj" /></div>

      {/* Saved Item Card — FULL DETAIL */}
      <ClayCard style={{ padding: 0, overflow: "hidden" }}>
        <div style={{ display: "flex", gap: 10, padding: 14 }}>
          <div style={{ width: 56, height: 56, borderRadius: C.md, background: C.clayBeige, overflow: "hidden", flexShrink: 0, border: `1.5px solid ${C.clayBorder}` }}>
            <img src="https://api.dicebear.com/9.x/shapes/svg?seed=clumsy&backgroundColor=F5EDE3" alt="" style={{ width: "100%", height: "100%" }} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <span style={{ fontSize: 16, fontWeight: 700, color: C.warmDark, fontFamily: C.fontBody }}>clumsy</span>
              <div style={{ display: "flex", gap: 8 }}>
                <span style={{ fontSize: 12, color: C.tealClay }}>🔊</span>
                <span style={{ fontSize: 12, color: C.success }}>▶</span>
                <span style={{ fontSize: 12, color: C.error }}>🗑️</span>
              </div>
            </div>
            <div style={{ fontSize: 11, color: C.purpleClay, fontWeight: 600, fontFamily: C.fontBody }}>Adjective (Tính từ)</div>
            <div style={{ display: "flex", alignItems: "center", gap: 4, marginTop: 2 }}>
              <div style={{ width: 60, height: 4, background: C.clayBeige, borderRadius: C.full }}><div style={{ width: "45%", height: "100%", background: C.warning, borderRadius: C.full }} /></div>
              <span style={{ fontSize: 10, color: C.warning, fontWeight: 700, fontFamily: C.fontBody }}>45%</span>
            </div>
          </div>
        </div>
        <div style={{ padding: "0 14px 10px" }}>
          <div style={{ fontSize: 12, color: C.warmMuted, lineHeight: 1.5, fontFamily: C.fontBody }}>
            Vụng về, lóng ngóng, thiếu khéo léo (trong ngữ cảnh này là sự lóng ngóng dẫn đến việc vô ý làm đổ cà phê).
          </div>
        </div>
        <div style={{ padding: "0 14px 12px" }}>
          {[
            { en: '"I was so clumsy that I dropped my phone on the floor."', vn: '"Tôi đã quá vụng về đến mức làm rơi điện thoại xuống sàn."' },
            { en: '"She made a clumsy attempt to catch the ball."', vn: '"Cô ấy đã có một nỗ lực vụng về để bắt quả bóng."' },
          ].map((ex, i) => (
            <div key={i} style={{ background: C.clayBeige, border: `1.5px solid ${C.clayBorder}`, borderRadius: C.sm, padding: 8, marginBottom: 4 }}>
              <div style={{ fontSize: 11, color: C.warmDark, lineHeight: 1.4, fontFamily: C.fontBody }}>{ex.en}</div>
              <div style={{ fontSize: 10, color: C.warmMuted, fontStyle: "italic", lineHeight: 1.3, fontFamily: C.fontBody }}>{ex.vn}</div>
            </div>
          ))}
        </div>
      </ClayCard>

      {/* Second item — compact */}
      <ClayCard style={{ padding: 0, overflow: "hidden" }}>
        <div style={{ display: "flex", gap: 10, padding: 14 }}>
          <div style={{ width: 56, height: 56, borderRadius: C.md, background: C.clayBeige, overflow: "hidden", flexShrink: 0, border: `1.5px solid ${C.clayBorder}` }}>
            <img src="https://api.dicebear.com/9.x/shapes/svg?seed=leverage&backgroundColor=F5EDE3" alt="" style={{ width: "100%", height: "100%" }} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <span style={{ fontSize: 16, fontWeight: 700, color: C.warmDark, fontFamily: C.fontBody }}>leverage</span>
              <div style={{ display: "flex", gap: 8 }}><span style={{ fontSize: 12, color: C.tealClay }}>🔊</span><span style={{ fontSize: 12, color: C.success }}>▶</span><span style={{ fontSize: 12, color: C.error }}>🗑️</span></div>
            </div>
            <div style={{ fontSize: 11, color: C.purpleClay, fontWeight: 600, fontFamily: C.fontBody }}>Verb (Động từ)</div>
            <div style={{ display: "flex", alignItems: "center", gap: 4, marginTop: 2 }}>
              <div style={{ width: 60, height: 4, background: C.clayBeige, borderRadius: C.full }}><div style={{ width: "20%", height: "100%", background: C.error, borderRadius: C.full }} /></div>
              <span style={{ fontSize: 10, color: C.error, fontWeight: 700, fontFamily: C.fontBody }}>20%</span>
            </div>
          </div>
        </div>
        <div style={{ padding: "0 14px 10px" }}>
          <div style={{ fontSize: 12, color: C.warmMuted, fontFamily: C.fontBody }}>Tận dụng, sử dụng đòn bẩy để đạt lợi thế tối đa.</div>
        </div>
      </ClayCard>

      {/* Third item — grammar type */}
      <ClayCard style={{ padding: 14, display: "flex", gap: 10 }}>
        <div style={{ width: 56, height: 56, borderRadius: C.md, background: C.clayBeige, overflow: "hidden", flexShrink: 0, border: `1.5px solid ${alpha(C.error, 0.3)}` }}>
          <img src="https://api.dicebear.com/9.x/shapes/svg?seed=present-perfect&backgroundColor=F5EDE3" alt="" style={{ width: "100%", height: "100%" }} />
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <span style={{ fontSize: 14, fontWeight: 700, color: C.warmDark, fontFamily: C.fontBody }}>I working here 2 years</span>
            <div style={{ display: "flex", gap: 8 }}><span style={{ fontSize: 12, color: C.success }}>▶</span><span style={{ fontSize: 12, color: C.error }}>🗑️</span></div>
          </div>
          <Badge text="Grammar" color={C.error} bg={alpha(C.error, 0.1)} border={`1.5px solid ${alpha(C.error, 0.3)}`} />
          <div style={{ fontSize: 12, color: C.tealClay, marginTop: 4, fontFamily: C.fontBody, fontWeight: 600 }}>→ I have been working here for 2 years</div>
          <div style={{ display: "flex", alignItems: "center", gap: 4, marginTop: 2 }}>
            <div style={{ width: 60, height: 4, background: C.clayBeige, borderRadius: C.full }}><div style={{ width: "90%", height: "100%", background: C.success, borderRadius: C.full }} /></div>
            <span style={{ fontSize: 10, color: C.success, fontWeight: 700, fontFamily: C.fontBody }}>90%</span>
          </div>
        </div>
      </ClayCard>
    </div>
    <BottomNav active="user" />
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 10: VOCAB HUB — Word Analysis (FULL features)
// ═══════════════════════════════════════════════════════════════════
const WordAnalysis = () => (
  <Phone label="/vocab-hub (analysis)" tall>
    <AppBar title="Vocab Hub" color={C.purpleClay} leading="←" tabs={[{ label: "Analysis", active: true }, { label: "Mind Map" }, { label: "Saved" }, { label: "Practice" }, { label: "Cards" }]} />
    <div style={{ flex: 1, padding: "10px 12px", overflow: "auto", display: "flex", flexDirection: "column", gap: 10, background: C.cream }}>
      <div style={{ display: "flex", gap: 8 }}><div style={{ flex: 1 }}><Input placeholder="Enter a word..." /></div><Btn text="Analyze" bg={C.tealClay} color={C.white} small /></div>

      {/* Word Header */}
      <ClayCard>
        <div style={{ fontSize: 28, fontWeight: 800, color: C.warmDark, fontFamily: C.fontHeading }}>clumsy</div>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 2 }}>
          <span style={{ fontSize: 12, fontFamily: "monospace", color: C.warmMuted }}>/ˈklʌmzi/</span>
          <span style={{ fontSize: 11, color: C.tealClay }}>🔊</span>
        </div>
        <div style={{ display: "inline-block", background: alpha(C.success, 0.1), border: `1.5px solid ${alpha(C.success, 0.3)}`, borderRadius: C.sm, padding: "3px 10px", marginTop: 6 }}>
          <span style={{ fontSize: 12, color: C.success, fontWeight: 600, fontFamily: C.fontBody }}>vụng về</span>
        </div>
      </ClayCard>

      {/* Morphological Breakdown */}
      <ClayCard>
        <div style={{ fontSize: 11, fontWeight: 700, color: C.warmDark, marginBottom: 8, textTransform: "uppercase", letterSpacing: "0.08em", fontFamily: C.fontBody }}>Morphological Breakdown</div>
        <div style={{ display: "flex", alignItems: "center", gap: 6, flexWrap: "wrap" }}>
          <div style={{ background: alpha(C.purpleClay, 0.1), border: `1.5px solid ${alpha(C.purpleClay, 0.3)}`, borderRadius: C.sm, padding: "6px 10px" }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: C.purpleClay, fontFamily: C.fontBody }}>clumse</div>
            <div style={{ fontSize: 9, color: C.warmMuted, fontFamily: C.fontBody }}>numb or stiff with cold</div>
            <div style={{ fontSize: 8, color: C.warmLight, fontStyle: "italic", fontFamily: C.fontBody }}>Middle English / Scandinavian</div>
          </div>
          <span style={{ fontSize: 16, color: C.warmLight }}>+</span>
          <div style={{ background: alpha(C.tealClay, 0.1), border: `1.5px solid ${alpha(C.tealClay, 0.3)}`, borderRadius: C.sm, padding: "6px 10px" }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: C.tealClay, fontFamily: C.fontBody }}>-y</div>
            <div style={{ fontSize: 9, color: C.warmMuted, fontFamily: C.fontBody }}>characterized by or inclined to</div>
          </div>
          <span style={{ fontSize: 16, color: C.warmLight }}>=</span>
          <div style={{ background: alpha(C.goldClay, 0.1), border: `1.5px solid ${alpha(C.goldClay, 0.3)}`, borderRadius: C.sm, padding: "6px 10px" }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: C.goldClay, fontFamily: C.fontBody }}>clumsy</div>
          </div>
        </div>
      </ClayCard>

      {/* Contextual Usage */}
      <ClayCard>
        <div style={{ fontSize: 11, fontWeight: 700, color: C.warmDark, marginBottom: 8, textTransform: "uppercase", letterSpacing: "0.08em", fontFamily: C.fontBody }}>Contextual Usage</div>
        <div style={{ marginBottom: 8 }}>
          <Badge text="Positive Context" color={C.success} bg={alpha(C.success, 0.1)} border={`1.5px solid ${alpha(C.success, 0.3)}`} />
          <div style={{ fontSize: 12, color: C.warmDark, marginTop: 4, lineHeight: 1.5, fontFamily: C.fontBody }}>His clumsy attempt at a joke actually made everyone laugh and eased the tension.</div>
          <div style={{ fontSize: 11, color: C.warmMuted, fontStyle: "italic", marginTop: 2, fontFamily: C.fontBody }}>Nỗ lực pha trò vụng về của anh ấy thực sự đã khiến mọi người bật cười.</div>
        </div>
        <div style={{ marginBottom: 8 }}>
          <Badge text="Negative Context" color={C.error} bg={alpha(C.error, 0.1)} border={`1.5px solid ${alpha(C.error, 0.3)}`} />
          <div style={{ fontSize: 12, color: C.warmDark, marginTop: 4, lineHeight: 1.5, fontFamily: C.fontBody }}>She felt clumsy and embarrassed after tripping over her own feet in front of the crowd.</div>
          <div style={{ fontSize: 11, color: C.warmMuted, fontStyle: "italic", marginTop: 2, fontFamily: C.fontBody }}>Cô cảm thấy vụng về và xấu hổ sau khi tự vấp ngã trước đám đông.</div>
        </div>
        <div>
          <div style={{ fontSize: 11, fontWeight: 700, color: C.warmMuted, marginBottom: 4, fontFamily: C.fontBody, textTransform: "uppercase", letterSpacing: "0.05em" }}>Common Collocations</div>
          <div style={{ display: "flex", gap: 4, flexWrap: "wrap" }}>
            {["clumsy hands", "clumsy mistake", "clumsy movement"].map((c, i) => <span key={i} style={{ fontSize: 10, background: C.clayBeige, border: `1.5px solid ${C.clayBorder}`, padding: "4px 10px", borderRadius: C.full, color: C.warmDark, fontFamily: C.fontBody, fontWeight: 500 }}>{c}</span>)}
          </div>
        </div>
      </ClayCard>

      {/* Word Family */}
      <ClayCard>
        <div style={{ fontSize: 11, fontWeight: 700, color: C.warmDark, marginBottom: 8, textTransform: "uppercase", letterSpacing: "0.08em", fontFamily: C.fontBody }}>Word Family</div>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 6 }}>
          {[
            { pos: "adjective", word: "clumsy", color: C.purpleClay },
            { pos: "adverb", word: "clumsily", color: C.tealClay },
            { pos: "noun", word: "clumsiness", color: C.goldClay },
            { pos: "verb", word: "—", color: C.warmLight },
          ].map((w, i) => (
            <div key={i} style={{ background: C.clayBeige, border: `1.5px solid ${C.clayBorder}`, borderRadius: C.sm, padding: 8, textAlign: "center" }}>
              <div style={{ fontSize: 9, color: w.color, fontWeight: 700, textTransform: "uppercase", fontFamily: C.fontBody, letterSpacing: "0.05em" }}>{w.pos}</div>
              <div style={{ fontSize: 13, color: w.word === "—" ? C.warmLight : C.warmDark, fontWeight: 600, fontFamily: C.fontBody }}>{w.word}</div>
            </div>
          ))}
        </div>
      </ClayCard>

      {/* Synonyms & Antonyms */}
      <ClayCard>
        <div style={{ display: "flex", gap: 12 }}>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 11, fontWeight: 700, color: C.success, marginBottom: 6, fontFamily: C.fontBody, textTransform: "uppercase", letterSpacing: "0.05em" }}>Synonyms</div>
            {["awkward", "inept", "uncoordinated"].map((w, i) => <div key={i} style={{ fontSize: 12, color: C.warmDark, marginBottom: 3, fontFamily: C.fontBody }}>• {w}</div>)}
          </div>
          <div style={{ width: 1, background: C.clayBorder }} />
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 11, fontWeight: 700, color: C.error, marginBottom: 6, fontFamily: C.fontBody, textTransform: "uppercase", letterSpacing: "0.05em" }}>Antonyms</div>
            {["graceful", "nimble", "deft"].map((w, i) => <div key={i} style={{ fontSize: 12, color: C.warmDark, marginBottom: 3, fontFamily: C.fontBody }}>• {w}</div>)}
          </div>
        </div>
      </ClayCard>
    </div>
    <BottomNav active="home" />
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 11: DIALOGUE LIST (Story Select)
// ═══════════════════════════════════════════════════════════════════
const DialogueList = () => (
  <Phone label="/chat/story/select">
    <AppBar title="Choose a Story" color={C.purpleClay} leading="←" />
    <div style={{ flex: 1, padding: "10px 12px", overflow: "auto", display: "flex", flexDirection: "column", gap: 10, background: C.cream }}>
      <ClayCard borderColor={alpha(C.purpleClay, 0.3)}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 8 }}>
          <Img3D src={E.sparkles} size={20} />
          <span style={{ fontSize: 14, fontWeight: 700, color: C.warmDark, fontFamily: C.fontBody }}>Custom Story</span>
        </div>
        <div style={{ background: C.clayBeige, border: `2px solid ${C.clayBorder}`, borderRadius: C.md, padding: 10, fontSize: 12, color: C.warmLight, minHeight: 36, marginBottom: 8, fontFamily: C.fontBody }}>Describe your scenario...</div>
        <Btn text="Start Custom Story ✨" bg={C.purpleClay} color={C.white} full small shadow={`3px 3px 0px ${alpha(C.purpleClay, 0.4)}`} />
      </ClayCard>
      {[
        { title: "At the Airport", diff: "Beginner", color: C.success, desc: "Navigate check-in and boarding", emoji: E.airplane },
        { title: "Job Interview", diff: "Intermediate", color: C.warning, desc: "Practice professional dialogue", emoji: E.briefcase },
        { title: "Medical Emergency", diff: "Advanced", color: C.error, desc: "Handle urgent situations", emoji: E.hospital },
      ].map((d, i) => (
        <ClayCard key={i} style={{ padding: 14, display: "flex", gap: 10 }} interactive>
          <div style={{ width: 48, height: 48, borderRadius: C.md, background: alpha(d.color, 0.15), display: "flex", alignItems: "center", justifyContent: "center" }}><Img3D src={d.emoji} size={32} /></div>
          <div style={{ flex: 1 }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 4 }}>
              <span style={{ fontSize: 14, fontWeight: 700, color: C.warmDark, fontFamily: C.fontBody }}>{d.title}</span>
              <Badge text={d.diff} color={d.color} bg={alpha(d.color, 0.1)} border={`1.5px solid ${alpha(d.color, 0.3)}`} />
            </div>
            <div style={{ fontSize: 12, color: C.warmMuted, fontFamily: C.fontBody }}>{d.desc}</div>
          </div>
        </ClayCard>
      ))}
    </div>
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 12: CONTEXT PANEL (Bottom Sheet)
// ═══════════════════════════════════════════════════════════════════
const ContextPanel = () => (
  <Phone label="Context Panel (sheet)">
    <AppBar title="Scenario Coach" color={C.tealClay} leading="←" />
    <div style={{ flex: 1, background: alpha(C.warmDark, 0.4), display: "flex", flexDirection: "column", justifyContent: "flex-end" }}>
      <div style={{ padding: "8px 12px", opacity: 0.3 }}><div style={{ background: C.clayBeige, borderRadius: C.md, padding: 12, fontSize: 12, color: C.warmLight }}>Chat messages behind...</div></div>
      <div style={{ background: C.clayWhite, borderRadius: `${C.lg}px ${C.lg}px 0 0`, padding: "8px 16px 16px", border: `2px solid ${C.clayBorder}`, borderBottom: "none", maxHeight: 400, overflow: "auto" }}>
        <div style={{ display: "flex", justifyContent: "center", marginBottom: 12 }}><div style={{ width: 36, height: 4, background: C.clayBorder, borderRadius: 2 }} /></div>
        <div style={{ fontSize: 18, fontWeight: 700, color: C.warmDark, marginBottom: 12, fontFamily: C.fontHeading }}>Context Details</div>
        <ClayCard style={{ marginBottom: 10, padding: 14 }}>
          <div style={{ fontSize: 12, fontWeight: 700, color: C.tealClay, marginBottom: 4, fontFamily: C.fontBody, textTransform: "uppercase", letterSpacing: "0.05em" }}>Current Scenario</div>
          <div style={{ fontSize: 14, color: C.warmDark, fontFamily: C.fontBody, fontWeight: 600 }}>Office — Apologizing to a colleague</div>
          <div style={{ fontSize: 12, color: C.warmMuted, marginTop: 4, fontFamily: C.fontBody }}>Level: B1/B2 · Topic: Business</div>
        </ClayCard>
        <ClayCard style={{ marginBottom: 10, padding: 14, borderLeft: `4px solid ${C.goldClay}` }}>
          <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 8 }}><span>💡</span><span style={{ fontSize: 12, fontWeight: 700, color: C.goldClay, fontFamily: C.fontBody }}>Hints (2/3)</span></div>
          <div style={{ fontSize: 12, color: C.warmMuted, borderLeft: `3px solid ${C.tealClay}`, paddingLeft: 8, marginBottom: 6, fontFamily: C.fontBody }}>Use an exclamation to show genuine surprise at your mistake</div>
          <div style={{ fontSize: 12, color: C.warmMuted, borderLeft: `3px solid ${C.tealClay}`, paddingLeft: 8, marginBottom: 6, fontFamily: C.fontBody }}>Offer to fix the situation — this is culturally expected</div>
          <div style={{ fontSize: 12, color: C.tealClay, fontWeight: 600, fontFamily: C.fontBody }}>▶ Reveal next hint</div>
        </ClayCard>
        <ClayCard style={{ padding: 14 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 6 }}><span>🎯</span><span style={{ fontSize: 12, fontWeight: 700, color: C.warning, fontFamily: C.fontBody }}>Tips for Success</span></div>
          <div style={{ fontSize: 12, color: C.warmMuted, lineHeight: 1.6, fontFamily: C.fontBody }}>• Use formal-friendly register<br />• Show empathy and accountability<br />• Offer a concrete solution</div>
        </ClayCard>
      </div>
    </div>
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 13: FLASHCARDS + PRACTICE + MIND MAP
// ═══════════════════════════════════════════════════════════════════
const FlashcardsScreen = () => (
  <Phone label="/vocab-hub/flashcards">
    <AppBar title="Flashcards (2/12)" color={C.purpleClay} leading="←" />
    <div style={{ flex: 1, padding: 16, display: "flex", flexDirection: "column", gap: 16, alignItems: "center", justifyContent: "center", background: C.cream }}>
      <ClayCard style={{ width: "100%", minHeight: 200, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", textAlign: "center", gap: 8, boxShadow: C.shadowClay }}>
        <Badge text="Vocabulary" color={C.purpleClay} bg={alpha(C.purpleClay, 0.1)} border={`1.5px solid ${alpha(C.purpleClay, 0.3)}`} />
        <div style={{ fontSize: 24, fontWeight: 700, color: C.warmDark, marginTop: 8, fontFamily: C.fontHeading }}>leverage</div>
        <div style={{ fontSize: 12, color: C.warmLight, marginTop: 4, fontFamily: C.fontBody }}>Mastery: 45%</div>
        <div style={{ fontSize: 11, color: C.warmMuted, marginTop: 12, fontStyle: "italic", fontFamily: C.fontBody }}>Tap to flip →</div>
      </ClayCard>
      <div style={{ fontSize: 12, color: C.warmMuted, fontFamily: C.fontBody }}>Rate how well you knew it:</div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr 1fr", gap: 6, width: "100%" }}>
        <Btn text="Again" bg={alpha(C.error, 0.1)} color={C.error} small shadow="none" />
        <Btn text="Hard" bg={alpha(C.warning, 0.1)} color="#9A7B3D" small shadow="none" />
        <Btn text="Good" bg={alpha(C.tealClay, 0.1)} color={C.tealClay} small shadow="none" />
        <Btn text="Easy" bg={alpha(C.success, 0.1)} color={C.success} small shadow="none" />
      </div>
    </div>
    <BottomNav active="home" />
  </Phone>
);

const PracticeScreen = () => (
  <Phone label="/vocab-hub/practice">
    <AppBar title="Practice (Q3/10)" color={C.purpleClay} leading="←" />
    <div style={{ flex: 1, padding: 16, display: "flex", flexDirection: "column", gap: 12, background: C.cream }}>
      <ClayCard>
        <Badge text="Fill in the blank" color={C.tealClay} bg={alpha(C.tealClay, 0.1)} border={`1.5px solid ${alpha(C.tealClay, 0.3)}`} />
        <div style={{ fontSize: 16, fontWeight: 600, color: C.warmDark, marginTop: 10, lineHeight: 1.5, fontFamily: C.fontBody }}>She _____ working here for 3 years.</div>
        <div style={{ marginTop: 12 }}><Input placeholder="Type your answer..." /></div>
        <div style={{ marginTop: 12 }}><Btn text="Check Answer ✓" bg={C.tealClay} color={C.white} full /></div>
      </ClayCard>
      <ClayCard borderColor={alpha(C.success, 0.3)} style={{ borderLeft: `4px solid ${C.success}` }}>
        <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 4 }}><span style={{ color: C.success }}>✓</span><span style={{ fontSize: 14, fontWeight: 700, color: C.success, fontFamily: C.fontBody }}>Correct!</span></div>
        <div style={{ fontSize: 12, color: C.warmMuted, fontFamily: C.fontBody }}>"has been" — Present perfect continuous.</div>
      </ClayCard>
    </div>
    <BottomNav active="home" />
  </Phone>
);

const MindMapScreen = () => (
  <Phone label="/vocab-hub/mind-map">
    <AppBar title="Mind Map: Technology" color={C.purpleClay} leading="←" actions={<IconBtn icon="📤" />} />
    <div style={{ flex: 1, padding: 12, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", background: C.cream }}>
      <svg width="280" height="340" viewBox="0 0 280 340">
        <rect x="90" y="150" width="100" height="40" rx={C.md} fill={C.tealClay} />
        <text x="140" y="175" textAnchor="middle" fill="white" fontSize="13" fontWeight="700" fontFamily="Nunito">Technology</text>
        {[{ x: 60, y: 70, label: "Hardware" }, { x: 220, y: 70, label: "Software" }, { x: 50, y: 260, label: "Networks" }, { x: 230, y: 260, label: "AI & Data" }].map((n, i) => (
          <g key={i}>
            <line x1="140" y1={i < 2 ? 150 : 190} x2={n.x} y2={i < 2 ? n.y + 36 : n.y} stroke={C.clayBorder} strokeWidth="2" />
            <rect x={n.x - 50} y={n.y} width="100" height="36" rx={C.sm} fill={C.clayWhite} stroke={C.clayBorder} strokeWidth="1.5" />
            <text x={n.x} y={n.y + 22} textAnchor="middle" fill={C.warmDark} fontSize="11" fontWeight="600" fontFamily="Nunito">{n.label}</text>
          </g>
        ))}
      </svg>
    </div>
    <BottomNav active="home" />
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// SCREEN 14: HISTORY + PROFILE
// ═══════════════════════════════════════════════════════════════════
const HistoryScreen = () => (
  <Phone label="/history">
    <AppBar title="History" leading="←" />
    <div style={{ flex: 1, padding: "10px 12px", overflow: "auto", display: "flex", flexDirection: "column", gap: 8, background: C.cream }}>
      <div style={{ display: "flex", gap: 6, overflow: "auto", paddingBottom: 4 }}><Chip text="All" active /><Chip text="Roleplay" color={C.tealClay} /><Chip text="Story" color={C.purpleClay} /><Chip text="Translator" color={C.goldClay} /></div>
      {[
        { title: "Office Apology", mode: "Roleplay", color: C.tealClay, date: "28/03/2026", msgs: 14 },
        { title: "At the Airport", mode: "Story", color: C.purpleClay, date: "27/03/2026", msgs: 22 },
        { title: "Email to Manager", mode: "Translator", color: C.goldClay, date: "27/03/2026", msgs: 3 },
      ].map((h, i) => (
        <div key={i} style={{ display: "flex" }}>
          <div style={{ width: 4, background: h.color, borderRadius: `${C.sm}px 0 0 ${C.sm}px` }} />
          <ClayCard style={{ flex: 1, padding: 14, borderRadius: `0 ${C.lg}px ${C.lg}px 0`, borderLeft: "none" }} interactive>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 4 }}>
              <span style={{ fontSize: 14, fontWeight: 700, color: C.warmDark, fontFamily: C.fontBody }}>{h.title}</span>
              <Badge text={h.mode} color={h.color} bg={alpha(h.color, 0.1)} border={`1.5px solid ${alpha(h.color, 0.3)}`} />
            </div>
            <div style={{ display: "flex", gap: 12, fontSize: 12, color: C.warmMuted, fontFamily: C.fontBody }}><span>📅 {h.date}</span><span>💬 {h.msgs} messages</span></div>
          </ClayCard>
        </div>
      ))}
    </div>
  </Phone>
);

const UserProfile = () => (
  <Phone label="Profile (sheet)">
    <div style={{ flex: 1, background: alpha(C.warmDark, 0.4), display: "flex", flexDirection: "column", justifyContent: "flex-end" }}>
      <div style={{ background: C.clayWhite, borderRadius: `${C.lg}px ${C.lg}px 0 0`, padding: "8px 16px 16px", border: `2px solid ${C.clayBorder}`, overflow: "auto" }}>
        <div style={{ display: "flex", justifyContent: "center", marginBottom: 16 }}><div style={{ width: 36, height: 4, background: C.clayBorder, borderRadius: 2 }} /></div>
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 8, marginBottom: 16 }}>
          <div style={{ width: 64, height: 64, borderRadius: C.full, overflow: "hidden", border: `3px solid ${C.tealClay}`, boxShadow: C.shadowClay }}>
            <img src={avatarUrl("Molly", 3)} alt="" style={{ width: "100%", height: "100%" }} />
          </div>
          <div style={{ fontSize: 20, fontWeight: 700, color: C.warmDark, fontFamily: C.fontHeading }}>Luu</div>
          <Badge text="Free Tier" color={C.warmMuted} bg={C.clayBeige} border={`1.5px solid ${C.clayBorder}`} />
        </div>
        <ClayCard style={{ marginBottom: 12 }}>
          <div style={{ fontSize: 14, fontWeight: 700, color: C.warmDark, marginBottom: 10, fontFamily: C.fontBody }}>Daily Usage</div>
          <ProgressBar label="Roleplay" count="3/5" value={60} color={C.tealClay} />
          <ProgressBar label="Stories" count="1/3" value={33} color={C.purpleClay} />
          <ProgressBar label="Translator" count="4/10" value={40} color={C.goldClay} />
        </ClayCard>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          <Btn text="⭐ Upgrade to Pro" bg={C.tealClay} color={C.white} full />
          <Btn text="⚙️ Settings" outline={C.clayBorder} color={C.warmMuted} full />
          <Btn text="🚪 Log Out" outline={alpha(C.error, 0.5)} color={C.error} full />
        </div>
      </div>
    </div>
  </Phone>
);

// ═══════════════════════════════════════════════════════════════════
// MAIN EXPORT
// ═══════════════════════════════════════════════════════════════════
export default function AuraCoachWireframes() {
  const [view, setView] = useState("all");
  return (
    <div style={{ background: C.cream, minHeight: "100vh", padding: "24px 16px", fontFamily: C.fontBody }}>
      <style>{`@import url('https://fonts.googleapis.com/css2?family=Fredoka:wght@600;700;800&family=Nunito:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap');`}</style>
      <div style={{ textAlign: "center", marginBottom: 24 }}>
        <h1 style={{ color: C.warmDark, fontSize: 28, fontWeight: 700, margin: 0, fontFamily: C.fontHeading }}>AURA COACH MOBILE</h1>
        <p style={{ color: C.warmMuted, fontSize: 14, margin: "4px 0 8px", fontFamily: C.fontBody }}>Wireframes v5.3 · Clay Design System · Cloudinary 3D Icons + Fluent Topics + Lucide UI</p>
        <p style={{ color: C.warmLight, fontSize: 11, margin: "0 0 16px", fontFamily: C.fontBody }}>
          v5.3: Cloudinary clay 3D icons (mode/nav/avatar/logo) · 3-tab bottom nav · Clay animal avatars · Asset registry linked
        </p>
        <div style={{ display: "flex", gap: 6, justifyContent: "center", flexWrap: "wrap" }}>
          {[{ key: "all", label: "All" }, { key: "auth", label: "Auth" }, { key: "home", label: "Home" }, { key: "chat", label: "Chat" }, { key: "library", label: "Library" }, { key: "vocab", label: "Vocab" }, { key: "misc", label: "History" }].map((t) => (
            <button key={t.key} onClick={() => setView(t.key)} style={{ padding: "8px 16px", borderRadius: C.full, border: view === t.key ? "none" : `1.5px solid ${C.clayBorder}`, background: view === t.key ? C.tealClay : C.clayWhite, color: view === t.key ? C.white : C.warmMuted, fontSize: 12, fontWeight: 700, cursor: "pointer", fontFamily: C.fontBody, boxShadow: view === t.key ? C.shadowClay : C.shadowCard }}>{t.label}</button>
          ))}
        </div>
      </div>

      {(view === "all" || view === "auth") && (<>
        <SectionTitle title="Authentication Flow" subtitle="Splash → Auth → Onboarding (Avatar + Levels + Topics)" />
        <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap", alignItems: "flex-start" }}>
          <SplashScreen /><FlowArrow label="Auto" /><AuthScreen /><FlowArrow label="New user" /><OnboardingStep1 /><FlowArrow label="Next" /><OnboardingStep2 />
        </div>
      </>)}

      {(view === "all" || view === "home") && (<>
        <SectionTitle title="Home & Profile" subtitle="Mode selection with 3D emojis + User profile sheet" />
        <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap", alignItems: "flex-end" }}>
          <HomeScreen /><FlowArrow label="Tap avatar" /><UserProfile />
        </div>
      </>)}

      {(view === "all" || view === "chat") && (<>
        <SectionTitle title="Scenario Coach (Roleplay)" subtitle="Sticky context + Full 4-section assessment + Save to Dictionary + Audio" />
        <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap", alignItems: "flex-start" }}>
          <ChatRoleplay /><FlowArrow label="💡 Hints" /><ContextPanel />
        </div>
        <SectionTitle title="Story Mode + Tone Translator" subtitle="Story with FULL assessment (same as Roleplay) + 4-tone translations" />
        <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap", alignItems: "flex-start" }}>
          <DialogueList /><FlowArrow label="Select" /><ChatStory /><ChatTranslator />
        </div>
      </>)}

      {(view === "all" || view === "library") && (<>
        <SectionTitle title="My Learning Library" subtitle="Full saved items: illustration, POS, explanation, EN/VN examples, pronunciation, practice, delete" />
        <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap", alignItems: "flex-start" }}>
          <MyLearningLibrary />
        </div>
      </>)}

      {(view === "all" || view === "vocab") && (<>
        <SectionTitle title="Vocab Hub — Word Analysis (Full)" subtitle="Phonetics · Morphology · Contextual Usage · Collocations · Word Family · Synonyms/Antonyms" />
        <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap", alignItems: "flex-start" }}>
          <WordAnalysis />
        </div>
        <SectionTitle title="Vocab Hub — Flashcards · Practice · Mind Map" />
        <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap", alignItems: "flex-end" }}>
          <FlashcardsScreen /><PracticeScreen /><MindMapScreen />
        </div>
      </>)}

      {(view === "all" || view === "misc") && (<>
        <SectionTitle title="History" />
        <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap", alignItems: "flex-end" }}>
          <HistoryScreen />
        </div>
      </>)}

      <div style={{ textAlign: "center", padding: "40px 0 20px", color: C.warmLight, fontSize: 11, fontFamily: C.fontBody }}>
        Aura Coach Mobile · Wireframes v5.3 · Clay Design System · Cloudinary Assets · {new Date().toLocaleDateString()} · Fredoka 800 + Nunito + Inter
      </div>
    </div>
  );
}
