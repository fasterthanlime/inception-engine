/**
 * Disgusting you say? Be polite please!
 * 
 * @version 1.0.0, 2010-09-14
 */
extend Closure {
    valid?: func () -> Bool { thunk != null }
    nullFunc: static func() -> Func { (null, null) as Closure as Func }
}
