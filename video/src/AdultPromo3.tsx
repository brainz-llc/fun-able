import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
} from "remotion";
import { TransitionSeries, linearTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";

const colors = {
  primary: "#27ae60",
  bg: "#0d0d0f",
  bgCard: "#1a1a1f",
  textPrimary: "#ffffff",
  textSecondary: "#a0a0a0",
  textMuted: "#666666",
  border: "rgba(255,255,255,0.08)",
  borderLight: "rgba(255,255,255,0.1)",
};

const GridPattern = ({ opacity = 0.02 }: { opacity?: number }) => (
  <div style={{ position: "absolute", inset: 0, opacity, backgroundImage: `linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px)`, backgroundSize: "60px 60px" }} />
);

const SoftOrb = ({ x, y, size, color }: { x: string | number; y: string | number; size: number; color: string }) => (
  <div style={{ position: "absolute", left: x, top: y, width: size, height: size, borderRadius: "50%", background: `radial-gradient(circle, ${color}25 0%, transparent 70%)`, filter: "blur(80px)" }} />
);

const CleanCard = ({ isBlack = false, children, style = {} }: { isBlack?: boolean; children: React.ReactNode; style?: React.CSSProperties }) => (
  <div style={{ width: 380, minHeight: 520, background: isBlack ? colors.bg : colors.bgCard, borderRadius: 20, padding: 36, display: "flex", flexDirection: "column", justifyContent: "space-between", boxShadow: "0 25px 50px rgba(0,0,0,0.5)", border: `1px solid ${colors.border}`, ...style }}>
    {children}
    <div style={{ display: "flex", alignItems: "center", gap: 10, marginTop: 24, paddingTop: 20, borderTop: `1px solid ${colors.borderLight}` }}>
      <div style={{ width: 28, height: 28, background: colors.primary, borderRadius: 6 }} />
      <span style={{ color: colors.textMuted, fontSize: 13, fontWeight: 600, letterSpacing: "0.5px" }}>CARTAS CONTRA LA FORMALIDAD</span>
    </div>
  </div>
);

const TitleScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({ frame, fps, config: { damping: 100, stiffness: 200 } });

  return (
    <AbsoluteFill style={{ background: colors.bg }}>
      <GridPattern />
      <SoftOrb x="10%" y="20%" size={600} color={colors.primary} />
      <SoftOrb x="70%" y="60%" size={500} color="#f39c12" />
      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <div style={{ textAlign: "center", transform: `translateY(${interpolate(progress, [0, 1], [40, 0])}px)`, opacity: interpolate(progress, [0, 1], [0, 1]) }}>
          <div style={{ fontSize: 80, marginBottom: 30 }}>💰🎰💸</div>
          <h1 style={{ fontSize: 90, fontWeight: 600, color: colors.textPrimary, margin: 0, letterSpacing: "-2px" }}>
            Edición <span style={{ color: colors.primary }}>Dinero</span>
          </h1>
          <p style={{ fontSize: 28, color: colors.textSecondary, marginTop: 30 }}>Porque la plata no compra la felicidad... pero ayuda</p>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

const CardScene = ({ black, white, orbColor }: { black: string; white: string; orbColor: string }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const cardProgress = spring({ frame, fps, config: { damping: 80, stiffness: 150 } });
  const whiteProgress = spring({ frame: frame - 30, fps, config: { damping: 80, stiffness: 150 } });

  return (
    <AbsoluteFill style={{ background: colors.bg }}>
      <GridPattern />
      <SoftOrb x="50%" y="50%" size={800} color={orbColor} />
      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <div style={{ display: "flex", gap: 40, alignItems: "center" }}>
          <div style={{ transform: `translateY(${interpolate(cardProgress, [0, 1], [60, 0])}px)`, opacity: interpolate(cardProgress, [0, 1], [0, 1]) }}>
            <CleanCard isBlack style={{ width: 340, minHeight: 450 }}>
              <p style={{ fontSize: 26, fontWeight: 500, color: colors.textPrimary, margin: 0, lineHeight: 1.6 }}>{black}</p>
              <div style={{ marginTop: 20, height: 4, width: 140, background: colors.primary, borderRadius: 2 }} />
            </CleanCard>
          </div>
          <div style={{ fontSize: 50, color: colors.primary, opacity: interpolate(whiteProgress, [0, 1], [0, 1]) }}>+</div>
          <div style={{ transform: `translateY(${interpolate(whiteProgress, [0, 1], [60, 0])}px)`, opacity: interpolate(whiteProgress, [0, 1], [0, 1]) }}>
            <CleanCard style={{ width: 340, minHeight: 450 }}>
              <p style={{ fontSize: 26, fontWeight: 500, color: colors.textPrimary, margin: 0, lineHeight: 1.6 }}>{white}</p>
            </CleanCard>
          </div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

const CTAScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({ frame, fps, config: { damping: 80, stiffness: 150 } });
  const pulse = Math.sin(frame * 0.08) * 0.02 + 1;

  return (
    <AbsoluteFill style={{ background: colors.primary }}>
      <GridPattern opacity={0.05} />
      <SoftOrb x="30%" y="30%" size={600} color="#ffffff" />
      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <div style={{ textAlign: "center", transform: `translateY(${interpolate(progress, [0, 1], [30, 0])}px)`, opacity: interpolate(progress, [0, 1], [0, 1]) }}>
          <div style={{ fontSize: 60, marginBottom: 20 }}>🤑</div>
          <h2 style={{ fontSize: 72, fontWeight: 600, color: "#fff", margin: 0 }}>Invierte en risas</h2>
          <p style={{ fontSize: 24, color: "rgba(255,255,255,0.8)", marginTop: 20, marginBottom: 50 }}>Edición Dinero - El humor no tiene precio</p>
          <div style={{ transform: `scale(${pulse})` }}>
            <div style={{ display: "inline-flex", alignItems: "center", gap: 12, background: colors.bg, padding: "24px 48px", borderRadius: 16 }}>
              <span style={{ fontSize: 28, fontWeight: 600, color: colors.primary }}>Comprar mazo</span>
              <span style={{ fontSize: 24 }}>💎</span>
            </div>
          </div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

const cardPairs = [
  { black: "Si me ganara la lotería, lo primero que haría es", white: "Cambiar de número para que mi familia no me encuentre", orb: colors.primary },
  { black: "Mi trabajo de medio tiempo secreto es", white: "Vender las fotos de pies de mi tía en OnlyFans", orb: "#f39c12" },
  { black: "El banco me rechazó el préstamo porque descubrieron", white: "Mis 47 suscripciones activas de streaming", orb: colors.primary },
  { black: "Mi plan para hacerme millonario incluye", white: "Un curso de criptomonedas de $9.99", orb: "#f39c12" },
  { black: "El verdadero motivo por el que no tengo ahorros es", white: "Las compras de madrugada en Amazon", orb: colors.primary },
  { black: "Si pudiera vender algo en el mercado negro, sería", white: "Los audios de voz de mi suegra", orb: "#f39c12" },
];

export const AdultPromo3 = () => {
  const { fps } = useVideoConfig();
  const td = Math.round(0.4 * fps);

  return (
    <TransitionSeries>
      <TransitionSeries.Sequence durationInFrames={2.5 * fps}><TitleScene /></TransitionSeries.Sequence>
      <TransitionSeries.Transition presentation={fade()} timing={linearTiming({ durationInFrames: td })} />
      {cardPairs.map((pair, i) => (
        <>
          <TransitionSeries.Sequence key={i} durationInFrames={3 * fps}>
            <CardScene black={pair.black} white={pair.white} orbColor={pair.orb} />
          </TransitionSeries.Sequence>
          <TransitionSeries.Transition presentation={fade()} timing={linearTiming({ durationInFrames: td })} />
        </>
      ))}
      <TransitionSeries.Sequence durationInFrames={3 * fps}><CTAScene /></TransitionSeries.Sequence>
    </TransitionSeries>
  );
};
