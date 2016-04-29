SteamID Crawler for Lost Planet
===================

**SteamID** のリストから、**ロストプラネット** を所有しているユーザーを検出します

----------

Insallation
-------------

> **Note:**

> - rubyで書かれているのでrubyとgemをインストールする必要があります
> - 必要ならインストール不要なデスクトップ版を作ってもいいです

####  rubyのインストール

http://rubyinstaller.org/downloads/
からrubyをインストールしてください
windows(64bit)なら
Ruby 2.3.0 (x64)
です

インストールする際に、**Rubyの実行ファイルへ環境変数 PATHを設定する** に必ずチェックを入れてください

インストールができたら、以下のコマンドをコマンドプロンプトで叩いてインストールを確認します

```sh
» ruby -v
```
このようになれば成功です
```sh
» ruby -v
ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]
```

####  Gemを使ってbundleのインストール

コマンドプロンプトで以下のコマンドを実行します

```sh
gem install bundle
```

以下のように出たら成功です

```sh
C:\Users\***\workspace\***\steam_id_crawler_for_lostplanet>gem install bundle
Fetching: bundler-1.11.2.gem (100%)
Successfully installed bundler-1.11.2
Fetching: bundle-0.0.1.gem (100%)
Successfully installed bundle-0.0.1
Parsing documentation for bundler-1.11.2
Installing ri documentation for bundler-1.11.2
Parsing documentation for bundle-0.0.1
Installing ri documentation for bundle-0.0.1
Done installing documentation for bundler, bundle after 3 seconds
2 gems installed
```

#### bundleを使って依存プログラムのインストール

コマンドプロンプトで以下のコマンドを実行します

```sh
bundle install
```

以下のように出たら成功です

```sh
C:\Users\***\workspace\***\steam_id_crawler_for_lostplanet>bundle install
Fetching gem metadata from https://rubygems.org/..............
Fetching version metadata from https://rubygems.org/..
Resolving dependencies...
Installing colorize 0.7.7
Installing thor 0.19.1
Using bundler 1.11.2
Bundle complete! 2 Gemfile dependencies, 3 gems now installed.
Use `bundle show [gemname]` to see where a bundled gem is installed.

C:\Users\***\workspace\***\steam_id_crawler_for_lostplanet>atom README.md
'atom' is not recognized as an internal or external command,
operable program or batch file.
```

もしくはinstall.batを実行してください

Usage
-------------

```sh
» bin/steam_id_crawler search_lost_planet
```
もしくは **runner.bat** で実行できます
steam_ids.csvに適宜SteamIDを追加して実行してください

以下のように出力されます
```sh
$ bin/steam_id_crawler search_lost_planet
2016-04-29 19:38:29 [INFO]  SteamID: 76561198296160690...
2016-04-29 19:38:29 [INFO]  found
2016-04-29 19:38:29 [INFO]  profile: http://steamcommunity.com/profiles/76561198296160690/

2016-04-29 19:38:29 [INFO]  SteamID: 76561198267109590...
2016-04-29 19:38:29 [INFO]  not found

```
