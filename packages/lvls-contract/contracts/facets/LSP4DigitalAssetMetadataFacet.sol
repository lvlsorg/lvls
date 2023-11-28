// errors
import {LSP4TokenNameNotEditable, LSP4TokenSymbolNotEditable} from "@lukso/lsp-smart-contracts/LSP4DigitalAssetMetadata/LSP4Errors.sol";
import {Lib725} from "../libraries/Lib725.sol";
import {IERC725Y} from "@erc725/smart-contracts/contracts/ERC725YCore.sol";

/**
 * @title Implementation of a LSP4DigitalAssetMetadata contract that stores the **Token-Metadata** (`LSP4TokenName` and `LSP4TokenSymbol`) in its ERC725Y data store.
 * @author Matthew Stevens
 * @dev Standard Implementation of the LSP4 standard.
 */
abstract contract LSP4DigitalAssetMetadata is IERC725Y {
    /**
     * @notice Deploying a digital asset `name_` with the `symbol_` symbol.
     *
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @param initialOwner_ The owner of the token contract
     */
    constructor() {
        // TODO potentially enforce set once symbol ad token
        // set data key SupportedStandards:LSP4DigitalAsset
        super._setData(_LSP4_SUPPORTED_STANDARDS_KEY, _LSP4_SUPPORTED_STANDARDS_VALUE);
    }

    /**
     * @dev The ERC725Y data keys `LSP4TokenName` and `LSP4TokenSymbol` cannot be changed
     * via this function once the digital asset contract has been deployed.
     *
     * @dev Save gas by emitting the {DataChanged} event with only the first 256 bytes of dataValue
     */
    function _setData(bytes32 dataKey, bytes memory dataValue) internal virtual override {
        /*    if (dataKey == _LSP4_TOKEN_NAME_KEY) {
            revert LSP4TokenNameNotEditable();
        } else if (dataKey == _LSP4_TOKEN_SYMBOL_KEY) {
            revert LSP4TokenSymbolNotEditable();
        } else {*/
        // _store[dataKey] = dataValue;
        Lib725._setData(dataKey, dataValue);
        emit DataChanged(dataKey, dataValue.length <= 256 ? dataValue : BytesLib.slice(dataValue, 0, 256));
        //}
    }

    function getData(bytes32 dataKey) public view virtual override returns (bytes memory dataValue) {
        dataValue = Lib725._getData(dataKey);
    }

    function getDataBatch(bytes32[] memory dataKeys) public view virtual returns (bytes[] memory dataValues) {
        return Lib725._getBatchData(dataKeys);
    }

    function setData(bytes32 dataKey, bytes memory dataValue) public payable virtual override onlyOwner {
        _setData(dataKey, dataValue);
    }

    function setDataBatch(bytes32[] memory dataKeys, bytes[] memory dataValues) public payable virtual override onlyOwner {
        Lib725._setBatchData(dataKeys, dataValues);
    }

    function setName(string memory name_) public {
        _setData(_LSP4_TOKEN_NAME_KEY, bytes(name_));
    }

    function setSymbol(string memory symbol_) public {
        _setData(_LSP4_TOKEN_SYMBOL_KEY, bytes(symbol_));
    }
}
