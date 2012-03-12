import mvar._

object IterTest extends App {

  val n = 100
  val its = 1000
  
  // This is my huge data array and which I want to iterate on
  val x = new MPromise[Int]()
  
  // Now define our iteration
  val result = iterate (x) (max_iter(10)) { v =>
    v onSuccess shdebug("v")
    iterate (v) (max_iter(10)) {_ map (_ + 1)}
  }
    
  // Now initialize x
  x.success(Nil,0)
  
  result onSuccess {
    case (i,s) => println("%s: %s".format(i,s))
  }
  
}