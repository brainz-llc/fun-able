import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
  Easing,
} from "remotion";
import { TransitionSeries, linearTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";

// Dark, edgy color palette for adult content
const colors = {
  primary: "#e94560",
  primaryMuted: "#e9456020",
  primarySoft: "#e9456040",
  bg: "#0d0d0f",
  bgCard: "#1a1a1f",
  bgSubtle: "#151518",
  textPrimary: "#ffffff",
  textSecondary: "#a0a0a0",
  textMuted: "#666666",
  textLight: "#ffffff",
  accent: "#ff8a8a",
  border: "rgba(255,255,255,0.08)",
  borderLight: "rgba(255,255,255,0.1)",
  shadow: "rgba(0,0,0,0.3)",
  warning: "#ffcc00",
};

const GridPattern = ({ opacity = 0.02 }: { opacity?: number }) => (
  <div
    style={{
      position: "absolute",
      inset: 0,
      opacity,
      backgroundImage: `
        linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px),
        linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px)
      `,
      backgroundSize: "60px 60px",
    }}
  />
);

const SoftOrb = ({
  x,
  y,
  size,
  color,
}: {
  x: string | number;
  y: string | number;
  size: number;
  color: string;
}) => (
  <div
    style={{
      position: "absolute",
      left: x,
      top: y,
      width: size,
      height: size,
      borderRadius: "50%",
      background: `radial-gradient(circle, ${color}25 0%, transparent 70%)`,
      filter: "blur(80px)",
      pointerEvents: "none",
    }}
  />
);

const CleanCard = ({
  isBlack = false,
  children,
  style = {},
}: {
  isBlack?: boolean;
  children: React.ReactNode;
  style?: React.CSSProperties;
}) => (
  <div
    style={{
      width: 380,
      minHeight: 520,
      background: isBlack ? colors.bg : colors.bgCard,
      borderRadius: 20,
      padding: 36,
      display: "flex",
      flexDirection: "column",
      justifyContent: "space-between",
      boxShadow: "0 25px 50px rgba(0,0,0,0.5)",
      border: `1px solid ${colors.border}`,
      ...style,
    }}
  >
    {children}
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: 10,
        marginTop: 24,
        paddingTop: 20,
        borderTop: `1px solid ${colors.borderLight}`,
      }}
    >
      <div
        style={{
          width: 28,
          height: 28,
          background: colors.primary,
          borderRadius: 6,
        }}
      />
      <span
        style={{
          color: colors.textMuted,
          fontSize: 13,
          fontWeight: 600,
          letterSpacing: "0.5px",
        }}
      >
        CARTAS CONTRA LA FORMALIDAD
      </span>
    </div>
  </div>
);

