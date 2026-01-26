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
import { InputField } from "/js/project/components/InputField.js";

import { Button } from "/js/project/components/Button.js";
import { ColorPickerSwatch } from "/js/project/components/colorPicker/ColorPickerSwatch.js";

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

  // Render parameter stuff:
  bUserOverrideAtmosphere: boolean;
  bUserOverrideSunDisk: boolean;
  bUserOverrideMoonDisk: boolean;
  nUserFogDensity: number;
  nUserFogScaleHeight: number;
  nUserHazeDensity: number;
  nUserHazeScaleHeight: number;

  // Sun/Moon disk and scatter
  nUserSunDiskSize: number;
  nUserSunDiskIntensity: number;
  nUserSunScatterIntensity: number;
  nUserMoonDiskSize: number;
  nUserMoonDiskIntensity: number;
  nUserMoonScatterIntensity: number;

  // Additional atmosphere controls
  nUserIrradianceScatterIntensity: number;
  nUserSkyLightIntensity: number;
  nUserSkyScatterIntensity: number;
  nUserSkyDensity: number;
  nUserVolumetricScatterWeight: number;
  nUserVolumetricDistanceStart: number;

  // Fog and Haze colors (as 0xRRGGBB integers for the color picker)
  nUserFogColor: number;
  nUserHazeColor: number;

  // Sun and Moon colors (as 0xRRGGBB integers for the color picker)
  nUserSunColor: number;
  nUserMoonColor: number;

  // Rendering tab: GI and HDR
  bUserOverrideGI: boolean;
  bUserOverrideHDR: boolean;
  nUserGISkyIntensity: number;
  nUserGISunIntensity: number;
  nUserGIBounceBoost: number;
  nUserGIMultiBounceIntensity: number;
  nUserGIEmissiveIntensity: number;
  nUserGIAmbientOcclusionWeight: number;
  nUserHDRAdaptionTime: number;
  nUserHDRAdaptionDarknessScale: number;

  // Shadows
  bUserOverrideShadows: boolean;
  nUserShadowFilterSoftness: number;

  // Clouds tab
  bUserOverrideClouds: boolean;
  nUserCloudsDensity: number;
  nUserCloudsScale: number;
  nUserCloudsSpeed: number;
  nUserCloudsAltitudeMin: number;
  nUserCloudsAltitudeMax: number;
  nUserCloudsCoverageMin: number;
  nUserCloudsCoverageMax: number;
  nUserCloudsHorizonDensity: number;
  nUserCloudsHorizonCoverageMin: number;
  nUserCloudsHorizonCoverageMax: number;

  sCurrentPresetName: string;
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
  confirmResetAtmosphere?: boolean;
  confirmResetRendering?: boolean;
  confirmResetClouds?: boolean;

  // Preset tab state
  presetList: Record<number, string>;
  presetModalState: 'none' | 'confirmSave' | 'confirmDelete' | 'confirmLoad' | 'saveAs' | 'confirmDeleteFromList';
  presetModalTargetIndex?: number; // For load/delete from list - which blueprint index is targeted
  saveAsInputValue: string;
  saveAsError: string | null;
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

  // Shadows
  bUserOverrideShadows: false,
  nUserShadowFilterSoftness: 2.5,

  // Clouds tab
  bUserOverrideClouds: false,
  nUserCloudsDensity: 150.0,
  nUserCloudsScale: 1.24,
  nUserCloudsSpeed: 70.0,
  nUserCloudsAltitudeMin: 1500.0,
  nUserCloudsAltitudeMax: 2700.0,
  nUserCloudsCoverageMin: 0.73,
  nUserCloudsCoverageMax: 1.0,
  nUserCloudsHorizonDensity: 0.0,
  nUserCloudsHorizonCoverageMin: 0.1,
  nUserCloudsHorizonCoverageMax: 1.0,

  sCurrentPresetName: "SkyStudio Preset"
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
    confirmResetAtmosphere: false,
    confirmResetClouds: false,

    presetList: {},
    presetModalState: 'none',
    presetModalTargetIndex: undefined,
    saveAsInputValue: '',
    saveAsError: null,
  };

  componentWillMount() {
    Engine.addListener("Show", this.onShow);
    Engine.addListener("Hide", this.onHide);
    Engine.addListener("UpdatePresetList", this.onUpdatePresetList);
    Engine.addListener("UpdateSettings", this.onUpdateSettings);

    focusDebuginterval = window.setInterval(this.updateFocusDebug, 250);
  }

  componentWillUnmount() {
    Engine.removeListener("Show", this.onShow);
    Engine.removeListener("Hide", this.onHide);
    Engine.removeListener("UpdatePresetList", this.onUpdatePresetList);
    Engine.removeListener("UpdateSettings", this.onUpdateSettings);

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

  // Called when settings are updated from Lua (e.g., after loading a preset)
  onUpdateSettings = (data: Partial<Config>) => {
    this.setState({
      config: {
        ...this.state.config,
        ...data,
      },
    });
  };

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

  // Track the original color before preview starts for each key
  _colorPreviewOriginal: Partial<Record<keyof Config, number>> = {};

  // Color picker preview handler - sends to engine for live preview only
  // Does NOT update React state so the original value is preserved if user cancels
  onColorPreview = (key: keyof Config) => (colorInt: number) => {
    // Store the original value if this is the first preview change
    if (this._colorPreviewOriginal[key] === undefined) {
      this._colorPreviewOriginal[key] = this.state.config[key] as number;
    }
    // Send to engine for live preview (don't update React state)
    const r = ((colorInt >> 16) & 0xff) / 255;
    const g = ((colorInt >> 8) & 0xff) / 255;
    const b = (colorInt & 0xff) / 255;
    Engine.sendEvent(`SkyStudioChangedValue_${key}`, r, g, b);
  };

  // Color picker commit handler - called when user confirms the color
  onColorCommit = (key: keyof Config) => (colorInt: number) => {
    // Update React state with the committed color
    this.setState({
      config: {
        ...this.state.config,
        [key]: colorInt,
      },
    });
    // Clear the preview original since we've committed
    delete this._colorPreviewOriginal[key];
    // Send to engine to confirm (it may already have this from preview)
    const r = ((colorInt >> 16) & 0xff) / 255;
    const g = ((colorInt >> 8) & 0xff) / 255;
    const b = (colorInt & 0xff) / 255;
    Engine.sendEvent(`SkyStudioChangedValue_${key}`, r, g, b);
  };

  // Color picker cancel handler - reverts the engine to the original color
  // Note: ColorPickerSwatch doesn't actually call this prop callback, so we also
  // handle revert via onColorPickerClose which is called on blur/click-outside
  onColorCanceled = (key: keyof Config) => () => {
    const originalColor = this._colorPreviewOriginal[key];
    if (originalColor !== undefined) {
      // Revert the engine to the original color
      const r = ((originalColor >> 16) & 0xff) / 255;
      const g = ((originalColor >> 8) & 0xff) / 255;
      const b = (originalColor & 0xff) / 255;
      Engine.sendEvent(`SkyStudioChangedValue_${key}`, r, g, b);
      // Clear the preview tracking
      delete this._colorPreviewOriginal[key];
    }
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

  beginResetAtmosphere = () => {
    this.setState({ confirmResetAtmosphere: true });
  };

  cancelResetAtmosphere = () => {
    this.setState({ confirmResetAtmosphere: false });
  };

  // Core reset logic helpers
  private resetSunToDefault = () => {
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

  private resetMoonToDefault = () => {
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

  private resetAtmosphereToDefault = () => {
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

    const newConfig: Config = { ...this.state.config };

    atmosphereKeys.forEach((key) => {
      newConfig[key] = defaultConfig[key];
    });

    this.setState({
      config: newConfig,
      confirmResetAtmosphere: false,
    });

    Engine.sendEvent("SkyStudio_ResetAtmosphere");
  };

  beginResetRendering = () => {
    this.setState({ confirmResetRendering: true });
  };

  cancelResetRendering = () => {
    this.setState({ confirmResetRendering: false });
  };

  beginResetClouds = () => {
    this.setState({ confirmResetClouds: true });
  };

  cancelResetClouds = () => {
    this.setState({ confirmResetClouds: false });
  };

  private resetCloudsToDefault = () => {
    const defaultConfig = this.state.defaultConfig;

    // All cloud-related values
    const cloudKeys = [
      "nUserCloudsDensity",
      "nUserCloudsScale",
      "nUserCloudsSpeed",
      "nUserCloudsAltitudeMin",
      "nUserCloudsAltitudeMax",
      "nUserCloudsCoverageMin",
      "nUserCloudsCoverageMax",
      "nUserCloudsHorizonDensity",
      "nUserCloudsHorizonCoverageMin",
      "nUserCloudsHorizonCoverageMax",
    ];

    const newConfig: Config = { ...this.state.config };

    cloudKeys.forEach((key) => {
      newConfig[key] = defaultConfig[key];
    });

    this.setState({
      config: newConfig,
      confirmResetClouds: false,
    });

    Engine.sendEvent("SkyStudio_ResetClouds");
  };

  private resetRenderingToDefault = () => {
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

    const newConfig: Config = { ...this.state.config };

    renderingKeys.forEach((key) => {
      newConfig[key] = defaultConfig[key];
    });

    this.setState({
      config: newConfig,
      confirmResetRendering: false,
    });

    Engine.sendEvent("SkyStudio_ResetRendering");
  };

  private resetAllToDefault = () => {
    const keysToReset = [
      // Sun settings
      "nUserSunAzimuth",
      "nUserSunLatitudeOffset",
      "nUserSunTimeOfDay",
      "nUserSunColorR",
      "nUserSunColorG",
      "nUserSunColorB",
      "nUserSunColor",
      "nUserSunIntensity",
      "nUserSunGroundMultiplier",
      "nUserSunFade",
      "nUserSunDiskSize",
      "nUserSunDiskIntensity",
      "nUserSunScatterIntensity",

      // Moon settings
      "nUserMoonAzimuth",
      "nUserMoonLatitudeOffset",
      "nUserMoonPhase",
      "nUserMoonColorR",
      "nUserMoonColorG",
      "nUserMoonColorB",
      "nUserMoonColor",
      "nUserMoonIntensity",
      "nUserMoonGroundMultiplier",
      "nUserMoonFade",
      "nUserMoonDiskSize",
      "nUserMoonDiskIntensity",
      "nUserMoonScatterIntensity",

      // Day/Night transition
      "nUserDayNightTransition",

      // Atmosphere settings
      "nUserFogDensity",
      "nUserFogScaleHeight",
      "nUserFogColor",
      "nUserHazeDensity",
      "nUserHazeScaleHeight",
      "nUserHazeColor",
      "nUserSkyDensity",
      "nUserIrradianceScatterIntensity",
      "nUserSkyLightIntensity",
      "nUserSkyScatterIntensity",
      "nUserVolumetricScatterWeight",
      "nUserVolumetricDistanceStart",

      // Rendering settings (GI + HDR)
      "nUserGISkyIntensity",
      "nUserGISunIntensity",
      "nUserGIBounceBoost",
      "nUserGIMultiBounceIntensity",
      "nUserGIEmissiveIntensity",
      "nUserGIAmbientOcclusionWeight",
      "nUserHDRAdaptionTime",
      "nUserHDRAdaptionDarknessScale",

      // Shadow settings
      "bUserOverrideShadows",
      "nUserShadowFilterSoftness",

      // Cloud settings
      "nUserCloudsDensity",
      "nUserCloudsScale",
      "nUserCloudsSpeed",
      "nUserCloudsAltitudeMin",
      "nUserCloudsAltitudeMax",
      "nUserCloudsCoverageMin",
      "nUserCloudsCoverageMax",
      "nUserCloudsHorizonDensity",
      "nUserCloudsHorizonCoverageMin",
      "nUserCloudsHorizonCoverageMax",
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

  // ========== PRESET TAB METHODS ==========
  
  // Called when preset list is received from engine
  onUpdatePresetList = (presetList: Record<number, string>) => {
    this.setState({ presetList });
  };

  // Save current preset (overwrite)
  onSavePreset = () => {
    Engine.sendEvent("SkyStudio_Preset_Save");
    this.setState({ presetModalState: 'none' });
  };

  beginSavePreset = () => {
    this.setState({ presetModalState: 'confirmSave' });
  };

  cancelSavePreset = () => {
    this.setState({ presetModalState: 'none' });
  };

  // Save As (new preset or copy)
  beginSaveAsPreset = () => {
    this.setState({ 
      presetModalState: 'saveAs',
      saveAsInputValue: this.state.config.sCurrentPresetName || '',
      saveAsError: null
    });
  };

  onSaveAsInputChange = (e: { text: string }) => {
    const newName = e.text;
    let error: string | null = null;
    
    // Check if name already exists in preset list
    if (Object.values(this.state.presetList).includes(newName)) {
      error = "A preset with this name already exists";
    }
    
    this.setState({ 
      saveAsInputValue: newName,
      saveAsError: error
    });

  };

  onSaveAsConfirm = () => {
    const name = this.state.saveAsInputValue.trim();
    if (name && !Object.values(this.state.presetList).includes(name)) {
      Engine.sendEvent("SkyStudioChangedValue_sCurrentPresetName", name);
      Engine.sendEvent("SkyStudio_Preset_SaveAs");
      this.setState({ 
        presetModalState: 'none',
        saveAsInputValue: '',
        saveAsError: null
      });
    }
  };

  cancelSaveAs = () => {
    this.setState({ 
      presetModalState: 'none',
      saveAsInputValue: '',
      saveAsError: null
    });
  };

  // Delete current preset
  beginDeleteCurrentPreset = () => {
    this.setState({ presetModalState: 'confirmDelete' });
  };

  onDeleteCurrentPreset = () => {
    const presetExists = (Object.values(this.state.presetList)).includes(this.state.config.sCurrentPresetName)
    if (presetExists) {
      Engine.sendEvent("SkyStudio_Preset_Delete", this.state.config.sCurrentPresetName);
      this.setState({ 
        presetModalState: 'none'
      });
    }
  };

  cancelDeletePreset = () => {
    this.setState({ presetModalState: 'none' });
  };

  // Load preset from list
  beginLoadPreset = (blueprintIndex: number) => {
    this.setState({ 
      presetModalState: 'confirmLoad',
      presetModalTargetIndex: blueprintIndex
    });
  };

  onLoadPreset = () => {
    const blueprintIndex = this.state.presetModalTargetIndex;
    if (blueprintIndex !== undefined) {
      // Add 1 to convert from JS 0-based index to Lua 1-based index
      Engine.sendEvent("SkyStudio_Preset_Load", blueprintIndex + 1);
      this.setState({
        presetModalState: 'none',
        presetModalTargetIndex: undefined
      });
    }
  };

  cancelLoadPreset = () => {
    this.setState({ 
      presetModalState: 'none',
      presetModalTargetIndex: undefined
    });
  };

  // Delete preset from list
  beginDeletePresetFromList = (blueprintIndex: number) => {
    this.setState({ 
      presetModalState: 'confirmDeleteFromList',
      presetModalTargetIndex: blueprintIndex
    });
  };

  onDeletePresetFromList = () => {
    const blueprintIndex = this.state.presetModalTargetIndex;
    if (blueprintIndex !== undefined) {
      // Add 1 to convert from JS 0-based index to Lua 1-based index
      Engine.sendEvent("SkyStudio_Preset_Delete", blueprintIndex + 1);
      this.setState({ 
        presetModalState: 'none',
        presetModalTargetIndex: undefined
      });
    }
  };

  cancelDeleteFromList = () => {
    this.setState({ 
      presetModalState: 'none',
      presetModalTargetIndex: undefined
    });
  };

  // Request preset list refresh
  refreshPresetList = () => {
    Engine.sendEvent("SkyStudio_Preset_RefreshList");
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

      bUserOverrideAtmosphere,
      bUserOverrideSunDisk,
      bUserOverrideMoonDisk,
      nUserFogDensity,
      nUserFogScaleHeight,
      nUserHazeDensity,
      nUserHazeScaleHeight,

      nUserSunDiskSize,
      nUserSunDiskIntensity,
      nUserSunScatterIntensity,
      nUserMoonDiskSize,
      nUserMoonDiskIntensity,
      nUserMoonScatterIntensity,

      nUserIrradianceScatterIntensity,
      nUserSkyLightIntensity,
      nUserSkyScatterIntensity,
      nUserSkyDensity,
      nUserVolumetricScatterWeight,
      nUserVolumetricDistanceStart,

      nUserFogColor,
      nUserHazeColor,

      nUserSunColor,
      nUserMoonColor,

      // Rendering tab
      bUserOverrideGI,
      bUserOverrideHDR,
      nUserGISkyIntensity,
      nUserGISunIntensity,
      nUserGIBounceBoost,
      nUserGIMultiBounceIntensity,
      nUserGIEmissiveIntensity,
      nUserGIAmbientOcclusionWeight,
      nUserHDRAdaptionTime,
      nUserHDRAdaptionDarknessScale,

      // Shadows
      bUserOverrideShadows,
      nUserShadowFilterSoftness,

      // Clouds tab
      bUserOverrideClouds,
      nUserCloudsDensity,
      nUserCloudsScale,
      nUserCloudsSpeed,
      nUserCloudsAltitudeMin,
      nUserCloudsAltitudeMax,
      nUserCloudsCoverageMin,
      nUserCloudsCoverageMax,
      nUserCloudsHorizonDensity,
      nUserCloudsHorizonCoverageMin,
      nUserCloudsHorizonCoverageMax,
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
    const atmosphereOverrideOn = bUserOverrideAtmosphere;
    const sunDiskOverrideOn = bUserOverrideSunDisk;
    const moonDiskOverrideOn = bUserOverrideMoonDisk;

    const giOverrideOn = bUserOverrideGI;
    const hdrOverrideOn = bUserOverrideHDR;
    const shadowsOverrideOn = bUserOverrideShadows;
    const cloudsOverrideOn = bUserOverrideClouds;

    const showResetConfirmation =
      this.state.confirmResetAll ||
      this.state.confirmResetMoon ||
      this.state.confirmResetSun;

    // Get entries as [index, name] pairs for the preset list
    const presetListEntries = Object.entries(this.state.presetList).map(([key, value]) => ({
      index: Number(key),
      name: value
    }))

    const tabs = [
      <Tab
        key="time"
        icon={"img/icons/clock.svg"}
        label={Format.stringLiteral("Time")}
        outcome="SkyStudio_Tab_Time"
      />,
      <Tab
        key="suncolor"
        icon={"img/icons/sun.svg"}
        label={Format.stringLiteral("Sun")}
        outcome="SkyStudio_Tab_Sun_Color"
      />,
      <Tab
        key="mooncolor"
        icon={"img/icons/moon.svg"}
        label={Format.stringLiteral("Moon")}
        outcome="SkyStudio_Tab_Moon_Color"
      />,
      <Tab
        key="atmosphere"
        icon={"img/icons/biomeTaiga.svg"}
        label={Format.stringLiteral("Atmosphere")}
        outcome="SkyStudio_Tab_Atmospherer"
      />,
      <Tab
        key="clouds"
        icon={"img/icons/footer_weather.svg"}
        label={Format.stringLiteral("Clouds")}
        outcome="SkyStudio_Tab_Clouds"
      />,
      <Tab
        key="rendering"
        icon={"img/icons/eye.svg"}
        label={Format.stringLiteral("GI")}
        outcome="SkyStudio_Tab_Rendering"
      />,
      <Tab
        key="other"
        icon={"img/icons/dataList.svg"}
        label={Format.stringLiteral("Misc")}
        outcome="SkyStudio_Tab_Other"
      />,
      <Tab
        key="preset"
        icon={"img/icons/save.svg"}
        label={Format.stringLiteral("Presets")}
        outcome="SkyStudio_Tab_Presets"
      />,
    ];

    const tabViews = [
      // TAB 0: Time of day
      <ScrollPane key="time" rootClassName="skystudio_scrollPane">
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
      </ScrollPane>,

      // <div key="orientation" className="skystudio_scrollPane">
      //    This section moved to Time of Day for now
      // </div>,

      // TAB 2: Sun color + intensity
      <div key="suncolor" className="relative">
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
        <ScrollPane rootClassName="skystudio_scrollPane">
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

          <FocusableDataRow
            label={Format.stringLiteral("Sun Color")}
            disabled={!customLightingEnabled || !sunColorOverrideOn}
          >
            <ColorPickerSwatch
              defaultColor={nUserSunColor}
              onChange={this.onColorPreview("nUserSunColor")}
              onCommit={this.onColorCommit("nUserSunColor")}
              onCancel={this.onColorCanceled("nUserSunColor")}
              disabled={!customLightingEnabled || !sunColorOverrideOn}
            />
          </FocusableDataRow>

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
            label={Format.stringLiteral("Override Sun Disk")}
            toggled={sunDiskOverrideOn}
            onToggle={this.onToggleValueChanged("bUserOverrideSunDisk")}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
          />

          <SliderRow
            label={Format.stringLiteral("Sun Disk Size")}
            min={0}
            max={10}
            step={0.01}
            value={nUserSunDiskSize}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged("nUserSunDiskSize", newValue)
            }
            editable={true}
            disabled={!customLightingEnabled || !sunDiskOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Sun Disk Intensity")}
            min={0}
            max={20}
            step={0.01}
            value={nUserSunDiskIntensity}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged("nUserSunDiskIntensity", newValue)
            }
            editable={true}
            disabled={!customLightingEnabled || !sunDiskOverrideOn}
            focusable={true}
          />
        </PanelArea>

        {/* <PanelArea
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
        </PanelArea> */}

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
        </ScrollPane>
      </div>,

      // TAB 3: Moon color + intensity
      <div key="mooncolor" className="relative">
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
        <ScrollPane rootClassName="skystudio_scrollPane">
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

          <FocusableDataRow
            label={Format.stringLiteral("Moon Color")}
            disabled={!customLightingEnabled || !moonColorOverrideOn}
          >
            <ColorPickerSwatch
              defaultColor={nUserMoonColor}
              onChange={this.onColorPreview("nUserMoonColor")}
              onCommit={this.onColorCommit("nUserMoonColor")}
              onCancel={this.onColorCanceled("nUserMoonColor")}
              disabled={!customLightingEnabled || !moonColorOverrideOn}
            />
          </FocusableDataRow>

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
            label={Format.stringLiteral("Override Moon Disk")}
            toggled={moonDiskOverrideOn}
            onToggle={this.onToggleValueChanged("bUserOverrideMoonDisk")}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
          />

          <SliderRow
            label={Format.stringLiteral("Moon Disk Size")}
            min={0}
            max={10}
            step={0.01}
            value={nUserMoonDiskSize}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged("nUserMoonDiskSize", newValue)
            }
            editable={true}
            disabled={!customLightingEnabled || !moonDiskOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Moon Disk Intensity")}
            min={0}
            max={100}
            step={0.1}
            value={nUserMoonDiskIntensity}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged("nUserMoonDiskIntensity", newValue)
            }
            editable={true}
            disabled={!customLightingEnabled || !moonDiskOverrideOn}
            focusable={true}
          />
        </PanelArea>

        {/* <PanelArea
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
        </PanelArea> */}

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
        </ScrollPane>
      </div>,

      <div key="atmosphere" className="relative">
        {this.state.confirmResetAtmosphere && (
          <div className={"skystudio_confirm_modal"}>
            <div>
              <div className={"skystudio_reset_header"}>
                Reset Atmosphere Settings to Default?
              </div>
              <div className={"skystudio_reset_confirm_buttons"}>
                <Button
                  label={Format.stringLiteral("Confirm")}
                  onSelect={this.resetAtmosphereToDefault}
                  modifiers={"positive"}
                  rootClassName={"skystudio_reset_confirm_button"}
                />
                <Button
                  label={Format.stringLiteral("Cancel")}
                  onSelect={this.cancelResetAtmosphere}
                  modifiers={"negative"}
                  rootClassName={"skystudio_reset_confirm_button"}
                />
              </div>
            </div>
          </div>
        )}
        <ScrollPane rootClassName="skystudio_scrollPane">
          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetAtmosphere && "skystudio_blur"
            )}
          >
            <ToggleRow
              label={Format.stringLiteral("Override Atmosphere")}
              toggled={atmosphereOverrideOn}
              onToggle={this.onToggleValueChanged("bUserOverrideAtmosphere")}
              inputName={InputName.Select}
              disabled={!customLightingEnabled}
            />
          </PanelArea>

          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetAtmosphere && "skystudio_blur"
            )}
          >
          <SliderRow
              label={Format.stringLiteral("Atmosphere Density")}
              min={0}
              max={10}
              step={0.01}
              value={nUserSkyDensity}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserSkyDensity", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !atmosphereOverrideOn}
              focusable={true}
            />
            
            <SliderRow
              label={Format.stringLiteral("Fog Density")}
              min={0}
              max={200}
              step={0.01}
              value={nUserFogDensity}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserFogDensity", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !atmosphereOverrideOn}
              focusable={true}
            />

            <FocusableDataRow
              label={Format.stringLiteral("Fog Color")}
              disabled={!customLightingEnabled || !atmosphereOverrideOn}
            >
              <ColorPickerSwatch
                defaultColor={nUserFogColor}
                onChange={this.onColorPreview("nUserFogColor")}
                onCommit={this.onColorCommit("nUserFogColor")}
                onCancel={this.onColorCanceled("nUserFogColor")}
                disabled={!customLightingEnabled || !atmosphereOverrideOn}
              />
            </FocusableDataRow>

            <SliderRow
              label={Format.stringLiteral("Haze Density")}
              min={0}
              max={100}
              step={0.1}
              value={nUserHazeDensity}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserHazeDensity", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !atmosphereOverrideOn}
              focusable={true}
            />

            <FocusableDataRow
              label={Format.stringLiteral("Haze Color")}
              disabled={!customLightingEnabled || !atmosphereOverrideOn}
            >
              <ColorPickerSwatch
                defaultColor={nUserHazeColor}
                onChange={this.onColorPreview("nUserHazeColor")}
                onCommit={this.onColorCommit("nUserHazeColor")}
                onCancel={this.onColorCanceled("nUserHazeColor")}
                disabled={!customLightingEnabled || !atmosphereOverrideOn}
              />
            </FocusableDataRow>

            <SliderRow
              label={Format.stringLiteral("Fog/Haze Start Distance")}
              min={0}
              max={500}
              step={1}
              value={nUserVolumetricDistanceStart}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserVolumetricDistanceStart", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !atmosphereOverrideOn}
              focusable={true}
            />

            <SliderRow
              label={Format.stringLiteral("Fog/Haze Scatter Weight")}
              min={0}
              max={1}
              step={0.01}
              value={nUserVolumetricScatterWeight}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserVolumetricScatterWeight", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !atmosphereOverrideOn}
              focusable={true}
            />
          </PanelArea>

          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetAtmosphere && "skystudio_blur"
            )}
          >
            <SliderRow
              label={Format.stringLiteral("Sun Scatter Intensity")}
              min={0.01}
              max={10}
              step={0.01}
              value={nUserSunScatterIntensity}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserSunScatterIntensity", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !atmosphereOverrideOn}
              focusable={true}
            />

            <SliderRow
              label={Format.stringLiteral("Moon Scatter Intensity")}
              min={0.01}
              max={3}
              step={0.01}
              value={nUserMoonScatterIntensity}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserMoonScatterIntensity", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !atmosphereOverrideOn}
              focusable={true}
            />

            <SliderRow
              label={Format.stringLiteral("Ambient Scatter Intensity")}
              min={0}
              max={2}
              step={0.01}
              value={nUserIrradianceScatterIntensity}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserIrradianceScatterIntensity", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !atmosphereOverrideOn}
              focusable={true}
            />
          </PanelArea>

          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetAtmosphere && "skystudio_blur"
            )}
          >
            <SliderRow
              label={Format.stringLiteral("Sky Light Intensity")}
              min={0}
              max={2}
              step={0.01}
              value={nUserSkyLightIntensity}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserSkyLightIntensity", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !atmosphereOverrideOn}
              focusable={true}
            />

            <SliderRow
              label={Format.stringLiteral("Sky Scatter Intensity")}
              min={0}
              max={2}
              step={0.01}
              value={nUserSkyScatterIntensity}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserSkyScatterIntensity", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !atmosphereOverrideOn}
              focusable={true}
            />
          </PanelArea>

          {/* Reset button */}
          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetAtmosphere && "skystudio_blur"
            )}
          >
            <FocusableDataRow label={Format.stringLiteral("Reset Atmosphere Settings")}>
              <Button
                icon={"img/icons/restart.svg"}
                label={Format.stringLiteral("Reset Atmosphere")}
                onSelect={this.beginResetAtmosphere}
                rootClassName={"skystudio_reset_confirm_button"}
              />
            </FocusableDataRow>
          </PanelArea>
        </ScrollPane>
      </div>,

      // TAB 5: Clouds
      <div key="clouds" className="relative">
        {this.state.confirmResetClouds && (
          <div className={"skystudio_confirm_modal"}>
            <div>
              <div className={"skystudio_reset_header"}>
                Reset Cloud Settings to Default?
              </div>
              <div className={"skystudio_reset_confirm_buttons"}>
                <Button
                  label={Format.stringLiteral("Confirm")}
                  onSelect={this.resetCloudsToDefault}
                  modifiers={"positive"}
                  rootClassName={"skystudio_reset_confirm_button"}
                />
                <Button
                  label={Format.stringLiteral("Cancel")}
                  onSelect={this.cancelResetClouds}
                  modifiers={"negative"}
                  rootClassName={"skystudio_reset_confirm_button"}
                />
              </div>
            </div>
          </div>
        )}
        <ScrollPane rootClassName="skystudio_scrollPane">
          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetClouds && "skystudio_blur"
            )}
          >
            <ToggleRow
              label={Format.stringLiteral("Override Clouds")}
              toggled={cloudsOverrideOn}
              onToggle={this.onToggleValueChanged("bUserOverrideClouds")}
              inputName={InputName.Select}
              disabled={!customLightingEnabled}
            />
          </PanelArea>

          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetClouds && "skystudio_blur"
            )}
          >
            <SliderRow
              label={Format.stringLiteral("Cloud Scale")}
              min={0.1}
              max={3}
              step={0.01}
              value={nUserCloudsScale}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserCloudsScale", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !cloudsOverrideOn}
              focusable={true}
            />

            <SliderRow
              label={Format.stringLiteral("Cloud Speed")}
              min={0}
              max={300}
              step={1}
              value={nUserCloudsSpeed}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserCloudsSpeed", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !cloudsOverrideOn}
              focusable={true}
            />
          </PanelArea>

          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetClouds && "skystudio_blur"
            )}
          >
            <SliderRow
              label={Format.stringLiteral("Altitude (m)")}
              min={100}
              max={6000}
              step={1}
              value={nUserCloudsAltitudeMin}
              onChange={(newValue: number) => {
                // Keep the same height when changing altitude
                const currentHeight = nUserCloudsAltitudeMax - nUserCloudsAltitudeMin;
                this.onNumericalValueChanged("nUserCloudsAltitudeMin", newValue);
                this.onNumericalValueChanged("nUserCloudsAltitudeMax", newValue + currentHeight);
              }}
              editable={true}
              disabled={!customLightingEnabled || !cloudsOverrideOn}
              focusable={true}
            />

            <SliderRow
              label={Format.stringLiteral("Height (m)")}
              min={35}
              max={5000}
              step={1}
              value={nUserCloudsAltitudeMax - nUserCloudsAltitudeMin}
              onChange={(newValue: number) => {
                // Height changes only affect AltitudeMax
                this.onNumericalValueChanged("nUserCloudsAltitudeMax", nUserCloudsAltitudeMin + newValue);
              }}
              editable={true}
              disabled={!customLightingEnabled || !cloudsOverrideOn}
              focusable={true}
            />
          </PanelArea>

          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetClouds && "skystudio_blur"
            )}
          >
            <SliderRow
              label={Format.stringLiteral("Density")}
              min={0}
              max={300}
              step={1}
              value={nUserCloudsDensity}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserCloudsDensity", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !cloudsOverrideOn}
              focusable={true}
            />

            <SliderRow
              label={Format.stringLiteral("Coverage")}
              min={0}
              max={1}
              step={0.01}
              value={1 - nUserCloudsCoverageMin}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserCloudsCoverageMin", 1 - newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !cloudsOverrideOn}
              focusable={true}
            />

            <SliderRow
              label={Format.stringLiteral("Thickness")}
              min={0}
              max={0.5}
              step={0.01}
              value={1 - nUserCloudsCoverageMax}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserCloudsCoverageMax", 1 - newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !cloudsOverrideOn}
              focusable={true}
            />
          </PanelArea>

          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetClouds && "skystudio_blur"
            )}
          >
            <SliderRow
              label={Format.stringLiteral("Horizon Density")}
              min={0}
              max={300}
              step={1}
              value={nUserCloudsHorizonDensity}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserCloudsHorizonDensity", newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !cloudsOverrideOn}
              focusable={true}
            />

            <SliderRow
              label={Format.stringLiteral("Horizon Coverage")}
              min={0}
              max={1}
              step={0.01}
              value={1 - nUserCloudsHorizonCoverageMin}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserCloudsHorizonCoverageMin", 1 - newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !cloudsOverrideOn}
              focusable={true}
            />

            <SliderRow
              label={Format.stringLiteral("Horizon Thickness")}
              min={0}
              max={0.5}
              step={0.01}
              value={1 - nUserCloudsHorizonCoverageMax}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged("nUserCloudsHorizonCoverageMax", 1 - newValue)
              }
              editable={true}
              disabled={!customLightingEnabled || !cloudsOverrideOn}
              focusable={true}
            />
          </PanelArea>

          {/* Reset button */}
          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetClouds && "skystudio_blur"
            )}
          >
            <FocusableDataRow label={Format.stringLiteral("Reset Cloud Settings")}>
              <Button
                icon={"img/icons/restart.svg"}
                label={Format.stringLiteral("Reset Clouds")}
                onSelect={this.beginResetClouds}
                rootClassName={"skystudio_reset_confirm_button"}
              />
            </FocusableDataRow>
          </PanelArea>
        </ScrollPane>
      </div>,

      // TAB 6: Rendering (GI + HDR)
      <div key="rendering" className="relative">
        {this.state.confirmResetRendering && (
          <div className={"skystudio_confirm_modal"}>
            <div>
              <div className={"skystudio_reset_header"}>
                Reset Global Illumination Settings to Default?
              </div>
              <div className={"skystudio_reset_confirm_buttons"}>
                <Button
                  label={Format.stringLiteral("Confirm")}
                  onSelect={this.resetRenderingToDefault}
                  modifiers={"positive"}
                  rootClassName={"skystudio_reset_confirm_button"}
                />
                <Button
                  label={Format.stringLiteral("Cancel")}
                  onSelect={this.cancelResetRendering}
                  modifiers={"negative"}
                  rootClassName={"skystudio_reset_confirm_button"}
                />
              </div>
            </div>
          </div>
        )}
        <ScrollPane rootClassName="skystudio_scrollPane">
          <PanelArea
          modifiers={classNames(
            "skystudio_section",
            this.state.confirmResetRendering && "skystudio_blur"
          )}
        >
          <ToggleRow
            label={Format.stringLiteral("Override Global Illumination")}
            toggled={giOverrideOn}
            onToggle={this.onToggleValueChanged("bUserOverrideGI")}
            inputName={InputName.Select}
            disabled={!customLightingEnabled}
          />

          <SliderRow
            label={Format.stringLiteral("Sky Ambient Intensity")}
            min={0}
            max={10} 
            step={0.01}
            value={nUserGISkyIntensity}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserGISkyIntensity",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !giOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Sun Direct Intensity")}
            min={0}
            max={5}
            step={0.01}
            value={nUserGISunIntensity}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserGISunIntensity",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !giOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Bounce Boost")}
            min={0}
            max={1}
            step={0.01}
            value={nUserGIBounceBoost}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserGIBounceBoost",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !giOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Multi-Bounce Intensity")}
            min={0}
            max={1}
            step={0.01}
            value={nUserGIMultiBounceIntensity}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserGIMultiBounceIntensity",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !giOverrideOn}
            focusable={true}
          />

          {/* <SliderRow
            label={Format.stringLiteral("Emissive Intensity")}
            min={0}
            max={5}
            step={0.01}
            value={nUserGIEmissiveIntensity}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserGIEmissiveIntensity",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !giOverrideOn}
            focusable={true}
          />

          <SliderRow
            label={Format.stringLiteral("Ambient Occlusion Weight")}
            min={0}
            max={1}
            step={0.01}
            value={nUserGIAmbientOcclusionWeight}
            onChange={(newValue: number) =>
              this.onNumericalValueChanged(
                "nUserGIAmbientOcclusionWeight",
                newValue as number
              )
            }
            editable={true}
            disabled={!customLightingEnabled || !giOverrideOn}
            focusable={true}
          /> */}
        </PanelArea>



        <PanelArea
          modifiers={classNames(
            "skystudio_section",
            this.state.confirmResetRendering && "skystudio_blur"
          )}
        >
          <FocusableDataRow label={Format.stringLiteral("Reset GI Settings")}>
            <Button
              icon={"img/icons/restart.svg"}
              label={Format.stringLiteral("Reset GI")}
              onSelect={this.beginResetRendering}
              rootClassName={"skystudio_reset_confirm_button"}
            />
          </FocusableDataRow>
        </PanelArea>
        </ScrollPane>
      </div>,

      // TAB 5: Miscellaneous -- Hide the less user-friendly features here
      <div key="other" className="relative">
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
        <ScrollPane rootClassName="skystudio_scrollPane">
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

          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetRendering && "skystudio_blur"
            )}
          >
            <ToggleRow
              label={Format.stringLiteral("Override HDR Adaptation")}
              toggled={hdrOverrideOn}
              onToggle={this.onToggleValueChanged("bUserOverrideHDR")}
              inputName={InputName.Select}
              disabled={!customLightingEnabled}
            />

            <SliderRow
              label={Format.stringLiteral("Adaptation Time")}
              min={0.1}
              max={2}
              step={0.01}
              value={nUserHDRAdaptionTime}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged(
                  "nUserHDRAdaptionTime",
                  newValue as number
                )
              }
              editable={true}
              disabled={!customLightingEnabled || !hdrOverrideOn}
              focusable={true}
            />

            {/* <SliderRow
              label={Format.stringLiteral("Darkness Adaptation Scale")}
              min={0}
              max={2}
              step={0.01}
              value={nUserHDRAdaptionDarknessScale}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged(
                  "nUserHDRAdaptionDarknessScale",
                  newValue as number
                )
              }
              editable={true}
              disabled={!customLightingEnabled || !hdrOverrideOn}
              focusable={true}
            /> */}
          </PanelArea>

          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetAll && "skystudio_blur"
            )}
          >
            <ToggleRow
              label={Format.stringLiteral("Override Shadow Softness")}
              toggled={shadowsOverrideOn}
              onToggle={this.onToggleValueChanged("bUserOverrideShadows")}
              inputName={InputName.Select}
              disabled={!customLightingEnabled}
            />

            <SliderRow
              label={Format.stringLiteral("Shadow Softness")}
              min={0}
              max={100}
              step={0.1}
              value={nUserShadowFilterSoftness}
              onChange={(newValue: number) =>
                this.onNumericalValueChanged(
                  "nUserShadowFilterSoftness",
                  newValue as number
                )
              }
              editable={true}
              disabled={!customLightingEnabled || !shadowsOverrideOn}
              focusable={true}
            />
          </PanelArea>

          {/* Global enable/disable */}
          {/* <PanelArea
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
          </PanelArea> */}

          <PanelArea
            modifiers={classNames(
              "skystudio_section",
              this.state.confirmResetAll && "skystudio_blur"
            )}
          >
            <FocusableDataRow label={Format.stringLiteral("Reset All Slider Values")}>
              <Button
                icon={"img/icons/restart.svg"}
                label={Format.stringLiteral("Reset All")}
                onSelect={this.beginResetAll}
                rootClassName={"skystudio_reset_confirm_button"}
              />
            </FocusableDataRow>
          </PanelArea>
        </ScrollPane>
      </div>,
      // TAB 7: Presets
      <div key="presets" className="relative">
            {/* Confirm Save Modal */}
            {this.state.presetModalState === 'confirmSave' && (
              <div className={"skystudio_confirm_modal"}>
                <div>
                  <div className={"skystudio_reset_header"}>
                    Save changes to "{this.state.config.sCurrentPresetName}"?
                  </div>
                  <div className={"skystudio_reset_confirm_buttons"}>
                    <Button
                      label={Format.stringLiteral("Confirm")}
                      onSelect={this.onSavePreset}
                      modifiers={"positive"}
                      rootClassName={"skystudio_reset_confirm_button"}
                    />
                    <Button
                      label={Format.stringLiteral("Cancel")}
                      onSelect={this.cancelSavePreset}
                      modifiers={"negative"}
                      rootClassName={"skystudio_reset_confirm_button"}
                    />
                  </div>
                </div>
              </div>
            )}
    
            {/* Confirm Delete Current Preset Modal */}
            {this.state.presetModalState === 'confirmDelete' && (
              <div className={"skystudio_confirm_modal"}>
                <div>
                  <div className={"skystudio_reset_header"}>
                    Delete preset "{this.state.config.sCurrentPresetName}"?
                  </div>
                  <div className={"skystudio_reset_confirm_buttons"}>
                    <Button
                      label={Format.stringLiteral("Delete")}
                      onSelect={this.onDeleteCurrentPreset}
                      modifiers={"negative"}
                      rootClassName={"skystudio_reset_confirm_button"}
                    />
                    <Button
                      label={Format.stringLiteral("Cancel")}
                      onSelect={this.cancelDeletePreset}
                      rootClassName={"skystudio_reset_confirm_button"}
                    />
                  </div>
                </div>
              </div>
            )}
    
            {/* Confirm Load Modal */}
            {this.state.presetModalState === 'confirmLoad' && this.state.presetModalTargetIndex !== undefined && (
              <div className={"skystudio_confirm_modal"}>
                <div>
                  <div className={"skystudio_reset_header"}>
                    Load preset "{this.state.presetList[this.state.presetModalTargetIndex]}"?
                  </div>
                  <div style={{ marginBottom: '12px', opacity: 0.7 }}>
                    Unsaved changes will be lost.
                  </div>
                  <div className={"skystudio_reset_confirm_buttons"}>
                    <Button
                      label={Format.stringLiteral("Load")}
                      onSelect={this.onLoadPreset}
                      modifiers={"positive"}
                      rootClassName={"skystudio_reset_confirm_button"}
                    />
                    <Button
                      label={Format.stringLiteral("Cancel")}
                      onSelect={this.cancelLoadPreset}
                      modifiers={"negative"}
                      rootClassName={"skystudio_reset_confirm_button"}
                    />
                  </div>
                </div>
              </div>
            )}
    
            {/* Confirm Delete From List Modal */}
            {this.state.presetModalState === 'confirmDeleteFromList' && this.state.presetModalTargetIndex !== undefined && (
              <div className={"skystudio_confirm_modal"}>
                <div>
                  <div className={"skystudio_reset_header"}>
                    Delete preset "{this.state.presetList[this.state.presetModalTargetIndex]}"?
                  </div>
                  <div className={"skystudio_reset_confirm_buttons"}>
                    <Button
                      label={Format.stringLiteral("Delete")}
                      onSelect={this.onDeletePresetFromList}
                      modifiers={"negative"}
                      rootClassName={"skystudio_reset_confirm_button"}
                    />
                    <Button
                      label={Format.stringLiteral("Cancel")}
                      onSelect={this.cancelDeleteFromList}
                      rootClassName={"skystudio_reset_confirm_button"}
                    />
                  </div>
                </div>
              </div>
            )}
    
            {/* Save As Modal */}
            {this.state.presetModalState === 'saveAs' && (
              <div className={"skystudio_confirm_modal"}>
                <div>
                  <div className={"skystudio_reset_header"}>
                    Save As New Preset
                  </div>
                  <div className="skystudio_preset_input_wrapper">
                    <InputField
                      text={this.state.saveAsInputValue}
                      onChange={this.onSaveAsInputChange}
                      onCommit={this.onSaveAsInputChange}
                      maxInputLength={64}
                      promptText={Format.stringLiteral("Enter preset name...")}
                      rootClassName="skystudio_preset_input"
                    />
                  </div>
                  {this.state.saveAsError && (
                    <div style={{ color: '#ff6b6b', marginBottom: '12px', fontSize: '12px' }}>
                      {this.state.saveAsError}
                    </div>
                  )}
                  <div className={"skystudio_reset_confirm_buttons"}>
                    <Button
                      label={Format.stringLiteral("Save")}
                      onSelect={this.onSaveAsConfirm}
                      modifiers={"positive"}
                      rootClassName={"skystudio_reset_confirm_button"}
                      disabled={!this.state.saveAsInputValue.trim() || !!this.state.saveAsError}
                    />
                    <Button
                      label={Format.stringLiteral("Cancel")}
                      onSelect={this.cancelSaveAs}
                      modifiers={"negative"}
                      rootClassName={"skystudio_reset_confirm_button"}
                    />
                  </div>
                </div>
              </div>
            )}
    
            <ScrollPane rootClassName="skystudio_scrollPane">
              {/* Current Preset Section */}
              <PanelArea
                modifiers={classNames(
                  "skystudio_section",
                  this.state.presetModalState !== 'none' && "skystudio_blur"
                )}
              >
                <div style={{ marginBottom: '8px', fontWeight: 'bold' }}>
                  {this.state.config.sCurrentPresetName ? "Current Preset: " + this.state.config.sCurrentPresetName : "No Preset Loaded"}
                </div>
                
                <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                  {this.state.config.sCurrentPresetName && (
                  <Button
                    icon={"img/icons/save.svg"}
                    label={Format.stringLiteral("Save")}
                    onSelect={this.beginSavePreset}
                    rootClassName={"skystudio_preset_button"}
                    disabled={!this.state.config.sCurrentPresetName}
                  />
                  )}
                  <Button
                    icon={"img/icons/save.svg"}
                    label={Format.stringLiteral("Save As New")}
                    onSelect={this.beginSaveAsPreset}
                    rootClassName={"skystudio_preset_button"}
                  />
                  {this.state.config.sCurrentPresetName && (
                  <Button
                    icon={"img/icons/delete.svg"}
                    label={Format.stringLiteral("Delete")}
                    onSelect={this.beginDeleteCurrentPreset}
                    modifiers={"negative"}
                    rootClassName={"skystudio_preset_button"}
                    disabled={!this.state.config.sCurrentPresetName}
                  />)}
                </div>
              {/* </PanelArea> */}
    
              {/* Preset List Section */}
              {/* <PanelArea
                modifiers={classNames(
                  "skystudio_section",
                  this.state.presetModalState !== 'none' && "skystudio_blur"
                )}
              > */}
                <div style={{ marginBottom: '8px', fontWeight: 'bold' }}>
                  Saved Presets
                </div>
                
                {presetListEntries.length === 0 ? (
                  <div style={{ opacity: 0.6, fontStyle: 'italic' }}>
                    No presets saved yet. Use "Save As" to create one.
                  </div>
                ) : (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
                    {presetListEntries.map(({ index, name }) => (
                      <div 
                        key={index}
                        style={{ 
                          display: 'flex', 
                          alignItems: 'center', 
                          justifyContent: 'space-between',
                          padding: '8px 12px',
                          background: this.state.config.sCurrentPresetName === name 
                            ? 'rgba(100, 200, 255, 0.2)' 
                            : 'rgba(255, 255, 255, 0.05)',
                          borderRadius: '4px'
                        }}
                      >
                        <span style={{ flex: 1 }}>{name}</span>
                        <div style={{ display: 'flex', gap: '4px' }}>
                          <Button
                            icon={"img/icons/load.svg"}
                            onSelect={() => this.beginLoadPreset(index)}
                            rootClassName={"skystudio_preset_list_button"}
                          />
                          <Button
                            icon={"img/icons/delete.svg"}
                            onSelect={() => this.beginDeletePresetFromList(index)}
                            modifiers={"negative"}
                            rootClassName={"skystudio_preset_list_button"}
                          />
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </PanelArea>
            </ScrollPane>
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

