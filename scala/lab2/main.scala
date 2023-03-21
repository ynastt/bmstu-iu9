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

/*
 Множество, конструируемое как множество строк, содержащих некоторую строку s.
 Операции: объединение («+»), пересечение («*»),
 проверка принадлежности строки множеству («in»).
 */

class mySet private (sstr: String, st: List[String]) {
  val str = sstr
  var set = st

  def this(sstr: String) = this(sstr, List(sstr))

  def removeDups() = {
    val set2 = set.toSet.toList
    set = set2
  }
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
    var resStr: String = set(0)
    if (str.indexOf(z.str) != -1)
      resStr = z.str
    if (z.str.indexOf(str) != -1)
      resStr = str
    var sumSet = new mySet(resStr)
    for (el <- set)
      if (in(el) || z.in(el))
        sumSet.addStr(el)
    for (el <- z.set)
      if (in(el) || z.in(el))
        sumSet.addStr(el)
    sumSet.removeDups()
    sumSet
  }

  def *(z: mySet) = {
    var tmp: String = set(0)
    var len: Int = 999
    for (el <- set)
      if (z.in(el)) {
        if (el.length() < len) {
          len = el.length()
          tmp = el
        }
      }
    if (len == 999)
    	tmp = ""
    var inSet = new mySet(tmp)
    for (el <- set)
      if (in(el) && z.in(el))
        inSet.addStr(el)
    inSet.removeDups()
    inSet
  }
}

object Main {
  def main(args: Array[String]) = {
    println("---test1---")
    val s1 = new mySet("sun")
    s1.addStr("sunset")
    s1.addStr("sunn")

    println(s"is sunny in set ${s1.set}? ${s1.in("sunny")}")
    s1.addStr("sunny")
    println(s"Set1: ${s1.set}, formed from string \"${s1.str}\"")

    val s2 = new mySet("sunn")
    s2.addStr("sunnyDays")
    s2.addStr("sunny")
    println(s"Set2: ${s2.set}, formed from string \"${s2.str}\"")

    var sum = s1 + s2
    println(s"Set1 + Set2: ${sum.set}, formed from string \"${sum.str}\"")

    var inter = s1 * s2
    println(s"Set1 * Set2: ${inter.set}, formed from string \"${inter.str}\"")

    println("---test2---")
    val s3 = new mySet("a")
    s3.addStr("ab")
    s3.addStr("cad")
    println(s"Set1: ${s3.set}, formed from string \"${s3.str}\"")

    val s4 = new mySet("b")
    s4.addStr("ab")
    s4.addStr("bad")
    println(s"Set2: ${s4.set}, formed from string \"${s4.str}\"")

    sum = s3 + s4
    println(s"Set1 + Set2: ${sum.set}, formed from string \"${sum.str}\"")

    inter = s3 * s4
    println(s"Set1 * Set2: ${inter.set}, formed from string \"${inter.str}\"")

    println("---test3---")
    val s5 = new mySet("a")
    s5.addStr("aaa")
    s5.addStr("caa")
    println(s"Set1: ${s5.set}, formed from string \"${s5.str}\"")

    val s6 = new mySet("b")
    s6.addStr("bbb")
    s6.addStr("bbd")
    println(s"Set2: ${s6.set}, formed from string \"${s6.str}\"")

    sum = s5 + s6
    println(s"Set1 + Set2: ${sum.set}, formed from string \"${sum.str}\"")

    inter = s5 * s6
    println(s"Set1 * Set2: ${inter.set}, formed from string \"${inter.str}\"")
  }
}
