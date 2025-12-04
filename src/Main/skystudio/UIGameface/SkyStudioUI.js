import * as preact from "/js/common/lib/preact.js";
import * as Engine from "/js/common/core/Engine.js";
import * as Focus from "/js/common/core/Focus.js";
import * as Format from "/js/common/util/LocalisationUtil.js";
import * as Focusable from "/js/common/components/Focusable.js";
import { loadCSS } from "/js/common/util/CSSUtil.js";
import { classNames } from "/js/common/lib/classnames.js";
import { Panel } from "/js/project/components/panel/Panel.js";
import { InputName } from "/js/common/core/InputTypes.js";
import { PanelArea } from "/js/project/components/PanelShared.js";
import { SliderRow } from "/js/project/components/SliderRow.js";
import { ToggleRow } from "/js/project/components/ToggleRow.js";
import { FocusableDataRow } from "/js/project/components/DataRow.js";
import { Tab } from "/js/common/components/Tab.js";
import { SkyStudioButton } from "/SkyStudioButton.js";
const DEBUG_MODE = false;
loadCSS("project/Shared");
loadCSS("project/components/Slider");
let focusDebuginterval;
// Full-width, 32px tall color swatch; editing is via RGB sliders below
const ColorPickerRow = ({ label, r, g, b, disabled, }) => {
    const clamp01 = (v) => Math.max(0, Math.min(1, isNaN(v) ? 0 : v));
    const r255 = Math.round(clamp01(r) * 255);
    const g255 = Math.round(clamp01(g) * 255);
    const b255 = Math.round(clamp01(b) * 255);
    const swatchStyle = {
        width: "100%",
        height: "4rem",
        borderRadius: "2px",
        border: "1px solid rgba(255,255,255,0.25)",
        backgroundColor: `rgb(${r255}, ${g255}, ${b255})`,
        boxSizing: "border-box",
        opacity: disabled ? 0.4 : 1,
    };
    return (preact.h(FocusableDataRow, { label: label, disabled: disabled, modifiers: classNames("rowControlChildren", "skystudio_colorRow") },
        preact.h("div", { className: "skystudio_colorRow_swatchWrapper" },
            preact.h("div", { className: "skystudio_colorRow_swatch", style: swatchStyle }))));
};
class _SkyStudioUI extends preact.Component {
    constructor() {
        super(...arguments);
        this.state = {
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
            nUserMoonPhase: 0,
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
            bUserOverrideMoonPhase: false,
            bUserOverrideMoonColorAndIntensity: false,
            bUserOverrideSunFade: false,
            bUserOverrideMoonFade: false,
            bUserOverrideDayNightTransition: false,
            visibleTabIndex: 0,
            focusDebugKey: "",
        };
        this.updateFocusDebug = () => {
            this.setState({
                ...this.state,
                focusDebugKey: `${Focus.toDebugFocusKey(Focus.get())}`,
            });
        };
        this.onShow = (data) => {
            this.setState({
                ...this.state,
                visible: true,
                controlsVisible: false,
                ...data,
            });
        };
        this.onHide = () => this.setState({ visible: false });
        this.onNumericalValueChanged = (key, newValue) => {
            this.setState({ [key]: newValue });
            Engine.sendEvent(`SkyStudioChangedValue_${key}`, newValue);
        };
        this.onToggleValueChanged = (key) => (toggled) => {
            // store booleans in state
            this.setState({ [key]: toggled });
            // send booleans to the engine
            Engine.sendEvent(`SkyStudioChangedValue_${key}`, toggled);
        };
        this.handleToggleControls = (value) => {
            this.setState({
                controlsVisible: value !== undefined ? value : !this.state.controlsVisible,
            });
        };
        this.changeVisibleTab = (visibleIndex) => {
            this.setState({ visibleTabIndex: visibleIndex });
        };
        // Override input handling on the panel
        // This prevents the escape key from getting stuck opening and closing the panel when the sliders / panel content are in focus
        this.handlePanelInput = (e) => {
            if (!e.button || !e.button.isPressed(true))
                return false;
            if (e.inputName === InputName.Cancel || e.inputName === InputName.Back) {
                Focus.set("");
                this.handleToggleControls(false);
                return true;
            }
            return false;
        };
    }
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
    render() {
        const { bUseVanillaLighting, nUserSunTimeOfDay, nUserSunAzimuth, nUserSunLatitudeOffset, nUserSunColorR, nUserSunColorG, nUserSunColorB, nUserSunIntensity, nUserMoonAzimuth, nUserMoonLatitudeOffset, nUserMoonPhase, nUserMoonColorR, nUserMoonColorG, nUserMoonColorB, nUserMoonIntensity, nUserDayNightTransition, nUserSunFade, nUserMoonFade, bUserOverrideSunTimeOfDay, bUserOverrideSunOrientation, bUserOverrideSunColorAndIntensity, bUserOverrideMoonOrientation, bUserOverrideMoonPhase, bUserOverrideMoonColorAndIntensity, bUserOverrideSunFade, bUserOverrideMoonFade, bUserOverrideDayNightTransition, visibleTabIndex, } = this.state;
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
        const tabs = [
            preact.h(Tab, { key: "time", icon: "img/icons/clock.svg", label: Format.stringLiteral("Time of Day"), outcome: "SkyStudio_Tab_Time" }),
            // Hide orientation for now, I think it will get enough use to warrant putting in the first tab
            // <Tab
            //   key="orientation"
            //   icon={"img/icons/worldAxis.svg"}
            //   label={Format.stringLiteral("Sky Orientation")}
            //   outcome="SkyStudio_Tab_Orientation"
            // />,
            preact.h(Tab, { key: "suncolor", icon: "img/icons/sun.svg", label: Format.stringLiteral("Sun Color"), outcome: "SkyStudio_Tab_Sun_Color" }),
            preact.h(Tab, { key: "mooncolor", icon: "img/icons/moon.svg", label: Format.stringLiteral("Moon Color"), outcome: "SkyStudio_Tab_Moon_Color" }),
            preact.h(Tab, { key: "other", icon: "img/icons/dataList.svg", label: Format.stringLiteral("Miscellaneous"), outcome: "SkyStudio_Tab_Other" }),
        ];
        const tabViews = [
            // TAB 0: Time of day + day/night transition
            preact.h("div", { key: "time", className: "skystudio_scrollPane" },
                preact.h(PanelArea, { modifiers: "skystudio_section" },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override Time of Day"), toggled: sunTimeOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideSunTimeOfDay"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Time of Day"), min: 0, max: 24, step: 0.01, value: nUserSunTimeOfDay, onChange: (newValue) => this.onNumericalValueChanged("nUserSunTimeOfDay", newValue), editable: true, disabled: !customLightingEnabled || !sunTimeOverrideOn, focusable: true }),
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override Moon Phase"), toggled: moonPhaseOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideMoonPhase"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Phase"), min: 0, max: 360, step: 0.01, value: nUserMoonPhase, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonPhase", newValue), editable: true, disabled: !customLightingEnabled || !moonPhaseOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: "skystudio_section" },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override Sun & Moon Orientation"), toggled: sunOrientationOverrideOn, onToggle: (value) => {
                            this.onToggleValueChanged("bUserOverrideSunOrientation")(value);
                            this.onToggleValueChanged("bUserOverrideMoonOrientation")(value);
                        }, inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun Azimuth"), min: 0, max: 360, step: 1, value: nUserSunAzimuth, onChange: (newValue) => this.onNumericalValueChanged("nUserSunAzimuth", newValue), editable: true, disabled: !customLightingEnabled || !sunOrientationOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun Latitude Offset"), min: -90, max: 90, step: 1, value: nUserSunLatitudeOffset, onChange: (newValue) => this.onNumericalValueChanged("nUserSunLatitudeOffset", newValue), editable: true, disabled: !customLightingEnabled || !sunOrientationOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Azimuth"), min: 0, max: 360, step: 1, value: nUserMoonAzimuth, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonAzimuth", newValue), editable: true, disabled: !customLightingEnabled || !moonOrientationOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Latitude Offset"), min: -90, max: 90, step: 1, value: nUserMoonLatitudeOffset, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonLatitudeOffset", newValue), editable: true, disabled: !customLightingEnabled || !moonOrientationOverrideOn, focusable: true }))),
            // <div key="orientation" className="skystudio_scrollPane">
            //    This section moved to Time of Day for now
            // </div>,
            // TAB 2: Sun color + intensity
            preact.h("div", { key: "suncolor", className: "skystudio_scrollPane" },
                preact.h(PanelArea, { modifiers: "skystudio_section" },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override Sun Color & Intensity"), toggled: sunColorOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideSunColorAndIntensity"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(ColorPickerRow, { label: Format.stringLiteral("Sun Color"), r: nUserSunColorR, g: nUserSunColorG, b: nUserSunColorB, disabled: !customLightingEnabled || !sunColorOverrideOn }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun Color R"), min: 0, max: 1, step: 0.01, value: nUserSunColorR, onChange: (newValue) => this.onNumericalValueChanged("nUserSunColorR", newValue), editable: true, disabled: !customLightingEnabled || !sunColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun Color G"), min: 0, max: 1, step: 0.01, value: nUserSunColorG, onChange: (newValue) => this.onNumericalValueChanged("nUserSunColorG", newValue), editable: true, disabled: !customLightingEnabled || !sunColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun Color B"), min: 0, max: 1, step: 0.01, value: nUserSunColorB, onChange: (newValue) => this.onNumericalValueChanged("nUserSunColorB", newValue), editable: true, disabled: !customLightingEnabled || !sunColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun Intensity"), min: 0, max: 255, step: 1, value: nUserSunIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserSunIntensity", newValue), editable: true, disabled: !customLightingEnabled || !sunColorOverrideOn, focusable: true })),
                preact.h(PanelArea, null,
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override Day/Night Transition"), toggled: sunFadeOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideSunFade"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun Day/Night Fade"), min: 0, max: 1, step: 0.01, value: nUserSunFade, onChange: (newValue) => this.onNumericalValueChanged("nUserSunFade", newValue), editable: true, disabled: !customLightingEnabled || !sunFadeOverrideOn, focusable: true }))),
            // TAB 3: Moon color + intensity
            preact.h("div", { key: "mooncolor", className: "skystudio_scrollPane" },
                preact.h(PanelArea, { modifiers: "skystudio_section" },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override Moon Color & Intensity"), toggled: moonColorOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideMoonColorAndIntensity"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(ColorPickerRow, { label: Format.stringLiteral("Moon Color"), r: nUserMoonColorR, g: nUserMoonColorG, b: nUserMoonColorB, disabled: !customLightingEnabled || !moonColorOverrideOn }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Color R"), min: 0, max: 1, step: 0.01, value: nUserMoonColorR, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonColorR", newValue), editable: true, disabled: !customLightingEnabled || !moonColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Color G"), min: 0, max: 1, step: 0.01, value: nUserMoonColorG, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonColorG", newValue), editable: true, disabled: !customLightingEnabled || !moonColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Color B"), min: 0, max: 1, step: 0.01, value: nUserMoonColorB, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonColorB", newValue), editable: true, disabled: !customLightingEnabled || !moonColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Intensity"), min: 0, max: 5, step: 0.05, value: nUserMoonIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonIntensity", newValue), editable: true, disabled: !customLightingEnabled || !moonColorOverrideOn, focusable: true })),
                preact.h(PanelArea, null,
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override Day/Night Transition"), toggled: moonFadeOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideMoonFade"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Day/Night Fade"), min: 0, max: 1, step: 0.01, value: nUserMoonFade, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonFade", newValue), editable: true, disabled: !customLightingEnabled || !moonFadeOverrideOn, focusable: true }))),
            // TAB 4: Miscellaneous -- Hide the less user-friendly features here
            preact.h("div", { key: "other", className: "skystudio_scrollPane" },
                preact.h(PanelArea, { modifiers: "skystudio_section" },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override RenderParameters Transition"), toggled: dayNightOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideDayNightTransition"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("RenderParameters Day/Night Fade"), min: 0, max: 100, step: 0.01, value: nUserDayNightTransition, onChange: (newValue) => this.onNumericalValueChanged("nUserDayNightTransition", newValue), editable: true, disabled: !customLightingEnabled || !dayNightOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: "skystudio_section" },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Use Vanilla Lighting (Disables all mod features)"), toggled: useVanillaLighting, onToggle: this.onToggleValueChanged("bUseVanillaLighting"), inputName: InputName.Select, disabled: false }))),
        ];
        return (preact.h("div", { className: "skystudio_root" },
            DEBUG_MODE && (preact.h(Panel, { rootClassName: classNames("skystudio_focus_debug"), title: Format.stringLiteral("Current Focus") }, this.state.focusDebugKey)),
            preact.h("div", { className: "skystudio_toggle_menu" },
                preact.h(SkyStudioButton, { src: "img/icons/tod.svg", 
                    // tooltip is kinda janky position-wise so not having one for now
                    focused: false, toggleable: true, toggled: !!this.state.controlsVisible, onSelect: this.handleToggleControls })),
            preact.h("div", { className: "skystudio_controls_panel_wrapper" },
                preact.h(Panel, { rootClassName: classNames("skystudio_controls_panel", !this.state.controlsVisible && "hidden"), icon: "img/icons/tod.svg", title: Format.stringLiteral("Sky Studio"), onClose: this.handleToggleControls, tabs: tabs, visibleTabIndex: visibleTabIndex, onTabChange: this.changeVisibleTab, handleInput: this.handlePanelInput }, tabViews))));
    }
}
export const SkyStudioUI = Focusable.decorateEx(_SkyStudioUI, {
    focusable: false,
});
