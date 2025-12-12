import * as preact from "/js/common/lib/preact.js";
import * as Engine from "/js/common/core/Engine.js";
import * as Focus from "/js/common/core/Focus.js";
import * as Format from "/js/common/util/LocalisationUtil.js";
import * as Focusable from "/js/common/components/Focusable.js";
import { loadCSS } from "/js/common/util/CSSUtil.js";
import { classNames } from "/js/common/lib/classnames.js";
import { Panel } from "/js/project/components/panel/Panel.js";
import { InputName } from "/js/common/core/InputTypes.js";

import { PanelArea, PanelHeader } from "/js/project/components/PanelShared.js";
import { SliderRow } from "/js/project/components/SliderRow.js";
import { ToggleRow } from "/js/project/components/ToggleRow.js";
import { FocusableDataRow } from "/js/project/components/DataRow.js";
import { ScrollPane } from "/js/common/components/ScrollPane.js";
import { Tab } from "/js/common/components/Tab.js";

import { Button } from "/js/project/components/Button.js";

import { SkyStudioButton } from "/SkyStudioButton.js";

const DEBUG_MODE = false;

loadCSS("project/Shared");
// loadCSS("project/components/Slider");
// loadCSS('project/components/Button');

// Values to pass back to lua
type Config = {
  bUseVanillaLighting: boolean;

  nUserSunAzimuth: number;
  nUserSunLatitudeOffset: number;
  nUserSunTimeOfDay: number;
  nUserSunColorR: number;
  nUserSunColorG: number;
  nUserSunColorB: number;
  nUserSunIntensity: number;
  nUserSunGroundMultiplier: number;
  bUserSunUseLinearColors: number; // still numeric for now, not hooked to a ToggleRow

  nUserMoonAzimuth: number;
  nUserMoonLatitudeOffset: number;
  nUserMoonPhase: number;
  nUserMoonColorR: number;
  nUserMoonColorG: number;
  nUserMoonColorB: number;
  nUserMoonIntensity: number;
  nUserMoonGroundMultiplier: number;
  bUserMoonUseLinearColors: number; // same as above

  nUserDayNightTransition: number;
  nUserSunFade: number;
  nUserMoonFade: number;

  bUserOverrideSunTimeOfDay: boolean;
  bUserOverrideSunOrientation: boolean;
  bUserOverrideSunColorAndIntensity: boolean;
  bUserOverrideMoonOrientation: boolean;
  bUserOverrideMoonPhase: boolean;
  bUserOverrideMoonColorAndIntensity: boolean;

  bUserOverrideSunFade: boolean;
  bUserOverrideMoonFade: boolean;

  bUserOverrideDayNightTransition: boolean;
};

type State = {
  config: Config;
  defaultConfig: Config | {};

  visible: boolean;
  controlsVisible?: boolean;

  visibleTabIndex: number;

  focusDebugKey?: string;

  // reset confirmation flags
  confirmResetSun?: boolean;
  confirmResetMoon?: boolean;
  confirmResetAll?: boolean;
};

const baseConfig = {
  bUseVanillaLighting: false,

  nUserSunAzimuth: 0,
  nUserSunLatitudeOffset: 0,
  nUserSunTimeOfDay: 0,
  nUserSunColorR: 0,
  nUserSunColorG: 0,
  nUserSunColorB: 0,
  nUserSunIntensity: 0,
  nUserSunGroundMultiplier: 0,
  bUserSunUseLinearColors: 0,

  nUserMoonAzimuth: 0,
  nUserMoonLatitudeOffset: 0,
  nUserMoonPhase: 0,
  nUserMoonColorR: 0,
  nUserMoonColorG: 0,
  nUserMoonColorB: 0,
  nUserMoonIntensity: 0,
  nUserMoonGroundMultiplier: 0,
  bUserMoonUseLinearColors: 0,

  nUserDayNightTransition: 0,
  nUserSunFade: 0,
  nUserMoonFade: 0,

  bUserOverrideSunTimeOfDay: false,
  bUserOverrideSunOrientation: false,
  bUserOverrideSunColorAndIntensity: false,
  bUserOverrideMoonOrientation: false,
  bUserOverrideMoonPhase: false,
  bUserOverrideMoonColorAndIntensity: false,

  bUserOverrideSunFade: false,
  bUserOverrideMoonFade: false,

  bUserOverrideDayNightTransition: false,
};

