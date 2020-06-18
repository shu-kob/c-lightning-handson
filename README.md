# c-lightning-handson
2020/6/19ビットコインとか勉強会c-lightningハンズオン

## Signet対応のbitcoindとc-lightningをDockerでインストール

```
git clone https://github.com/shu-kob/c-lightning-handson
cd c-lightning-handson
./build.sh
```

## ビルドが終わったら起動

```
./run.sh 
```

別ターミナルを開き、Dockerの中を操作するためコンテナのIDを取得

```
docker ps
```

```
ID=XXX
```

起動中のコンテナが一つだけの場合は以下で取得できる
```
ID=$(docker ps -q)
```

```
alias bcli="docker exec $ID bitcoin-cli"
alias lcli="docker exec $ID lightning-cli"
```

bitcoindの状態を確認

```
bcli getblockchaininfo
```
ブロックチェーンエクスプローラとブロック高が一致すれば同期完了

https://explorer.bc-2.jp/

c-lightningを起動する

```
docker exec $ID lightningd --log-level=debug >> ~/.lightning/debug.log &
```

また別ターミナルを開くなどして、Dockerの外でc-lightningノードの状態を確認
```
lcli getinfo
```

Dockerの中に入る場合は、別のターミナルを開き下記のコマンド

```
ID=$(docker ps -q)
docker exec -i -t $ID bash
```

参考）
~/.lightning/config
でLightning Nodeのエイリアスと色を設定できる

例）
```
alias=Aquamarine
rgb=7FFFD4
network=signet
```

c-lightningウォレットに入金するため、アドレスを発行

```
lcli newaddr
{
   "address": "sb1qll2ssyjnklvapqpmapyq0dwnhtp4p8g9a0r8rh",
   "bech32": "sb1qll2ssyjnklvapqpmapyq0dwnhtp4p8g9a0r8rh"
}

```

Signet Faucetに上記で得たアドレスをコピペして、Signet用BTCを入手

https://signet.bc-2.jp/

TXをExplorerで確認

https://explorer.bc-2.jp/

listfundsコマンドのoutputsがconfirmedされたらfundchannelでチャンネルを開ける

承認前

```
lcli listfunds
{
   "outputs": [],
   "channels": []
}
```

1承認後
```
{
   "outputs": [
      {
         "txid": "094958065057e48342dfb3e40a5cda15a7a44847f11f7186752741ff33e8d160",
         "output": 0,
         "value": 1000000000,
         "amount_msat": "1000000000000msat",
         "address": "sb1qll2ssyjnklvapqpmapyq0dwnhtp4p8g9a0r8rh",
         "status": "confirmed",
         "blockheight": 15294
      }
   ],
   "channels": []
}
```


チャンネルを貼るため、ネットワーク上のノードを見つける

```
lcli listnodes
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
ノードに接続（BTCは消費しない）
IPアドレスが表示されているもののほうが接続しやすい
```
lcli connect 03d850b86b3efd56317fa4a6291480b04aca2ee1c1649ee9cdc02e205e0ed7f55a@2001:268:c0e4:ae82:29e7:b9bb:2c03:b22d:9735
{
   "id": "03d850b86b3efd56317fa4a6291480b04aca2ee1c1649ee9cdc02e205e0ed7f55a",
   "features": "02aaa2"
}
```

接続先のIDが返ってきたら接続成功


```
lcli fundchannel 03e0bcd5e2d8fe663c54b8c129d277812bfa3fbd62dcd1424c21a28bdc6e51f632 100000
{
   "tx": "0200000000010101a1837f1ff8ab00b2029822597435f5fa18ec052d7770023369751b7f27b25c0100000000feffffff02a086010000000000220020155eff4d34ad33683b56974b287675d828af0a92b0f05c26ba9f29b778848736b747f10500000000160014d943a1df3ec162d77b9e10ce4780bb687b6cf0bb0247304402204f85f7162a9d86023f05513dc2f7e15b0bf0f7d00ac3cfa8922bbe5df9634e150220184b39b9aeba1ec13d6f0411c0f5f7b6f2c6d20b3c33fcc4b4eb290baf4d176a012102f45c34a953d45b600422c565a5f2b611293035f0c31bc2b1c8afa5578ba9539700000000",
   "txid": "8db0f3db78d7316d9981501fa37dcba548931fe700c878830a2ff6ec31d1f68d",
   "channel_id": "8df6d131ecf62f0a8378c800e71f9348a5cb7da31f5081996d31d778dbf3b08d"
}
```

```
lcli listpeers
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
lcli invoice 100000 "test" "test"
{
   "payment_hash": "5e8f876b9064f8ba870436e6218510a5ca591e6a69c86ffa5b82d6bbc08d085b",
   "expires_at": 1592011601,
   "bolt11": "lnsb1u1p0d4ux3pp5t68cw6usvnut4pcyxmnzrpgs5h99j8n2d8yxl7jmsttthsydppdsdq8w3jhxaqxqyjw5qcqp2sp5g5wfjjl2ra7kfwmu9dnejl5pp5qr6w94kg3mazm8kjk2acnrydks9qy9qsqdehsvf2d5xwqtkxt622h694nxchp6xd0wqg3563r8x6xpsactfprkd0ac4p9e9xp6mzg4td8u60natuj6suryelfm6rf8zepmx494xqpp7x7xq",
   "warning_deadends": "No channel with a peer that is not a dead end"
}
```

送る方はpayコマンドを叩きましょう。

```
lcli pay lnsb1u1p0d4ux3pp5t68cw6usvnut4pcyxmnzrpgs5h99j8n2d8yxl7jmsttthsydppdsdq8w3jhxaqxqyjw5qcqp2sp5g5wfjjl2ra7kfwmu9dnejl5pp5qr6w94kg3mazm8kjk2acnrydks9qy9qsqdehsvf2d5xwqtkxt622h694nxchp6xd0wqg3563r8x6xpsactfprkd0ac4p9e9xp6mzg4td8u60natuj6suryelfm6rf8zepmx494xqpp7x7xq
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
