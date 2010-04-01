import engine/[Engine, Entity]
import text/StringTokenizer

import Console

Command: class {
    
    console: Console
    
    name, help: String
    action: Func (Console, StringTokenizer)
    
    init: func ~cmd (=name, =help, =action) {}
    
    getName: func -> String { name }
    getHelp: func -> String { help }
    
}
