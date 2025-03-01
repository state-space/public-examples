import "@xyrusworx/hardhat-solidity-json";
import "@nomicfoundation/hardhat-toolbox";
import { HardhatUserConfig } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import "solidity-coverage";
import "@nomiclabs/hardhat-solhint";
import "@primitivefi/hardhat-dodoc";

//import statements for using the State Space Hardhat Plugin.
import "@state-space/hardhat";
import { extractAccountNames } from "@state-space/hardhat";

const config: HardhatUserConfig = {
	solidity: {
		version: "0.8.17",
		settings: {
			optimizer: {
				enabled: true,
				runs: 200,
			},
		},
	},

	statespace: {
		deployments: {
			"Full Suite": async () => {
				const { deployFullSuiteFixture } = await import(
					"./test/fixtures/deploy-full-suite.fixture"
				);
				const accounts = await deployFullSuiteFixture();
				return {
					accountNames: extractAccountNames(accounts),
				};
			},

			"Compliance Fixture": async () => {
				const { deployComplianceFixture } = await import(
					"./test/fixtures/deploy-compliance.fixture"
				);
				const accounts = await deployComplianceFixture();
				return {
					accountNames: extractAccountNames(accounts),
				};
			},
		},
	},

	gasReporter: {
		enabled: true,
	},
	dodoc: {
		runOnCompile: false,
		debugMode: true,
		outputDir: "./docgen",
		freshOutput: true,
	},
};

export default config;
