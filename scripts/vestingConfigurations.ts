import { ethers } from "hardhat";
import { Vesting, VestingType } from "./types";

export const TEST_VESTINGS: Record<VestingType, Vesting> = {
  Foundation: {
    end: 1816120800,
    allocations: [
      {
        address: "0xeAb9ca51bC0aB18888C227ABAB8f74c6e0A02009",
        initialSupply: ethers.utils.parseEther("100"),
        totalRemaining: ethers.utils.parseEther("10000"),
        frozen: false,
      },
    ],
  },
  Seed: {
    end: 1784584800,
    allocations: [
      {
        address: "0xeAb9ca51bC0aB18888C227ABAB8f74c6e0A02009",
        initialSupply: ethers.utils.parseEther("42.4"),
        totalRemaining: ethers.utils.parseEther("1400"),
        frozen: false,
      },
    ],
  },
  Private: {
    end: 1742511600,
    allocations: [
      {
        address: "0xeAb9ca51bC0aB18888C227ABAB8f74c6e0A02009",
        initialSupply: ethers.utils.parseEther("32"),
        totalRemaining: ethers.utils.parseEther("323232"),
        frozen: false,
      },
    ],
  },
  Hypera2: {
    end: 1742511600,
    allocations: [
      {
        address: "0xeAb9ca51bC0aB18888C227ABAB8f74c6e0A02009",
        initialSupply: ethers.utils.parseEther("6969"),
        totalRemaining: ethers.utils.parseEther("42000"),
        frozen: false,
      },
    ],
  },
  KuCoin: {
    end: 1752660000,
    allocations: [
      {
        address: "0xeAb9ca51bC0aB18888C227ABAB8f74c6e0A02009",
        initialSupply: ethers.utils.parseEther("100"),
        totalRemaining: ethers.utils.parseEther("10000"),
        frozen: false,
      },
    ],
  },
  Hashed: {
    end: 1771588800,
    allocations: [
      {
        address: "0xeAb9ca51bC0aB18888C227ABAB8f74c6e0A02009",
        initialSupply: ethers.utils.parseEther("100"),
        totalRemaining: ethers.utils.parseEther("10000"),
        frozen: false,
      },
    ],
  },
  Hashed2: {
    end: 1771588800,
    allocations: [
      {
        address: "0xeAb9ca51bC0aB18888C227ABAB8f74c6e0A02009",
        initialSupply: ethers.utils.parseEther("100"),
        totalRemaining: ethers.utils.parseEther("10000"),
        frozen: false,
      },
    ],
  },
  Laskarzewski: {
    end: 1768996800,
    allocations: [
      {
        address: "0xeAb9ca51bC0aB18888C227ABAB8f74c6e0A02009",
        initialSupply: ethers.utils.parseEther("100"),
        totalRemaining: ethers.utils.parseEther("10000"),
        frozen: false,
      },
    ],
  },
  Parzynski: {
    end: 1816131600,
    allocations: [
      {
        address: "0xeAb9ca51bC0aB18888C227ABAB8f74c6e0A02009",
        initialSupply: ethers.utils.parseEther("100"),
        totalRemaining: ethers.utils.parseEther("10000"),
        frozen: false,
      },
    ],
  },
};

