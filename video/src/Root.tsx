import { Composition } from "remotion";
import { AppPromo } from "./AppPromo";
import { AdultPromo } from "./AdultPromo";
import { AdultPromo2 } from "./AdultPromo2";
import { AdultPromo3 } from "./AdultPromo3";
import { AdultPromo4 } from "./AdultPromo4";
import { AdultPromo5 } from "./AdultPromo5";
import { AdultPromo6 } from "./AdultPromo6";

export const RemotionRoot = () => {
  return (
    <>
      <Composition
        id="AppPromo"
        component={AppPromo}
        durationInFrames={450}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="AdultPromo"
        component={AdultPromo}
        durationInFrames={540}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="AdultPromo2-Citas"
        component={AdultPromo2}
        durationInFrames={780}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="AdultPromo3-Dinero"
        component={AdultPromo3}
        durationInFrames={780}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="AdultPromo4-Familia"
        component={AdultPromo4}
        durationInFrames={780}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="AdultPromo5-Oficina"
        component={AdultPromo5}
        durationInFrames={780}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="AdultPromo6-Fiesta"
        component={AdultPromo6}
        durationInFrames={780}
        fps={30}
        width={1920}
        height={1080}
      />
    </>
  );
};
