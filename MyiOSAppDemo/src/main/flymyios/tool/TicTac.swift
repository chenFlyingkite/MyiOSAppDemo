//
// Created by Eric Chen on 2021/3/24.
//

import Foundation

/**
  The class performing the same intention with {@link TicTac}.
  Unlike {@link TicTac} provides static method and uses global time stack,
  {@link TicTac2} provides for creating instance and use its own one time stack. <br/>
  {@link TicTac2} is specially better usage for tracking performance in different AsyncTasks,
  by each task create a new object and call its {@link TicTac2#tic()} and {@link TicTac2#tac(String)} in task.

  <p>Here is an example of usage:</p>
  <pre class="prettyprint">
  public class Main {
      public static void main(String[] args) {
          // Let's start the tic-tac
          TicTac.tic();
              f();
          TicTac.tac("f is done");
          TicTac.tic();
              g();
              TicTac.tic();
                  g1();
              TicTac.tac("g1 is done");
              TicTac.tic();
                  g2();
              TicTac.tac("g2 is done");
          TicTac.tac("g + g1 + g2 is done");
          // Now is ended
      }

      private void f() {
          // your method body
      }
      private void g() {
           // your method body
      }
      private void g1() {
           // your method body
      }
      private void g2() {
           // your method body
      }
  }
  </pre>
 */
public class TicTac : NSObject {
    private var tictac = Array<Int64>()

    // https://en.wikipedia.org/wiki/ISO_8601
    private let formatISO8601 = DateFormatter()

    /**
     Print log or not
     @see #logTac(String)
     @see #logError(long, String)
     */
    public var log = true

    /**
     Enable tictac or not, if disabled all the tic() tac() method returns -1 directly
     @see #tic()
     @see #tac(String)
     @see #tac(String, Object...)
     @see #tacL()
     */
    public var enable = true

    public override init() {
        super.init()
        // setup formatter
        let f = formatISO8601
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        f.locale = Locale.init(identifier: "en-US")
    }

    /**
     Clear all the pushed tics
    */
    public func reset() -> Void {
        tictac.removeAll()
    }

    /**
     Push time of tic
     @return tic Time of tic, -1 if disabled
    */
    @discardableResult
    public func tic() -> Int64 {
        if (!enable) {
            return -1
        }
        let tic = now()
        tictac.append(tic)
        return tic
    }

    /**
     Evaluate time diff and return the tac time
     @return time diff = tac - tic, -1 if no tic or disabled
    */
    @discardableResult
    public func tacL() -> Int64 {
        if (!enable) {
            return -1
        }

        let tac = now()
        if (tictac.count < 1) {
            return -1
        }
        let tic = tictac.popLast()!
        return tac - tic
    }

    /**
     Print formatted
     @see #tac(String)
    */
//    public func tac(_ format:String, _ p:Any...) -> Int64 {
//        return tac(String.init(format: format, p)) // ?
//    }

    /**
     Evaluate time diff, Print logs and return the tac time
     @return time diff = tac - tic, -1 if no tic or disabled
    */
    @discardableResult
    public func tac(_ msg:String) -> Int64 {
        if (!enable) {
            return -1
        }
        let tac = now()
        if (tictac.isEmpty) {
            logError(tac, msg)
            return -1
        }
        let tic = tictac.popLast()!
        let depth = xn(" ", tictac.count)
        logTac("\(depth)[\(tac - tic)] : \(msg)")
        return tac - tic
    }

    /**
     Print log when {@link #tac(String)} is called with valid tic
     */

    /**
     Print log when {@link #tac(String)} is called with no tic
    */
    @discardableResult
    public func logError(_ tac:Int64, _ msg:String) -> Void {
        if (log) {
            let s = getTime(tac)
            print("X_X Omitted. tic = N/A, tac = \(s) : \(msg)")
        }
    }

    public func logTac(_ msg:String) -> Void {
        if (log) {
            print(msg)
        }
    }

    /**
     Format time to be ISO8601 format, yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
     Like 2018-07-24T12:34:56.789Z
    */
     private func getTime(_ time:Int64) -> String {
         return formatISO8601.string(from: Date(timeIntervalSince1970: time * 1.0))
     }

    public override var description: String {
        return "tictac.size() = \(tictac.count)"
    }

    // MARK: Core
    private func now() -> Int64 {
        return Date().currentTimeMillis()
    }

    public func xn(_ s:String, _ n:Int) -> String {
        //return String.init(repeating: s, count: n) // ?
        var ans = ""
        var now = s
        var x = n
        while (x > 0) {
            if ((x & 0x1) == 1) {
                ans += now
            }
            now += now
            x >>= 1
        }
        return ans
    }
}

