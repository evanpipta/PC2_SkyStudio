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
import { ScrollPane } from "/js/common/components/ScrollPane.js";
import { Tab } from "/js/common/components/Tab.js";
import { Button } from "/js/project/components/Button.js";
import { ColorPickerSwatch } from "/js/project/components/colorPicker/ColorPickerSwatch.js";
import { SkyStudioButton } from "/SkyStudioButton.js";
const DEBUG_MODE = false;
loadCSS("project/Shared");
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
    bUserOverrideAtmosphere: false,
    bUserOverrideSunDisk: false,
    bUserOverrideMoonDisk: false,
    nUserFogDensity: 1,
    nUserFogScaleHeight: 500,
    nUserHazeDensity: 1,
    nUserHazeScaleHeight: 1200,
    // Sun/Moon disk and scatter
    nUserSunDiskSize: 1.5,
    nUserSunDiskIntensity: 1.35,
    nUserSunScatterIntensity: 3.0,
    nUserMoonDiskSize: 1.5,
    nUserMoonDiskIntensity: 17.5,
    nUserMoonScatterIntensity: 0.1,
    // Additional atmosphere controls
    nUserIrradianceScatterIntensity: 2.0,
    nUserSkyLightIntensity: 1.0,
    nUserSkyScatterIntensity: 1.0,
    nUserSkyDensity: 1.0,
    nUserVolumetricScatterWeight: 0.4,
    nUserVolumetricDistanceStart: 50.0,
    // Fog and Haze colors (as 0xRRGGBB integers)
    nUserFogColor: 0x5D7E9A, // Default fog color
    nUserHazeColor: 0x7DD1F9, // Default haze color
    // Sun and Moon colors (as 0xRRGGBB integers)
    nUserSunColor: 0xFFFFFF, // Default sun color (white)
    nUserMoonColor: 0x5796FF, // Default moon color (blueish)
    // Rendering tab: GI and HDR
    bUserOverrideGI: false,
    bUserOverrideHDR: false,
    nUserGISkyIntensity: 1.0,
    nUserGISunIntensity: 1.0,
    nUserGIBounceBoost: 0.39,
    nUserGIMultiBounceIntensity: 1.0,
    nUserGIEmissiveIntensity: 1.0,
    nUserGIAmbientOcclusionWeight: 0.0,
    nUserHDRAdaptionTime: 1.35,
    nUserHDRAdaptionDarknessScale: 0.9,
};
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
            confirmResetAtmosphere: false,
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
                config: {
                    ...data,
                },
                defaultConfig: {
                    ...data,
                },
            });
        };
        this.onHide = () => this.setState({ visible: false });
        this.onNumericalValueChanged = (key, newValue) => {
            this.setState({
                config: {
                    ...this.state.config,
                    [key]: newValue,
                },
            });
            Engine.sendEvent(`SkyStudioChangedValue_${key}`, newValue);
        };
        this.onToggleValueChanged = (key) => (toggled) => {
            this.setState({
                config: {
                    ...this.state.config,
                    [key]: toggled,
                },
            });
            Engine.sendEvent(`SkyStudioChangedValue_${key}`, toggled);
        };
        // Color picker handler - converts integer color (0xRRGGBB) to RGB floats [0-1]
        this.onColorValueChanged = (key) => (colorInt) => {
            this.setState({
                config: {
                    ...this.state.config,
                    [key]: colorInt,
                },
            });
            // Convert integer color to RGB floats (0-1 range)
            const r = ((colorInt >> 16) & 0xff) / 255;
            const g = ((colorInt >> 8) & 0xff) / 255;
            const b = (colorInt & 0xff) / 255;
            Engine.sendEvent(`SkyStudioChangedValue_${key}`, r, g, b);
        };
        this.handleToggleControls = (value) => {
            this.setState({
                controlsVisible: value !== undefined ? value : !this.state.controlsVisible,
                confirmResetAll: false,
                confirmResetMoon: false,
                confirmResetSun: false,
            });
        };
        this.changeVisibleTab = (visibleIndex) => {
            this.setState({
                visibleTabIndex: visibleIndex,
                confirmResetAll: false,
                confirmResetMoon: false,
                confirmResetSun: false,
            });
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
        // Begin / cancel confirmation flows
        this.beginResetSun = () => {
            this.setState({ confirmResetSun: true });
        };
        this.cancelResetSun = () => {
            this.setState({ confirmResetSun: false });
        };
        this.beginResetMoon = () => {
            this.setState({ confirmResetMoon: true });
        };
        this.cancelResetMoon = () => {
            this.setState({ confirmResetMoon: false });
        };
        this.beginResetAll = () => {
            this.setState({ confirmResetAll: true });
        };
        this.cancelResetAll = () => {
            this.setState({ confirmResetAll: false });
        };
        this.beginResetAtmosphere = () => {
            this.setState({ confirmResetAtmosphere: true });
        };
        this.cancelResetAtmosphere = () => {
            this.setState({ confirmResetAtmosphere: false });
        };
        // Core reset logic helpers
        this.resetSunToDefault = () => {
            const defaultConfig = this.state.defaultConfig;
            // All sun-related values in the "Sun Color" tab, including fade and disk settings
            const sunKeys = [
                "nUserSunColorR",
                "nUserSunColorG",
                "nUserSunColorB",
                "nUserSunColor",
                "nUserSunIntensity",
                "nUserSunGroundMultiplier",
                "nUserSunFade",
                "nUserSunDiskSize",
                "nUserSunDiskIntensity",
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
        this.resetMoonToDefault = () => {
            const defaultConfig = this.state.defaultConfig;
            // All moon-related values in the "Moon Color" tab, including fade and disk settings
            const moonKeys = [
                "nUserMoonColorR",
                "nUserMoonColorG",
                "nUserMoonColorB",
                "nUserMoonColor",
                "nUserMoonIntensity",
                "nUserMoonGroundMultiplier",
                "nUserMoonFade",
                "nUserMoonDiskSize",
                "nUserMoonDiskIntensity",
            ];
            const newConfig = { ...this.state.config };
            moonKeys.forEach((key) => {
                newConfig[key] = defaultConfig[key];
            });
            this.setState({
                config: newConfig,
                confirmResetMoon: false,
            });
            Engine.sendEvent("SkyStudio_ResetMoon");
        };
        this.resetAtmosphereToDefault = () => {
            const defaultConfig = this.state.defaultConfig;
            // All atmosphere-related values
            const atmosphereKeys = [
                "nUserFogDensity",
                "nUserFogScaleHeight",
                "nUserFogColor",
                "nUserHazeDensity",
                "nUserHazeScaleHeight",
                "nUserHazeColor",
                "nUserSkyDensity",
                "nUserSunScatterIntensity",
                "nUserMoonScatterIntensity",
                "nUserIrradianceScatterIntensity",
                "nUserSkyLightIntensity",
                "nUserSkyScatterIntensity",
                "nUserVolumetricScatterWeight",
                "nUserVolumetricDistanceStart",
            ];
            const newConfig = { ...this.state.config };
            atmosphereKeys.forEach((key) => {
                newConfig[key] = defaultConfig[key];
            });
            this.setState({
                config: newConfig,
                confirmResetAtmosphere: false,
            });
            Engine.sendEvent("SkyStudio_ResetAtmosphere");
        };
        this.beginResetRendering = () => {
            this.setState({ confirmResetRendering: true });
        };
        this.cancelResetRendering = () => {
            this.setState({ confirmResetRendering: false });
        };
        this.resetRenderingToDefault = () => {
            const defaultConfig = this.state.defaultConfig;
            // All rendering-related values (GI + HDR)
            const renderingKeys = [
                "nUserGISkyIntensity",
                "nUserGISunIntensity",
                "nUserGIBounceBoost",
                "nUserGIMultiBounceIntensity",
                "nUserGIEmissiveIntensity",
                "nUserGIAmbientOcclusionWeight",
                "nUserHDRAdaptionTime",
                "nUserHDRAdaptionDarknessScale",
            ];
            const newConfig = { ...this.state.config };
            renderingKeys.forEach((key) => {
                newConfig[key] = defaultConfig[key];
            });
            this.setState({
                config: newConfig,
                confirmResetRendering: false,
            });
            Engine.sendEvent("SkyStudio_ResetRendering");
        };
        this.resetAllToDefault = () => {
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
        const { bUseVanillaLighting, nUserSunTimeOfDay, nUserSunAzimuth, nUserSunLatitudeOffset, nUserSunColorR, nUserSunColorG, nUserSunColorB, nUserSunIntensity, nUserSunGroundMultiplier, nUserMoonAzimuth, nUserMoonLatitudeOffset, nUserMoonPhase, nUserMoonColorR, nUserMoonColorG, nUserMoonColorB, nUserMoonIntensity, nUserMoonGroundMultiplier, nUserDayNightTransition, nUserSunFade, nUserMoonFade, bUserOverrideSunTimeOfDay, bUserOverrideSunOrientation, bUserOverrideSunColorAndIntensity, bUserOverrideMoonOrientation, bUserOverrideMoonPhase, bUserOverrideMoonColorAndIntensity, bUserOverrideSunFade, bUserOverrideMoonFade, bUserOverrideDayNightTransition, bUserOverrideAtmosphere, bUserOverrideSunDisk, bUserOverrideMoonDisk, nUserFogDensity, nUserFogScaleHeight, nUserHazeDensity, nUserHazeScaleHeight, nUserSunDiskSize, nUserSunDiskIntensity, nUserSunScatterIntensity, nUserMoonDiskSize, nUserMoonDiskIntensity, nUserMoonScatterIntensity, nUserIrradianceScatterIntensity, nUserSkyLightIntensity, nUserSkyScatterIntensity, nUserSkyDensity, nUserVolumetricScatterWeight, nUserVolumetricDistanceStart, nUserFogColor, nUserHazeColor, nUserSunColor, nUserMoonColor, 
        // Rendering tab
        bUserOverrideGI, bUserOverrideHDR, nUserGISkyIntensity, nUserGISunIntensity, nUserGIBounceBoost, nUserGIMultiBounceIntensity, nUserGIEmissiveIntensity, nUserGIAmbientOcclusionWeight, nUserHDRAdaptionTime, nUserHDRAdaptionDarknessScale, } = this.state.config;
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
        const atmosphereOverrideOn = bUserOverrideAtmosphere;
        const sunDiskOverrideOn = bUserOverrideSunDisk;
        const moonDiskOverrideOn = bUserOverrideMoonDisk;
        const giOverrideOn = bUserOverrideGI;
        const hdrOverrideOn = bUserOverrideHDR;
        const showResetConfirmation = this.state.confirmResetAll ||
            this.state.confirmResetMoon ||
            this.state.confirmResetSun;
        const tabs = [
            preact.h(Tab, { key: "time", icon: "img/icons/clock.svg", label: Format.stringLiteral("Time of Day"), outcome: "SkyStudio_Tab_Time" }),
            preact.h(Tab, { key: "suncolor", icon: "img/icons/sun.svg", label: Format.stringLiteral("Sun"), outcome: "SkyStudio_Tab_Sun_Color" }),
            preact.h(Tab, { key: "mooncolor", icon: "img/icons/moon.svg", label: Format.stringLiteral("Moon"), outcome: "SkyStudio_Tab_Moon_Color" }),
            preact.h(Tab, { key: "atmosphere", icon: "img/icons/biomeTaiga.svg", label: Format.stringLiteral("Atmosphere"), outcome: "SkyStudio_Tab_Atmospherer" }),
            preact.h(Tab, { key: "rendering", icon: "img/icons/eye.svg", label: Format.stringLiteral("Rendering"), outcome: "SkyStudio_Tab_Rendering" }),
            preact.h(Tab, { key: "other", icon: "img/icons/dataList.svg", label: Format.stringLiteral("Misc"), outcome: "SkyStudio_Tab_Other" }),
        ];
        const tabViews = [
            // TAB 0: Time of day
            preact.h(ScrollPane, { key: "time", rootClassName: "skystudio_scrollPane" },
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
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Azimuth Offset"), min: -30, max: 30, step: 1, value: nUserMoonAzimuth, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonAzimuth", newValue), editable: true, disabled: !customLightingEnabled || !moonOrientationOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Latitude Offset"), min: -90, max: 90, step: 1, value: nUserMoonLatitudeOffset, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonLatitudeOffset", newValue), editable: true, disabled: !customLightingEnabled || !moonOrientationOverrideOn, focusable: true }))),
            // <div key="orientation" className="skystudio_scrollPane">
            //    This section moved to Time of Day for now
            // </div>,
            // TAB 2: Sun color + intensity
            preact.h(ScrollPane, { key: "suncolor", rootClassName: "skystudio_scrollPane" },
                this.state.confirmResetSun && (preact.h("div", { className: "skystudio_confirm_modal" },
                    preact.h("div", null,
                        preact.h("div", { className: "skystudio_reset_header" }, "Reset Sun Color/Intensity/Fade to Default?"),
                        preact.h("div", { className: "skystudio_reset_confirm_buttons" },
                            preact.h(Button, { label: Format.stringLiteral("Confirm"), onSelect: this.resetSunToDefault, modifiers: "positive", rootClassName: "skystudio_reset_confirm_button" }),
                            preact.h(Button, { label: Format.stringLiteral("Cancel"), onSelect: this.cancelResetSun, modifiers: "negative", rootClassName: "skystudio_reset_confirm_button" }))))),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetSun && "skystudio_blur") },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override Sun Color & Intensity"), toggled: sunColorOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideSunColorAndIntensity"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(FocusableDataRow, { label: Format.stringLiteral("Sun Color"), disabled: !customLightingEnabled || !sunColorOverrideOn },
                        preact.h(ColorPickerSwatch, { defaultColor: nUserSunColor, onCommit: this.onColorValueChanged("nUserSunColor"), disabled: !customLightingEnabled || !sunColorOverrideOn })),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun Intensity"), min: 0, max: 255, step: 1, value: nUserSunIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserSunIntensity", newValue), editable: true, disabled: !customLightingEnabled || !sunColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun Ground Multiplier"), min: 0, max: 5, step: 0.01, value: nUserSunGroundMultiplier, onChange: (newValue) => this.onNumericalValueChanged("nUserSunGroundMultiplier", newValue), editable: true, disabled: !customLightingEnabled || !sunColorOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetSun && "skystudio_blur") },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override Sun Disk"), toggled: sunDiskOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideSunDisk"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun Disk Size"), min: 0, max: 10, step: 0.01, value: nUserSunDiskSize, onChange: (newValue) => this.onNumericalValueChanged("nUserSunDiskSize", newValue), editable: true, disabled: !customLightingEnabled || !sunDiskOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun Disk Intensity"), min: 0, max: 20, step: 0.01, value: nUserSunDiskIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserSunDiskIntensity", newValue), editable: true, disabled: !customLightingEnabled || !sunDiskOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetSun && "skystudio_blur") },
                    preact.h(FocusableDataRow, { label: Format.stringLiteral("Reset Sun Color/Intensity/Fade") },
                        preact.h(Button, { icon: "img/icons/restart.svg", label: Format.stringLiteral("Reset Sun"), onSelect: this.beginResetSun, rootClassName: "skystudio_reset_confirm_button" })))),
            // TAB 3: Moon color + intensity
            preact.h(ScrollPane, { key: "mooncolor", rootClassName: "skystudio_scrollPane" },
                this.state.confirmResetMoon && (preact.h("div", { className: "skystudio_confirm_modal" },
                    preact.h("div", null,
                        preact.h("div", { className: "skystudio_reset_header" }, "Reset Moon Color/Intensity/Fade to Default?"),
                        preact.h("div", { className: "skystudio_reset_confirm_buttons" },
                            preact.h(Button, { label: Format.stringLiteral("Confirm"), onSelect: this.resetMoonToDefault, modifiers: "positive", rootClassName: "skystudio_reset_confirm_button" }),
                            preact.h(Button, { label: Format.stringLiteral("Cancel"), onSelect: this.cancelResetMoon, modifiers: "negative", rootClassName: "skystudio_reset_confirm_button" }))))),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetMoon && "skystudio_blur") },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override Moon Color & Intensity"), toggled: moonColorOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideMoonColorAndIntensity"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(FocusableDataRow, { label: Format.stringLiteral("Moon Color"), disabled: !customLightingEnabled || !moonColorOverrideOn },
                        preact.h(ColorPickerSwatch, { defaultColor: nUserMoonColor, onCommit: this.onColorValueChanged("nUserMoonColor"), disabled: !customLightingEnabled || !moonColorOverrideOn })),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Intensity"), min: 0, max: 5, step: 0.05, value: nUserMoonIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonIntensity", newValue), editable: true, disabled: !customLightingEnabled || !moonColorOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Ground Multiplier"), min: 0, max: 5, step: 0.01, value: nUserMoonGroundMultiplier, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonGroundMultiplier", newValue), editable: true, disabled: !customLightingEnabled || !moonColorOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetMoon && "skystudio_blur") },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override Moon Disk"), toggled: moonDiskOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideMoonDisk"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Disk Size"), min: 0, max: 10, step: 0.01, value: nUserMoonDiskSize, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonDiskSize", newValue), editable: true, disabled: !customLightingEnabled || !moonDiskOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Disk Intensity"), min: 0, max: 50, step: 0.1, value: nUserMoonDiskIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonDiskIntensity", newValue), editable: true, disabled: !customLightingEnabled || !moonDiskOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetMoon && "skystudio_blur") },
                    preact.h(FocusableDataRow, { label: Format.stringLiteral("Reset Moon Color/Intensity/Fade") },
                        preact.h(Button, { icon: "img/icons/restart.svg", label: Format.stringLiteral("Reset Moon"), onSelect: this.beginResetMoon, rootClassName: "skystudio_reset_confirm_button" })))),
            preact.h(ScrollPane, { key: "atmosphere", rootClassName: "skystudio_scrollPane" },
                this.state.confirmResetAtmosphere && (preact.h("div", { className: "skystudio_confirm_modal" },
                    preact.h("div", null,
                        preact.h("div", { className: "skystudio_reset_header" }, "Reset Atmosphere Settings to Default?"),
                        preact.h("div", { className: "skystudio_reset_confirm_buttons" },
                            preact.h(Button, { label: Format.stringLiteral("Confirm"), onSelect: this.resetAtmosphereToDefault, modifiers: "positive", rootClassName: "skystudio_reset_confirm_button" }),
                            preact.h(Button, { label: Format.stringLiteral("Cancel"), onSelect: this.cancelResetAtmosphere, modifiers: "negative", rootClassName: "skystudio_reset_confirm_button" }))))),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetAtmosphere && "skystudio_blur") },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override Atmosphere"), toggled: atmosphereOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideAtmosphere"), inputName: InputName.Select, disabled: !customLightingEnabled })),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetAtmosphere && "skystudio_blur") },
                    preact.h(SliderRow, { label: Format.stringLiteral("Atmosphere Density"), min: 0, max: 10, step: 0.01, value: nUserSkyDensity, onChange: (newValue) => this.onNumericalValueChanged("nUserSkyDensity", newValue), editable: true, disabled: !customLightingEnabled || !atmosphereOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Fog Density"), min: 0, max: 200, step: 0.01, value: nUserFogDensity, onChange: (newValue) => this.onNumericalValueChanged("nUserFogDensity", newValue), editable: true, disabled: !customLightingEnabled || !atmosphereOverrideOn, focusable: true }),
                    preact.h(FocusableDataRow, { label: Format.stringLiteral("Fog Color"), disabled: !customLightingEnabled || !atmosphereOverrideOn },
                        preact.h(ColorPickerSwatch, { defaultColor: nUserFogColor, onCommit: this.onColorValueChanged("nUserFogColor"), disabled: !customLightingEnabled || !atmosphereOverrideOn })),
                    preact.h(SliderRow, { label: Format.stringLiteral("Haze Density"), min: 0, max: 100, step: 0.1, value: nUserHazeDensity, onChange: (newValue) => this.onNumericalValueChanged("nUserHazeDensity", newValue), editable: true, disabled: !customLightingEnabled || !atmosphereOverrideOn, focusable: true }),
                    preact.h(FocusableDataRow, { label: Format.stringLiteral("Haze Color"), disabled: !customLightingEnabled || !atmosphereOverrideOn },
                        preact.h(ColorPickerSwatch, { defaultColor: nUserHazeColor, onCommit: this.onColorValueChanged("nUserHazeColor"), disabled: !customLightingEnabled || !atmosphereOverrideOn })),
                    preact.h(SliderRow, { label: Format.stringLiteral("Fog/Haze Start Distance"), min: 0, max: 500, step: 1, value: nUserVolumetricDistanceStart, onChange: (newValue) => this.onNumericalValueChanged("nUserVolumetricDistanceStart", newValue), editable: true, disabled: !customLightingEnabled || !atmosphereOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Fog/Haze Scatter Weight"), min: 0, max: 1, step: 0.01, value: nUserVolumetricScatterWeight, onChange: (newValue) => this.onNumericalValueChanged("nUserVolumetricScatterWeight", newValue), editable: true, disabled: !customLightingEnabled || !atmosphereOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetAtmosphere && "skystudio_blur") },
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun Scatter Intensity"), min: 0.01, max: 10, step: 0.01, value: nUserSunScatterIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserSunScatterIntensity", newValue), editable: true, disabled: !customLightingEnabled || !atmosphereOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Moon Scatter Intensity"), min: 0.01, max: 3, step: 0.01, value: nUserMoonScatterIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserMoonScatterIntensity", newValue), editable: true, disabled: !customLightingEnabled || !atmosphereOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Ambient Scatter Intensity"), min: 0, max: 2, step: 0.01, value: nUserIrradianceScatterIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserIrradianceScatterIntensity", newValue), editable: true, disabled: !customLightingEnabled || !atmosphereOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetAtmosphere && "skystudio_blur") },
                    preact.h(SliderRow, { label: Format.stringLiteral("Clouds Light Intensity"), min: 0, max: 5, step: 0.01, value: nUserSkyLightIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserSkyLightIntensity", newValue), editable: true, disabled: !customLightingEnabled || !atmosphereOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Clouds Scatter Intensity"), min: 0, max: 5, step: 0.01, value: nUserSkyScatterIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserSkyScatterIntensity", newValue), editable: true, disabled: !customLightingEnabled || !atmosphereOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetAtmosphere && "skystudio_blur") },
                    preact.h(FocusableDataRow, { label: Format.stringLiteral("Reset Atmosphere Settings") },
                        preact.h(Button, { icon: "img/icons/restart.svg", label: Format.stringLiteral("Reset Atmosphere"), onSelect: this.beginResetAtmosphere, rootClassName: "skystudio_reset_confirm_button" })))),
            // TAB 4: Rendering (GI + HDR)
            preact.h(ScrollPane, { key: "rendering", rootClassName: "skystudio_scrollPane" },
                this.state.confirmResetRendering && (preact.h("div", { className: "skystudio_confirm_modal" },
                    preact.h("div", null,
                        preact.h("div", { className: "skystudio_reset_header" }, "Reset Rendering Settings to Default?"),
                        preact.h("div", { className: "skystudio_reset_confirm_buttons" },
                            preact.h(Button, { label: Format.stringLiteral("Confirm"), onSelect: this.resetRenderingToDefault, modifiers: "positive", rootClassName: "skystudio_reset_confirm_button" }),
                            preact.h(Button, { label: Format.stringLiteral("Cancel"), onSelect: this.cancelResetRendering, modifiers: "negative", rootClassName: "skystudio_reset_confirm_button" }))))),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetRendering && "skystudio_blur") },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override Global Illumination"), toggled: giOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideGI"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sky Ambient Intensity"), min: 0, max: 10, step: 0.01, value: nUserGISkyIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserGISkyIntensity", newValue), editable: true, disabled: !customLightingEnabled || !giOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Sun Direct Intensity"), min: 0, max: 5, step: 0.01, value: nUserGISunIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserGISunIntensity", newValue), editable: true, disabled: !customLightingEnabled || !giOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Bounce Boost"), min: 0, max: 1, step: 0.01, value: nUserGIBounceBoost, onChange: (newValue) => this.onNumericalValueChanged("nUserGIBounceBoost", newValue), editable: true, disabled: !customLightingEnabled || !giOverrideOn, focusable: true }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Multi-Bounce Intensity"), min: 0, max: 1, step: 0.01, value: nUserGIMultiBounceIntensity, onChange: (newValue) => this.onNumericalValueChanged("nUserGIMultiBounceIntensity", newValue), editable: true, disabled: !customLightingEnabled || !giOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetRendering && "skystudio_blur") },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override HDR Adaptation"), toggled: hdrOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideHDR"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("Adaptation Time"), min: 0.1, max: 5, step: 0.01, value: nUserHDRAdaptionTime, onChange: (newValue) => this.onNumericalValueChanged("nUserHDRAdaptionTime", newValue), editable: true, disabled: !customLightingEnabled || !hdrOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetRendering && "skystudio_blur") },
                    preact.h(FocusableDataRow, { label: Format.stringLiteral("Reset Rendering Settings") },
                        preact.h(Button, { icon: "img/icons/restart.svg", label: Format.stringLiteral("Reset Rendering"), onSelect: this.beginResetRendering, rootClassName: "skystudio_reset_confirm_button" })))),
            // TAB 5: Miscellaneous -- Hide the less user-friendly features here
            preact.h("div", { key: "other", className: "skystudio_scrollPane" },
                this.state.confirmResetAll && (preact.h("div", { className: "skystudio_confirm_modal" },
                    preact.h("div", null,
                        preact.h("div", { className: "skystudio_reset_header" }, "Reset All Slider Values to Default?"),
                        preact.h("div", { className: "skystudio_reset_confirm_buttons" },
                            preact.h(Button, { label: Format.stringLiteral("Confirm"), onSelect: this.resetAllToDefault, modifiers: "positive", rootClassName: "skystudio_reset_confirm_button" }),
                            preact.h(Button, { label: Format.stringLiteral("Cancel"), onSelect: this.cancelResetAll, modifiers: "negative", rootClassName: "skystudio_reset_confirm_button" }))))),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetAll && "skystudio_blur") },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Override RenderParameters Transition"), toggled: dayNightOverrideOn, onToggle: this.onToggleValueChanged("bUserOverrideDayNightTransition"), inputName: InputName.Select, disabled: !customLightingEnabled }),
                    preact.h(SliderRow, { label: Format.stringLiteral("RenderParameters Day/Night Fade"), min: 0, max: 100, step: 0.01, value: nUserDayNightTransition, onChange: (newValue) => this.onNumericalValueChanged("nUserDayNightTransition", newValue), editable: true, disabled: !customLightingEnabled || !dayNightOverrideOn, focusable: true })),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetAll && "skystudio_blur") },
                    preact.h(ToggleRow, { label: Format.stringLiteral("Use Vanilla Lighting (Disables all mod features)"), toggled: useVanillaLighting, onToggle: this.onToggleValueChanged("bUseVanillaLighting"), inputName: InputName.Select, disabled: false })),
                preact.h(PanelArea, { modifiers: classNames("skystudio_section", this.state.confirmResetAll && "skystudio_blur") },
                    preact.h(FocusableDataRow, { label: Format.stringLiteral("Reset All Slider Values") },
                        preact.h(Button, { icon: "img/icons/restart.svg", label: Format.stringLiteral("Reset All"), onSelect: this.beginResetAll, rootClassName: "skystudio_reset_confirm_button" })))),
        ];
        return (preact.h("div", { className: "skystudio_root" },
            DEBUG_MODE && (preact.h(Panel, { rootClassName: classNames("skystudio_focus_debug"), title: Format.stringLiteral("Current Focus") },
                preact.h("div", { style: { maxWidth: "500px" } }, JSON.stringify(this.state.defaultConfig)))),
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
