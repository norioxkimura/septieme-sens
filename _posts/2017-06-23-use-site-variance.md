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
static double sum(List<Number> numbers) { /* ... */ }

double result = sum(Arrays.asList(1.0, 2.0, 3.0));
    // error: incompatible types: List<Double> cannot be converted to List<Number>
```

このケースは `Double extends Number` のときに `List<Double> extends List<Number>` になって欲しいケー
スである。Java では `List<Nubmer>` の代わりに `List<? extends Number>` と書くことで、任意の `Number`
のサブクラス X について `List<X> extends List<? extends Number>` であるようにできる。実際のコードは
以下のようになる :

```java
static double sum(List<? extends Number> numbers) {
    double result = 0.0;
    for (Number n: numbers)
        result += n.doubleValue();
    return result;
}
```

ただし、`numbers` に対して `List<E>` クラスのメソッドのうち `E` を引数とするメソッドを呼ぶことはでき
ず、コンパイルエラーとなる。

ただし、`List<? extends Number>` 型として宣言された `numbers` に対して

このケースはサブクラスの List をスーパークラスの List に変換できないケースで
ある。以下の `sum()` の実装を見ても分かる通り、型安全を保証できそうに見えるので
、この変換が実現できると嬉しい。

```java
static double sum(List<Number> numbers) {
    double result = 0.0;
    for (Number n: numbers)
        result += n.doubleValue();
    return result;
}
```

実際に

```java
class Test {
    static double sum(List<Number> numbers) {
        double result = 0.0;
        for (Number n: numbers)
            result += n;
        return n;
    }
    static void main(String[] args) {
        List<Double> doubles = Arrays.asList(1.0, 2.0, 3.0);
        double result = sum(doubles);
          // error: incompatible types: List<Double> cannot be converted to List<Number>
    }
}
```

```java
class Test {

    static class Suuper {}
    static class Sub extends Super {}

    static void f(List<Super> 

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
