
// launch XP Token
// launch SoulBoundDecayStaking 

// first thing launch an XP token with given facets



// second thing launch a SoulBoundDecayStaking with given facets



// set Reward Token , deposit token into contract, to be escrowed by contract, 
// call distribute to distribute XP token to potential new holders, with an amount
// that the contract is holding 
// new holder can burn immediately
// new holder can wait 

import {ethers} from "ethers";
import { BigNumber, Contract, ContractFactory, Signer } from "ethers";
import * as contracts from "./generated/typechain";
import * as presets from "./presets.json";
import * as facets from "./generated/deployed.json";
const endpoint = "http://127.0.0.1:8545"
const provider = new ethers.providers.JsonRpcProvider(endpoint);
// const privateKey = process.env.PRIV_KEY || "";
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
const signer = new ethers.Wallet(privateKey, provider);

const suzyJoePrivKey ="0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"
//publicKey 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
const suzyJoe = new ethers.Wallet(suzyJoePrivKey, provider); 

const getCuts = (presetName: "xpToken" | "xpSoulboundDecayStaking" | "lxpToken" | "rewardToken", chainId: string ):any => {
    return ((presets as any)[presetName as any] as string[])
   .filter((facetName)=>{
        return !(facetName==="DiamondCutFacet" || 
        facetName==="DiamondLoupeFacet")
    })
    .map((facetName)=>{
        return (facets as any)[chainId][facetName as any] as any;
    })
}

const getFundamentalCuts = (chainId: string) => {
        return [(facets as any)[chainId]["DiamondLoupeFacet"] as any, 
        (facets as any)[chainId]["DiamondCutFacet"] as any];
}


async function mtest(){
  const addr = '0x6C2d83262fF84cBaDb3e416D527403135D757892'
  const lsp7 = contracts.XPLSP7TokenFacet__factory.connect(addr, signer);
  /*await lsp7.setDecayRate(100);
  let tokenSuply = await lsp7.totalSupply();
  console.log(addr)
  console.log(tokenSuply.toString())
  console.log(await signer.getBalance())
  */
  await lsp7.mint(signer.address, 100, false, "0x");
 
}

// returns address of diamond
const makeBlankDiamond = async (signer: ethers.Wallet, chainId: string) => {
  const diamondFactory = new contracts.Diamond__factory(signer);
  const fundCuts = getFundamentalCuts(chainId).map((cut)=>cut);
  const diamondLoupe = fundCuts[0].facetAddress;
  const diamondCut = fundCuts[1].facetAddress;
  const diamondAddr = await (await diamondFactory.deploy(signer.address, diamondCut, diamondLoupe)).deployed();
  return diamondAddr.address; 
}


const makeRewardToken = async(signer: ethers.Wallet, chainId: string) => {
    const diamondAddr = await makeBlankDiamond(signer, chainId);
    const cuts = getCuts("rewardToken", chainId);
    const diamond = contracts.DiamondCutFacet__factory.connect(diamondAddr, signer);
    await (await diamond.diamondCut(cuts, ethers.constants.AddressZero, "0x")).wait();
    return diamondAddr;
}

const makeLXPToken = async (signer: ethers.Wallet, chainId: string) => {
    const diamondAddr = await makeBlankDiamond(signer, chainId);
    const cuts = getCuts("lxpToken", chainId);
    const diamond = contracts.DiamondCutFacet__factory.connect(diamondAddr, signer);
    await (await diamond.diamondCut(cuts, ethers.constants.AddressZero, "0x")).wait();
    return diamondAddr; 
}

const makeXPToken = async (signer: ethers.Wallet, chainId: string, decayRate: number) => {
    const diamondAddr = await makeBlankDiamond(signer, chainId);
    const cuts = getCuts("xpToken", chainId);
    const diamond = contracts.DiamondCutFacet__factory.connect(diamondAddr, signer);
    await (await diamond.diamondCut(cuts, ethers.constants.AddressZero, "0x")).wait();
    const lsp7 = contracts.XPLSP7TokenFacet__factory.connect(diamondAddr, signer);
    await lsp7.setDecayRate(decayRate);
    return diamondAddr; 
}