let focusDebuginterval: number;

type ColorPickerRowProps = {
  label: string;
  r: number;
  g: number;
  b: number;
  disabled?: boolean;
};

// Full-width, 32px tall color swatch; editing is via RGB sliders below
const ColorPickerRow: preact.FunctionComponent<ColorPickerRowProps> = ({
  label,
  r,
  g,
  b,
  disabled,
}) => {
  const clamp01 = (v: number) => Math.max(0, Math.min(1, isNaN(v) ? 0 : v));
  const r255 = Math.round(clamp01(r) * 255);
  const g255 = Math.round(clamp01(g) * 255);
  const b255 = Math.round(clamp01(b) * 255);

  const swatchStyle: preact.JSX.CSSProperties = {
    width: "100%",
    height: "4rem",
    borderRadius: "2px",
    border: "1px solid rgba(255,255,255,0.25)",
    backgroundColor: `rgb(${r255}, ${g255}, ${b255})`,
    boxSizing: "border-box",
    opacity: disabled ? 0.4 : 1,
  };

  return (
    <FocusableDataRow
      label={label}
      disabled={disabled}
      modifiers={classNames("rowControlChildren", "skystudio_colorRow")}
    >
      <div className="skystudio_colorRow_swatchWrapper">
        <div className="skystudio_colorRow_swatch" style={swatchStyle} />
      </div>
    </FocusableDataRow>
  );
};

class _SkyStudioUI extends preact.Component<{}, State> {
  state: State = {
    visible: false,
    controlsVisible: false,
    visibleTabIndex: 0,
    focusDebugKey: "",

    // Everything in config are values that can be passed back to the lua manager
    config: {
      ...baseConfig,
    },

    // This will be populated from the engine, but won't change when the user makes changes
    // Used for "reset" buttons
    defaultConfig: {
      ...baseConfig,
    },

    confirmResetSun: false,
    confirmResetMoon: false,
    confirmResetAll: false,
  };

  componentWillMount() {
    Engine.addListener("Show", this.onShow);
    Engine.addListener("Hide", this.onHide);

    focusDebuginterval = window.setInterval(this.updateFocusDebug, 250);
  }

  componentWillUnmount() {
    Engine.removeListener("Show", this.onShow);
    Engine.removeListener("Hide", this.onHide);

    clearInterval(focusDebuginterval);
  }

  updateFocusDebug = () => {
    this.setState({
      ...this.state,
      focusDebugKey: `${Focus.toDebugFocusKey(Focus.get())}`,
    });
  };

  onShow = (data: Config) => {
    this.setState({
      ...this.state,
      visible: true,
      controlsVisible: false,
      config: {
        ...data,
      },
      defaultConfig: {
        ...data,
      },
    });
  };

  onHide = () => this.setState({ visible: false });

  onNumericalValueChanged = (key: keyof Config, newValue: number) => {
    this.setState({
      config: {
        ...this.state.config,
        [key]: newValue,
      },
    });
    Engine.sendEvent(`SkyStudioChangedValue_${key}`, newValue);
  };

  onToggleValueChanged =
    (key: keyof Config) =>
    (toggled: boolean): void => {
      this.setState({
        config: {
          ...this.state.config,
          [key]: toggled,
        },
      });
      Engine.sendEvent(`SkyStudioChangedValue_${key}`, toggled);
    };

  handleToggleControls = (value?: boolean) => {
    this.setState({
      controlsVisible:
        value !== undefined ? value : !this.state.controlsVisible,
      confirmResetAll: false,
      confirmResetMoon: false,
      confirmResetSun: false,
    });
  };

  changeVisibleTab = (visibleIndex: number) => {
    this.setState({
      visibleTabIndex: visibleIndex,
      confirmResetAll: false,
      confirmResetMoon: false,
      confirmResetSun: false,
    });
  };

  // Override input handling on the panel
  // This prevents the escape key from getting stuck opening and closing the panel when the sliders / panel content are in focus
  handlePanelInput = (e) => {
    if (!e.button || !e.button.isPressed(true)) return false;

    if (e.inputName === InputName.Cancel || e.inputName === InputName.Back) {
      Focus.set("");
      this.handleToggleControls(false);
      return true;
    }

    return false;
  };

