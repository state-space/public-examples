import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@state-space/hardhat";

const config: HardhatUserConfig = {
	solidity: "0.8.4",
	statespace: {
		project: "DEIStablecoin-hardhat",
	},
};

export default config;