export const VESTINGS: Record<VestingType, Vesting> = {
  Foundation: {
    end: 1816120800,
    allocations: {
      pathToCsv:
        "/Users/marcincichocki/dev/gameswift/gs-evm-contracts/scripts/data/GSWIFT resume vesting do devów - Foundation.csv",
    },
  },
  Seed: {
    end: 1784584800,
    allocations: {
      pathToCsv:
        "/Users/marcincichocki/dev/gameswift/gs-evm-contracts/scripts/data/GSWIFT resume vesting do devów - Seed.csv",
    },
  },
  Private: {
    end: 1742511600,
    allocations: {
      pathToCsv:
        "/Users/marcincichocki/dev/gameswift/gs-evm-contracts/scripts/data/GSWIFT resume vesting do devów - Private.csv",
    },
  },
  Hypera2: {
    end: 1742511600,
    allocations: [
      {
        address: "0x5ae39c544119D7CE0760029F28cefCca85443c8e",
        initialSupply: ethers.utils.parseEther("0"),
        totalRemaining: ethers.utils.parseEther("238348.945"),
        frozen: false,
      },
    ],
  },
  KuCoin: {
    end: 1752660000,
    allocations: [
      {
        address: "0x44848e2167B168755414d67F683C88eBd3c9CEe6",
        initialSupply: ethers.utils.parseEther("0"),
        totalRemaining: ethers.utils.parseEther("421947.8742"),
        frozen: false,
      },
    ],
  },
  Hashed: {
    end: 1771588800,
    allocations: [
      {
        address: "0xBC0a4EcE9682ab7bA0A94810F07783a822B82005",
        initialSupply: ethers.utils.parseEther("100"),
        totalRemaining: ethers.utils.parseEther("10000"),
        frozen: false,
      },
    ],
  },
  Hashed2: {
    end: 1771588800,
    allocations: [
      {
        address: "0xBC0a4EcE9682ab7bA0A94810F07783a822B82005",
        initialSupply: ethers.utils.parseEther("0"),
        totalRemaining: ethers.utils.parseEther("1555758.24"),
        frozen: false,
      },
    ],
  },
  Laskarzewski: {
    end: 1768996800,
    allocations: [
      {
        address: "0xeAb9ca51bC0aB18888C227ABAB8f74c6e0A02009",
        initialSupply: ethers.utils.parseEther("0"),
        totalRemaining: ethers.utils.parseEther("125698.324022"),
        frozen: false,
      },
    ],
  },
  Parzynski: {
    end: 1816131600,
    allocations: [
      {
        address: "0xeAb9ca51bC0aB18888C227ABAB8f74c6e0A02009",
        initialSupply: ethers.utils.parseEther("100"),
        totalRemaining: ethers.utils.parseEther("10000"),
        frozen: false,
      },
    ],
  },
};