  // Begin / cancel confirmation flows
  beginResetSun = () => {
    this.setState({ confirmResetSun: true });
  };

  cancelResetSun = () => {
    this.setState({ confirmResetSun: false });
  };

  beginResetMoon = () => {
    this.setState({ confirmResetMoon: true });
  };

  cancelResetMoon = () => {
    this.setState({ confirmResetMoon: false });
  };

  beginResetAll = () => {
    this.setState({ confirmResetAll: true });
  };

  cancelResetAll = () => {
    this.setState({ confirmResetAll: false });
  };

  // Core reset logic helpers
  private resetSunToDefault = () => {
    const defaultConfig = this.state.defaultConfig;

    // All sun-related values in the "Sun Color" tab, including its fade override
    const sunKeys = [
      "nUserSunColorR",
      "nUserSunColorG",
      "nUserSunColorB",
      "nUserSunIntensity",
      "nUserSunGroundMultiplier",
      "nUserSunFade",
    ];

    const newConfig = { ...this.state.config };

    sunKeys.forEach((key) => {
      newConfig[key] = defaultConfig[key];
    });

    this.setState({
      config: newConfig,
      confirmResetSun: false,
    });

    Engine.sendEvent("SkyStudio_ResetSun");
  };

  private resetMoonToDefault = () => {
    const defaultConfig = this.state.defaultConfig;

    // All moon-related values in the "Moon Color" tab, including its fade override
    const moonKeys = [
      "nUserMoonColorR",
      "nUserMoonColorG",
      "nUserMoonColorB",
      "nUserMoonIntensity",
      "nUserMoonGroundMultiplier",
      "nUserMoonFade",
    ];

    const newConfig: Config = { ...this.state.config };

    moonKeys.forEach((key) => {
      newConfig[key] = defaultConfig[key];
    });

    this.setState({
      config: newConfig,
      confirmResetMoon: false,
    });

    Engine.sendEvent("SkyStudio_ResetMoon");
  };

  private resetAllToDefault = () => {
    const keysToReset = [
      "nUserSunAzimuth",
      "nUserSunLatitudeOffset",
      "nUserSunTimeOfDay",
      "nUserSunColorR",
      "nUserSunColorG",
      "nUserSunColorB",
      "nUserSunIntensity",
      "nUserSunGroundMultiplier",

      "nUserMoonAzimuth",
      "nUserMoonLatitudeOffset",
      "nUserMoonPhase",
      "nUserMoonColorR",
      "nUserMoonColorG",
      "nUserMoonColorB",
      "nUserMoonIntensity",
      "nUserMoonGroundMultiplier",

      "nUserDayNightTransition",
      "nUserSunFade",
      "nUserMoonFade",
    ];

    const defaultConfig = this.state.defaultConfig;

    const newConfig = { ...this.state.config };

    // Send an engine event for every config key
    keysToReset.forEach((key) => {
      newConfig[key] = defaultConfig[key];
    });

    this.setState({
      config: newConfig,
      confirmResetSun: false,
      confirmResetMoon: false,
      confirmResetAll: false,
    });

    Engine.sendEvent("SkyStudio_ResetAll");
  };

