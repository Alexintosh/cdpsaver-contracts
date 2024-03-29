pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./ProtocolInterface.sol";
import "../interfaces/ERC20.sol";
import "../constants/ConstantAddresses.sol";
import "./dydx/ISoloMargin.sol";

contract SavingsProxy is ConstantAddresses {

    address constant public SAVINGS_COMPOUND_ADDRESS = 0xba7676a6c3E2FFff9f8d16e9C7b1e7848CC0f7DE;
    address constant public SAVINGS_DYDX_ADDRESS = 0x97a13567879471E1d6a3C37AB1017321980cd0ca;
    address constant public SAVINGS_FULCRUM_ADDRESS = 0x0F0277EE54403a46f12D68Eeb49e444FE0bd4682;

    enum SavingsProtocol { Compound, Dydx, Fulcrum }

    function deposit(SavingsProtocol _protocol, uint _amount) public {
        approveDeposit(_protocol, _amount);

        ProtocolInterface(getAddress(_protocol)).deposit(address(this), _amount);

        endAction(_protocol);
    }

    function withdraw(SavingsProtocol _protocol, uint _amount) public {
        approveWithdraw(_protocol, _amount);

        ProtocolInterface(getAddress(_protocol)).withdraw(address(this), _amount);

        endAction(_protocol);

        withdrawDai();
    }

    function swap(SavingsProtocol _from, SavingsProtocol _to, uint _amount) public {
        withdraw(_from, _amount);
        deposit(_to, _amount);
    }

    // @dev only DSProxy holds dai, so if its called from random address, balance will be 0
    function withdrawDai() public {

        ERC20(MAKER_DAI_ADDRESS).transfer(msg.sender, ERC20(MAKER_DAI_ADDRESS).balanceOf(address(this)));
    }


    function getAddress(SavingsProtocol _protocol) public pure returns(address) {
        if (_protocol == SavingsProtocol.Compound) {
            return SAVINGS_COMPOUND_ADDRESS;
        }

        if (_protocol == SavingsProtocol.Dydx) {
            return SAVINGS_DYDX_ADDRESS;
        }

        if (_protocol == SavingsProtocol.Fulcrum) {
            return SAVINGS_FULCRUM_ADDRESS;
        }
    }

    function endAction(SavingsProtocol _protocol)  internal {
        if (_protocol == SavingsProtocol.Dydx) {
            setDydxOperator(false);
        }
    }

    function approveDeposit(SavingsProtocol _protocol, uint _amount) internal {
        ERC20(MAKER_DAI_ADDRESS).transferFrom(msg.sender, address(this), _amount);

        if (_protocol == SavingsProtocol.Compound || _protocol == SavingsProtocol.Fulcrum) {
            ERC20(MAKER_DAI_ADDRESS).approve(getAddress(_protocol), _amount);
        }

        if (_protocol == SavingsProtocol.Dydx) {
            ERC20(MAKER_DAI_ADDRESS).approve(SOLO_MARGIN_ADDRESS, _amount);
            setDydxOperator(true);
        }
    }

    function approveWithdraw(SavingsProtocol _protocol, uint _amount) internal {
        if (_protocol == SavingsProtocol.Compound) {
            ERC20(CDAI_ADDRESS).approve(getAddress(_protocol), _amount);
        }

        if (_protocol == SavingsProtocol.Dydx) {
            setDydxOperator(true);
        }

        if (_protocol == SavingsProtocol.Fulcrum) {
            ERC20(IDAI_ADDRESS).approve(getAddress(_protocol), _amount);
        }
    }

    function setDydxOperator(bool _trusted) internal {
        ISoloMargin.OperatorArg[] memory operatorArgs = new ISoloMargin.OperatorArg[](1);
        operatorArgs[0] = ISoloMargin.OperatorArg({
            operator: getAddress(SavingsProtocol.Dydx),
            trusted: _trusted
        });

        ISoloMargin(SOLO_MARGIN_ADDRESS).setOperators(operatorArgs);
    }
}