const getInitSoulboundStakingData = (exchangeRate: string, penaltyRate: string, xpTokenAddress: string, 
    lxpTokenAddress: string, rewardTokenAddress: string) => {
    return contracts.SoulboundDecayStakingFacet__factory.createInterface().encodeFunctionData("setDecayStaking",[
        exchangeRate,
        penaltyRate,
        xpTokenAddress,
        lxpTokenAddress,
        rewardTokenAddress
    ])
}



export interface StakingConfig {
    exchangeRate: string;
    penaltyRate: string;
    xpTokenAddress: string;
    lxpTokenAddress: string;
    rewardTokenAddress: string;
}
const makeStakingContract = async (signer: ethers.Wallet, chainId: string, config: StakingConfig) => {
    const diamondAddr = await makeBlankDiamond(signer, chainId);
    const cuts = getCuts("xpSoulboundDecayStaking", chainId);
    const callData = getInitSoulboundStakingData(config.exchangeRate, config.penaltyRate, config.xpTokenAddress, config.lxpTokenAddress, config.rewardTokenAddress);
    const diamond = contracts.DiamondCutFacet__factory.connect(diamondAddr, signer);
    await (await diamond.diamondCut(cuts, diamondAddr, callData)).wait();
    return diamond.address;
}

const setTokenOwner=  async (signer: ethers.Wallet, tokenAddr: string, ownerAddr: string) => {
    const ownerFacet = contracts.OwnershipFacet__factory.connect(tokenAddr, signer);
    return ownerFacet.transferOwnership(ownerAddr);
}

