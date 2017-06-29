---
title: Node.js における複数ファイルの実行
---

Node.js で複数の JS ファイルはどのように実行されるのだろうか？

## node コマンド

`node` コマンドで指定できるのは１つのファイルのみである。

```shell-session
$ node main.js
```

その他のファイルは `require()` によって芋づる式にロードされる。

## require()

`require()` は文字列を引数（以下、X とする）として取り、１つのファイルをロードする。

- X がコアモジュールならそのコアモジュールファイル。
- X が `"/"`, `"./"`, `"../"` のいずれかで始まっていたら :
  - X が存在するファイルのパスならそのファイル。
  - X が存在するディレクトリのパスなら :
    - ディレクトリに package.json があるならその `"main":` フィールドのパスのファイル。
    - ディレクトリに package.json が無いならそのディレクトリにある index.js
- X が `"/"`, `"./"`, `"../"` のいずれでも始まらないなら :
  - node\_modules/X が存在するファイルのパスならそのファイル。
    - node_modules/X が存在するディレクトリのパスなら :
      - ディレクトリに package.json があるならその `"main":` フィールドのパスのファイル。
      - ディレクトリに package.json が無いならそのディレクトリにある index.js

node\_modules から探す場合、見つからなければ親ディレクトリへとさかのぼって検索される。これによって
node\_modules/X から require(Y) で node\_modules/X/node_modules/Y ではなく node\_modules/Y をロード
することができる。

正確な定義については以下を参照 : [Modules | Node.js v6.11.0 Documentation](
https://nodejs.org/dist/latest-v6.x/docs/api/modules.html )

## Node.js 処理系が特別扱いするファイル・ディレクトリ名

上のことから node\_modules/, package.json, index.js というファイル・ディレクトリは Node.js 処理系が
「知って」いて特別扱いするファイル・ディレクトリ名だということがわかる。

