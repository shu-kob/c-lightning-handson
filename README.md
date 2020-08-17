# c-lightning-handson
2020/6/19ビットコインとか勉強会c-lightningハンズオン
https://cryptocurrency.connpass.com/event/177836/

https://youtu.be/B9LYmm5Z6cw

2020/8/18ビットコインとか勉強会c-lightningハンズオン
https://cryptocurrency.connpass.com/event/184541/

## Dockerをインストール

https://www.docker.com/


### MacにDockerをインストール

https://hub.docker.com/editions/community/docker-ce-desktop-mac

### UbuntuにDockerとDocker-composeをインストール（DockerのみでOK、docker-composeは不要）

https://qiita.com/youtangai/items/ff67ceff5497a0e0b1af

###Windows10の方はUbuntuを入れた上で、上記「UbuntuにDockerとDocker-composeをインストール」

https://www.microsoft.com/ja-jp/p/ubuntu/9nblggh4msv6?activetab=pivot:overviewtab

## Dockerfileなどをダウンロードしてセットアップ

```
git clone https://github.com/shu-kob/c-lightning-handson
cd c-lightning-handson
```

### 6月ご参加の方、ローカルにリポジトリがある方はこちら

Signetがリセットされているため、旧signetのデータを消してください。

```
cd docker-signet
rm -rf signet
```
```
cd c-lightning-handson
git pull
```

### Signet対応のbitcoindとc-lightningをインストールしたDockerをビルド

Signetがリセットされており、新ネットワークに接続するため、前回ご参加の方も再度ビルドしてください。
c-lightningのVer.も0.8.2から0.9.0.1に上げています。

```
./build.sh
```


### ビルドが終わったらDocker起動（bitcoindが起動する)

```
./run.sh 
```

### 別ターミナルを開き、Dockerの中を操作するためコンテナのIDを取得

```
docker ps
```
CONTAINER IDを取得

```
ID=XXX
```

XXXはCONTAINER ID

### 起動中のコンテナが一つだけの場合は以下で取得
```
ID=$(docker ps -q)
```
### Dockerコンテナ内でコマンドを打ちやすくするためにエイリアスを設定
```
alias bcli="docker exec $ID bitcoin-cli"
```

### bitcoindの状態を確認

```
bcli getblockchaininfo
```
ブロックチェーンエクスプローラとブロック高が一致すれば同期完了

https://explorer.bc-2.jp/

### c-lightningを起動する

```
docker exec $ID lightningd &
```

### 別ターミナルを開くなどして、Dockerの外でc-lightningノードの状態を確認
```
ID=$(docker ps -q)
alias lcli="docker exec $ID lightning-cli"
lcli getinfo
```

```
{
   "id": "02f15b34c18d0e1d41879af15b0b8aeeb646d1266445d2f9fa806befe16417197c",
   "alias": "SILENTCHIPMUNK",
   "color": "02f15b",
   "num_peers": 0,
   "num_pending_channels": 0,
   "num_active_channels": 0,
   "num_inactive_channels": 0,
   "address": [],
   "binding": [
      {
         "type": "ipv6",
         "address": "::",
         "port": 9735
      },
      {
         "type": "ipv4",
         "address": "0.0.0.0",
         "port": 9735
      }
   ],
   "version": "0.9.0-1",
   "blockheight": 1013,
   "network": "signet",
   "msatoshi_fees_collected": 0,
   "fees_collected_msat": "0msat",
   "lightning-dir": "/root/.lightning/signet"
}
```

### 参考）Dockerの中に入る場合は、別のターミナルを開き下記のコマンド

```
ID=$(docker ps -q)
docker exec -i -t $ID bash
```

### c-lightningウォレットに入金するため、アドレスを発行

```
lcli newaddr
{
   "address": "sb1qa0p37nztzp6m6kv4kemmvdymjs2zezum05g2q9",
   "bech32": "sb1qa0p37nztzp6m6kv4kemmvdymjs2zezum05g2q9"
}
```

### Signet Faucetに上記で得たアドレスをコピペして、Signet用BTCを入手

https://signet.bc-2.jp/

同一IP、同一アドレスでは1回入手するとしばらくもらえない

### TXをExplorerで確認

https://explorer.bc-2.jp/

### listfundsコマンドのoutputsがconfirmedされたらfundchannelでチャンネルを開ける

承認前

```
lcli listfunds
{
   "outputs": [],
   "channels": []
}
```

1承認後（Signetの場合はどのブロックも生成間隔がほぼ10分)
```
lcli listfunds
{
   "outputs": [
      {
         "txid": "1fac38170d24a7e5905e8b88ff6db3af98b91b496153e60bb516c61423144a68",
         "output": 1,
         "value": 1000000000,
         "amount_msat": "1000000000000msat",
         "scriptpubkey": "0014ebc31f4c4b1075bd5995b677b6349b94142c8b9b",
         "address": "sb1qa0p37nztzp6m6kv4kemmvdymjs2zezum05g2q9",
         "status": "confirmed",
         "blockheight": 1014,
         "reserved": false
      }
   ],
   "channels": []
}
```


