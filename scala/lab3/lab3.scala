// Класс Formula[T], представляющий формулу, состоящую из имён переменных, констант типа T и бинарных операций. 
// Ассортимент операций зависит от типа T: если определён Numeric[T], то должны присутствовать четыре базовых арифметических операций;
// если T — это string, то должна присутствовать только операция сложения, обозначающая конкатенацию.

// Для создания объектов класса Formula[T] доступны два конструктора: 
// первый принимает имя переменной и создаёт формулу, состоящую из единственной переменной; 
// второй конструктор принимает значение типа T и создаёт формулу, состоящую из единственной константы. 
// Все остальные формулы возвращаются бинарными операциями.

// В классе Formula[T] должен быть определён метод, принимающий отображение имён переменных в их значения и считающий значение формулы.

class Variable(val name: String)

class Formula[T] private (s: Map[String, T] => T) { 
  def this(varName: Variable) = this(varMap => varMap(varName.name))
  def this(value: T) = this(varMap => value)
  
  def eval(vars: Map[String, T]): T = s(vars) 

  def +(other: Formula[T])(implicit op: FormulaOps[T]): Formula[T] = {
    new Formula(varMap => op.add(this.eval(varMap), other.eval(varMap)))
  }

  def -(other: Formula[T])(implicit num: Numeric[T]): Formula[T] = {
    new Formula(varMap => num.minus(this.eval(varMap), other.eval(varMap)))
  }

  def *(other: Formula[T])(implicit num: Numeric[T]): Formula[T] = {
    new Formula(varMap => num.times(this.eval(varMap), other.eval(varMap)))
  }
  
  def /(other: Formula[T])(implicit op: DivOps[T]): Formula[T] = {
    new Formula(varMap => op.div(this.eval(varMap), other.eval(varMap)))
  }
}

trait DivOps[T] {
  def div(a: T, b: T): T
}

object DivOps {
  implicit def float_ops[T](implicit frac: Fractional[T]): DivOps[T] =
    new DivOps[T] {
      def div(a: T, b: T): T = frac.div(a, b)
    }

  implicit def int_ops[T](implicit integral: Integral[T]): DivOps[T] =
    new DivOps[T] {
      def div(a: T, b: T): T = integral.quot(a, b)
    }
}

trait FormulaOps[T] {
  def add(a: T, b: T): T
}

object FormulaOps {
  implicit def num_ops[T](implicit num: Numeric[T]): FormulaOps[T] =
    new FormulaOps[T] {
      def add(a: T, b: T): T = num.plus(a, b)
    }
  
  implicit final val str_ops: FormulaOps[String] =
    new FormulaOps[String] {
      def add(a: String, b: String): String = a + b
    }
}

object Main extends App {
  val f1 = new Formula("abc") 
  val d = new Variable("d")
  val f2 = new Formula[String](d) 
  val f12 = f1 + f2 
  println(f12.eval(Map.apply("abc" -> "abc", "d" -> "defg"))) 
  
  val a = new Variable("a") 
  val f3 = new Formula[Long](a) 
  val b = new Variable("b")
  val f4 = new Formula[Long](b)
  val f34 = f3 / f4 
  println(f34.eval(Map.apply("a" -> 2_000L, "b" -> 2_00L))) 
   
  val f5 = new Formula[Double](a) 
  val f6 = new Formula[Double](b)
  val f56 = f5 / f6 
  println(f56.eval(Map.apply("a" -> 256.12, "b" -> 16.06))) 

  val c = new Variable("c") 
  val f7 = new Formula[String](c) 
  val f8 = new Formula[String](d)
  val f78 = f7 + f8
  println(f78.eval(Map.apply("c" -> "abra", "d" -> "cadabra")))

  val f91 = new Formula[Byte](a) 
  val f92 = new Formula[Byte](b)
  val f93 = new Formula[Byte](c)
  val f9 = f91 * (f92 - f93)
  println(f9.eval(Map.apply("a" -> 7, "b" -> 6, "c" -> 2)))

  val fa = new Formula[Int](a) 
  val fb = new Formula[Int](b)
  val fc = new Formula[Int](c)
  val fd = new Formula(4)
  val ff = fa * fa - fd * fb + fc
  println(ff.eval(Map.apply("a" -> 7, "b" -> 6, "c" -> 2)))
}
