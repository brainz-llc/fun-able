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
import { slide } from "@remotion/transitions/slide";

// Anthropic-inspired color palette (keeping app's identity)
const colors = {
  // Primary brand
  primary: "#e94560",
  primaryMuted: "#e9456020",
  primarySoft: "#e9456040",

  // Backgrounds - warm, sophisticated
  bg: "#faf9f7",
  bgDark: "#0d0d0f",
  bgCard: "#ffffff",
  bgSubtle: "#f5f4f2",

  // Text
  textPrimary: "#1a1a1a",
  textSecondary: "#6b6b6b",
  textMuted: "#9a9a9a",
  textLight: "#ffffff",

  // Accents
  accent: "#ff8a8a",
  border: "rgba(0,0,0,0.08)",
  borderLight: "rgba(255,255,255,0.1)",

  // Shadows
  shadow: "rgba(0,0,0,0.04)",
  shadowMedium: "rgba(0,0,0,0.08)",
  shadowDark: "rgba(0,0,0,0.15)",
};

// Subtle grid pattern overlay
const GridPattern = ({ opacity = 0.03 }: { opacity?: number }) => (
  <div
    style={{
      position: "absolute",
      inset: 0,
      opacity,
      backgroundImage: `
        linear-gradient(rgba(0,0,0,0.03) 1px, transparent 1px),
        linear-gradient(90deg, rgba(0,0,0,0.03) 1px, transparent 1px)
      `,
      backgroundSize: "60px 60px",
    }}
  />
);

// Soft gradient orb (Anthropic-style)
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
      background: `radial-gradient(circle, ${color}30 0%, transparent 70%)`,
      filter: "blur(60px)",
      pointerEvents: "none",
    }}
  />
);

// Clean card component (Anthropic-style)
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
      background: isBlack ? colors.bgDark : colors.bgCard,
      borderRadius: 20,
      padding: 36,
      display: "flex",
      flexDirection: "column",
      justifyContent: "space-between",
      boxShadow: isBlack
        ? "0 25px 50px rgba(0,0,0,0.5)"
        : "0 4px 6px rgba(0,0,0,0.02), 0 12px 24px rgba(0,0,0,0.04), 0 24px 48px rgba(0,0,0,0.06)",
      border: isBlack ? "none" : `1px solid ${colors.border}`,
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
        borderTop: `1px solid ${isBlack ? colors.borderLight : colors.border}`,
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
          color: isBlack ? colors.textMuted : colors.textSecondary,
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

// Scene 1: Title Screen - Clean, centered typography
const TitleScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const titleProgress = spring({
    frame,
    fps,
    config: { damping: 100, stiffness: 200 },
  });

  const titleY = interpolate(titleProgress, [0, 1], [40, 0]);
  const titleOpacity = interpolate(titleProgress, [0, 1], [0, 1]);

  const subtitleProgress = spring({
    frame: frame - 15,
    fps,
    config: { damping: 100, stiffness: 200 },
  });

  const taglineProgress = interpolate(
    frame,
    [1.5 * fps, 2 * fps],
    [0, 1],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.quad) }
  );

  return (
    <AbsoluteFill style={{ background: colors.bg }}>
      <GridPattern />

      <SoftOrb x="10%" y="20%" size={600} color={colors.primary} />
      <SoftOrb x="70%" y="60%" size={500} color={colors.accent} />

      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <div style={{ textAlign: "center", maxWidth: 1200 }}>
          <div
            style={{
              transform: `translateY(${titleY}px)`,
              opacity: titleOpacity,
            }}
          >
            <h1
              style={{
                fontSize: 120,
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
                fontSize: 120,
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
              fontSize: 24,
              color: colors.textSecondary,
              marginTop: 40,
              opacity: taglineProgress,
              transform: `translateY(${interpolate(taglineProgress, [0, 1], [15, 0])}px)`,
              fontWeight: 400,
              letterSpacing: "0.5px",
            }}
          >
            El juego de cartas más irreverente de Latinoamérica
          </p>
        </div>
      </AbsoluteFill>

      {/* Subtle decorative elements */}
      <div
        style={{
          position: "absolute",
          bottom: 80,
          left: "50%",
          transform: "translateX(-50%)",
          display: "flex",
          gap: 8,
          opacity: taglineProgress * 0.4,
        }}
      >
        {[...Array(3)].map((_, i) => (
          <div
            key={i}
            style={{
              width: 6,
              height: 6,
              borderRadius: "50%",
              background: colors.primary,
            }}
          />
        ))}
      </div>
    </AbsoluteFill>
  );
};