// const FoundationAllocation: Allocation[] = [
//   [
//     "0xf8c32b1cce8621778eb1ea0eab439d2bf3ae88af",
//     ethers.utils.parseEther("921396.2719"),
//     ethers.utils.parseEther("6792619.028"),
//   ],
//   [
//     "0xfdebe9c9f42a45ac6c86f62e270736ee2b4a5e45",
//     ethers.utils.parseEther("815.1849196"),
//     ethers.utils.parseEther("335593.8111"),
//   ],
//   [
//     "0x188bf6431bb1f3aea852a892715543a784395ff9",
//     ethers.utils.parseEther("1174.047874"),
//     ethers.utils.parseEther("307046.2"),
//   ],
//   [
//     "0x9289ad9b67e16e24cc8b8c49c07f9ad2196707f1",
//     ethers.utils.parseEther("527.1798126"),
//     ethers.utils.parseEther("253757.6194"),
//   ],
//   [
//     "0x45d7a4252af600fa964983bb9da0153d670c87d5",
//     ethers.utils.parseEther("598.9199594"),
//     ethers.utils.parseEther("253757.6194"),
//   ],
//   [
//     "0xe133230cbc5c325c23ed5500d2a289f81b008d9e",
//     ethers.utils.parseEther("4353.702771"),
//     ethers.utils.parseEther("245369.4472"),
//   ],
//   [
//     "0xf1433d2aa883e88625b9d6e3d001c1a52043fe93",
//     ethers.utils.parseEther("2252.238729"),
//     ethers.utils.parseEther("237122.1639"),
//   ],
//   [
//     "0xc1165400a091447416a78edf041c4f000ee03346",
//     ethers.utils.parseEther("2198.886126"),
//     ethers.utils.parseEther("207360.2667"),
//   ],
//   [
//     "0xb8b34e9d1dab90bd496b8120f9ad19bf673bf3f1",
//     ethers.utils.parseEther("1447.914577"),
//     ethers.utils.parseEther("199751.4141"),
//   ],
//   [
//     "0xa6554af23cff4a0e50a33a049f0d7c41da3dd7c5",
//     ethers.utils.parseEther("295.0505128"),
//     ethers.utils.parseEther("192284.7361"),
//   ],
//   [
//     "0xfc81d6159103b8bc9a09846053e02869aa187a55",
//     ethers.utils.parseEther("470.3644953"),
//     ethers.utils.parseEther("192284.7361"),
//   ],
//   [
//     "0x7c0ef6cdbe693fa8a642e532aaa2a6c317f3c3b1",
//     ethers.utils.parseEther("9684.429402"),
//     ethers.utils.parseEther("184960.2805"),
//   ],
//   [
//     "0x52255adf53a3be2c9576dba3afdb46c582ee52b7",
//     ethers.utils.parseEther("414.5252137"),
//     ethers.utils.parseEther("163840.2485"),
//   ],
//   [
//     "0xc5bc0b02c0703b500390ebb788338b3d3a65f717",
//     ethers.utils.parseEther("389.0152739"),
//     ethers.utils.parseEther("163840.2485"),
//   ],
//   [
//     "0xe084e22c018b3211e9086109b11dfe6c44a90eb2",
//     ethers.utils.parseEther("20410.93877"),
//     ethers.utils.parseEther("150471.3393"),
//   ],
//   [
//     "0x9c260d53ee5739f368528479c451ec522a65461a",
//     ethers.utils.parseEther("1010.578445"),
//     ethers.utils.parseEther("150471.3393"),
//   ],
//   [
//     "0x5521f46524b1f1375fc251d55f99278545565881",
//     ethers.utils.parseEther("1243.930844"),
//     ethers.utils.parseEther("144000.2184"),
//   ],
//   [
//     "0x7a46b6fe56dec884651c62a54944ad379bb2ec03",
//     ethers.utils.parseEther("4475.177264"),
//     ethers.utils.parseEther("144000.2184"),
//   ],
//   [
//     "0xfa5b9bb588785714aa8b8b0550a2829b101331c4",
//     ethers.utils.parseEther("592.1308838"),
//     ethers.utils.parseEther("144000.2184"),
//   ],
//   [
//     "0x02d5ab05d0e4966cb51f3f56961561ff371ab244",
//     ethers.utils.parseEther("17835.45642"),
//     ethers.utils.parseEther("131484.6439"),
//   ],
//   [
//     "0x9384e4500b81bebba0025fb063b217444bfd7eb7",
//     ethers.utils.parseEther("402.8762306"),
//     ethers.utils.parseEther("125440.1903"),
//   ],
//   [
//     "0xc07cc0c441111f129d5c68e00ddee75e5f37f1ac",
//     ethers.utils.parseEther("467.427455"),
//     ethers.utils.parseEther("102684.6002"),
//   ],
//   [
//     "0x2874aeaa14672226db2844a959966698c660bbbb",
//     ethers.utils.parseEther("101.9223588"),
//     ethers.utils.parseEther("28444.48759"),
//   ],
//   [
//     "0xa342683dac63acd9f4007c98bce7c4c6ec645c64",
//     ethers.utils.parseEther("3858.400524"),
//     ethers.utils.parseEther("28444.48759"),
//   ],
//   [
//     "0x82daab0b45425a420ad624adbc5338e812b06821",
//     ethers.utils.parseEther("101.3197185"),
//     ethers.utils.parseEther("28444.48759"),
//   ],
//   [
//     "0x2651c947137cd9f83449ad927fb0148c6d6b54cb",
//     ethers.utils.parseEther("3496.646623"),
//     ethers.utils.parseEther("28444.48759"),
//   ],
//   [
//     "0xa2458383f29827d71b1eba2e23ed1491a92f969c",
//     ethers.utils.parseEther("3858.400524"),
//     ethers.utils.parseEther("28444.48759"),
//   ],
//   [
//     "0xd09eb467a2f8f32dce4d0bbaf8b71f8fea9f676f",
//     ethers.utils.parseEther("2774.357077"),
//     ethers.utils.parseEther("28444.48759"),
//   ],
//   [
//     "0x19c2f6f862d67d9a70ef3cbc20ba622694b460d3",
//     ethers.utils.parseEther("190.7583741"),
//     ethers.utils.parseEther("28444.48759"),
//   ],
//   [
//     "0x3ba8c6c9836fef6f9844b1189379d65b4518b0e3",
//     ethers.utils.parseEther("3263.793565"),
//     ethers.utils.parseEther("28444.48759"),
//   ],
//   [
//     "0x5a2e4295f9f1fd50ee93746e9aa3ffb8c716d61b",
//     ethers.utils.parseEther("3858.400524"),
//     ethers.utils.parseEther("28444.48759"),
//   ],
//   [
//     "0x9780b281b05bde9f88033777ba8891695758a006",
//     ethers.utils.parseEther("477.5516694"),
//     ethers.utils.parseEther("28444.48759"),
//   ],
//   [
//     "0xff5fe3dde9623a89d71a71933c14e1f281ea1226",
//     ethers.utils.parseEther("415.9110223"),
//     ethers.utils.parseEther("26416.66667"),
//   ],
//   [
//     "0x6100cc0c2d7f078a02af90a244892e141ef889a9",
//     ethers.utils.parseEther("414.2862126"),
//     ethers.utils.parseEther("26416.66667"),
//   ],
//   [
//     "0x2de4b336b5830085a7f6aadeec966316dddf6f78",
//     ethers.utils.parseEther("376.5738627"),
//     ethers.utils.parseEther("88055.55556"),
//   ],
//   [
//     "0x67aee3680ba78276ac62fd15b0d3cf2f483d210f",
//     ethers.utils.parseEther("132.441654"),
//     ethers.utils.parseEther("52833.33333"),
//   ],
//   [
//     "0xa058c37cf385044e642f19ed5a2f7d725c27beb0",
//     ethers.utils.parseEther("312.1247675"),
//     ethers.utils.parseEther("88055.55556"),
//   ],
//   [
//     "0xd385abb8a81f6cbc207f5f7c7e9d4e9111ef641e",
//     ethers.utils.parseEther("1965.361809"),
//     ethers.utils.parseEther("132083.3333"),
//   ],
//   [
//     "0x6cd378a46ae6f0d2707be7d7d130a4831ddd23d2",
//     ethers.utils.parseEther("184279.2544"),
//     ethers.utils.parseEther("1358523.806"),
//   ],
//   [
//     "0x93e4a7de93ec834eb920ec9f2c3989957a6fc242",
//     ethers.utils.parseEther("230349.068"),
//     ethers.utils.parseEther("1698154.757"),
//   ],
//   [
//     "0xbd132c99f9b16605fed07784024353ef87aac814",
//     ethers.utils.parseEther("51701.79164"),
//     ethers.utils.parseEther("1698154.757"),
//   ],
//   [
//     "0x6bd5a1cc3574b2dd69c62cf583876550d6294af3",
//     ethers.utils.parseEther("7484.548009"),
//     ethers.utils.parseEther("3443148.333"),
//   ],
//   [
//     "0x4401ebbb599c0d01e3dbe774bfa0c8666e7fea91",
//     ethers.utils.parseEther("18427.92544"),
//     ethers.utils.parseEther("135852.3806"),
//   ],
//   [
//     "0x1d89999f6f878ea4b84c03b8816bbaef33dbcc6d",
//     ethers.utils.parseEther("38645.44412"),
//     ethers.utils.parseEther("950966.6639"),
//   ],
//   [
//     "0xab54ac1a31609e5ef43e3fafb8ae9e56303980e0",
//     ethers.utils.parseEther("193493.2171"),
//     ethers.utils.parseEther("1426449.996"),
//   ],
//   [
//     "0x8d5cd25f78ea81c001ad0ae8c022380a7602cf8f",
//     ethers.utils.parseEther("138209.4408"),
//     ethers.utils.parseEther("1018892.854"),
//   ],
//   [
//     "0x1815c4d887a4d2ebff52e7bc10a0d9d16c75acb2",
//     ethers.utils.parseEther("3125.524269"),
//     ethers.utils.parseEther("176111.1111"),
//   ],
//   [
//     "0x674d97d144e066d95df7574991a85d62f7fe450c",
//     ethers.utils.parseEther("11944.44444"),
//     ethers.utils.parseEther("88055.55556"),
//   ],
//   [
//     "0xd3674c20124b1077fb8c3cc68fa33adbcf23c27f",
//     ethers.utils.parseEther("570.4639143"),
//     ethers.utils.parseEther("66041.66667"),
//   ],
//   [
//     "0x1df54eaf8395a7331a366b34e03fedf95c19c2d2",
//     ethers.utils.parseEther("2986.111111"),
//     ethers.utils.parseEther("22013.88889"),
//   ],
//   [
//     "0x1d6dbbd08b671bb8324010812f72d0df75f511b7",
//     ethers.utils.parseEther("1987.7003"),
//     ethers.utils.parseEther("22013.88889"),
//   ],
//   [
//     "0x72dece2efd443beebb497be895eccea80a5b8852",
//     ethers.utils.parseEther("1634.703461"),
//     ethers.utils.parseEther("22013.88889"),
//   ],
//   [
//     "0x489bd2e16c8c665ccd35dbcbcfb895a5750f823d",
//     ethers.utils.parseEther("90.49049763"),
//     ethers.utils.parseEther("22013.88889"),
//   ],
//   [
//     "0x6111228851d71a8dd5c7c97477e963f265656986",
//     ethers.utils.parseEther("55.70776256"),
//     ethers.utils.parseEther("22013.88889"),
//   ],
//   [
//     "0x267fae9ec638957379bd9d2738e5e8ff308fa6e3",
//     ethers.utils.parseEther("1941.662703"),
//     ethers.utils.parseEther("22013.88889"),
//   ],
//   [
//     "0x3bdd050825b6ca026ec7cc41542088bb3b91e329",
//     ethers.utils.parseEther("15108.97038"),
//     ethers.utils.parseEther("6148479.167"),
//   ],
//   [
//     "0xf790d4140b245c35adb0a868694b83469f126667",
//     ethers.utils.parseEther("15106.97766"),
//     ethers.utils.parseEther("6148479.167"),
//   ],
//   [
//     "0x098208c402d635dc9eb7dac5d15fd4647f096809",
//     ethers.utils.parseEther("15511.86937"),
//     ethers.utils.parseEther("6148479.167"),
//   ],
//   [
//     "0x8046c4afaf2499759d0a4fc89c5d881ee8a2e918",
//     ethers.utils.parseEther("15516.51906"),
//     ethers.utils.parseEther("6148479.167"),
//   ],
//   [
//     "0x7dfc498377e36547f2daac9fd1d6aefae68753af",
//     ethers.utils.parseEther("29424.39434"),
//     ethers.utils.parseEther("12296958.33"),
//   ],
//   [
//     "0xa11ff2e632612bc6433360417b9dfc584848ff05",
//     ethers.utils.parseEther("57224.49835"),
//     ethers.utils.parseEther("24593916.67"),
//   ],
//   [
//     "0xc2defbf0d1ca36761311566719259e4fa8f5dc8e",
//     ethers.utils.parseEther("331.4219018"),
//     ethers.utils.parseEther("143999.8917"),
//   ],
//   [
//     "0x47627df1175c7eda92d213daf620e4c46cc3062d",
//     ethers.utils.parseEther("2986.111111"),
//     ethers.utils.parseEther("22013.88889"),
//   ],
// ];

