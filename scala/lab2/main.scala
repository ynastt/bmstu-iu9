/*
 Множество, конструируемое как множество строк, содержащих некоторую строку s.
 Операции: объединение («+»), пересечение («*»),
 проверка принадлежности строки множеству («in»).
 */

/*
Конструктор, который требуется написать в некоторых вариантах — вспомогательный.
Первичный конструктор у таких классов должен быть частным (private).

В некоторых вариантах требуется построить множество с проверкой на принадлежность (методы с именами вроде in или contains)
или функцию, вычисляющую значение (методы вроде eval или get).
В таких случаях удобно представлять класс обёрткой над функцией-предикатом или функцией, возвращающей некоторое значение.
Конструктор класса создаёт базовую версию функции, методы комбинируют предикаты своих аргументов (включая неявный this).
 */

// is s the substring of x?
def isSubstr(x: String, s: String): Boolean = x.indexOf(s) != -1

class mySet private (sstr: String, st: List[String]) {
  val str = sstr
  var set = st

  def this(sstr: String) = this(sstr, List(sstr))
  //def this(st: List[String]) = this(List(0), List(sstr))
  def addStr(newstr: String) = {
    val set2 = set :+ newstr
    set = set2
  }
  def in(s: String): Boolean = {
    if (s.indexOf(str) != -1)
      true
    else
      false
  }
  def +(z: mySet) = {
    var resStr: String = null
    if (str.indexOf(z.str) != -1)
      resStr = z.str
    if (z.str.indexOf(str) != -1)
      resStr = str
    var sumSet = new mySet(resStr)
    var l = List.concat(sumSet.set,List.concat(set, z.set))
    sumSet.set = l.drop(1).toSet.toList
    sumSet
  }
  // def * (z: mySet) =
}

object Main {
  def main(args: Array[String]) = {

    var str = "blabla"
    println(str.indexOf("heaven"))
    println(str.indexOf("la"))

    // println(s"x: ${p.x}, y: ${p.y}, z: ${p.z}")

    println("=======")
    val s1 = new mySet("sun")
    s1.addStr("sunset")

    println(s"is sunny in set ${s1.set}? ${s1.in("sunny")}")
    s1.addStr("sunny")
    println(s"Set1: ${s1.set}, formed from string \"${s1.str}\"")

    val s2 = new mySet("sunny")
    s2.addStr("sunnyDays")
    println(s"Set2: ${s2.set}, formed from string \"${s2.str}\"")

    var sum = s1 + s2
    println(s"Union(Set1,Set2): ${sum.set}, formed from string \"${sum.str}\"")
    
    var inter = s1 * s2
    println(s"Intersection(Set1, Set2): ${inter.set}, formed from string \"${inter.str}\"")
  }
}
