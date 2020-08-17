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

### Signet対応のbitcoindとc-lightningをインストールしたDockerをビルド

```
git clone https://github.com/shu-kob/c-lightning-handson
cd c-lightning-handson
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
alias lcli="docker exec $ID lightning-cli"
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
lcli getinfo
```

```
{
   "id": "03e3f432238c431ac66f1080560d6426b450d3cd63279cf4ee002044bbe860834e",
   "alias": "SLIMYWATCH",
   "color": "03e3f4",
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
   "version": "0.8.2.1",
   "blockheight": 15393,
   "network": "signet",
   "msatoshi_fees_collected": 0,
   "fees_collected_msat": "0msat",
   "lightning-dir": "/root/.lightning/signet"
}
```

### Dockerの中に入る場合は、別のターミナルを開き下記のコマンド

```
ID=$(docker ps -q)
docker exec -i -t $ID bash
```

### 参考）エイリアスとカラー
~/.lightning/config
でLightning Nodeのエイリアスと色を設定できる（Dockerの中に入るのが必要）

例）
```
alias=Aquamarine
rgb=7FFFD4
network=signet
```

### c-lightningウォレットに入金するため、アドレスを発行

```
lcli newaddr
{
   "address": "sb1qll2ssyjnklvapqpmapyq0dwnhtp4p8g9a0r8rh",
   "bech32": "sb1qll2ssyjnklvapqpmapyq0dwnhtp4p8g9a0r8rh"
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


### チャンネルを貼るため、ネットワーク上のノードを見つける

```
lcli listnodes
{
   "nodes": []
}
```

ない場合は。
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
   "tx": "02000000000101824b3fcde7ea3dabf1cda9dc3c3dbcb9620be10c5e19c11c30d163689c2e8f4b0100000000feffffff02a0860100000000002200207c17946c68a32bbe0dd345ad1c70f51209c72a1dacfd742e4be6c3178fc69936c642993b00000000160014e320904b02b6bb8bbfa60ee9ee74085382fb2fa002473044022017867d12f7f0b3341410650ec403031b0664f45c62c4ccde53a5f3b5aca809b402203a11218bda9795414185e9889b3b6bc8667e9d1f5d071cf256d3892d1f842615012103d371db825181b528a934e0cf56ece2c6a00b192ff8842b75add58b096293d35b3c030000",
   "txid": "413884d7c2ffdf18d9867e3e6c61a037609250bee63f7175f4547eac43b3ab22",
   "channel_id": "22abb343ac7e54f475713fe6be50926037a0616c3e7e86d918dfffc2d7843841"
}
```

```
lcli listpeers
```

```
"CHANNELD_AWAITING_LOCKIN:Funding needs 1 more confirmations for lockin."
```

これはLightningにデポジットするのをロック中という意味で、
Signetの場合、1承認で
```
"CHANNELD_NORMAL:Funding transaction locked."
```
となる。Testnetの場合3承認。

Invoiceを発行して、送ってもらう。

```
lcli invoice 50000000 "test" "test"
{
   "payment_hash": "35905e06212e3eec1967d9db568d023ed50d8154c60326ad6021a036c3de9fcb",
   "expires_at": 1598162705,
   "bolt11": "lnsb100n1p0n3ny3pp5xkg9up3p9clwcxt8m8d4drgz8m2smq25ccpjdttqyxsrds77nl9sdq8w3jhxaqxqyjw5qcqp2sp50nj0hugzz054z6rpnfr3094jwa6ahg20r60s3c0eyucvewca0c5s9qy9qsqlp4xu032sr6dmqa35306cal45wd35zmkeyvxd5quqyau0shqf6g39mu8mfq9f2hmw4tz02sys7z7jevlfz439gpqmafqsxadv342qhqp9u6lcc",
   "warning_deadends": "No channel with a peer that is not a dead end"
}

```

```
"warning_capacity": "No channels"
```

となっている場合は、fundingTXの承認待ち。しばらく待つ。

送る方はpayコマンドを叩く

```
lcli pay lnsb100n1p0n3ny3pp5xkg9up3p9clwcxt8m8d4drgz8m2smq25ccpjdttqyxsrds77nl9sdq8w3jhxaqxqyjw5qcqp2sp50nj0hugzz054z6rpnfr3094jwa6ahg20r60s3c0eyucvewca0c5s9qy9qsqlp4xu032sr6dmqa35306cal45wd35zmkeyvxd5quqyau0shqf6g39mu8mfq9f2hmw4tz02sys7z7jevlfz439gpqmafqsxadv342qhqp9u6lcc
{
   "destination": "031c94cba9161457236a6df85d6c890e82f1dcbf5729e80f06c318f94139f17015",
   "payment_hash": "35905e06212e3eec1967d9db568d023ed50d8154c60326ad6021a036c3de9fcb",
   "created_at": 1597558024.047,
   "parts": 1,
   "msatoshi": 50000000,
   "amount_msat": "50000000msat",
   "msatoshi_sent": 50000000,
   "amount_sent_msat": "50000000msat",
   "payment_preimage": "f6acfa0b712a7a4b0d307c62a621af3f38f4db4d26e1969aa4fe4a7083578a7b",
   "status": "complete"
}
```
受け取った方は
```
lcli listinvoices
{
   "invoices": [
      {
         "label": "test",
         "bolt11": "lnsb100n1p0n3ny3pp5xkg9up3p9clwcxt8m8d4drgz8m2smq25ccpjdttqyxsrds77nl9sdq8w3jhxaqxqyjw5qcqp2sp50nj0hugzz054z6rpnfr3094jwa6ahg20r60s3c0eyucvewca0c5s9qy9qsqlp4xu032sr6dmqa35306cal45wd35zmkeyvxd5quqyau0shqf6g39mu8mfq9f2hmw4tz02sys7z7jevlfz439gpqmafqsxadv342qhqp9u6lcc",
         "payment_hash": "35905e06212e3eec1967d9db568d023ed50d8154c60326ad6021a036c3de9fcb",
         "msatoshi": 50000000,
         "amount_msat": "50000000msat",
         "status": "paid",
         "pay_index": 1,
         "msatoshi_received": 50000000,
         "amount_received_msat": "50000000msat",
         "paid_at": 1597558024,
         "payment_preimage": "f6acfa0b712a7a4b0d307c62a621af3f38f4db4d26e1969aa4fe4a7083578a7b",
         "description": "test",
         "expires_at": 1598162705
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
