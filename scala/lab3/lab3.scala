//aaaaaaaaaaa
//aaaaaaaaaaa
// flag: 1 - for variable's name, 2 - for constants type T, 3 +, 4 -, 5 *, 6 /
class Formula[T](a: T, flag: Int) {
  val form = a

  this(str: String, f: Int) = Formula(str, 1)
  this(value: T) = Formula(value, 2)

	def add(f1 : Formula[T])(implicit ops: FormulaOps[T]): Formula[T] = {
    
  }

  def sub[]()(implicit ops: FormulaOps[T]): Formula[T] = {
    
  }

  def mul[]()(implicit ops: FormulaOps[T]): Formula[T] = {
    
  }

  def div[]()(implicit ops: FormulaOps[T]): Formula[T] = {
    
  }
  
  def solve[S]()(implicit ops: FormulaOps[T]): Option[(S, S)] = {
    val d = num.minus(num.times(a11, a22), num.times(a21, a12))
    if (num.equiv(d, num.zero)) {
      None
    } else {
      val d1 = num.minus(num.times(b1, a22), num.times(a12, b2))
      val d2 = num.minus(num.times(a11, b2), num.times(b1, a21))
      Some((ops.div(d1, d), ops.div(d2, d)))
    }
  }
}

trait FormulaOps[T] {
  def add(a: T, b: T): T
}

object FormulaOps {
  implicit def float_ops[T](implicit frac: Fractional[T]): FormulaOps[T] =
    new FormulaOps[T] {
      def add(a: T, b: T): T = frac.plus(a, b)
      def sub(a: T, b: T): T = frac.minus(a, b)
      def mul(a: T, b: T): T = frac.times(a, b)
      def div(a: T, b: T): T = frac.div(a, b)
    }

  implicit def int_ops[T](implicit integral: Integral[T]): FormulaOps[T] =
    new FormulaOps[T] {
			def add(a: T, b: T): T = integral.plus(a, b)
      def sub(a: T, b: T): T = integral.minus(a, b)
      def mul(a: T, b: T): T = integral.times(a, b)
      def div(a: T, b: T): T = integral.quot(a, b)
    }
  implicit final val strOps: FormulaOps[String] =
    new FormulaOps[String] {
			def add(a: String, b: String): String = a + b
    }
}

object Main extends App {
  val f1 = new Formula("abc") // string constant
  val f2 = new Formula("a", 1) // variable with name a
  val f3 = new Formula(2_00L) // Long constant
  val f4 = new Formula(13_00L) // Long constant
  val f45 = f4.add(f5) //1500 ?
  println(f45.solve()) //?
  
}