  render() {
    const {
      bUseVanillaLighting,

      nUserSunTimeOfDay,
      nUserSunAzimuth,
      nUserSunLatitudeOffset,
      nUserSunColorR,
      nUserSunColorG,
      nUserSunColorB,
      nUserSunIntensity,
      nUserSunGroundMultiplier,

      nUserMoonAzimuth,
      nUserMoonLatitudeOffset,
      nUserMoonPhase,
      nUserMoonColorR,
      nUserMoonColorG,
      nUserMoonColorB,
      nUserMoonIntensity,
      nUserMoonGroundMultiplier,

      nUserDayNightTransition,
      nUserSunFade,
      nUserMoonFade,

      bUserOverrideSunTimeOfDay,
      bUserOverrideSunOrientation,
      bUserOverrideSunColorAndIntensity,
      bUserOverrideMoonOrientation,
      bUserOverrideMoonPhase,
      bUserOverrideMoonColorAndIntensity,

      bUserOverrideSunFade,
      bUserOverrideMoonFade,

      bUserOverrideDayNightTransition,
    } = this.state.config;

    const visibleTabIndex = this.state.visibleTabIndex;

    const useVanillaLighting = bUseVanillaLighting;
    const customLightingEnabled = !useVanillaLighting;

    const sunTimeOverrideOn = bUserOverrideSunTimeOfDay;
    const sunOrientationOverrideOn = bUserOverrideSunOrientation;
    const sunColorOverrideOn = bUserOverrideSunColorAndIntensity;

    const moonOrientationOverrideOn = bUserOverrideMoonOrientation;
    const moonPhaseOverrideOn = bUserOverrideMoonPhase;
    const moonColorOverrideOn = bUserOverrideMoonColorAndIntensity;

    const dayNightOverrideOn = bUserOverrideDayNightTransition;

    const sunFadeOverrideOn = bUserOverrideSunFade;
    const moonFadeOverrideOn = bUserOverrideMoonFade;

    const showResetConfirmation =
      this.state.confirmResetAll ||
      this.state.confirmResetMoon ||
      this.state.confirmResetSun;

    const tabs = [
      <Tab
        key="time"
        icon={"img/icons/clock.svg"}
        label={Format.stringLiteral("Time of Day")}
        outcome="SkyStudio_Tab_Time"
      />,
      <Tab
        key="suncolor"
        icon={"img/icons/sun.svg"}
        label={Format.stringLiteral("Sun Color")}
        outcome="SkyStudio_Tab_Sun_Color"
      />,
      <Tab
        key="mooncolor"
        icon={"img/icons/moon.svg"}
        label={Format.stringLiteral("Moon Color")}
        outcome="SkyStudio_Tab_Moon_Color"
      />,
      <Tab
        key="other"
        icon={"img/icons/dataList.svg"}
        label={Format.stringLiteral("Miscellaneous")}
        outcome="SkyStudio_Tab_Other"
      />,
    ];

    const tabViews = [
      // TAB 0: Time of day + day/night transition
      <div key="time" className="skystudio_scrollPane">
        <PanelArea modifiers="skystudio_section">
          <ToggleRow
            label={Format.stringLiteral("Override Time of Day")}
            toggled={sunTimeOverrideOn}
            onToggle={this.onToggleValueChanged("bUserOverrideSunTimeOfDay")}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
          />

          <SliderRow
            label={Format.stringLiteral("Time of Day")}
            min={0}
            max={24}
            step={0.01}
            value={nUserSunTimeOfDay}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserSunTimeOfDay",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !sunTimeOverrideOn}
            focusable={true}
          />

          <ToggleRow
            label={Format.stringLiteral("Override Moon Phase")}
            toggled={moonPhaseOverrideOn}
            onToggle={this.onToggleValueChanged("bUserOverrideMoonPhase")}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
          />

          <SliderRow
            label={Format.stringLiteral("Moon Phase")}
            min={0}
            max={360}
            step={0.01}
            value={nUserMoonPhase}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged("nUserMoonPhase", newValue as number)
            }
            editable={true}
            disabled={!customLightingEnabled || !moonPhaseOverrideOn}
            focusable={true}
          />
        </PanelArea>
        <PanelArea modifiers="skystudio_section">
          {/* Mixed feelings on binding the sun and moon orientation toggles together */}
          {/* but I can't imagine why you'd want to override one without the other */}
          {/* since this basically controls the park's theoretical coordinates on the earth which affects both sun and moon position in the sky */}
          <ToggleRow
            label={Format.stringLiteral("Override Sun & Moon Orientation")}
            toggled={sunOrientationOverrideOn}
            onToggle={(value) => {
              this.onToggleValueChanged("bUserOverrideSunOrientation")(value);
              this.onToggleValueChanged("bUserOverrideMoonOrientation")(value);
            }}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
          />

          <SliderRow
            label={Format.stringLiteral("Sun Azimuth")}
            min={0}
            max={360}
            step={1}
            value={nUserSunAzimuth}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserSunAzimuth",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !sunOrientationOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Sun Latitude Offset")}
            min={-90}
            max={90}
            step={1}
            value={nUserSunLatitudeOffset}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserSunLatitudeOffset",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !sunOrientationOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Moon Azimuth Offset")}
            min={-30}
            max={30}
            step={1}
            value={nUserMoonAzimuth}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserMoonAzimuth",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !moonOrientationOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Moon Latitude Offset")}
            min={-90}
            max={90}
            step={1}
            value={nUserMoonLatitudeOffset}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserMoonLatitudeOffset",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !moonOrientationOverrideOn}
            focusable={true}
          />
        </PanelArea>
      </div>,

      // <div key="orientation" className="skystudio_scrollPane">
      //    This section moved to Time of Day for now
      // </div>,

      // TAB 2: Sun color + intensity
      <div key="suncolor" className="skystudio_scrollPane">
        {this.state.confirmResetSun && (
          <div className={"skystudio_confirm_modal"}>
            <div>
              <div className={"skystudio_reset_header"}>
                Reset Sun Color/Intensity/Fade to Default?
              </div>
              <div className={"skystudio_reset_confirm_buttons"}>
                <Button
                  label={Format.stringLiteral("Confirm")}
                  onSelect={this.resetSunToDefault}
                  modifiers={"positive"}
                  rootClassName={"skystudio_reset_confirm_button"}
                />
                <Button
                  label={Format.stringLiteral("Cancel")}
                  onSelect={this.cancelResetSun}
                  modifiers={"negative"}
                  rootClassName={"skystudio_reset_confirm_button"}
                />
              </div>
            </div>
          </div>
        )}

        <PanelArea
          modifiers={classNames(
            "skystudio_section",
            this.state.confirmResetSun && "skystudio_blur"
          )}
        >
          <ToggleRow
            label={Format.stringLiteral("Override Sun Color & Intensity")}
            toggled={sunColorOverrideOn}
            onToggle={this.onToggleValueChanged(
              "bUserOverrideSunColorAndIntensity"
            )}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
          />

          <ColorPickerRow
            label={Format.stringLiteral("Sun Color")}
            r={nUserSunColorR}
            g={nUserSunColorG}
            b={nUserSunColorB}
            disabled={!customLightingEnabled || !sunColorOverrideOn}
          />

          <SliderRow
            label={Format.stringLiteral("Sun Color R")}
            min={0}
            max={1}
            step={0.01}
            value={nUserSunColorR}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged("nUserSunColorR", newValue)
            }
            editable={true}
            disabled={!customLightingEnabled || !sunColorOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Sun Color G")}
            min={0}
            max={1}
            step={0.01}
            value={nUserSunColorG}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged("nUserSunColorG", newValue)
            }
            editable={true}
            disabled={!customLightingEnabled || !sunColorOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Sun Color B")}
            min={0}
            max={1}
            step={0.01}
            value={nUserSunColorB}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged("nUserSunColorB", newValue)
            }
            editable={true}
            disabled={!customLightingEnabled || !sunColorOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Sun Intensity")}
            min={0}
            max={255}
            step={1}
            value={nUserSunIntensity}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserSunIntensity",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !sunColorOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Sun Ground Multiplier")}
            min={0}
            max={5}
            step={0.01}
            value={nUserSunGroundMultiplier}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged("nUserSunGroundMultiplier", newValue)
            }
            editable={true}
            disabled={!customLightingEnabled || !sunColorOverrideOn}
            focusable={true}
          />
        </PanelArea>

        <PanelArea
          modifiers={classNames(
            "skystudio_section",
            this.state.confirmResetSun && "skystudio_blur"
          )}
        >
          <ToggleRow
            label={Format.stringLiteral("Override Day/Night Transition")}
            toggled={sunFadeOverrideOn}
            onToggle={this.onToggleValueChanged("bUserOverrideSunFade")}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
          />
          <SliderRow
            label={Format.stringLiteral("Sun Day/Night Fade")}
            min={0}
            max={1}
            step={0.01}
            value={nUserSunFade}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged("nUserSunFade", newValue)
            }
            editable={true}
            disabled={!customLightingEnabled || !sunFadeOverrideOn}
            focusable={true}
          />
        </PanelArea>

        {/* Reset button */}
        <PanelArea
          modifiers={classNames(
            "skystudio_section",
            this.state.confirmResetSun && "skystudio_blur"
          )}
        >
          <FocusableDataRow
            label={Format.stringLiteral("Reset Sun Color/Intensity/Fade")}
          >
            <Button
              icon={"img/icons/restart.svg"}
              label={Format.stringLiteral("Reset Sun")}
              onSelect={this.beginResetSun}
              rootClassName={"skystudio_reset_confirm_button"}
            />
          </FocusableDataRow>
        </PanelArea>
      </div>,

      // TAB 3: Moon color + intensity
      <div key="mooncolor" className="skystudio_scrollPane">
        {this.state.confirmResetMoon && (
          <div className={"skystudio_confirm_modal"}>
            <div>
              <div className={"skystudio_reset_header"}>
                Reset Moon Color/Intensity/Fade to Default?
              </div>
              <div className={"skystudio_reset_confirm_buttons"}>
                <Button
                  label={Format.stringLiteral("Confirm")}
                  onSelect={this.resetMoonToDefault}
                  modifiers={"positive"}
                  rootClassName={"skystudio_reset_confirm_button"}
                />
                <Button
                  label={Format.stringLiteral("Cancel")}
                  onSelect={this.cancelResetMoon}
                  modifiers={"negative"}
                  rootClassName={"skystudio_reset_confirm_button"}
                />
              </div>
            </div>
          </div>
        )}

        <PanelArea
          modifiers={classNames(
            "skystudio_section",
            this.state.confirmResetMoon && "skystudio_blur"
          )}
        >
          <ToggleRow
            label={Format.stringLiteral("Override Moon Color & Intensity")}
            toggled={moonColorOverrideOn}
            onToggle={this.onToggleValueChanged(
              "bUserOverrideMoonColorAndIntensity"
            )}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
          />

          <ColorPickerRow
            label={Format.stringLiteral("Moon Color")}
            r={nUserMoonColorR}
            g={nUserMoonColorG}
            b={nUserMoonColorB}
            disabled={!customLightingEnabled || !moonColorOverrideOn}
          />

          <SliderRow
            label={Format.stringLiteral("Moon Color R")}
            min={0}
            max={1}
            step={0.01}
            value={nUserMoonColorR}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserMoonColorR",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !moonColorOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Moon Color G")}
            min={0}
            max={1}
            step={0.01}
            value={nUserMoonColorG}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserMoonColorG",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !moonColorOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Moon Color B")}
            min={0}
            max={1}
            step={0.01}
            value={nUserMoonColorB}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserMoonColorB",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !moonColorOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Moon Intensity")}
            min={0}
            max={5}
            step={0.05}
            value={nUserMoonIntensity}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserMoonIntensity",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !moonColorOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Moon Ground Multiplier")}
            min={0}
            max={5}
            step={0.01}
            value={nUserMoonGroundMultiplier}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserMoonGroundMultiplier",
                newValue
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !moonColorOverrideOn}
            focusable={true}
          />
        </PanelArea>

        <PanelArea
          modifiers={classNames(
            "skystudio_section",
            this.state.confirmResetMoon && "skystudio_blur"
          )}
        >
          <ToggleRow
            label={Format.stringLiteral("Override Day/Night Transition")}
            toggled={moonFadeOverrideOn}
            onToggle={this.onToggleValueChanged("bUserOverrideMoonFade")}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
          />

          <SliderRow
            label={Format.stringLiteral("Moon Day/Night Fade")}
            min={0}
            max={1}
            step={0.01}
            value={nUserMoonFade}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged("nUserMoonFade", newValue)
            }
            editable={true}
            disabled={!customLightingEnabled || !moonFadeOverrideOn}
            focusable={true}
          />
        </PanelArea>

        {/* Reset button */}
        <PanelArea
          modifiers={classNames(
            "skystudio_section",
            this.state.confirmResetMoon && "skystudio_blur"
          )}
        >
          <FocusableDataRow
            label={Format.stringLiteral("Reset Moon Color/Intensity/Fade")}
          >
            <Button
              icon={"img/icons/restart.svg"}
              label={Format.stringLiteral("Reset Moon")}
              onSelect={this.beginResetMoon}
              rootClassName={"skystudio_reset_confirm_button"}
            />
          </FocusableDataRow>
        </PanelArea>
      </div>,

      // TAB 4: Miscellaneous -- Hide the less user-friendly features here
      <div key="other" className="skystudio_scrollPane">
        {this.state.confirmResetAll && (
          <div className={"skystudio_confirm_modal"}>
            <div>
              <div className={"skystudio_reset_header"}>
                Reset All Slider Values to Default?
              </div>
              <div className={"skystudio_reset_confirm_buttons"}>
                <Button
                  label={Format.stringLiteral("Confirm")}
                  onSelect={this.resetAllToDefault}
                  modifiers={"positive"}
                  rootClassName={"skystudio_reset_confirm_button"}
                />
                <Button
                  label={Format.stringLiteral("Cancel")}
                  onSelect={this.cancelResetAll}
                  modifiers={"negative"}
                  rootClassName={"skystudio_reset_confirm_button"}
                />
              </div>
            </div>
          </div>
        )}

        <PanelArea
          modifiers={classNames(
            "skystudio_section",
            this.state.confirmResetAll && "skystudio_blur"
          )}
        >
          <ToggleRow
            label={Format.stringLiteral("Override RenderParameters Transition")}
            toggled={dayNightOverrideOn}
            onToggle={this.onToggleValueChanged(
              "bUserOverrideDayNightTransition"
            )}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
          />

          <SliderRow
            label={Format.stringLiteral("RenderParameters Day/Night Fade")}
            min={0}
            max={100}
            step={0.01}
            value={nUserDayNightTransition}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserDayNightTransition",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !dayNightOverrideOn}
            focusable={true}
          />
        </PanelArea>

        {/* Global enable/disable */}
        <PanelArea
          modifiers={classNames(
            "skystudio_section",
            this.state.confirmResetAll && "skystudio_blur"
          )}
        >
          <ToggleRow
            label={Format.stringLiteral(
              "Use Vanilla Lighting (Disables all mod features)"
            )}
            toggled={useVanillaLighting}
            onToggle={this.onToggleValueChanged("bUseVanillaLighting")}
            inputName={InputName.Select}
            disabled={false}
          />
        </PanelArea>

        <PanelArea
          modifiers={classNames(
            "skystudio_section",
            this.state.confirmResetAll && "skystudio_blur"
          )}
        >
          {/* <FocusableDataRow
            label={Format.stringLiteral("Reset Sun Color/Intensity")}
          >
            <Button
              icon={"img/icons/restart.svg"}
              label={Format.stringLiteral("Reset Sun Color")}
              onSelect={this.beginResetSun}
              rootClassName={"skystudio_reset_confirm_button"}
            />
          </FocusableDataRow>

          <FocusableDataRow
            label={Format.stringLiteral("Reset Moon Color/Intensity")}
          >
            <Button
              icon={"img/icons/restart.svg"}
              label={Format.stringLiteral("Reset Moon Color")}
              onSelect={this.beginResetMoon}
              rootClassName={"skystudio_reset_confirm_button"}
            />
          </FocusableDataRow> */}

          <FocusableDataRow label={Format.stringLiteral("Reset All Slider Values")}>
            <Button
              icon={"img/icons/restart.svg"}
              label={Format.stringLiteral("Reset All")}
              onSelect={this.beginResetAll}
              rootClassName={"skystudio_reset_confirm_button"}
            />
          </FocusableDataRow>
        </PanelArea>
      </div>,
    ];

    return (
      <div className="skystudio_root">
        {DEBUG_MODE && (
          <Panel
            rootClassName={classNames("skystudio_focus_debug")}
            title={Format.stringLiteral("Current Focus")}
          >
            <div style={{ maxWidth: "500px" }}>
              {JSON.stringify(this.state.defaultConfig)}
            </div>
          </Panel>
        )}

        <div className="skystudio_toggle_menu">
          <SkyStudioButton
            src="img/icons/tod.svg"
            // tooltip is kinda janky position-wise so not having one for now
            focused={false}
            toggleable
            toggled={!!this.state.controlsVisible}
            onSelect={this.handleToggleControls}
          />
        </div>

        <div className="skystudio_controls_panel_wrapper">
          <Panel
            rootClassName={classNames(
              "skystudio_controls_panel",
              !this.state.controlsVisible && "hidden"
            )}
            icon={"img/icons/tod.svg"}
            title={Format.stringLiteral("Sky Studio")}
            onClose={this.handleToggleControls}
            tabs={tabs}
            visibleTabIndex={visibleTabIndex}
            onTabChange={this.changeVisibleTab}
            handleInput={this.handlePanelInput}
          >
            {tabViews}
          </Panel>
        </div>
      </div>
    );
  }
}

export const SkyStudioUI = Focusable.decorateEx(_SkyStudioUI, {
  focusable: false,
});