### チャンネルを貼るため、ネットワーク上のノードを見つける

```
lcli listnodes
{
   "nodes": []
}
```

ない場合は
```
031c94cba9161457236a6df85d6c890e82f1dcbf5729e80f06c318f94139f17015@153.126.144.46:9735
```
に接続する

### ノードに接続
BTCは消費しない
IPアドレスが表示されているもののほうが接続しやすい
```
lcli connect 031c94cba9161457236a6df85d6c890e82f1dcbf5729e80f06c318f94139f17015@153.126.144.46:9735
{
   "id": "031c94cba9161457236a6df85d6c890e82f1dcbf5729e80f06c318f94139f17015",
   "features": "02aaa2"
}
```

### 接続先のIDが返ってきたら接続成功


```
lcli fundchannel 031c94cba9161457236a6df85d6c890e82f1dcbf5729e80f06c318f94139f17015 100000
{
   "tx": "02000000000101684a142314c616b50be65361491bb998afb36dff888b5e90e5a7240d1738ac1f0100000000feffffff02a086010000000000220020ee26fe5b118833f83c02cef110f961b07343779878f4b776187f15f955fba8f8c642993b000000001600144e0e9980ed1e9247d6676b2a1dd35bb0d31b90e602473044022031e4e922850f497ead2b253b4522d80d4e8ce846bbecb9f4e0ad91a6578be3f602201aff23fd05e1a9c4e9db4514cb0fc8a45f65bbf967283ab50b11ae99dd090019012103d731d8fd405616f4072874b056ab79348d94f9f540a55983f804aa5169a57ed5f6030000",
   "txid": "8025b931111ef199e4e47b2183ff9ce32bf15370c751ebc593e12786f76082ca",
   "channel_id": "ca8260f78627e193c5eb51c77053f12be39cff83217be4e499f11e1131b92580"
}
```

```
lcli listpeers
```

```
"status": [
   "CHANNELD_AWAITING_LOCKIN:Funding needs 1 more confirmations for lockin."
],
```

これはLightningにデポジットするのをロック中という意味で、
Signetの場合、1承認で
```
"CHANNELD_NORMAL:Funding transaction locked."
```
となる。ちなみにTestnetの場合3承認。Mainnetの場合は6承認。

Invoice(請求書)を発行して、送ってもらう。

```
lcli invoice 50000000 "test55" "signet"
{
   "payment_hash": "cc769bd3dd25c06cfbd9d76e08b1534eeea5240de57c575e0bcb5f1155cc2930",
   "expires_at": 1598276216,
   "bolt11": "lnsb500u1p0n4plcpp5e3mfh57ayhqxe77e6ahq3v2nfmh22fqdu479whsted03z4wv9ycqdq2wd5kwmn9wsxqyjw5qcqp2sp5pywnduz0vpq3cha257klk3qul5f9q35m47lt95t76vuewjn4dm3s9qy9qsqcf2hwc50xlch40zq8efcec88xc4g6yddfdyxxtnauaxhpl5p94nxfxmzudxg26w5yg93dher3yd27arlragtymh4065nkj0pcmpw7dqqyczz4x",
   "warning_deadends": "No channel with a peer that is not a dead end"
}
```

```
"warning_capacity": "No channels"
```

となっている場合は、fundingTXの承認待ち。しばらく待つ。

送る方はpayコマンドを叩く