// Scene 1: Adult Warning Title
const AdultTitleScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const warningProgress = spring({
    frame,
    fps,
    config: { damping: 100, stiffness: 200 },
  });

  const titleProgress = spring({
    frame: frame - 20,
    fps,
    config: { damping: 100, stiffness: 200 },
  });

  const subtitleProgress = spring({
    frame: frame - 35,
    fps,
    config: { damping: 100, stiffness: 200 },
  });

  const taglineProgress = interpolate(
    frame,
    [1.8 * fps, 2.3 * fps],
    [0, 1],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.quad) }
  );

  // Pulsing effect for 18+
  const pulse = Math.sin(frame * 0.1) * 0.05 + 1;

  return (
    <AbsoluteFill style={{ background: colors.bg }}>
      <GridPattern />
      <SoftOrb x="10%" y="20%" size={600} color={colors.primary} />
      <SoftOrb x="70%" y="60%" size={500} color="#ff3366" />

      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <div style={{ textAlign: "center", maxWidth: 1200 }}>
          {/* 18+ Badge */}
          <div
            style={{
              opacity: interpolate(warningProgress, [0, 1], [0, 1]),
              transform: `scale(${interpolate(warningProgress, [0, 1], [0.5, 1]) * pulse})`,
              marginBottom: 40,
            }}
          >
            <div
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: 12,
                background: colors.primary,
                padding: "12px 28px",
                borderRadius: 50,
              }}
            >
              <span style={{ fontSize: 28, fontWeight: 700, color: "white" }}>🔞</span>
              <span
                style={{
                  fontSize: 22,
                  fontWeight: 700,
                  color: "white",
                  letterSpacing: "2px",
                }}
              >
                SOLO ADULTOS
              </span>
            </div>
          </div>

          <div
            style={{
              transform: `translateY(${interpolate(titleProgress, [0, 1], [40, 0])}px)`,
              opacity: interpolate(titleProgress, [0, 1], [0, 1]),
            }}
          >
            <h1
              style={{
                fontSize: 110,
                fontWeight: 600,
                color: colors.textPrimary,
                margin: 0,
                lineHeight: 1.1,
                letterSpacing: "-3px",
                fontFamily: "system-ui, -apple-system, sans-serif",
              }}
            >
              Cartas Contra
            </h1>
          </div>

          <div
            style={{
              transform: `translateY(${interpolate(subtitleProgress, [0, 1], [30, 0])}px)`,
              opacity: interpolate(subtitleProgress, [0, 1], [0, 1]),
            }}
          >
            <h1
              style={{
                fontSize: 110,
                fontWeight: 600,
                color: colors.primary,
                margin: 0,
                marginTop: -10,
                lineHeight: 1.1,
                letterSpacing: "-3px",
                fontFamily: "system-ui, -apple-system, sans-serif",
              }}
            >
              la Formalidad
            </h1>
          </div>

          <p
            style={{
              fontSize: 26,
              color: colors.textSecondary,
              marginTop: 40,
              opacity: taglineProgress,
              transform: `translateY(${interpolate(taglineProgress, [0, 1], [15, 0])}px)`,
              fontWeight: 400,
              letterSpacing: "0.5px",
            }}
          >
            Edición para adultos sin censura 🌶️
          </p>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

