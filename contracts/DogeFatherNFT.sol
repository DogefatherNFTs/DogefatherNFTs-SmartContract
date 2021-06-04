// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract DogeFatherNFT is ERC721URIStorage, Ownable {
    using SafeMath for uint256;
    using Address for address;

    address public feeAddress;
    uint256 public feePercent = 3;

    mapping(uint256 => uint256) public price;
    mapping(uint256 => bool) public listedMap;

    uint256 private mintIndex = 0;

    event Purchase(address indexed previousOwner, address indexed newOwner, uint256 price, uint256 nftID, string uri);
    event Minted(address indexed minter, uint256 price, uint256 nftID, string uri);
    event PriceUpdate(address indexed owner, uint256 oldPrice, uint256 newPrice, uint256 nftID);
    event NftListStatus(address indexed owner, uint256 nftID, bool isListed);
    event Burned(uint256 nftID);

    modifier _validateBuy(uint256 _id) {
        require(_exists(_id), "Error, wrong tokenId");
        require(listedMap[_id], "Item not listed currently");
        require(msg.value >= price[_id], "Error, the amount is lower");
        require(_msgSender() != ownerOf(_id), "Can not buy what you own");
        _;
    }

    modifier _validateOwnerOfToken(uint256 _id) {
        require(_exists(_id), "Error, wrong tokenId");
        require(_msgSender() == ownerOf(_id), "Only Owner Can Burn");
        _;
    }

    constructor() ERC721("Doge Father NFTs", "DOGF") {
        feeAddress = _msgSender();
    }

    function setFee(address _feeAddress, uint256 _feePercent) external onlyOwner {
        feeAddress = _feeAddress;
        feePercent = _feePercent;
    }

    function mint(string memory _tokenURI, uint256 _price) external returns (uint256) {
        mintIndex = mintIndex.add(1);
        uint256 _tokenId = mintIndex;
        price[_tokenId] = _price;
        listedMap[_tokenId] = true;

        _safeMint(_msgSender(), _tokenId);
        _setTokenURI(_tokenId, _tokenURI);

        emit Minted(_msgSender(), _price, _tokenId, _tokenURI);

        return _tokenId;
    }

    function burn(uint256 _id) external _validateOwnerOfToken(_id) {
        _burn(_id);
        delete price[_id];
        delete listedMap[_id];

        emit Burned(_id);
    }

    function buy(uint256 _id) external payable _validateBuy(_id) {
        address _previousOwner = ownerOf(_id);
        address _newOwner = _msgSender();

        _trade(_id);

        emit Purchase(_previousOwner, _newOwner, price[_id], _id, tokenURI(_id));
    }

    function updatePrice(uint256 _tokenId, uint256 _price) external _validateOwnerOfToken(_tokenId){
        uint256 oldPrice = price[_tokenId];
        price[_tokenId] = _price;

        emit PriceUpdate(_msgSender(), oldPrice, _price, _tokenId);
    }

    function updateListingStatus(uint256 _tokenId, bool shouldBeListed) external _validateOwnerOfToken(_tokenId){
        listedMap[_tokenId] = shouldBeListed;

        emit NftListStatus(_msgSender(), _tokenId, shouldBeListed);
    }


    function _trade(uint256 _id) internal {
        address payable _buyer = payable(_msgSender());
        address payable _owner = payable(ownerOf(_id));

        _transfer(_owner, _buyer, _id);

        uint256 _commissionValue = price[_id].mul(feePercent).div(10**2);
        uint256 _sellerValue = price[_id] - _commissionValue;

        _owner.transfer(_sellerValue);
        payable(feeAddress).transfer(_commissionValue);

        // If buyer sent more than price, we send them back their rest of funds
        if (msg.value > price[_id]) {
            _buyer.transfer(msg.value.sub(price[_id]));
        }

        listedMap[_id] = false;
    }
}