```
lcli pay lnsb500u1p0n4plcpp5e3mfh57ayhqxe77e6ahq3v2nfmh22fqdu479whsted03z4wv9ycqdq2wd5kwmn9wsxqyjw5qcqp2sp5pywnduz0vpq3cha257klk3qul5f9q35m47lt95t76vuewjn4dm3s9qy9qsqcf2hwc50xlch40zq8efcec88xc4g6yddfdyxxtnauaxhpl5p94nxfxmzudxg26w5yg93dher3yd27arlragtymh4065nkj0pcmpw7dqqyczz4x
{
   "destination": "031c94cba9161457236a6df85d6c890e82f1dcbf5729e80f06c318f94139f17015",
   "payment_hash": "cc769bd3dd25c06cfbd9d76e08b1534eeea5240de57c575e0bcb5f1155cc2930",
   "created_at": 1597671864.509,
   "parts": 1,
   "msatoshi": 50000000,
   "amount_msat": "50000000msat",
   "msatoshi_sent": 50000000,
   "amount_sent_msat": "50000000msat",
   "payment_preimage": "18d7af61cdabb87a588d6b8c4dd561208c156cfed86be7df0b42862b64dabe8c",
   "status": "complete"
}
```
受け取った方は
```
lcli listinvoices
{
   "invoices": [
{
         "label": "test55",
         "bolt11": "lnsb500u1p0n4plcpp5e3mfh57ayhqxe77e6ahq3v2nfmh22fqdu479whsted03z4wv9ycqdq2wd5kwmn9wsxqyjw5qcqp2sp5pywnduz0vpq3cha257klk3qul5f9q35m47lt95t76vuewjn4dm3s9qy9qsqcf2hwc50xlch40zq8efcec88xc4g6yddfdyxxtnauaxhpl5p94nxfxmzudxg26w5yg93dher3yd27arlragtymh4065nkj0pcmpw7dqqyczz4x",
         "payment_hash": "cc769bd3dd25c06cfbd9d76e08b1534eeea5240de57c575e0bcb5f1155cc2930",
         "msatoshi": 50000000,
         "amount_msat": "50000000msat",
         "status": "paid",
         "pay_index": 4,
         "msatoshi_received": 50000000,
         "amount_received_msat": "50000000msat",
         "paid_at": 1597671446,
         "payment_preimage": "18d7af61cdabb87a588d6b8c4dd561208c156cfed86be7df0b42862b64dabe8c",
         "description": "signet",
         "expires_at": 1598276216
      }
   ]
}
```
で資金を受け取っていることを確認

```
"status": "expired",
```
は支払いがなされないままinvoiceの有効期限を迎えたもの

```
"status": "paid",
```
は支払いがされたもの

支払い時、以下はルートが見つからないエラー
支払いのために十分なL-BTC(LN上のBTC)を持っていないことが原因
30Ksatoshi(30000satoshi=30000000msat)必要？
```
lightning-cli pay lnsb50n1p0n3nt4pp5jxmw5gnae3up8fllnkfgthd2kksdjcg8ldmud6l8ls63lnrdhxasdq8w3jhxaqxqyjw5qcqp2sp52q3lqjlkyfduq7w94tn9fl2l58yxddqqag6dj95jdufgw73ehm7q9qy9qsqrzv3k33hnjv0ae55p2zt4jvghr7kejmud03ucf7p0d7r96sv2fljzzput9pde3pncjlhuqhgfrphx28fdectgpcc9npzjummly450jspx730th
{
   "code": 210,
   "message": "Ran out of routes to try after 1 attempt: see `paystatus`",
   "attempts": [
      {
         "status": "failed",
         "failreason": "Error computing a route to 02605b52c049f80135dd0d4fad1fcb97c9b789bff2794696152a74dc9cacf27587: \"Could not find a route\" (205)",
         "partid": 1,
         "amount": "5000msat"
      }
   ]
}
```

## ヘルプ

```
lcli help
```
でコマンド一覧を見れる

## チャンネルを張るためにデポジットした情報を見る

listfundsを見ると、channelsの情報が見れる。
```
lcli listfunds
{
   "outputs": [
      {
         "txid": "12e8b124ba1367e72793a9e1815a8b8a9581a8e83e3280caf9fc3c7e9b98f946",
         "output": 1,
         "value": 1999899846,
         "amount_msat": "1999899846000msat",
         "address": "sb1qrkehc98qen3t4wscy3yqvqm2qs67xnprh29q26",
         "status": "confirmed",
         "blockheight": 15423
      }
   ],
   "channels": [
      {
         "peer_id": "02e5db87cad8761fe5fe7cadfb3c9393098e217db3d8a00500565fe6b8ea040972",
         "connected": true,
         "state": "CHANNELD_NORMAL",
         "short_channel_id": "15423x1x0",
         "channel_sat": 99899,
         "our_amount_msat": "99899000msat",
         "channel_total_sat": 100000,
         "amount_msat": "100000000msat",
         "funding_txid": "12e8b124ba1367e72793a9e1815a8b8a9581a8e83e3280caf9fc3c7e9b98f946",
         "funding_output": 0
      }
   ]
}
```
## チャンネルのクローズ

### チャンネルをクローズする際は以下

```
lcli close 02e5db87cad8761fe5fe7cadfb3c9393098e217db3d8a00500565fe6b8ea040972
{
   "tx": "020000000146f9989b7e3cfcf9ca80323ee8a881958a8b5a81e1a99327e76713ba24b1e8120000000000ffffffff018485010000000000160014b9acff5dfb4a684414409d9dc2ff0a64ac0cf43800000000",
   "txid": "641a41b2214a7b876f06dc30242a289084a1d61cc8d4789b432172ad7af3015a",
   "type": "mutual"
}
```

## c-lightningウォレットからの資金引き出し

```
lcli withdraw <address> all
```
はc-lightningウォレットから資金を外に送るときに使う
