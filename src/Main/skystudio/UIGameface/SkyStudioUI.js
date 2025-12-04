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
let focusDebuginterval;
// Full-width, 32px tall color swatch; editing is via RGB sliders below
const ColorPickerRow = ({ label, r, g, b, disabled, }) => {
    const clamp01 = (v) => Math.max(0, Math.min(1, isNaN(v) ? 0 : v));
    const r255 = Math.round(clamp01(r) * 255);
    const g255 = Math.round(clamp01(g) * 255);
    const b255 = Math.round(clamp01(b) * 255);
    const swatchStyle = {
        width: "100%",
        height: "32px",
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
        const { bUseVanillaLighting, nUserSunTimeOfDay, nUserSunAzimuth, nUserSunLatitudeOffset, nUserSunColorR, nUserSunColorG, nUserSunColorB, nUserSunIntensity, nUserMoonAzimuth, nUserMoonLatitudeOffset, nUserMoonTimeOfDay, nUserMoonColorR, nUserMoonColorG, nUserMoonColorB, nUserMoonIntensity, nUserDayNightTransition, nUserSunFade, nUserMoonFade, bUserOverrideSunTimeOfDay, bUserOverrideSunOrientation, bUserOverrideSunColorAndIntensity, bUserOverrideMoonOrientation, bUserOverrideMoonTimeOfDay, bUserOverrideMoonColorAndIntensity, bUserOverrideDayNightTransition, visibleTabIndex, } = this.state;
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
            preact.h(Tab, { key: "time", label: Format.stringLiteral("Time / Transition"), outcome: "SkyStudio_Tab_Time" }),
            preact.h(Tab, { key: "orientation", label: Format.stringLiteral("Orientation"), outcome: "SkyStudio_Tab_Orientation" }),
            preact.h(Tab, { key: "color", label: Format.stringLiteral("Color & Intensity"), outcome: "SkyStudio_Tab_Color" }),
        ];
        const tabViews = [
            // TAB 0: Time of day + day/night transition
            preact.h(ScrollPane, { key: "time", rootClassName: "skystudio_scrollPane", contentClassName: "skystudio_scrollPaneContent" },
                preact.h(PanelArea, { modifiers: "skystudio_section" },
                    preact.h(PanelHeader, { text: Format.stringLiteral("Global Lighting Control") }),
                    preact.h(ToggleRow, { label: Format.stringLiteral("Use vanilla lighting"), toggled: useVanillaLighting, onToggle: this.onToggleValueChanged("bUseVanillaLighting"), inputName: InputName.Select, disabled: false })),
                preact.h(PanelArea, { modifiers: "skystudio_section" },
                    preact.h(PanelHeader, { text: Format.stringLiteral("Time of day") }),
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override time of day"), toggled: sunTimeOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideSunTimeOfDay"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Time of day"), min: -90, max: 270, step: 0.01, value: nUserSunTimeOfDay, onChange: (newValue) => this.onNumericalValueChanged("nUserSunTimeOfDay", newValue), editable: true, disabled: !customLightingEnabled || !sunTimeOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: "skystudio_section" },
                    preact.h(PanelHeader, { text: Format.stringLiteral("Day / night transition") }),
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override day / night transition"), toggled: dayNightOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideDayNightTransition"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Day / night fade"), min: 37, max: 100, step: 0.01, value: nUserDayNightTransition, onChange: (newValue) => this.onNumericalValueChanged("nUserDayNightTransition", newValue), editable: true, disabled: !customLightingEnabled || !dayNightOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun fade"), min: 0, max: 1, step: 0.01, value: nUserSunFade, onChange: (newValue) => this.onNumericalValueChanged("nUserSunFade", newValue), editable: true, disabled: !customLightingEnabled || !dayNightOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon fade"), min: 0, max: 1, step: 0.01, value: nUserMoonFade, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonFade", newValue), editable: true, disabled: !customLightingEnabled || !dayNightOverrideOn, focusable: true }))),
            // TAB 1: Sun & Moon orientation
            preact.h(ScrollPane, { key: "orientation", rootClassName: "skystudio_scrollPane", contentClassName: "skystudio_scrollPaneContent" },
                preact.h(PanelArea, { modifiers: "skystudio_section" },
                    preact.h(PanelHeader, { text: Format.stringLiteral("Sun orientation") }),
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override sun orientation"), toggled: sunOrientationOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideSunOrientation"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun azimuth"), min: 0, max: 360, step: 1, value: nUserSunAzimuth, onChange: (newValue) => this.onNumericalValueChanged("nUserSunAzimuth", newValue), editable: true, disabled: !customLightingEnabled || !sunOrientationOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun latitude offset"), min: -90, max: 90, step: 1, value: nUserSunLatitudeOffset, onChange: (newValue) => this.onNumericalValueChanged("nUserSunLatitudeOffset", newValue), editable: true, disabled: !customLightingEnabled || !sunOrientationOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: "skystudio_section" },
                    preact.h(PanelHeader, { text: Format.stringLiteral("Moon orientation & time") }),
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override moon orientation"), toggled: moonOrientationOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideMoonOrientation"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override moon time of day"), toggled: moonTimeOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideMoonTimeOfDay"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon azimuth"), min: 0, max: 360, step: 1, value: nUserMoonAzimuth, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonAzimuth", newValue), editable: true, disabled: !customLightingEnabled || !moonOrientationOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon latitude offset"), min: -90, max: 90, step: 1, value: nUserMoonLatitudeOffset, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonLatitudeOffset", newValue), editable: true, disabled: !customLightingEnabled || !moonOrientationOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon time of day"), min: -90, max: 270, step: 0.01, value: nUserMoonTimeOfDay, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonTimeOfDay", newValue), editable: true, disabled: !customLightingEnabled || !moonTimeOverrideOn, focusable: true }))),
            // TAB 2: Sun & Moon color + intensity
            preact.h(ScrollPane, { key: "color", rootClassName: "skystudio_scrollPane", contentClassName: "skystudio_scrollPaneContent" },
                preact.h(PanelArea, { modifiers: "skystudio_section" },
                    preact.h(PanelHeader, { text: Format.stringLiteral("Sun color & intensity") }),
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override sun color & intensity"), toggled: sunColorOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideSunColorAndIntensity"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(ColorPickerRow, { label: Format.stringLiteral("Sun color"), r: nUserSunColorR, g: nUserSunColorG, b: nUserSunColorB, disabled: !customLightingEnabled || !sunColorOverrideOn }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun color R"), min: 0, max: 1, step: 0.01, value: nUserSunColorR, onChange: (newValue) => this.onNumericalValueChanged("nUserSunColorR", newValue), editable: true, disabled: !customLightingEnabled || !sunColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun color G"), min: 0, max: 1, step: 0.01, value: nUserSunColorG, onChange: (newValue) => this.onNumericalValueChanged("nUserSunColorG", newValue), editable: true, disabled: !customLightingEnabled || !sunColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun color B"), min: 0, max: 1, step: 0.01, value: nUserSunColorB, onChange: (newValue) => this.onNumericalValueChanged("nUserSunColorB", newValue), editable: true, disabled: !customLightingEnabled || !sunColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun intensity"), min: 0, max: 255, step: 1, value: nUserSunIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserSunIntensity", newValue), editable: true, disabled: !customLightingEnabled || !sunColorOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: "skystudio_section" },
                    preact.h(PanelHeader, { text: Format.stringLiteral("Moon color & intensity") }),
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override moon color & intensity"), toggled: moonColorOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideMoonColorAndIntensity"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(ColorPickerRow, { label: Format.stringLiteral("Moon color"), r: nUserMoonColorR, g: nUserMoonColorG, b: nUserMoonColorB, disabled: !customLightingEnabled || !moonColorOverrideOn }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon color R"), min: 0, max: 1, step: 0.01, value: nUserMoonColorR, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonColorR", newValue), editable: true, disabled: !customLightingEnabled || !moonColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon color G"), min: 0, max: 1, step: 0.01, value: nUserMoonColorG, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonColorG", newValue), editable: true, disabled: !customLightingEnabled || !moonColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon color B"), min: 0, max: 1, step: 0.01, value: nUserMoonColorB, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonColorB", newValue), editable: true, disabled: !customLightingEnabled || !moonColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon intensity"), min: 0, max: 5, step: 0.05, value: nUserMoonIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonIntensity", newValue), editable: true, disabled: !customLightingEnabled || !moonColorOverrideOn, focusable: true }))),
        ];
        return (preact.h("div", { className: "skystudio_root" },
            DEBUG_MODE && (preact.h(Panel, { rootClassName: classNames("skystudio_focus_debug"), title: Format.stringLiteral("Current Focus") }, this.state.focusDebugKey)),
            preact.h("div", { className: "skystudio_toggle_menu" },
                preact.h(SkyStudioButton, { src: "img/icons/tod.svg", tooltip: Format.stringLiteral("Sky Studio"), focused: false, toggleable: true, toggled: !!this.state.controlsVisible, onSelect: this.handleToggleControls })),
            preact.h("div", { className: "skystudio_controls_panel_wrapper" },
                preact.h(Panel, { rootClassName: classNames("skystudio_controls_panel", !this.state.controlsVisible && "hidden"), title: Format.stringLiteral("Sky Studio"), onClose: this.handleToggleControls, tabs: tabs, visibleTabIndex: visibleTabIndex, onTabChange: this.changeVisibleTab, handleInput: this.handlePanelInput }, tabViews))));
    }
}
export const SkyStudioUI = Focusable.decorateEx(_SkyStudioUI, {
    focusable: false,
});