// const SeedAllocations: Allocation[] = [
//   [
//     "0xb75becd13bbd85d7b7e3bbbe66b9ee8b59f36199",
//     ethers.utils.parseEther("153501,259"),
//     ethers.utils.parseEther("17008069,53"),
//   ],
//   [
//     "0xc6c883e9af08293f49ca8fd90d8c9cadfa933b39",
//     ethers.utils.parseEther("62671,7897"),
//     ethers.utils.parseEther("8504034,763"),
//   ],
//   [
//     "0xca8ef5b2eef847f6acb62fc7016b37188daff324",
//     ethers.utils.parseEther("26136,56558"),
//     ethers.utils.parseEther("2126008,691"),
//   ],
//   [
//     "0x3fd6dc6169faa55f27196d7ee44ae29a12f199e3",
//     ethers.utils.parseEther("21108,24864"),
//     ethers.utils.parseEther("1700806,951"),
//   ],
//   [
//     "0xd744723419531086fe06fd0509bade4d9aa28f48",
//     ethers.utils.parseEther("22712,70261"),
//     ethers.utils.parseEther("1700806,951"),
//   ],
//   [
//     "0xe539e8a25710bbc4cd0df438cea2b7e864217715",
//     ethers.utils.parseEther("42268,15451"),
//     ethers.utils.parseEther("850403,4793"),
//   ],
//   [
//     "0xc25733fc9d73e91018b7e84939872ce6adac9f90",
//     ethers.utils.parseEther("3282,341983"),
//     ethers.utils.parseEther("425201,7397"),
//   ],
//   [
//     "0xe339575b815fb96f865f3de0a6d80c5174dbecaf",
//     ethers.utils.parseEther("62998,97451"),
//     ethers.utils.parseEther("4252017,381"),
//   ],
//   [
//     "0xe570cd64bfd9d71e196a29de029285a00a557d6b",
//     ethers.utils.parseEther("39445,43769"),
//     ethers.utils.parseEther("425201,7397"),
//   ],
//   [
//     "0xe561219020d08e77933e9f5e58665b34507690ee",
//     ethers.utils.parseEther("16106,16076"),
//     ethers.utils.parseEther("425201,7397"),
//   ],
//   [
//     "0x9e528d2d08a4f2e7efbeefbd5722d971c466459e",
//     ethers.utils.parseEther("53382,99261"),
//     ethers.utils.parseEther("170080,6974"),
//   ],
//   [
//     "0x308eba39bae161118fd43d9083f0c7f5c062eb18",
//     ethers.utils.parseEther("40037,24267"),
//     ethers.utils.parseEther("127560,5173"),
//   ],
//   [
//     "0x53e4ca73edce4303eeba2d98d8247282438a4dfb",
//     ethers.utils.parseEther("13345,74756"),
//     ethers.utils.parseEther("42520,17244"),
//   ],
//   [
//     "0x3d106f1cb3b75c7c1b029e81ef1b7d074b4773d1",
//     ethers.utils.parseEther("13345,74756"),
//     ethers.utils.parseEther("42520,17244"),
//   ],
//   [
//     "0x93bd8b53a74645b40ec7c65ecf0dc9f566b0a414",
//     ethers.utils.parseEther("13345,74756"),
//     ethers.utils.parseEther("42520,17244"),
//   ],
//   [
//     "0xec6ce0f929f68c59a3611e6ee05e7e78b4216ce2",
//     ethers.utils.parseEther("13345,74756"),
//     ethers.utils.parseEther("42520,17244"),
//   ],
//   [
//     "0xabf54bfc77a53b73f72f4f8e0ce7e399862baa0f",
//     ethers.utils.parseEther("80074,48772"),
//     ethers.utils.parseEther("255121,0423"),
//   ],
//   [
//     "0x4401ebbb599c0d01e3dbe774bfa0c8666e7fea91",
//     ethers.utils.parseEther("8540,572768"),
//     ethers.utils.parseEther("223207,25"),
//   ],
// ];
