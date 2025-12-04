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

import { SkyStudioButton } from "/SkyStudioButton.js";

const DEBUG_MODE = false;

loadCSS("project/Shared");
loadCSS("project/components/Slider");

type State = {
  bUseVanillaLighting: number;

  nUserSunAzimuth: number;
  nUserSunLatitudeOffset: number;
  nUserSunTimeOfDay: number;
  nUserSunColorR: number;
  nUserSunColorG: number;
  nUserSunColorB: number;
  nUserSunIntensity: number;
  bUserSunUseLinearColors: number;

  nUserMoonAzimuth: number;
  nUserMoonLatitudeOffset: number;
  nUserMoonTimeOfDay: number;
  nUserMoonColorR: number;
  nUserMoonColorG: number;
  nUserMoonColorB: number;
  nUserMoonIntensity: number;
  bUserMoonUseLinearColors: number;

  nUserDayNightTransition: number;
  nUserSunFade: number;
  nUserMoonFade: number;

  // New override flags (numeric 0/1 so they can be driven by engine data)
  bUserOverrideSunTimeOfDay: number;
  bUserOverrideSunOrientation: number;
  bUserOverrideSunColorAndIntensity: number;
  bUserOverrideMoonOrientation: number;
  bUserOverrideMoonTimeOfDay: number;
  bUserOverrideMoonColorAndIntensity: number;
  bUserOverrideDayNightTransition: number;

  visible: boolean;
  controlsVisible?: boolean;

  focusDebugKey?: string;
};

let focusDebuginterval: number;

