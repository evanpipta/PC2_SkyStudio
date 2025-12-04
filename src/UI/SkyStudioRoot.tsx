import * as preact from "/js/common/lib/preact.js";
import * as DataStore from "/js/common/core/DataStore.js";
import * as Engine from "/js/common/core/Engine.js";
import * as Input from "/js/common/core/Input.js";
import * as Localisation from "/js/common/core/Localisation.js";
import * as Player from "/js/common/core/Player.js";
import * as System from "/js/common/core/System.js";
import * as Focus from "/js/common/core/Focus.js";

import { loadDebugDefaultTools } from "/js/common/debug/DebugToolImports.js";
import { SkyStudioUI } from "/SkyStudioUI.js";

Engine.initialiseSystems([
  {
    system: Engine.Systems.System,
    initialiser: System.attachToEngineReadyForSystem,
  },
  {
    system: Engine.Systems.DataStore,
    initialiser: DataStore.attachToEngineReadyForSystem,
  },
  {
    system: Engine.Systems.Input,
    initialiser: Input.attachToEngineReadyForSystem,
  },
  {
    system: Engine.Systems.Localisation,
    initialiser: Localisation.attachToEngineReadyForSystem,
  },
  {
    system: Engine.Systems.Player,
    initialiser: Player.attachToEngineReadyForSystem,
  },
]);

Engine.whenReady
  .then(async () => {
    await loadDebugDefaultTools();
    preact.render(<SkyStudioUI />, document.body);
    Engine.sendEvent("OnReady");
  })
  .catch(Engine.defaultCatch);
