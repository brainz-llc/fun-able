import { Composition } from "remotion";
import { AppPromo } from "./AppPromo";

export const RemotionRoot = () => {
  return (
    <Composition
      id="AppPromo"
      component={AppPromo}
      durationInFrames={450}
      fps={30}
      width={1920}
      height={1080}
    />
  );
};
