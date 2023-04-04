//aaaaaaaaaaa
// flag: 1 - for variable's name, 2 - for constants type T, 3 +, 4 -, 5 *, 6 /
class Formula[T](a: T, flag: Int) {
  val form = a
  val typ = flag

  this(str: String, f: Int) = Formula(str, 1)
  this(value: T) = Formula(value, 2)

	def add(f1 : Formula[T])(implicit ops: FormulaOps[T]): Formula[T] = {
    val s1 = form
    val s2 = f1.form
    val sum = ops.add(s1, s2)
    new Formula(sum)
  }

  def sub(f1 : Formula[T])(implicit ops: FormulaOps[T]): Formula[T] = {
    val s1 = form
    val s2 = f1.form
    val sub = ops.sub(s1, s2)
    new Formula(sub)
  }

  def mul(f1 : Formula[T])(implicit ops: FormulaOps[T]): Formula[T] = {
    val s1 = form
    val s2 = f1.form
    val res = ops.mul(s1, s2)
    new Formula(res)
  }

  def div(f1 : Formula[T])(implicit ops: FormulaOps[T]): Formula[T] = {
    val s1 = form
    val s2 = f1.form
    val res = ops.div(s1, s2)
    new Formula(res)
  }
  
  def solve(mapa: Map[String, T])(implicit ops: FormulaOps[T]): T = {
    
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
  val f12 = f1.add(f2) // "abc" + a
  println(f12.solve(Map.apply("a" -> "d"))) // "abcd"
  val f3 = new Formula(2_00L) // Long constant
  val f4 = new Formula(13_00L) // Long constant
  val f45 = f4.add(f5) //1500 ?
  println(f45.solve()) //?
  
}
