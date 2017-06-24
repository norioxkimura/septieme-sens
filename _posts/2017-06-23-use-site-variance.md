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

Java の総称型は型パラメーターに対して不変である。C\<A\> と C\<B\> は A ≠ B のときスーパー／サブ関係
にない。以下のコードを見てみよう :

```java
static double sum(List<Number> numbers) { /* ... */ }

double result = sum(Arrays.asList(1.0, 2.0, 3.0));
    // error: incompatible types: List<Double> cannot be converted to List<Number>
```

このコードのコンパイルが通るためには `List<Number>` が `List<Double>` のスーパークラスである必要があ
るが、総称型の不変性のためエラーとなる。しかしこのコードのケースでは `List<Number>` が
`List<Double>` のスーパークラスであるのが自然で有用である。そこで Java では `List<Nubmer>` の代わり
に `List<?  extends Number>` と書くことで、任意の `Number` のサブクラス X について `List<X>` のスー
パークラスとすることができる。

`sum()` は以下のように定義できる。

```java
static double sum(List<? extends Number> numbers) {
    double result = 0.0;
    for (Number n: numbers)
        result += n.doubleValue();
    return result;
}
```

このように `numbers` を `List<Numbers>` として扱ってコーディングすればよい。ただし、 `numbers` に対
して `List<E>` クラスのメソッドのうち `E` を引数とするメソッドを呼ぶことはできず、コンパイルエラーと
なる。そのような操作は型安全ではない可能性があるからである。例えば

```java
static double sum(List<? extends Number> numbers) {
    numbers.add(Integer(1));
    // ...
}
```

が許されるとすると `sum(Arrays.asList(1.0, 2.0, 3.0))` としたときに List\<Double> 型のリスト中に
Integer のインスタンスが足されることが許されてしまい、型安全ではなくなってしまう。

型パラメーターと総称型の継承方向がそろっていることを**共変**と呼ぶが、`? extends T` を使うと Java の
不変な総称型の利用時に共変を実現できることになる。これに対してすべてがあべこべな**反変**と呼ばれる性
質があって、`? super T` で実装できるが、ここではその話は省略する。

### 「? extends T」 をスーパークラス指定のところに書けるのが気持ち悪い

以下のコード :

```java
class SpecialTransform<T> extends Transform<Collection<? extends T>> {}
```

... ... よくわからなくなってきた。

```java
class SpecialTransform<T> extends Transform<Collection<T>> {}
```

と比較してどう違うか考えてみよう。

<!--

をぱっと見るとひるんでしまうかもしれないが、こう考えよう : ここでのクラスはインスタンスメソッドの
`this` の型を定めているに過ぎない。

`class A extends B { void f() { ... } }` のとき、`...` での `this` は A のインスタンスとしても B の
インスタンスとしても扱うことができる。

## 疑問点

- `? extends C` が書ける場所はどこどこなのか？例えば `class A extends B<?
  extends C>` がダメなのはなぜなのか？

-->
