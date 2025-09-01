<template>
    <div class = "hello">
        <h1>{{ msg }}</h1>
        <button @click="onConnect"> Connect Wallet </button><br/>
        <p>Address : {{ Account }}</p>
        <button @click="onSign">Sign with metamask</button>
    </div>
</template>

<script>
import { ethers } from "ethers";

export default{
    name: "HelloWorld",
    props: {},
    data: function () {
        return {
            mag: "VerifySignature",
            Account: "Not connect",
        };
    },
    methods: {
        async onConnect() {
            if (typeof window.ethereum != "undefined"){
                console.log("MetaMask is installed!");
            }

            let ethereum = window.ethereum;

            try {
                await ethereum.request({
                    method: "wallet_switchEthereumChain",
                    params: [{chainId:"0x4"}],
                });
            } catch (switchError) {
                // This error code indicates that the chain has not been added to MetaMask.
                if (switchError.code === 4902) {
                    try {
                        await ethereum.request({
                            method: "wallet_addEthereumChain",
                            params: [
                            {
                                chainId: "0x4",
                                chainName: "Rinkeby",
                                rpcUrls: ["https://rinkeby.infura.io/v3/"] /* ... */,
                            },
                            ],
                        });
                    } catch (addError) {
                        // handle "add" error
                        console.log(addError);
                    }
                }
            }
            this.getAccount(ethereum);
        },

        //授权账户
        async getAccount(ethereum) {
            const accounts = await ethereum.request({
                method: "eth_requestAccounts",
            });
            const myAccount = accounts[0];
            this.Account = myAccount;
        },
        //签名
        async onSign(){
            // 1、构建 provider
            let ethereum = window.ethereum;
            const provider = new ethers.providers.Web3Provider(ethereum);
            let signer = await provider.getSigner();

            //2、对签名内容进行 k256 获取 hash
            let message = ethers.utils.solidityKeccak256(["string",["HelloWorld"]]);

            //3、转换成 UTF8 bytes
            let arrayifyMessage = ehters.utils.arrayify(message);

            //4、使用私钥进行消息签名
            let flatSignature = await signer.signMessage(arrayifyMessage);
            console.log(flatSignature);
        },
    },    
};
</script>

<!-- 添加 "scoped "属性，使 CSS 仅限于该组件 -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>