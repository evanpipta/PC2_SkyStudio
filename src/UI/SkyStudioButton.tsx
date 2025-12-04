import { ButtonBehaviour } from "/js/common/components/ButtonBehaviour.js";
import { Constraint } from "/js/common/components/Constraint.js";
import * as Focusable from "/js/common/components/Focusable.js";
import { Icon } from "/js/common/components/Icon.js";
import { InputIconEx } from "/js/common/components/InputIcon.js";
import * as Focus from "/js/common/core/Focus.js";
import { currentInputMethodIs } from "/js/common/core/Input.js";
import { InputMethod } from "/js/common/core/InputTypes.js";
import { classNames } from "/js/common/lib/classnames.js";
import * as preact from "/js/common/lib/preact.js";
import { loadCSS } from "/js/common/util/CSSUtil.js";
import {
  TooltipAutoHideShort,
  TooltipContainer,
} from "/js/project/components/Tooltip.js";

loadCSS("project/modules/managementMenu/ManagementMenuButton");

interface SkyStudioButtonProps {
  src: string;
  rootClassName?: string;
  modifiers?: any;
  disabled?: boolean;
  userData?: any;
  onToggle?: (toggled: boolean, userData: any) => void;
  toggled?: boolean;
  toggleable?: boolean;
  onSelect?: (userData: any) => void;
  outcome?: any;
  focused?: boolean;
  inputName?: string;
  tooltip?: preact.ComponentChildren;
  tooltipInputName?: string;
  focusOnHover?: boolean;
  focusKey?: any;
}

interface SkyStudioButtonState {
  hover: boolean;
}

const TOOLTIP_ANCHOR = [Constraint.LeftOutside, Constraint.CenterV];

class _SkyStudioButton extends preact.Component<
  SkyStudioButtonProps,
  SkyStudioButtonState
> {
  state: SkyStudioButtonState = {
    hover: false,
  };

  render(props: SkyStudioButtonProps, state: SkyStudioButtonState) {
    const { src, rootClassName, modifiers, disabled, userData, onToggle } =
      props;
    const focused = state.hover === true || props.focused === true;
    const isGamepad = currentInputMethodIs(InputMethod.Gamepad);
    const showTooltip =
      (focused && isGamepad) || (!isGamepad && state.hover === true);

    return (
      <ButtonBehaviour
        rootClassName={classNames(
          "ManagementMenuButton_root",
          rootClassName,
          modifiers,
          { focused, disabled }
        )}
        userData={userData}
        toggled={props.toggled}
        toggleable={props.toggleable}
        onHover={this.onHover}
        onLeave={this.onLeave}
        onSelect={this.onSelect}
        onToggle={onToggle}
        outcome={props.outcome}
        disabled={props.disabled}
      >
        <Icon
          rootClassName={classNames("ManagementMenuButton_icon", modifiers, {
            focused,
            disabled,
          })}
          src={src}
        />
        {props.inputName && (
          <InputIconEx
            rootClassName="ManagementMenuButton_buttonPrompt"
            modifiers={modifiers}
            inputName={props.inputName}
            onlyShowWhenInputMethodIs={InputMethod.Gamepad}
          />
        )}
        {props.tooltip && showTooltip && (
          <TooltipContainer
            target={this}
            tooltip={props.tooltip}
            inputName={props.tooltipInputName}
            modifiers="hudAccess extraMargin inputIconOnLeft"
            showDuration={TooltipAutoHideShort}
            anchor={TOOLTIP_ANCHOR}
          />
        )}
      </ButtonBehaviour>
    );
  }

  onHover = (): void => {
    if (this.props.focusOnHover !== false) {
      Focus.set(this.props.focusKey, Focus.ChangeReason.Hover);
    }
    this.setState({ hover: true });
  };

  onLeave = (): void => {
    this.setState({ hover: false });
  };

  onSelect = (userData: any): void => {
    this.setState({ hover: false });
    if (this.props.onSelect) {
      this.props.onSelect(userData);
    }
  };
}

export const SkyStudioButton = Focusable.decorate(
  _SkyStudioButton as any
) as any;