// Scene 2: Black Card - Adult prompt
const AdultBlackCardScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const cardProgress = spring({
    frame,
    fps,
    config: { damping: 80, stiffness: 150 },
  });

  const cardY = interpolate(cardProgress, [0, 1], [80, 0]);
  const cardOpacity = interpolate(cardProgress, [0, 1], [0, 1]);
  const cardScale = interpolate(cardProgress, [0, 1], [0.95, 1]);

  return (
    <AbsoluteFill style={{ background: colors.bg }}>
      <GridPattern opacity={0.02} />
      <SoftOrb x="50%" y="50%" size={800} color={colors.primary} />

      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <div
          style={{
            transform: `translateY(${cardY}px) scale(${cardScale})`,
            opacity: cardOpacity,
          }}
        >
          <CleanCard isBlack>
            <div>
              <p
                style={{
                  fontSize: 32,
                  fontWeight: 500,
                  color: colors.textLight,
                  margin: 0,
                  lineHeight: 1.6,
                  fontFamily: "system-ui, -apple-system, sans-serif",
                }}
              >
                Lo que realmente pasa en el grupo de WhatsApp de la familia después de las 2am es
              </p>
              <div
                style={{
                  marginTop: 24,
                  height: 4,
                  width: 180,
                  background: colors.primary,
                  borderRadius: 2,
                }}
              />
            </div>
          </CleanCard>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

// Scene 3: Adult White Cards Selection
const AdultWhiteCardsScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const answers = [
    "Los mensajes borrados del tío",
    "Memes de señora con minions",
    "Fotos de pies 'por error'",
    "Stickers de políticos sin contexto",
  ];

  const selectedIndex = 2;
  const selectionFrame = 65;

  return (
    <AbsoluteFill style={{ background: colors.bg }}>
      <GridPattern />
      <SoftOrb x="0%" y="30%" size={500} color={colors.primary} />
      <SoftOrb x="80%" y="70%" size={400} color={colors.accent} />

      {/* Black card - left side */}
      <div
        style={{
          position: "absolute",
          left: 100,
          top: "50%",
          transform: "translateY(-50%)",
        }}
      >
        <CleanCard isBlack style={{ width: 340, minHeight: 460 }}>
          <div>
            <p
              style={{
                fontSize: 24,
                fontWeight: 500,
                color: colors.textLight,
                margin: 0,
                lineHeight: 1.6,
              }}
            >
              Lo que realmente pasa en el grupo de WhatsApp de la familia después de las 2am es
            </p>
            <div
              style={{
                marginTop: 20,
                height: 3,
                width: 140,
                background: colors.primary,
                borderRadius: 2,
              }}
            />
          </div>
        </CleanCard>
      </div>

      {/* Answer cards - right side */}
      <div
        style={{
          position: "absolute",
          right: 100,
          top: "50%",
          transform: "translateY(-50%)",
          display: "flex",
          flexDirection: "column",
          gap: 16,
        }}
      >
        {answers.map((text, i) => {
          const delay = 8 + i * 8;
          const cardProgress = spring({
            frame: frame - delay,
            fps,
            config: { damping: 80, stiffness: 150 },
          });

          const isSelected = i === selectedIndex && frame > selectionFrame;
          const selectProgress = spring({
            frame: frame - selectionFrame,
            fps,
            config: { damping: 80, stiffness: 150 },
          });

          const cardX = interpolate(cardProgress, [0, 1], [100, 0]);
          const cardOpacity = interpolate(cardProgress, [0, 1], [0, 1]);

          return (
            <div
              key={i}
              style={{
                width: 400,
                padding: "24px 28px",
                background: colors.bgCard,
                borderRadius: 16,
                transform: `translateX(${cardX}px) scale(${isSelected ? interpolate(selectProgress, [0, 1], [1, 1.02]) : 1})`,
                opacity: cardOpacity,
                boxShadow: isSelected
                  ? `0 8px 32px ${colors.primarySoft}, 0 0 0 2px ${colors.primary}`
                  : "0 2px 8px rgba(0,0,0,0.2), 0 8px 24px rgba(0,0,0,0.3)",
                border: isSelected ? "none" : `1px solid ${colors.border}`,
                position: "relative",
              }}
            >
              {isSelected && (
                <div
                  style={{
                    position: "absolute",
                    top: -10,
                    right: -10,
                    width: 32,
                    height: 32,
                    background: colors.primary,
                    borderRadius: "50%",
                    display: "flex",
                    justifyContent: "center",
                    alignItems: "center",
                    opacity: interpolate(selectProgress, [0, 1], [0, 1]),
                    transform: `scale(${interpolate(selectProgress, [0, 1], [0.5, 1])})`,
                  }}
                >
                  <span style={{ color: "white", fontSize: 16 }}>✓</span>
                </div>
              )}
              <p
                style={{
                  fontSize: 18,
                  fontWeight: 500,
                  color: colors.textPrimary,
                  margin: 0,
                  lineHeight: 1.5,
                }}
              >
                {text}
              </p>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

// Scene 4: More Adult Card Examples
const AdultCardShowcaseScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const cardPairs = [
    {
      black: "Mi ex me bloqueó después de enviarle",
      white: "Un audio de 7 minutos llorando",
    },
    {
      black: "El secreto del éxito de mi matrimonio es",
      white: "Audífonos con cancelación de ruido",
    },
  ];

  const currentPair = Math.floor(frame / (2 * fps)) % cardPairs.length;
  const pairFrame = frame % (2 * fps);

  const cardProgress = spring({
    frame: pairFrame,
    fps,
    config: { damping: 80, stiffness: 150 },
  });

  const whiteCardProgress = spring({
    frame: pairFrame - 25,
    fps,
    config: { damping: 80, stiffness: 150 },
  });

  return (
    <AbsoluteFill style={{ background: colors.bg }}>
      <GridPattern />
      <SoftOrb x="20%" y="30%" size={600} color={colors.primary} />
      <SoftOrb x="70%" y="60%" size={500} color="#ff3366" />

      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <div style={{ display: "flex", gap: 40, alignItems: "center" }}>
          {/* Black Card */}
          <div
            style={{
              transform: `translateY(${interpolate(cardProgress, [0, 1], [60, 0])}px)`,
              opacity: interpolate(cardProgress, [0, 1], [0, 1]),
            }}
          >
            <CleanCard isBlack style={{ width: 360, minHeight: 480 }}>
              <div>
                <p
                  style={{
                    fontSize: 28,
                    fontWeight: 500,
                    color: colors.textLight,
                    margin: 0,
                    lineHeight: 1.6,
                  }}
                >
                  {cardPairs[currentPair].black}
                </p>
                <div
                  style={{
                    marginTop: 24,
                    height: 4,
                    width: 160,
                    background: colors.primary,
                    borderRadius: 2,
                  }}
                />
              </div>
            </CleanCard>
          </div>

          {/* Plus sign */}
          <div
            style={{
              fontSize: 60,
              color: colors.primary,
              fontWeight: 300,
              opacity: interpolate(whiteCardProgress, [0, 1], [0, 1]),
            }}
          >
            +
          </div>

          {/* White Card */}
          <div
            style={{
              transform: `translateY(${interpolate(whiteCardProgress, [0, 1], [60, 0])}px)`,
              opacity: interpolate(whiteCardProgress, [0, 1], [0, 1]),
            }}
          >
            <CleanCard style={{ width: 360, minHeight: 480 }}>
              <div>
                <p
                  style={{
                    fontSize: 28,
                    fontWeight: 500,
                    color: colors.textLight,
                    margin: 0,
                    lineHeight: 1.6,
                  }}
                >
                  {cardPairs[currentPair].white}
                </p>
              </div>
            </CleanCard>
          </div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

// Scene 5: Party Mode Features
const AdultFeaturesScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const features = [
    { icon: "🌶️", title: "Contenido picante", desc: "Sin filtros ni censura" },
    { icon: "🍺", title: "Modo borrachera", desc: "Reglas especiales para fiestas" },
    { icon: "🔞", title: "Solo +18", desc: "Verificación de edad obligatoria" },
    { icon: "😈", title: "Cartas secretas", desc: "Las que no puedes leer en voz alta" },
  ];

  const titleProgress = spring({
    frame,
    fps,
    config: { damping: 80, stiffness: 150 },
  });

  return (
    <AbsoluteFill style={{ background: colors.bg }}>
      <GridPattern />
      <SoftOrb x="20%" y="20%" size={500} color={colors.accent} />
      <SoftOrb x="80%" y="80%" size={400} color={colors.primary} />

      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <div
          style={{
            transform: `translateY(${interpolate(titleProgress, [0, 1], [20, 0])}px)`,
            opacity: interpolate(titleProgress, [0, 1], [0, 1]),
            marginBottom: 60,
          }}
        >
          <h2
            style={{
              fontSize: 56,
              fontWeight: 600,
              color: colors.textPrimary,
              margin: 0,
              textAlign: "center",
              letterSpacing: "-1px",
            }}
          >
            Para noches{" "}
            <span style={{ color: colors.primary }}>memorables</span>
          </h2>
        </div>

        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(2, 1fr)",
            gap: 24,
          }}
        >
          {features.map((feature, i) => {
            const delay = 15 + i * 10;
            const featureProgress = spring({
              frame: frame - delay,
              fps,
              config: { damping: 60, stiffness: 120 },
            });

            const featureY = interpolate(featureProgress, [0, 1], [30, 0]);
            const featureOpacity = interpolate(featureProgress, [0, 1], [0, 1]);

            return (
              <div
                key={i}
                style={{
                  width: 380,
                  padding: 32,
                  background: colors.bgCard,
                  borderRadius: 20,
                  transform: `translateY(${featureY}px)`,
                  opacity: featureOpacity,
                  boxShadow: "0 2px 8px rgba(0,0,0,0.2), 0 8px 24px rgba(0,0,0,0.3)",
                  border: `1px solid ${colors.border}`,
                  display: "flex",
                  gap: 20,
                  alignItems: "flex-start",
                }}
              >
                <div
                  style={{
                    width: 56,
                    height: 56,
                    borderRadius: 14,
                    background: colors.bgSubtle,
                    display: "flex",
                    justifyContent: "center",
                    alignItems: "center",
                    fontSize: 28,
                    flexShrink: 0,
                  }}
                >
                  {feature.icon}
                </div>
                <div>
                  <h3
                    style={{
                      fontSize: 22,
                      fontWeight: 600,
                      color: colors.textPrimary,
                      margin: 0,
                      marginBottom: 6,
                    }}
                  >
                    {feature.title}
                  </h3>
                  <p
                    style={{
                      fontSize: 16,
                      color: colors.textSecondary,
                      margin: 0,
                      lineHeight: 1.5,
                    }}
                  >
                    {feature.desc}
                  </p>
                </div>
              </div>
            );
          })}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

// Scene 6: Adult CTA
const AdultCTAScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const titleProgress = spring({
    frame,
    fps,
    config: { damping: 80, stiffness: 150 },
  });

  const buttonProgress = spring({
    frame: frame - 20,
    fps,
    config: { damping: 60, stiffness: 120 },
  });

  const pulse = Math.sin(frame * 0.08) * 0.015 + 1;

  return (
    <AbsoluteFill style={{ background: colors.primary }}>
      <GridPattern opacity={0.05} />
      <SoftOrb x="30%" y="30%" size={600} color="#ffffff" />
      <SoftOrb x="70%" y="70%" size={500} color="#ff3366" />

      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <div
          style={{
            textAlign: "center",
            transform: `translateY(${interpolate(titleProgress, [0, 1], [30, 0])}px)`,
            opacity: interpolate(titleProgress, [0, 1], [0, 1]),
          }}
        >
          <div style={{ fontSize: 60, marginBottom: 20 }}>🔞🌶️😈</div>

          <h2
            style={{
              fontSize: 72,
              fontWeight: 600,
              color: colors.textLight,
              margin: 0,
              letterSpacing: "-2px",
            }}
          >
            ¿Te atreves?
          </h2>

          <p
            style={{
              fontSize: 24,
              color: "rgba(255,255,255,0.8)",
              marginTop: 20,
              marginBottom: 50,
              fontWeight: 400,
            }}
          >
            El juego de cartas más atrevido de Latinoamérica
          </p>

          <div
            style={{
              transform: `translateY(${interpolate(buttonProgress, [0, 1], [20, 0])}px) scale(${interpolate(buttonProgress, [0, 1], [0.9, 1]) * pulse})`,
              opacity: interpolate(buttonProgress, [0, 1], [0, 1]),
            }}
          >
            <div
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: 12,
                background: colors.bg,
                padding: "24px 48px",
                borderRadius: 16,
                boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
              }}
            >
              <span
                style={{
                  fontSize: 28,
                  fontWeight: 600,
                  color: colors.primary,
                }}
              >
                Jugar ahora
              </span>
              <span style={{ fontSize: 24 }}>🔥</span>
            </div>
          </div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

// Main composition
export const AdultPromo = () => {
  const { fps } = useVideoConfig();
  const transitionDuration = Math.round(0.5 * fps);

  return (
    <TransitionSeries>
      <TransitionSeries.Sequence durationInFrames={3 * fps}>
        <AdultTitleScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      <TransitionSeries.Sequence durationInFrames={2.5 * fps}>
        <AdultBlackCardScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      <TransitionSeries.Sequence durationInFrames={3 * fps}>
        <AdultWhiteCardsScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      <TransitionSeries.Sequence durationInFrames={4 * fps}>
        <AdultCardShowcaseScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      <TransitionSeries.Sequence durationInFrames={3 * fps}>
        <AdultFeaturesScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      <TransitionSeries.Sequence durationInFrames={3 * fps}>
        <AdultCTAScene />
      </TransitionSeries.Sequence>
    </TransitionSeries>
  );
};
