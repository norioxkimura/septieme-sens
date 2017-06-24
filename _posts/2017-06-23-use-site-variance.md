---
title: 突然 Java の総称型に衝突してしまったケース
---

# 突然 Java の総称型に衝突してしまったケース

## 事故現場

以下の Java コードでエラーが発生した : 

```java
class SpecialTransform<T> extends Transform<Collection<? extends T>> {}

Transform<Collection<String>> x = new SpecialTransform<String>;
    // error: incompatible types: SpecialTransform<String> cannot be converted to Transform<Collection<String>>
```

## 事故処理

以下のように修正すればよい :

```java
Transform<Collection<? extends String>> x = new SpecialTransform<String>;
```

## 状況説明

SpecialTransform, Transform, Collection は自分のコードが依存しているライブラリが定義しているクラスで
ある。Transform を継承しているクラスは SpecialTransform 以外にもたくさん用意されている。自分のコード
はそれらの SpecialTransformX クラスを String 型に特化したものしか扱わない。そしてそれらのインスタン
スを 1 つの変数に格納しておきたい。それは直感的には Transform\<Collection\<String\>> であると思った
のだがうまくいかなかった。

## 何が問題だったのか

### そもそも「? extends T」ってなに？

Java の総称型は型パラメーターに対して不変である。つまり以下はコンパイル不可 :

```java
class ProductImpl extends AbstractProduct {}

List<AbstractProduct> superProducts = new ArrayList<AbstractProduct>();
List<ProductImpl>     subProducts   = new ArrayList<ProductImpl>();

superProducts = subProducts;    // コンパイル不可
subProducts   = superProducts;  // コンパイル不可
```

しかし List\<T\> が不変では使いづらいだろう。使いづらいとは一体どういうことか？2 つのケースを考えて
みよう。

 1. `superProducts = subProducts` がエラーになるとつらい :

    ```java
    a = b;
    ```

「使いづらい」とは以下の 1, 2 のどちらかだと、ここでは
定義しよう。`List<ProductImpl> subproducts = ...; List<AbstractProduct> superproducts = ...;` のとき :

 1. `subproducts = superproducts` がエラーになってしまう。
 2. `superproducts = subproducts` がエラーになってしまう。

## 疑問点

- `? extends C` が書ける場所はどこどこなのか？例えば `class A extends B<?
  extends C>` がダメなのはなぜなのか？
