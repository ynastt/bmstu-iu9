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
  
  override def toString() : String = {
    return this.s.toString()
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
  val f1 = new Formula("abc") // string constant
  val f3 = new Formula("d") // string constant
  val f13 = f1 + f3 // "abcd"
  println(f13.eval(Map.apply("abc" -> "abc", "d" -> "d"))) 
  
  val a = new Variable("a") // variable with name a
  val f2 = new Formula[Long](a) 
  println(a.name)
  val b = new Variable("b")
  val f4 = new Formula[Long](b)
  println(b.name)
  val f24 = f2 + f4 
  println(f24.eval(Map.apply("a" -> 2_0L, "b" -> 2_00L))) 

  val c = new Variable("c") // variable with name a
  val f6 = new Formula[String](c) 
  
  val d = new Variable("d")
  val f7 = new Formula[String](d)
  
  val f67 = f6 + f7 
  println(f67.eval(Map.apply("c" -> "abra", "d" -> "cadabra")))
}
