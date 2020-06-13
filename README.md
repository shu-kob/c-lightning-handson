# c-lightning-handson
2020/6/19ビットコインとか勉強会c-lightningハンズオン

## bitcoindをSignetで対応でインストール

必要なライブラリをインストール（Macの場合）
```
$ brew upgrade
$ brew install autoconf automake libtool berkeley-db4 boost miniupnpc openssl pkg-config protobuf qt
```

必要なライブラリをインストール（Ubuntuの場合）
```
$ sudo apt-get update
$ sudo apt-get install autoconf build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
$ sudo apt-get install libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev

$ sudo add-apt-repository ppa:bitcoin/bitcoin
$ sudo apt-get update

$ sudo apt-get install libdb4.8-dev libdb4.8++-dev
$ sudo apt-get install libminiupnpc-dev
$ sudo apt-get install libzmq3-dev
```

Mac, Ubuntu共通
```
$ git clone https://github.com/bitcoin/bitcoin
$ cd bitcoin
```

既にbitcoinリポジトリがある場合は

```
$ cd bitcoin
$ git pull
```

git cloneした場合も、既にbitcoinブランチがあってpullした場合も共通

```
$ git fetch origin pull/16411/head:signet
$ git checkout signet
```

signetブランチになっていることを確認
```
$ git branch
  master
* signet
```

```
$ ./autogen.sh
$ ./configure
$ make
$ sudo make install
```

Macでbitcoin.confを編集
```
$ nano "/Users/${USER}/Library/Application Support/Bitcoin/bitcoin.conf"
```

Ubuntuでbitcoin.confを編集
```
$ nano ~/.bitcoin/bitcoin.conf
```

```
signet=1
txindex=1
server=1
daemon=1
rpcuser=hoge
rpcpassword=hoge
[signet]
rpcport=38332
port=38333
```

c-lightning公式ドキュメントに沿ってインストール

Macの場合

https://github.com/ElementsProject/lightning/blob/master/doc/INSTALL.md#to-build-on-macos

Ubuntuの場合

https://github.com/ElementsProject/lightning/blob/master/doc/INSTALL.md#to-build-on-ubuntu

インストールが終わったら
~/.lightning/config
を作成します。

```
alias=Aquamarine
rgb=7FFFD4
#network=bitcoin
#network=testnet
#network=regtest
network=signet
```

ネットワーク上のノードを見つけます。

```
$ lightning-cli listnodes
{
   "nodes": [
      {
         "nodeid": "03e0bcd5e2d8fe663c54b8c129d277812bfa3fbd62dcd1424c21a28bdc6e51f632",
         "alias": "Aquamarine",
         "color": "7fffd4",
         "last_timestamp": 1591400993,
         "features": "8000000002aaa2",
         "addresses": []
      },
      {
         "nodeid": "03d850b86b3efd56317fa4a6291480b04aca2ee1c1649ee9cdc02e205e0ed7f55a",
         "alias": "ORANGEBEAM",
         "color": "ff8c00",
         "last_timestamp": 1591400192,
         "features": "8000000002aaa2",
         "addresses": [
            {
               "type": "ipv6",
               "address": "2001:268:c0e4:ae82:29e7:b9bb:2c03:b22d",
               "port": 9735
            }
         ]
      }
   ]
}
```
ノードに接続します。（BTCは消費しません）
IPアドレスが表示されているもののほうが接続しやすいです。
```
$ lightning-cli connect 03d850b86b3efd56317fa4a6291480b04aca2ee1c1649ee9cdc02e205e0ed7f55a@2001:268:c0e4:ae82:29e7:b9bb:2c03:b22d:9735
{
   "id": "03d850b86b3efd56317fa4a6291480b04aca2ee1c1649ee9cdc02e205e0ed7f55a",
   "features": "02aaa2"
}
```

接続先のIDが返ってきたので接続成功です！


c-lightningウォレットに入金するため、アドレスを発行します。

```
$ lightning-cli newaddr
{
   "address": "sb1qjfnc470q679yjm99e86meakn863708njlx4k2n",
   "bech32": "sb1qjfnc470q679yjm99e86meakn863708njlx4k2n"
}
```

Signet Faucetに上記で得たアドレスをコピペして、Signet用BTCを入手します。

https://signet.bc-2.jp/

TXをExplorerで確認してみましょう。
https://explorer.bc-2.jp/

listfundsコマンドのoutputsがconfirmedされたらfundchannelでチャンネルを開けます。

