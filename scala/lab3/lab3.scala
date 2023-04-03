//aaaaaaaaaaa
// flag: 1 - for variable's name, 2 - for constants type T, 3 +, 4 -, 5 *, 6 /
class Formula[T](a: T, flag: Int) {
  val formula = a

  this(str: String, f: Int) = Formula(str, 1)
  this(value: T) = Formula(value, 2)

  def solve[S]()(implicit ops: EquationSystemOps[T, S]): Option[(S, S)] = {
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
  implicit def str_ops[T](implicit s: String): FormulaOps[T] =
    new FormulaOps[T] {
			def add(a: T, b: T): T = a.toString() + b.toString()
    }
}

object Main extends App {
  val f1 = new Formula("")
  val s2 = new EquationSystem(((3, 4), (2, 5)), (18, 19))
  val s3 = new EquationSystem(((2.0, 1.0), (3.0, 2.0)), (5.0, 3.0))
  val s4 = new EquationSystem(((2, 1), (4, 2)), (5, 3))
  println(s1.solve())
  println(s2.solve())
  println(s3.solve())
  println(s4.solve())

  val s5 = new EquationSystem((("a", "b"), ("c", "d")), ("e", "f"))
  /* Следующая строчка не компилируется */
  // println(s5.solve())
}
