// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
//import "github.com/Arachnid/solidity-stringutils/strings.sol";
//import "solidity-stringutils-master/strings.sol";
import "solidity-string-utils/StringUtils.sol";

contract AdvancedCollection is ERC721, VRFConsumerBase {

  using StringUtils for *;

  uint public counter;

  bytes32 public keyHash;
  address public linkToken;
  address  public vrfCoordinator;
  uint public fee;
  //Product[] public products;
  
  mapping(bytes32 => address) public requestIdToSender;
  mapping(bytes32 => string) public requestIdToTokenURI;
  mapping(bytes32 => uint) public  requestIdToTokenId;
  mapping(uint => uint) public tokenIdToGene;
  mapping(bytes32 => string) public requestIdToProduct;

  event CreatedColection(bytes32 requestId, uint tokenId);
  
//   struct Product {
//       string id;
//       string color;
//       string name;
//       string description;
//   }
  /*
* Rinkeby: https://docs.chain.link/docs/vrf-contracts/#rinkeby
* _vrfCoordinator: '0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B'
* _linkToken: '0x01BE23585060835E02B77ef475b0Cc51aA1e0709'
* _keyhash: '0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311'
* Fee: 0.1 LINK
* LINK token faucet: https://rinkeby.chain.link/
*/
  constructor(address _vrfCoordinator, address _linkToken, bytes32 _keyhash) public
    VRFConsumerBase(_vrfCoordinator, _linkToken)
    ERC721("My NFTs" , "NFT")
  {
    vrfCoordinator = _vrfCoordinator;
    linkToken = _linkToken;
    keyHash = _keyhash;
    fee = 0.1 * 10 ** 18;
  }

  function create(string memory tokenURI, string memory productText) public {
    bytes32 requestId = requestRandomness(keyHash, fee);
    requestIdToSender[requestId] = msg.sender;
    requestIdToTokenURI[requestId] = tokenURI;
    
    // lấy dữ liệu từ fe gửi lên
    //const productInfo = productText;
    // const name = productInfo[0];
    // const color = productInfo[1];
    // const description = productInfo[2];
    
    // lưu vào mảng
    // products.push(new Product(11,color, name,description));
    requestIdToProduct[requestId] = productText;
  }

  function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
    address owner = requestIdToSender[requestId];
    string memory tokenURI = requestIdToTokenURI[requestId];
    uint newItemId = counter;
    _safeMint(owner, newItemId);
    _setTokenURI(newItemId, tokenURI);
    requestIdToTokenId[requestId] = newItemId;
    tokenIdToGene[newItemId] = randomness;
    counter = counter + 1;
    emit CreatedColection(requestId, newItemId);
  } 
}