async function main(){

    //construct the tokens XP and LXP
    const xpAddr = await makeXPToken(signer,"31337", 100);
    const lxpAddr = await makeLXPToken(signer,"31337");
    const rewardAddr = await makeRewardToken(signer,"31337");

    // create and laucnh staking token with the following tokens under it's ownership
    // penalty rate is out of 1000 so 100 is effectively 10%
    const stakingAddr = await makeStakingContract(signer,"31337", {
        exchangeRate: "100",
        penaltyRate: "100",
        xpTokenAddress: xpAddr,
        lxpTokenAddress: lxpAddr,
        rewardTokenAddress: rewardAddr
    });

    const sbds = contracts.SoulboundDecayStakingFacet__factory.connect(stakingAddr, signer);

    // Configure the Staking contract
    // set reward token
    // set rate of decay
    // set exchange rate
    // set discount fee



    // here we transfer ownership to the staking contract
    await setTokenOwner(signer, xpAddr, stakingAddr);
    await setTokenOwner(signer, lxpAddr, stakingAddr);
   
   // here we deposit into the contract

   // here we distribute to potential new holders


    const lsp7 = contracts.XPLSP7TokenFacet__factory.connect(xpAddr, signer);
    const reward = contracts.LSP7DigitalAssetFacet__factory.connect(rewardAddr, signer);
    let numTokens = ethers.utils.parseUnits("100","ether");
    await (await reward.mint(signer.address, numTokens, true, "0x")).wait();
    numTokens = ethers.utils.parseUnits("300","ether");
    await (await reward.mint(signer.address, numTokens, true, "0x")).wait();
    const supply = await reward.totalSupply();
    console.log(supply.toString())

    // so we authorize the staking contract to spend our reward tokens
    await (await reward.authorizeOperator(stakingAddr, ethers.utils.parseUnits("100","ether"))).wait();
    console.log((await reward.authorizedAmountFor(stakingAddr, signer.address)).toString());
    // we deposit our reward tokens into the staking contract and distribute tokens to suzyJoe
    await ((await sbds.distributeXP(suzyJoe.address, ethers.utils.parseUnits("100","ether"))).wait());
    
    console.log("reg balance:", (await lsp7.balanceOf(suzyJoe.address)).toString());
    console.log("active xp:", (await lsp7.activeVirtualBalanceOf(suzyJoe.address)).toString());
    console.log("held decayed xp:", (await lsp7.inactiveVirtualBalanceOf(suzyJoe.address)).toString());
    // bump time forward 
    await (await reward.authorizeOperator(stakingAddr, ethers.utils.parseUnits("100","ether"))).wait();

    // Shows the change in balance over time in this case we are saying every block
    // you lose 10% of the value of your XP, we will change this to be a constant factor
    // so it's smaller and more predictable that after x timesteps you lose 100% vs a 
    // rate applied as a percentage / we could say you earn 5 tokens max per contribution
    // and the rate of decay is 1 token every 5000 blocks
    console.log("reg balance:", (await lsp7.balanceOf(suzyJoe.address)).toString());
    console.log("active xp:", (await lsp7.activeVirtualBalanceOf(suzyJoe.address)).toString());
    console.log("held decayed xp:", (await lsp7.inactiveVirtualBalanceOf(suzyJoe.address)).toString());

    //
    const suzyXP = contracts.XPLSP7TokenFacet__factory.connect(xpAddr, suzyJoe);
    suzyXP.authorizeOperator(stakingAddr, ethers.utils.parseUnits("100","ether"));

    // The last snapshot of values of suzies balances 
    console.log("reg balance:", (await lsp7.balanceOf(suzyJoe.address)).toString());
    console.log("active xp:", (await lsp7.activeVirtualBalanceOf(suzyJoe.address)).toString());
    console.log("held decayed xp:", (await lsp7.inactiveVirtualBalanceOf(suzyJoe.address)).toString());

    const sbsSuzy = contracts.SoulboundDecayStakingFacet__factory.connect(stakingAddr, suzyJoe);
    console.log("rewards suzyJoe addr: balance pre burn", await reward.balanceOf(suzyJoe.address));
    await sbsSuzy.burnXP(ethers.utils.parseUnits("50","ether"));
    console.log("rewards suzyJoe addr: balance post burn", await reward.balanceOf(suzyJoe.address));

    // The updated values of suzies balances 
    console.log("reg balance:", (await lsp7.balanceOf(suzyJoe.address)).toString());
    console.log("active xp:", (await lsp7.activeVirtualBalanceOf(suzyJoe.address)).toString());
    console.log("held decayed xp:", (await lsp7.inactiveVirtualBalanceOf(suzyJoe.address)).toString());

    const lxpContract = contracts.LXPFacet__factory.connect(lxpAddr, signer);
    console.log("long term xp:", (await lxpContract.balanceOf(suzyJoe.address)).toString());




/*  console.log(getCuts("xpToken","31337"));
  console.log(getFundamentalCuts("31337"));

  console.log(diamondLoupe);
  const diamondFactory = new contracts.Diamond__factory(signer);
  
  const xpTokenAddr = await (await diamondFactory.deploy(signer.address, diamondCut, diamondLoupe)).deployed();
  const lxpToken = await diamondFactory.deploy(signer.address, diamondCut, diamondLoupe);
  const decayingStaker = await diamondFactory.deploy(signer.address, diamondCut, diamondLoupe);

  const xpToken = contracts.DiamondCutFacet__factory.connect(xpTokenAddr.address, signer);
  await (await diamond.diamondCut(getCuts("xpToken","31337"), ethers.constants.AddressZero, "0x")).wait();
  const lsp7 = contracts.XPLSP7TokenFacet__factory.connect(xpAddr.address, signer);
  await lsp7.setDecayRate(100);
  let tokenSupply = await lsp7.totalSupply();
  console.log(xpAddr.address)
  console.log(tokenSupply.toString())
  console.log(await signer.getBalance())
 
  // In this case we need the non EOA account to be the recipient
  await lsp7.mint(signer.address, 100, true, "0x");
  tokenSupply = await lsp7.totalSupply();
  console.log(tokenSupply.toString())
  
  
/*contracts.Diamond__factory.connect({

})*/
}
try {
main()

}catch(e: any){
    console.log(e.stack)
}