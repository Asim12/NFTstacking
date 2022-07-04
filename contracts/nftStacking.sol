// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // erc20 interface for rewards transfer
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; 
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";  // nft interface for burn stacking nft etc
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; //for security 

contract nftStacking is ReentrancyGuard {
    using SafeERC20 for IERC20;
    IERC721 public immutable nftContractAddress;
    IERC20 public immutable rewardContractAddress;
    uint256 public immutable rewardPerHours;
    struct StakedToken {
        address staker;
        uint256 tokenId;
    }
    struct StackingUserDeatils{
        uint256 amountStaked;
        uint256 unclaimedRewards;
        StakedToken[] stakedTokens;
        uint256 timeOfLastUpdate;
    } 
    mapping(address => StackingUserDeatils) public stackingUserDeatil;
    mapping(uint256 => address) public stakerAddress;
    
    constructor(IERC721 _nftContractAddress, IERC20 _rewardContractAddress, uint256 _rewardPerHours) {

        nftContractAddress      =   _nftContractAddress;
        rewardContractAddress   =   _rewardContractAddress;
        rewardPerHours          =   _rewardPerHours;
    }
    function calculateRewards()internal view returns(uint256){
        return( (((block.timestamp -  stackingUserDeatil[msg.sender].timeOfLastUpdate) *  stackingUserDeatil[msg.sender].amountStaked) * rewardPerHours)/ 3600 );
    }

    function stackeNFT(uint256 _tokenId) external nonReentrant{
        if(stackingUserDeatil[msg.sender].amountStaked > 0){
            stackingUserDeatil[msg.sender].unclaimedRewards += calculateRewards();
        }
        nftContractAddress.approve(address(this), _tokenId);
        require(nftContractAddress.ownerOf(_tokenId) == msg.sender, "You don't own this token!");
        nftContractAddress.transferFrom(msg.sender, address(this), _tokenId);
        StakedToken memory stakedToken = StakedToken(msg.sender, _tokenId);
        stackingUserDeatil[msg.sender].stakedTokens.push(stakedToken);
        stackingUserDeatil[msg.sender].amountStaked +=1;
        stackingUserDeatil[msg.sender].timeOfLastUpdate = block.timestamp;
        stakerAddress[_tokenId] = msg.sender;
    }

    function claimRewards() external {
        uint256 totalRewards = calculateRewards() + stackingUserDeatil[msg.sender].unclaimedRewards;
        require(totalRewards > 0 , "You don not have any pending rewards");

        stackingUserDeatil[msg.sender].timeOfLastUpdate = block.timestamp;
        stackingUserDeatil[msg.sender].unclaimedRewards = 0;
        rewardContractAddress.safeTransfer(msg.sender, totalRewards);
    }

    function withdraw(uint256 _tokenId)external nonReentrant{
        require(stackingUserDeatil[msg.sender].amountStaked > 0, "You don not have any Stacked NFT for withdraw");
        require(nftContractAddress.ownerOf(_tokenId) == msg.sender, "You are not the owner");
        stackingUserDeatil[msg.sender].unclaimedRewards += calculateRewards();
        stackingUserDeatil[msg.sender].amountStaked -=1;
        stakerAddress[_tokenId] = address(0);
        for (uint256 i = 0; i < stackingUserDeatil[msg.sender].stakedTokens.length; i++) {
            if (stackingUserDeatil[msg.sender].stakedTokens[i].tokenId == _tokenId) {
                stackingUserDeatil[msg.sender].stakedTokens[i].staker = address(0);
                break;
            }
        }
        nftContractAddress.transferFrom(address(this), msg.sender, _tokenId);
        stackingUserDeatil[msg.sender].timeOfLastUpdate = block.timestamp;
    }

    function myStackingNFT() public view returns (StakedToken[] memory) {
        if(stackingUserDeatil[msg.sender].amountStaked > 0){
            StakedToken[] memory _stakedTokens = new StakedToken[](stackingUserDeatil[msg.sender].amountStaked);
            uint256 _index = 0;
            for (uint256 j = 0; j < stackingUserDeatil[msg.sender].stakedTokens.length; j++) {
                if (stackingUserDeatil[msg.sender].stakedTokens[j].staker != (address(0))) {
                    _stakedTokens[_index] = stackingUserDeatil[msg.sender].stakedTokens[j];
                    _index++;
                }
            }
            return _stakedTokens;
        }else{
            return new StakedToken[](0);
        }
    }

    function myPendingRewards()public view returns(uint256){
        return (calculateRewards() + stackingUserDeatil[msg.sender].unclaimedRewards);
    }
}