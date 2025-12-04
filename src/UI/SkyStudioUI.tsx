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

import { SkyStudioButton } from "/SkyStudioButton.js";

const DEBUG_MODE = false;

loadCSS("project/Shared");
loadCSS("project/components/Slider");

type State = {
  bUseVanillaLighting: boolean;

  nUserSunAzimuth: number;
  nUserSunLatitudeOffset: number;
  nUserSunTimeOfDay: number;
  nUserSunColorR: number;
  nUserSunColorG: number;
  nUserSunColorB: number;
  nUserSunIntensity: number;
  bUserSunUseLinearColors: number; // still numeric for now, not hooked to a ToggleRow

  nUserMoonAzimuth: number;
  nUserMoonLatitudeOffset: number;
  nUserMoonTimeOfDay: number;
  nUserMoonColorR: number;
  nUserMoonColorG: number;
  nUserMoonColorB: number;
  nUserMoonIntensity: number;
  bUserMoonUseLinearColors: number; // same as above

  nUserDayNightTransition: number;
  nUserSunFade: number;
  nUserMoonFade: number;

  bUserOverrideSunTimeOfDay: boolean;
  bUserOverrideSunOrientation: boolean;
  bUserOverrideSunColorAndIntensity: boolean;
  bUserOverrideMoonOrientation: boolean;
  bUserOverrideMoonTimeOfDay: boolean;
  bUserOverrideMoonColorAndIntensity: boolean;
  bUserOverrideDayNightTransition: boolean;

  visible: boolean;
  controlsVisible?: boolean;

  visibleTabIndex: number;

  focusDebugKey?: string;
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
    height: "32px",
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

    bUseVanillaLighting: false,

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

    bUserOverrideSunTimeOfDay: false,
    bUserOverrideSunOrientation: false,
    bUserOverrideSunColorAndIntensity: false,
    bUserOverrideMoonOrientation: false,
    bUserOverrideMoonTimeOfDay: false,
    bUserOverrideMoonColorAndIntensity: false,
    bUserOverrideDayNightTransition: false,

    visibleTabIndex: 0,

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
    this.setState({ [key]: newValue } as unknown as State);
    Engine.sendEvent(`SkyStudioChangedValue_${key}`, newValue);
  };

  onToggleValueChanged =
    (key: keyof State) =>
    (toggled: boolean): void => {
      // store booleans in state
      this.setState({ [key]: toggled } as unknown as State);

      // send booleans to the engine
      Engine.sendEvent(`SkyStudioChangedValue_${key}`, toggled);
    };

  handleToggleControls = (value?: boolean) => {
    this.setState({
      controlsVisible:
        value !== undefined ? value : !this.state.controlsVisible,
    });
  };

  changeVisibleTab = (visibleIndex: number) => {
    this.setState({ visibleTabIndex: visibleIndex });
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

      visibleTabIndex,
    } = this.state;

    const useVanillaLighting = bUseVanillaLighting;
    const customLightingEnabled = !useVanillaLighting;

    const sunTimeOverrideOn = bUserOverrideSunTimeOfDay;
    const sunOrientationOverrideOn = bUserOverrideSunOrientation;
    const sunColorOverrideOn = bUserOverrideSunColorAndIntensity;

    const moonOrientationOverrideOn = bUserOverrideMoonOrientation;
    const moonTimeOverrideOn = bUserOverrideMoonTimeOfDay;
    const moonColorOverrideOn = bUserOverrideMoonColorAndIntensity;

    const dayNightOverrideOn = bUserOverrideDayNightTransition;

    const tabs = [
      <Tab
        key="time"
        label={Format.stringLiteral("Time / Transition")}
        outcome="SkyStudio_Tab_Time"
      />,
      <Tab
        key="orientation"
        label={Format.stringLiteral("Orientation")}
        outcome="SkyStudio_Tab_Orientation"
      />,
      <Tab
        key="color"
        label={Format.stringLiteral("Color & Intensity")}
        outcome="SkyStudio_Tab_Color"
      />,
    ];

    const tabViews = [
      // TAB 0: Time of day + day/night transition
      <ScrollPane
        key="time"
        rootClassName="skystudio_scrollPane"
        contentClassName="skystudio_scrollPaneContent"
      >
        {/* Global enable/disable */}
        <PanelArea modifiers="skystudio_section">
          <PanelHeader text={Format.stringLiteral("Global Lighting Control")} />
          <ToggleRow
            label={Format.stringLiteral("Use vanilla lighting")}
            toggled={useVanillaLighting}
            onToggle={this.onToggleValueChanged("bUseVanillaLighting")}
            inputName={InputName.Select}
            disabled={false}
          />
        </PanelArea>

        <PanelArea modifiers="skystudio_section">
          <PanelHeader text={Format.stringLiteral("Time of day")} />

          <ToggleRow
            label={Format.stringLiteral("Override time of day")}
            toggled={sunTimeOverrideOn}
            onToggle={this.onToggleValueChanged("bUserOverrideSunTimeOfDay")}
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

        <PanelArea modifiers="skystudio_section">
          <PanelHeader text={Format.stringLiteral("Day / night transition")} />

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
              this.onNumericalValueChanged("nUserSunFade", newValue as number)
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
              this.onNumericalValueChanged("nUserMoonFade", newValue as number)
            }
            editable={true}
            disabled={!customLightingEnabled || !dayNightOverrideOn}
            focusable={true}
          />
        </PanelArea>
      </ScrollPane>,

      // TAB 1: Sun & Moon orientation
      <ScrollPane
        key="orientation"
        rootClassName="skystudio_scrollPane"
        contentClassName="skystudio_scrollPaneContent"
      >
        <PanelArea modifiers="skystudio_section">
          <PanelHeader text={Format.stringLiteral("Sun orientation")} />

          <ToggleRow
            label={Format.stringLiteral("Override sun orientation")}
            toggled={sunOrientationOverrideOn}
            onToggle={this.onToggleValueChanged("bUserOverrideSunOrientation")}
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
        </PanelArea>

        <PanelArea modifiers="skystudio_section">
          <PanelHeader text={Format.stringLiteral("Moon orientation & time")} />

          <ToggleRow
            label={Format.stringLiteral("Override moon orientation")}
            toggled={moonOrientationOverrideOn}
            onToggle={this.onToggleValueChanged("bUserOverrideMoonOrientation")}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
          />

          <ToggleRow
            label={Format.stringLiteral("Override moon time of day")}
            toggled={moonTimeOverrideOn}
            onToggle={this.onToggleValueChanged("bUserOverrideMoonTimeOfDay")}
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
        </PanelArea>
      </ScrollPane>,

      // TAB 2: Sun & Moon color + intensity
      <ScrollPane
        key="color"
        rootClassName="skystudio_scrollPane"
        contentClassName="skystudio_scrollPaneContent"
      >
        <PanelArea modifiers="skystudio_section">
          <PanelHeader text={Format.stringLiteral("Sun color & intensity")} />

          <ToggleRow
            label={Format.stringLiteral("Override sun color & intensity")}
            toggled={sunColorOverrideOn}
            onToggle={this.onToggleValueChanged(
              "bUserOverrideSunColorAndIntensity"
            )}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
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
              this.onNumericalValueChanged("nUserSunColorR", newValue as number)
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
              this.onNumericalValueChanged("nUserSunColorG", newValue as number)
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
              this.onNumericalValueChanged("nUserSunColorB", newValue as number)
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

        <PanelArea modifiers="skystudio_section">
          <PanelHeader text={Format.stringLiteral("Moon color & intensity")} />

          <ToggleRow
            label={Format.stringLiteral("Override moon color & intensity")}
            toggled={moonColorOverrideOn}
            onToggle={this.onToggleValueChanged(
              "bUserOverrideMoonColorAndIntensity"
            )}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
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
      </ScrollPane>,
    ];

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
