val myflatten: (Int => Boolean) => (List[List[Int]] => List[Int]) =
    p => {
        case Nil => Nil
        case x :: xs if (p(x.length)) => x ::: myflatten(p)(xs)
        case x :: xs => myflatten(p)(xs)
    }

object Main {
    def main(args: Array[String]) = {
        val list = List(List(1, 2), List(3), List(-5, 6), List(1, -100))
        val sumLengthAppropriateLists = myflatten(_ == 2)
        val s = sumLengthAppropriateLists(list)
        println(s)
    }
}