// Scene 2: Black Card Reveal - Elegant entrance
const BlackCardScene = () => {
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
    <AbsoluteFill style={{ background: colors.bgDark }}>
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
                Lo que más me gusta de las fiestas familiares es
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

// Scene 3: White Cards - Clean layout with selection
const WhiteCardsScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const answers = [
    "Fingir que no escuchaste el comentario del abuelo",
    "Un reggaetón bien duro",
    "La tía borracha bailando sola",
    "Pretender que estudias",
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
                fontSize: 26,
                fontWeight: 500,
                color: colors.textLight,
                margin: 0,
                lineHeight: 1.6,
              }}
            >
              Lo que más me gusta de las fiestas familiares es
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
                  : "0 2px 8px rgba(0,0,0,0.04), 0 8px 24px rgba(0,0,0,0.06)",
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

// Scene 4: Multiplayer - Clean player avatars
const MultiplayerScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const players = [
    { flag: "🇨🇴", name: "Carlos", initials: "CA" },
    { flag: "🇲🇽", name: "María", initials: "MA" },
    { flag: "🇦🇷", name: "Diego", initials: "DI" },
    { flag: "🇪🇸", name: "Sofía", initials: "SO" },
    { flag: "🇵🇪", name: "Ana", initials: "AN" },
  ];

  const titleProgress = spring({
    frame,
    fps,
    config: { damping: 80, stiffness: 150 },
  });

  return (
    <AbsoluteFill style={{ background: colors.bg }}>
      <GridPattern />

      <SoftOrb x="50%" y="0%" size={700} color={colors.primary} />

      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <div
          style={{
            transform: `translateY(${interpolate(titleProgress, [0, 1], [30, 0])}px)`,
            opacity: interpolate(titleProgress, [0, 1], [0, 1]),
            textAlign: "center",
            marginBottom: 80,
          }}
        >
          <h2
            style={{
              fontSize: 64,
              fontWeight: 600,
              color: colors.textPrimary,
              margin: 0,
              letterSpacing: "-2px",
            }}
          >
            Juega con amigos de
          </h2>
          <h2
            style={{
              fontSize: 64,
              fontWeight: 600,
              color: colors.primary,
              margin: 0,
              marginTop: 8,
              letterSpacing: "-2px",
            }}
          >
            toda Latinoamérica
          </h2>
        </div>

        <div style={{ display: "flex", gap: 40 }}>
          {players.map((player, i) => {
            const delay = 20 + i * 10;
            const playerProgress = spring({
              frame: frame - delay,
              fps,
              config: { damping: 60, stiffness: 120 },
            });

            const playerY = interpolate(playerProgress, [0, 1], [40, 0]);
            const playerOpacity = interpolate(playerProgress, [0, 1], [0, 1]);

            // Subtle floating animation
            const float = Math.sin(frame * 0.04 + i * 1.2) * 4;

            return (
              <div
                key={i}
                style={{
                  display: "flex",
                  flexDirection: "column",
                  alignItems: "center",
                  gap: 16,
                  transform: `translateY(${playerY + float}px)`,
                  opacity: playerOpacity,
                }}
              >
                <div
                  style={{
                    width: 100,
                    height: 100,
                    borderRadius: 24,
                    background: colors.bgCard,
                    display: "flex",
                    justifyContent: "center",
                    alignItems: "center",
                    fontSize: 40,
                    boxShadow: "0 4px 12px rgba(0,0,0,0.06), 0 12px 32px rgba(0,0,0,0.08)",
                    border: `1px solid ${colors.border}`,
                  }}
                >
                  {player.flag}
                </div>
                <span
                  style={{
                    fontSize: 18,
                    color: colors.textPrimary,
                    fontWeight: 500,
                  }}
                >
                  {player.name}
                </span>
              </div>
            );
          })}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

// Scene 5: Features - Clean grid layout
const FeaturesScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const features = [
    { icon: "🎴", title: "Mazos personalizados", desc: "Crea y comparte tus propios mazos" },
    { icon: "⏱", title: "Turnos dinámicos", desc: "Temporizador configurable por partida" },
    { icon: "🏆", title: "Sistema de ranking", desc: "Compite por el primer lugar" },
    { icon: "🌎", title: "Contenido regional", desc: "Humor auténtico de tu país" },
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
            Todo lo que necesitas
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
                  boxShadow: "0 2px 8px rgba(0,0,0,0.02), 0 8px 24px rgba(0,0,0,0.04)",
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

// Scene 6: CTA - Clean, bold ending
const CTAScene = () => {
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

  // Subtle pulse for button
  const pulse = Math.sin(frame * 0.08) * 0.015 + 1;

  return (
    <AbsoluteFill style={{ background: colors.primary }}>
      <GridPattern opacity={0.05} />

      <SoftOrb x="30%" y="30%" size={600} color="#ffffff" />
      <SoftOrb x="70%" y="70%" size={500} color={colors.accent} />

      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <div
          style={{
            textAlign: "center",
            transform: `translateY(${interpolate(titleProgress, [0, 1], [30, 0])}px)`,
            opacity: interpolate(titleProgress, [0, 1], [0, 1]),
          }}
        >
          <h2
            style={{
              fontSize: 80,
              fontWeight: 600,
              color: colors.textLight,
              margin: 0,
              letterSpacing: "-2px",
            }}
          >
            ¿Listo para jugar?
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
            Únete a miles de jugadores en toda Latinoamérica
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
                background: colors.bgCard,
                padding: "24px 48px",
                borderRadius: 16,
                boxShadow: "0 8px 32px rgba(0,0,0,0.15)",
              }}
            >
              <span
                style={{
                  fontSize: 28,
                  fontWeight: 600,
                  color: colors.primary,
                }}
              >
                Comenzar a jugar
              </span>
              <span style={{ fontSize: 24 }}>→</span>
            </div>
          </div>
        </div>
      </AbsoluteFill>

      {/* Corner decoration */}
      <div
        style={{
          position: "absolute",
          bottom: 40,
          left: "50%",
          transform: "translateX(-50%)",
          display: "flex",
          gap: 6,
          opacity: 0.3,
        }}
      >
        {[...Array(5)].map((_, i) => (
          <div
            key={i}
            style={{
              width: 4,
              height: 4,
              borderRadius: "50%",
              background: "white",
            }}
          />
        ))}
      </div>
    </AbsoluteFill>
  );
};

// Main composition
export const AppPromo = () => {
  const { fps } = useVideoConfig();
  const transitionDuration = Math.round(0.5 * fps);

  return (
    <TransitionSeries>
      <TransitionSeries.Sequence durationInFrames={3 * fps}>
        <TitleScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      <TransitionSeries.Sequence durationInFrames={2.5 * fps}>
        <BlackCardScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      <TransitionSeries.Sequence durationInFrames={3 * fps}>
        <WhiteCardsScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      <TransitionSeries.Sequence durationInFrames={3 * fps}>
        <MultiplayerScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      <TransitionSeries.Sequence durationInFrames={3 * fps}>
        <FeaturesScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      <TransitionSeries.Sequence durationInFrames={3 * fps}>
        <CTAScene />
      </TransitionSeries.Sequence>
    </TransitionSeries>
  );
};