// Simple presentational swatch row – color display only, actual editing via RGB sliders
type ColorPickerRowProps = {
  label: string;
  r: number;
  g: number;
  b: number;
  disabled?: boolean;
};

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
    width: "32px",
    height: "18px",
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

    bUseVanillaLighting: 0,

    nUserSunAzimuth: 0,
    nUserSunLatitudeOffset: 0,
    nUserSunTimeOfDay: 0,
    nUserSunColorR: 0,
    nUserSunColorG: 0,
    nUserSunColorB: 0,
    nUserSunIntensity: 0,
    bUserSunUseLinearColors: 0,

    nUserMoonAzimuth: 0,
    nUserMoonLatitudeOffset: 0,
    nUserMoonTimeOfDay: 0,
    nUserMoonColorR: 0,
    nUserMoonColorG: 0,
    nUserMoonColorB: 0,
    nUserMoonIntensity: 0,
    bUserMoonUseLinearColors: 0,

    nUserDayNightTransition: 0,
    nUserSunFade: 0,
    nUserMoonFade: 0,

    bUserOverrideSunTimeOfDay: 0,
    bUserOverrideSunOrientation: 0,
    bUserOverrideSunColorAndIntensity: 0,
    bUserOverrideMoonOrientation: 0,
    bUserOverrideMoonTimeOfDay: 0,
    bUserOverrideMoonColorAndIntensity: 0,
    bUserOverrideDayNightTransition: 0,

    // focus debug
    focusDebugKey: "",
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

  onShow = (data: Partial<State>) => {
    this.setState({
      ...this.state,
      visible: true,
      controlsVisible: false,
      ...data,
    });
  };

  onHide = () => this.setState({ visible: false });

  onNumericalValueChanged = (key: keyof State, newValue: number) => {
    // All numeric values (sliders) go through here
    this.setState({ [key]: newValue } as unknown as State);
    Engine.sendEvent(`SkyStudioChangedValue_${key}`, newValue);
  };

  onToggleValueChanged =
    (key: keyof State) =>
    (toggled: boolean): void => {
      // Store as numeric 0/1 for compatibility with engine-side data
      const numericValue = toggled ? 1 : 0;
      this.setState({ [key]: numericValue } as unknown as State);
      Engine.sendEvent(`SkyStudioChangedValue_${key}`, numericValue);
    };

  handleToggleControls = (value?: boolean) => {
    this.setState({
      controlsVisible:
        value !== undefined ? value : !this.state.controlsVisible,
    });
  };

  // Prevent Escape from ping-ponging the panel when sliders/panel content have focus
  handlePanelInput = (e) => {
    if (!e.button || !e.button.isPressed(true)) return false;

    if (e.inputName === InputName.Cancel || e.inputName === InputName.Back) {
      Focus.set("");
      this.handleToggleControls(false);
      return true;
    }

    return false;
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

      nUserMoonAzimuth,
      nUserMoonLatitudeOffset,
      nUserMoonTimeOfDay,
      nUserMoonColorR,
      nUserMoonColorG,
      nUserMoonColorB,
      nUserMoonIntensity,

      nUserDayNightTransition,
      nUserSunFade,
      nUserMoonFade,

      bUserOverrideSunTimeOfDay,
      bUserOverrideSunOrientation,
      bUserOverrideSunColorAndIntensity,
      bUserOverrideMoonOrientation,
      bUserOverrideMoonTimeOfDay,
      bUserOverrideMoonColorAndIntensity,
      bUserOverrideDayNightTransition,
    } = this.state;

    // Global enable/disable: when using vanilla lighting, all custom controls are disabled
    const useVanillaLighting = !!bUseVanillaLighting;
    const customLightingEnabled = !useVanillaLighting;

    const sunTimeOverrideOn = !!bUserOverrideSunTimeOfDay;
    const sunOrientationOverrideOn = !!bUserOverrideSunOrientation;
    const sunColorOverrideOn = !!bUserOverrideSunColorAndIntensity;

    const moonOrientationOverrideOn = !!bUserOverrideMoonOrientation;
    const moonTimeOverrideOn = !!bUserOverrideMoonTimeOfDay;
    const moonColorOverrideOn = !!bUserOverrideMoonColorAndIntensity;

    const dayNightOverrideOn = !!bUserOverrideDayNightTransition;

    return (
      <div className="skystudio_root">
        {DEBUG_MODE && (
          <Panel
            rootClassName={classNames("skystudio_focus_debug")}
            title={Format.stringLiteral("Current Focus")}
          >
            {this.state.focusDebugKey}
          </Panel>
        )}

        <div className="skystudio_toggle_menu">
          <SkyStudioButton
            src="img/icons/tod.svg"
            tooltip={Format.stringLiteral("Sky Studio")}
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
            title={Format.stringLiteral("Sky Studio")}
            onClose={this.handleToggleControls}
            handleInput={this.handlePanelInput}
          >
            {/* GLOBAL ENABLE/DISABLE */}
            <PanelArea modifiers="skystudio_section">
              <PanelHeader
                text={Format.stringLiteral("Global Lighting Control")}
              />
              <ToggleRow
                label={Format.stringLiteral("Use vanilla lighting")}
                toggled={useVanillaLighting}
                onToggle={this.onToggleValueChanged("bUseVanillaLighting")}
                inputName={InputName.Select}
                disabled={false}
              />
            </PanelArea>

            {/* TIME OF DAY */}
            <PanelArea modifiers="skystudio_section">
              <PanelHeader text={Format.stringLiteral("Time of day")} />

              <ToggleRow
                label={Format.stringLiteral("Override time of day")}
                toggled={sunTimeOverrideOn}
                onToggle={this.onToggleValueChanged(
                  "bUserOverrideSunTimeOfDay"
                )}
                inputName={InputName.Select}
                disabled={!customLightingEnabled}
              />

              <SliderRow
                label={Format.stringLiteral("Time of day")}
                min={-90}
                max={270}
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
            </PanelArea>

            {/* SUN */}
            <PanelArea modifiers="skystudio_section">
              <PanelHeader text={Format.stringLiteral("Sun")} />

              <ToggleRow
                label={Format.stringLiteral("Override sun orientation")}
                toggled={sunOrientationOverrideOn}
                onToggle={this.onToggleValueChanged(
                  "bUserOverrideSunOrientation"
                )}
                inputName={InputName.Select}
                disabled={!customLightingEnabled}
              />

              <ToggleRow
                label={Format.stringLiteral("Override sun color & intensity")}
                toggled={sunColorOverrideOn}
                onToggle={this.onToggleValueChanged(
                  "bUserOverrideSunColorAndIntensity"
                )}
                inputName={InputName.Select}
                disabled={!customLightingEnabled}
              />

              <SliderRow
                label={Format.stringLiteral("Sun azimuth")}
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
                label={Format.stringLiteral("Sun latitude offset")}
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

              <ColorPickerRow
                label={Format.stringLiteral("Sun color")}
                r={nUserSunColorR}
                g={nUserSunColorG}
                b={nUserSunColorB}
                disabled={!customLightingEnabled || !sunColorOverrideOn}
              />

              <SliderRow
                label={Format.stringLiteral("Sun color R")}
                min={0}
                max={1}
                step={0.01}
                value={nUserSunColorR}
                onChange={(newValue: number) =>
                  this.onNumericalValueChanged(
                    "nUserSunColorR",
                    newValue as number
                  )
                }
                editable={true}
                disabled={!customLightingEnabled || !sunColorOverrideOn}
                focusable={true}
              />

              <SliderRow
                label={Format.stringLiteral("Sun color G")}
                min={0}
                max={1}
                step={0.01}
                value={nUserSunColorG}
                onChange={(newValue: number) =>
                  this.onNumericalValueChanged(
                    "nUserSunColorG",
                    newValue as number
                  )
                }
                editable={true}
                disabled={!customLightingEnabled || !sunColorOverrideOn}
                focusable={true}
              />

              <SliderRow
                label={Format.stringLiteral("Sun color B")}
                min={0}
                max={1}
                step={0.01}
                value={nUserSunColorB}
                onChange={(newValue: number) =>
                  this.onNumericalValueChanged(
                    "nUserSunColorB",
                    newValue as number
                  )
                }
                editable={true}
                disabled={!customLightingEnabled || !sunColorOverrideOn}
                focusable={true}
              />

              <SliderRow
                label={Format.stringLiteral("Sun intensity")}
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
            </PanelArea>

            {/* MOON */}
            <PanelArea modifiers="skystudio_section">
              <PanelHeader text={Format.stringLiteral("Moon")} />

              <ToggleRow
                label={Format.stringLiteral("Override moon orientation")}
                toggled={moonOrientationOverrideOn}
                onToggle={this.onToggleValueChanged(
                  "bUserOverrideMoonOrientation"
                )}
                inputName={InputName.Select}
                disabled={!customLightingEnabled}
              />

              <ToggleRow
                label={Format.stringLiteral("Override moon time of day")}
                toggled={moonTimeOverrideOn}
                onToggle={this.onToggleValueChanged(
                  "bUserOverrideMoonTimeOfDay"
                )}
                inputName={InputName.Select}
                disabled={!customLightingEnabled}
              />

              <ToggleRow
                label={Format.stringLiteral("Override moon color & intensity")}
                toggled={moonColorOverrideOn}
                onToggle={this.onToggleValueChanged(
                  "bUserOverrideMoonColorAndIntensity"
                )}
                inputName={InputName.Select}
                disabled={!customLightingEnabled}
              />

              <SliderRow
                label={Format.stringLiteral("Moon azimuth")}
                min={0}
                max={360}
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
                label={Format.stringLiteral("Moon latitude offset")}
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

              <SliderRow
                label={Format.stringLiteral("Moon time of day")}
                min={-90}
                max={270}
                step={0.01}
                value={nUserMoonTimeOfDay}
                onChange={(newValue: number) =>
                  this.onNumericalValueChanged(
                    "nUserMoonTimeOfDay",
                    newValue as number
                  )
                }
                editable={true}
                disabled={!customLightingEnabled || !moonTimeOverrideOn}
                focusable={true}
              />

              <ColorPickerRow
                label={Format.stringLiteral("Moon color")}
                r={nUserMoonColorR}
                g={nUserMoonColorG}
                b={nUserMoonColorB}
                disabled={!customLightingEnabled || !moonColorOverrideOn}
              />

              <SliderRow
                label={Format.stringLiteral("Moon color R")}
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
                label={Format.stringLiteral("Moon color G")}
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
                label={Format.stringLiteral("Moon color B")}
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
                label={Format.stringLiteral("Moon intensity")}
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
            </PanelArea>

            {/* DAY / NIGHT TRANSITION */}
            <PanelArea modifiers="skystudio_section">
              <PanelHeader
                text={Format.stringLiteral("Day / night transition")}
              />

              <ToggleRow
                label={Format.stringLiteral("Override day / night transition")}
                toggled={dayNightOverrideOn}
                onToggle={this.onToggleValueChanged(
                  "bUserOverrideDayNightTransition"
                )}
                inputName={InputName.Select}
                disabled={!customLightingEnabled}
              />

              <SliderRow
                label={Format.stringLiteral("Day / night fade")}
                min={37}
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

              <SliderRow
                label={Format.stringLiteral("Sun fade")}
                min={0}
                max={1}
                step={0.01}
                value={nUserSunFade}
                onChange={(newValue: number) =>
                  this.onNumericalValueChanged(
                    "nUserSunFade",
                    newValue as number
                  )
                }
                editable={true}
                disabled={!customLightingEnabled || !dayNightOverrideOn}
                focusable={true}
              />

              <SliderRow
                label={Format.stringLiteral("Moon fade")}
                min={0}
                max={1}
                step={0.01}
                value={nUserMoonFade}
                onChange={(newValue: number) =>
                  this.onNumericalValueChanged(
                    "nUserMoonFade",
                    newValue as number
                  )
                }
                editable={true}
                disabled={!customLightingEnabled || !dayNightOverrideOn}
                focusable={true}
              />
            </PanelArea>
          </Panel>
        </div>
      </div>
    );
  }
}

// Root focusable: one “stack” containing button + panel + rows.
export const SkyStudioUI = Focusable.decorateEx(_SkyStudioUI, {
  focusable: false,
});
