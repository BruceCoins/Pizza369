// Keccak-256: 产生256位哈希
const keccak256 = require('keccak256')
const { MerkleTree } = require('merkletreejs')

//白名单地址
const address = ["0xeD2827f8f76892320e73f90e4D49Ebf8a0Af7c43","0x1071258E2C706fFc9A32a5369d4094d11D4392Ec","0x25f7fF7917555132eDD3294626D105eA1C797250","0xF6574D878f99D94896Da75B6762fc935F34C1300","0xfDbAb374ee0FC0EA0D7e7A60917ac01365010bFe","0xfB73f8B1DcD5d61D4dDC3872dA53200B8562F243","0x95F6E4C94857f605b9A73c9163D5c94AAf849c40","0xEd2C82417256DF74a995213713A586E07d3e5255","0xCb14d0D43BB32705fAbbD863f860A1410fa14613","0x7a865e44988a2ebcad845E977db07C71f8c62d31","0x340F5bEcB63a33B53959026d0CEb1f83C53A102F","0x969560dBBf4872049D0d245791eD74dEd0D66578","0x81B8888dfbdcc3Ad1dfe30A6f58a6d47eaf99aE8","0x29aB6E246c4aC305974A730B10459417FF65D469","0x2B790Dd5d9440f098E057E4958e3Ac0214712352","0xA53E16be846D815dfF774A384858021952b5B22E","0x04473648f6BeA9b074DFd7693b20AFCF9971a125","0xc26716b827c0d207AA3D25667028C2da1De787bf","0x21BAa9441e2DF389Ca27c9dB1cD9B59f2504dfEa","0x93D5193694a49eB85366ea1BDa69B577f1b878ae","0x3654322cFecCD60965A8b7866f50e55FE14EEBCC","0x174BAFfcB004ACfc53cDD3A48957b9D353BB171f","0x1d9A510DfCa2b1f3C52BD81122816FD86C7C7Ba0","0x55ae457519BbAf25d825772da81F57bD18E4B6Db","0x0997680928431EA22C1930c12Dc91f06d10be0c6","0xF9E8383bd1250aCf18Da971467B70045d4D06fB1","0x847aB63F94e931F9264407C54C97DbCfFEC9f8FE","0x5dcE9Fc14eED67D046A130d1d991163114b2820c","0x53b5585AA42b79B0b8e620896ceB0D0435441071","0x5E661e550Fcac43DEC925449A7F0bCA0C32D6A44","0xA46f327d91282aFD4E99d79a8fD7Eac7A123dAF5","0xD03241a89a18c779B71f1bD348d2BbF1e20b8ea8","0xed0850a960ABE5715ECEa4b479272092733922f0","0x4D15f921A25e8677Da2d878B01c80Df861E67F03","0x98d450BfbBFD64D780B632f6acd0FC59d11E575e","0xaef0FfA370108915d4198Fe6eF40eBa446f00d79","0x5Bc46cf525E6E26f8799685E5247a93355354cBf","0x5B9837c339F7b55564Aeb185e8DEdeEDD10AfcB7","0xbda8049200F7a42312AFeBDb5b99D514EE0df302","0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"]

//通过hash生成叶子，返回二进制格式（buffer）
const leaves = address.map(x => keccak256(x))
console.log(leaves);

//输出116进制数据
//console.log(leaves[0].toString('hex'))

//MerkleTree 运算
const tree = new MerkleTree(leaves, keccak256, {sortPairs: true})
//console.log(tree.toString('hex'))

//获取root
const root = tree.getHexRoot()

// 0xb60f0853dd9086cfb567b6ad26b471de1f2f1e3d7045117b51960e0b8f75f601
// console.log(`root=\n${root}`

// 0xeD2827f8f76892320e73f90e4D49Ebf8a0Af7c43
let leaf = address[0]

//获取proof, 'getHexProof'将返回相邻节点、父节点的hash值，
let proof = tree.getHexProof(keccak256(leaf))

// ["0xb7b19092bad498eae34230a9e14c8ce3d9d85b2bb91212108c9d47d1948acfeb","0x1f957db768cd7253fad82a8a30755840d536fb0ffca7c5c73fe9d815b1bc2f2f","0x924862b314bd38813a325167aca7caee16318f07303bd8e9f81bbe5808575fbf","0xe5076a139576746fd34a0fd9c21222dc274a909421fcbaa332a5af7272b6dcb1","0x148c730f8169681c1ebfb5626eb20af3d2351445463a1fdc5d0b116c62dc58c8","0x5712507eeb3d7b48e5876f21fc871656c2379464b480c8e89c50c2a1e8f58ac5"]
// console.log(`hexProof=\n${JSON.stringify(hexProof)}`);

const verify = tree.verify(proof, keccak256(leaf), tree.getRoot());
//console.log(verify)

//buffer 转成 16进制
const buf2hex = (x) => {
    return '0x' + x.toString('hex')
}

//buffer 转换成16进制，在合约 isValid 验证白名单
let inputRemixLeaf = buf2hex(keccak256(address[0]))

// 0x1f2ad17a70338fba481e2da1976862f7f435fbd2636deab2265049161ac113e5
// console.log(`inputRemixLeaf=\n${inputRemixLeaf}`);