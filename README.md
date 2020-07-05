# c-lightning-handson
2020/6/19ビットコインとか勉強会c-lightningハンズオン

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

### ビルドが終わったらDocker起動（bitcoindも起動する)

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
02e5db87cad8761fe5fe7cadfb3c9393098e217db3d8a00500565fe6b8ea040972@153.126.144.46:9735
```
に接続する

### ノードに接続
BTCは消費しない
IPアドレスが表示されているもののほうが接続しやすい
```
lcli connect 02e5db87cad8761fe5fe7cadfb3c9393098e217db3d8a00500565fe6b8ea040972@153.126.144.46:9735
{
   "id": "02e5db87cad8761fe5fe7cadfb3c9393098e217db3d8a00500565fe6b8ea040972",
   "features": "02aaa2"
}
```

### 接続先のIDが返ってきたら接続成功


```
lcli fundchannel 02e5db87cad8761fe5fe7cadfb3c9393098e217db3d8a00500565fe6b8ea040972 100000
{
   "tx": "02000000000101c9daf4bf03669e097b4a81726066a7ccb9423e5cc6e905ad97bb9d56883980280000000000feffffff02a08601000000000022002034c0c319476d458cd80992be0d497fe45ca9d05b6b96851b03439d4da3d67426c60c3477000000001600141db37c14e0cce2baba18244806036a0435e34c23024730440220566ef4ded9966fdb68a79d2620c87c64b5429e6ff77b50c84511556e0a40d518022017b3ae316ab7304f45c80fc802c17984a5c80956934a8fc49f6e6bd70cedf1b50121025721147c93567d486de6e9b3b6418f208c12f987e3f34fe19318734e4437b06100000000",
   "txid": "12e8b124ba1367e72793a9e1815a8b8a9581a8e83e3280caf9fc3c7e9b98f946",
   "channel_id": "46f9989b7e3cfcf9ca80323ee8a881958a8b5a81e1a99327e76713ba24b1e812"
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
lcli invoice 100000 "test" "test"
{
   "payment_hash": "9ac3a93fc9eb6897044889c4bfea2c23eb593d08b2ad917219f9a315a314fe8a",
   "expires_at": 1593158566,
   "bolt11": "lnsb1u1p0wcufxpp5ntp6j07fad5fwpzg38ztl63vy044j0ggk2kezuselx33tgc5l69qdq8w3jhxaqxqyjw5qcqp2sp5v76jend8mznkx87qeru4wkzu9q3tm6ae0yx3xsh7mkg43vaf2z4s9qy9qsq7kn8hdw6z9wwn45rp4eec9gpfdj4hcmsvjtq2lsdxwj0ehnegzejrudq2h7qr7lq28uq66gxhu40mvwceer7qn6ga7ctmuynqzxgfmcp8fqpam",
   "warning_capacity": "No channels"
}
```

```
"warning_capacity": "No channels"
```

となっている場合は、fundingTXの承認待ち。しばらく待つ。

送る方はpayコマンドを叩く

```
lcli pay lnsb1u1p0wcufxpp5ntp6j07fad5fwpzg38ztl63vy044j0ggk2kezuselx33tgc5l69qdq8w3jhxaqxqyjw5qcqp2sp5v76jend8mznkx87qeru4wkzu9q3tm6ae0yx3xsh7mkg43vaf2z4s9qy9qsq7kn8hdw6z9wwn45rp4eec9gpfdj4hcmsvjtq2lsdxwj0ehnegzejrudq2h7qr7lq28uq66gxhu40mvwceer7qn6ga7ctmuynqzxgfmcp8fqpam
{
   "id": 1,
   "payment_hash": "9ac3a93fc9eb6897044889c4bfea2c23eb593d08b2ad917219f9a315a314fe8a",
   "destination": "02e5db87cad8761fe5fe7cadfb3c9393098e217db3d8a00500565fe6b8ea040972",
   "msatoshi": 100004,
   "amount_msat": "100004msat",
   "msatoshi_sent": 100004,
   "amount_sent_msat": "100004msat",
   "created_at": 1592554031,
   "status": "complete",
   "payment_preimage": "6f37be7990520b4af20629541e527eaf8a6a4a8ddb27cc272fdc07876ff3b1b7",
   "bolt11": "lnsb1u1p0wcufxpp5ntp6j07fad5fwpzg38ztl63vy044j0ggk2kezuselx33tgc5l69qdq8w3jhxaqxqyjw5qcqp2sp5v76jend8mznkx87qeru4wkzu9q3tm6ae0yx3xsh7mkg43vaf2z4s9qy9qsq7kn8hdw6z9wwn45rp4eec9gpfdj4hcmsvjtq2lsdxwj0ehnegzejrudq2h7qr7lq28uq66gxhu40mvwceer7qn6ga7ctmuynqzxgfmcp8fqpam"
}
```
受け取った方は
```
listinvoices
{
   "invoices": [
      {
         "label": "aaa",
         "bolt11": "lnsb10u1p0tgy5xpp5knzslnnz57g9ewy05kugnef8d6ejjhm908wms6jzhsa5u9z2eegsdq9venxvxqyjw5qcqp2sp5njdxjp8jkx9djagjxq5ks5v9mms4xxtdjjed00renva02hpyy6ds9qy9qsq6ajtp928gqwm5xzy5f6kaeh8vpg2z8rksz4gq2hxlp72mc9ugv2ru4atrgtsywplsyn0mmw9jrrnddlfr6dkzp8ezaxqe2znqy8mpgcpny3nf2",
         "payment_hash": "b4c50fce62a7905cb88fa5b889e5276eb3295f6579ddb86a42bc3b4e144ace51",
         "msatoshi": 1000000,
         "amount_msat": "1000000msat",
         "status": "expired",
         "description": "fff",
         "expires_at": 1589464326
      },
      {
         "label": "testr",
         "bolt11": "lnsb100n1p0w7aszpp5yh9at6xlf5g3ds9are3s9pqepcpqnqngl2yspr8qwvrmqas40qwqdq0w3jhxar5v4ehgusxqyjw5qcqp2sp5937u8ey8hysgnkrrajp4e3a8n99fcjtva3mmv8tcrqe29uh65ljq9qy9qsqjargqx7ms8pudfkc0ye5qx6mj6ass9mn4a4h06l2aqm24sw7an6yykfhle43f79qtp8ckea4v8kafnxe22gjpckz2a94lh3eg978s0gpradgsq",
         "payment_hash": "25cbd5e8df4d1116c0bd1e630284190e02098268fa89008ce07307b07615781c",
         "msatoshi": 10000,
         "amount_msat": "10000msat",
         "status": "paid",
         "pay_index": 1,
         "msatoshi_received": 10000,
         "amount_received_msat": "10000msat",
         "paid_at": 1592751676,
         "payment_preimage": "decb3a48e9f95da2e1e0ea5dcc1ac3dd52ac9f76b139fd300d402c7274bc4ac7",
         "description": "testtestr",
         "expires_at": 1593356418
      },
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
