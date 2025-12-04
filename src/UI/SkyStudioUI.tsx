import * as preact from "/js/common/lib/preact.js";
import * as Engine from "/js/common/core/Engine.js";
import * as Focus from "/js/common/core/Focus.js";
import * as Format from "/js/common/util/LocalisationUtil.js";
import * as Focusable from "/js/common/components/Focusable.js";
import { loadCSS } from "/js/common/util/CSSUtil.js";
import { Slider } from "/js/project/components/Slider.js";
import { classNames } from "/js/common/lib/classnames.js";
import { Panel } from "/js/project/components/panel/Panel.js";

import { InputName } from "/js/common/core/InputTypes.js";

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
  visible: boolean;
  controlsVisible?: boolean;

  focusDebugKey?: string;
};

let focusDebuginterval: number;

class _SkyStudioUI extends preact.Component<{}, State> {
  state = {
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

    // For debugging the focus issue
    focusDebugKey: "",
  };

  componentWillMount() {
    Engine.addListener("Show", this.onShow);
    Engine.addListener("Hide", this.onHide);

    focusDebuginterval = setInterval(this.updateFocusDebug, 250);
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

  onShow = (data) => {
    this.setState({
      ...this.state,
      visible: true,
      controlsVisible: false,
      ...data,
    });
  };

  onHide = () => this.setState({ visible: false });

  onNumericalValueChanged = (key, newValue) => {
    this.setState({ [key]: newValue });
    Engine.sendEvent(`SkyStudioChangedValue_${key}`, this.state[key]);
  };

  handleToggleControls = (value?: boolean) => {
    this.setState({
      controlsVisible:
        value !== undefined ? value : !this.state.controlsVisible,
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

  // Base the UI on "NotificationsModule.js" from vanilla, but in the bottom right instead of top left
  render() {
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
            toggled={this.state.controlsVisible}
            onSelect={this.handleToggleControls}
          />
        </div>
        <div className={"skystudio_controls_panel_wrapper"}>
          <Panel
            rootClassName={classNames(
              "skystudio_controls_panel",
              !this.state.controlsVisible && "hidden"
            )}
            title={Format.stringLiteral("Sky Studio")}
            onClose={this.handleToggleControls}
            handleInput={this.handlePanelInput}
          >
            <Slider
              label={Format.stringLiteral(`Time of Day: `)}
              min={-90}
              max={270}
              step={0.01}
              value={this.state.nUserSunTimeOfDay}
              onChange={(newValue) =>
                this.onNumericalValueChanged("nUserSunTimeOfDay", newValue)
              }
              editable={true}
              className="skystudio_slider"
              focused
            />
            <Slider
              label={Format.stringLiteral(`Sun Azimuth: `)}
              min={0}
              max={360}
              step={1}
              value={this.state.nUserSunAzimuth}
              onChange={(newValue) =>
                this.onNumericalValueChanged("nUserSunAzimuth", newValue)
              }
              editable={true}
              className="skystudio_slider"
            />
            <Slider
              label={Format.stringLiteral(`Sun Latitude Offset: `)}
              min={-90}
              max={90}
              step={1}
              value={this.state.nUserSunLatitudeOffset}
              onChange={(newValue) =>
                this.onNumericalValueChanged("nUserSunLatitudeOffset", newValue)
              }
              editable={true}
              className="skystudio_slider"
            />
            <Slider
              label={Format.stringLiteral(`Sun Intensity: `)}
              min={0}
              max={255}
              step={1}
              value={this.state.nUserSunIntensity}
              onChange={(newValue) =>
                this.onNumericalValueChanged("nUserSunIntensity", newValue)
              }
              editable={true}
              className="skystudio_slider"
            />
            <Slider
              label={Format.stringLiteral(`Moon Azimuth: `)}
              min={0}
              max={360}
              step={1}
              value={this.state.nUserMoonAzimuth}
              onChange={(newValue) =>
                this.onNumericalValueChanged("nUserMoonAzimuth", newValue)
              }
              editable={true}
              className="skystudio_slider"
            />
            <Slider
              label={Format.stringLiteral(`Moon Latitude Offset: `)}
              min={-90}
              max={90}
              step={1}
              value={this.state.nUserMoonLatitudeOffset}
              onChange={(newValue) =>
                this.onNumericalValueChanged(
                  "nUserMoonLatitudeOffset",
                  newValue
                )
              }
              editable={true}
              className="skystudio_slider"
            />
            <Slider
              label={Format.stringLiteral(`Moon Time of Day: `)}
              min={-90}
              max={270}
              step={0.01}
              value={this.state.nUserMoonTimeOfDay}
              onChange={(newValue) =>
                this.onNumericalValueChanged("nUserMoonTimeOfDay", newValue)
              }
              editable={true}
              className="skystudio_slider"
            />
            <Slider
              label={Format.stringLiteral(`Moon Intensity: `)}
              min={0}
              max={5}
              step={0.05}
              value={this.state.nUserMoonIntensity}
              onChange={(newValue) =>
                this.onNumericalValueChanged("nUserMoonIntensity", newValue)
              }
              editable={true}
              className="skystudio_slider"
            />
            <Slider
              label={Format.stringLiteral(`Day/Night Fade: `)}
              min={37}
              max={100}
              step={0.01}
              value={this.state.nUserDayNightTransition}
              onChange={(newValue) =>
                this.onNumericalValueChanged(
                  "nUserDayNightTransition",
                  newValue
                )
              }
              editable={true}
              className="skystudio_slider"
            />
            <Slider
              label={Format.stringLiteral(`Sun Fade: `)}
              min={0}
              max={1}
              step={0.01}
              value={this.state.nUserSunFade}
              onChange={(newValue) =>
                this.onNumericalValueChanged("nUserSunFade", newValue)
              }
              editable={true}
              className="skystudio_slider"
            />
            <Slider
              label={Format.stringLiteral(`Moon Fade: `)}
              min={0}
              max={1}
              step={0.01}
              value={this.state.nUserMoonFade}
              onChange={(newValue) =>
                this.onNumericalValueChanged("nUserMoonFade", newValue)
              }
              editable={true}
              className="skystudio_slider"
            />
          </Panel>
        </div>
      </div>
    );
  }
}

// Root focusable: one “stack” containing button + panel + sliders.
export const SkyStudioUI = Focusable.decorateEx(_SkyStudioUI, {
  focusable: false, // root itself isn’t a selectable item
});