```
$ lightning-cli listfunds
{
   "outputs": [
      {
         "txid": "5cb2277f1b7569330270772d05ec18faf5357459229802b200abf81f7f83a101",
         "output": 1,
         "value": 99798769,
         "amount_msat": "99798769000msat",
         "address": "sb1qds0ad9en4ef5ynecvqpspz70lxsarw5uaknakp",
         "status": "confirmed",
         "blockheight": 13043
      },
      {
         "txid": "00448232dc6acbf8c4a52258339bff36e478fa11b809df8c76007749d6e798ef",
         "output": 0,
         "value": 99817,
         "amount_msat": "99817000msat",
         "address": "sb1q5r46nlkqkhgtvd05aauv7gt73adw6eswl8eszd",
         "status": "confirmed",
         "blockheight": 13043
      },
      {
         "txid": "4669a808bc261e44548603fea1abc4927e7b7e344ef1dbac77195ee3da00fd83",
         "output": 0,
         "value": 99817,
         "amount_msat": "99817000msat",
         "address": "sb1qeekv4h2c3wvaknhyzn2d73s07j8nq9vh789aec",
         "status": "confirmed",
         "blockheight": 13532
      },
      {
         "txid": "bdece94d394a54952cd62755a6a774597bffcb311c3ad6f597a2787c124949ba",
         "output": 1,
         "value": 100000000,
         "amount_msat": "100000000000msat",
         "address": "sb1qjfnc470q679yjm99e86meakn863708njlx4k2n",
         "status": "confirmed",
         "blockheight": 13535
      }
   ],
   "channels": [
      {
         "peer_id": "03e0bcd5e2d8fe663c54b8c129d277812bfa3fbd62dcd1424c21a28bdc6e51f632",
         "connected": false,
         "state": "ONCHAIN",
         "short_channel_id": "13043x2x0",
         "channel_sat": 100000,
         "our_amount_msat": "100000000msat",
         "channel_total_sat": 100000,
         "amount_msat": "100000000msat",
         "funding_txid": "5cb2277f1b7569330270772d05ec18faf5357459229802b200abf81f7f83a101",
         "funding_output": 0
      }
   ]
}
```

```
$ lightning-cli fundchannel 03e0bcd5e2d8fe663c54b8c129d277812bfa3fbd62dcd1424c21a28bdc6e51f632 100000
{
   "tx": "0200000000010101a1837f1ff8ab00b2029822597435f5fa18ec052d7770023369751b7f27b25c0100000000feffffff02a086010000000000220020155eff4d34ad33683b56974b287675d828af0a92b0f05c26ba9f29b778848736b747f10500000000160014d943a1df3ec162d77b9e10ce4780bb687b6cf0bb0247304402204f85f7162a9d86023f05513dc2f7e15b0bf0f7d00ac3cfa8922bbe5df9634e150220184b39b9aeba1ec13d6f0411c0f5f7b6f2c6d20b3c33fcc4b4eb290baf4d176a012102f45c34a953d45b600422c565a5f2b611293035f0c31bc2b1c8afa5578ba9539700000000",
   "txid": "8db0f3db78d7316d9981501fa37dcba548931fe700c878830a2ff6ec31d1f68d",
   "channel_id": "8df6d131ecf62f0a8378c800e71f9348a5cb7da31f5081996d31d778dbf3b08d"
}
```

```
$ lightning-cli listpeers
```

```
"state": "CHANNELD_AWAITING_LOCKIN",
```
これはLightningにデポジットするのをロック中という意味で、
Signetの場合、1承認で
```
"state": "CHANNELD_NORMAL",
```
となります。

Invoiceを発行して、送ってもらいましょう。

```
$ lightning-cli invoice 100000 "test" "test"
{
   "payment_hash": "5e8f876b9064f8ba870436e6218510a5ca591e6a69c86ffa5b82d6bbc08d085b",
   "expires_at": 1592011601,
   "bolt11": "lnsb1u1p0d4ux3pp5t68cw6usvnut4pcyxmnzrpgs5h99j8n2d8yxl7jmsttthsydppdsdq8w3jhxaqxqyjw5qcqp2sp5g5wfjjl2ra7kfwmu9dnejl5pp5qr6w94kg3mazm8kjk2acnrydks9qy9qsqdehsvf2d5xwqtkxt622h694nxchp6xd0wqg3563r8x6xpsactfprkd0ac4p9e9xp6mzg4td8u60natuj6suryelfm6rf8zepmx494xqpp7x7xq",
   "warning_deadends": "No channel with a peer that is not a dead end"
}
```

送る方はpayコマンドを叩きましょう。

```
$ lightning-cli pay lnsb1u1p0d4ux3pp5t68cw6usvnut4pcyxmnzrpgs5h99j8n2d8yxl7jmsttthsydppdsdq8w3jhxaqxqyjw5qcqp2sp5g5wfjjl2ra7kfwmu9dnejl5pp5qr6w94kg3mazm8kjk2acnrydks9qy9qsqdehsvf2d5xwqtkxt622h694nxchp6xd0wqg3563r8x6xpsactfprkd0ac4p9e9xp6mzg4td8u60natuj6suryelfm6rf8zepmx494xqpp7x7xq
{
   "id": 3,
   "payment_hash": "5e8f876b9064f8ba870436e6218510a5ca591e6a69c86ffa5b82d6bbc08d085b",
   "destination": "03e0bcd5e2d8fe663c54b8c129d277812bfa3fbd62dcd1424c21a28bdc6e51f632",
   "msatoshi": 100004,
   "amount_msat": "100004msat",
   "msatoshi_sent": 100004,
   "amount_sent_msat": "100004msat",
   "created_at": 1591406825,
   "status": "complete",
   "payment_preimage": "2944013f9ac06051181131781ae5a561b5e10564877442c0e3231fb5a39c889a",
   "bolt11": "lnsb1u1p0d4ux3pp5t68cw6usvnut4pcyxmnzrpgs5h99j8n2d8yxl7jmsttthsydppdsdq8w3jhxaqxqyjw5qcqp2sp5g5wfjjl2ra7kfwmu9dnejl5pp5qr6w94kg3mazm8kjk2acnrydks9qy9qsqdehsvf2d5xwqtkxt622h694nxchp6xd0wqg3563r8x6xpsactfprkd0ac4p9e9xp6mzg4td8u60natuj6suryelfm6rf8zepmx494xqpp7x7xq"
}
```
